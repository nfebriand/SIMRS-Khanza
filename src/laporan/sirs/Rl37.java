package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * RL 3.7 — Rekapitulasi Pelayanan Neonatal, Bayi, dan Balita (bulanan, realtime).
 * Port Rl37Controller.php. Trimitra menghitung langsung dari Khanza:
 *  - baris berat lahir & asfiksia (1.x, 4.1) dari pasien_bayi (lahir di RS),
 *  - baris komplikasi (2.x, 4.x, 9.x) dari diagnosa_pasien via pola ICD-10,
 *  - baris kematian (3.1/3.2) & lahir mati (2.1) dari pasien_mati x umur,
 *  - baris umur (8.x) dari reg_periksa x pasien.
 * Section A (Neonatal) + B (Bayi & Anak Balita).
 */
public class Rl37 implements SirsBuilder {

    /** {kode, nama, parent, isParent("P"/""), section} */
    private static final String[][] MASTER = {
        {"1",     "Bayi Lahir Hidup", "", "P", "A"},
        {"1.1",   "Lahir Prematur (< 37 minggu)", "1", "P", "A"},
        {"1.1.1", "1500 - <2500 gram (BBLR)", "1.1", "", "A"},
        {"1.1.2", "1000 - <1500 gram (BBLSR)", "1.1", "", "A"},
        {"1.1.3", "<1000 gram (BBLER)", "1.1", "", "A"},
        {"1.2",   "Lahir Non Prematur (>= 37 - 41 minggu)", "1", "P", "A"},
        {"1.2.1", "1500 - <2500 gram (BBLR)", "1.2", "", "A"},
        {"1.2.2", "2500 - <4000 gram (BBLN)", "1.2", "", "A"},
        {"1.2.3", ">=4000 gram (BBLL)", "1.2", "", "A"},
        {"1.3",   "Lahir Lebih dari 41 minggu", "1", "P", "A"},
        {"1.3.1", "1500 - <2500 gram (BBLR)", "1.3", "", "A"},
        {"1.3.2", "2500 - <4000 gram (BBLN)", "1.3", "", "A"},
        {"1.3.3", ">=4000 gram (BBLL)", "1.3", "", "A"},
        {"2",     "Lahir Mati", "", "P", "A"},
        {"2.1",   "Lahir Mati Antepartum", "2", "", "A"},
        {"2.2",   "Lahir Mati Intrapartum", "2", "", "A"},
        {"3",     "Kematian Neonatal dan Perinatal", "", "P", "A"},
        {"3.1",   "Kematian Neonatal Dini (0 - 7 hari)", "3", "", "A"},
        {"3.2",   "Kematian Neonatal Lanjut Perinatal (8 - 28 hari)", "3", "", "A"},
        {"4",     "Komplikasi Neonatal:", "", "P", "A"},
        {"4.1",   "Asfiksia", "4", "", "A"},
        {"4.2",   "Trauma Kelahiran", "4", "", "A"},
        {"4.3",   "BBLR", "4", "", "A"},
        {"4.4",   "Tetanus Neonatorum", "4", "", "A"},
        {"4.5",   "Kelainan Bawaan", "4", "", "A"},
        {"4.6",   "Covid-19", "4", "", "A"},
        {"4.7",   "Infeksi / Sepsis", "4", "", "A"},
        {"4.8",   "Komplikasi lainnya", "4", "", "A"},
        {"5",     "Bayi BBLR yang dilakukan perawatan metode kanguru", "", "", "A"},
        {"6",     "Bayi baru lahir yang dilakukan IMD", "", "", "A"},
        {"7",     "Bayi baru lahir yang dilakukan Skrining Hipertiroid Kongenital", "", "", "A"},
        {"8",     "Bayi dan Anak Balita", "", "P", "B"},
        {"8.1",   "Bayi Baru Lahir (0 - 28 hari)", "8", "", "B"},
        {"8.2",   "Bayi (29 hari - 11 bulan)", "8", "", "B"},
        {"8.3",   "Anak Balita (12 - 59 bulan)", "8", "", "B"},
        {"9",     "Balita Gizi Buruk", "", "P", "B"},
        {"9.1",   "Balita Gizi Buruk usia 0-5 bulan", "9", "", "B"},
        {"9.2",   "Balita Gizi Buruk usia 6-59 bulan", "9", "", "B"},
        {"10",    "Balita menggunakan Buku KIA", "", "", "B"},
        {"11",    "Balita dilakukan skrining pertumbuhan dan perkembangan", "", "P", "B"},
        {"11.1",  "Skrining Pertumbuhan sesuai umur", "11", "", "B"},
        {"11.2",  "Skrining Perkembangan sesuai umur", "11", "", "B"},
        {"11.3",  "Skrining keterlambatan bicara dan bahasa", "11", "", "B"},
        {"11.4",  "Assessment kelainan motorik", "11", "", "B"},
        {"11.5",  "Skrining Kelainan Perilaku", "11", "", "B"},
        {"11.6",  "Skrining Gangguan Pendengaran", "11", "", "B"},
        {"11.7",  "Skrining Gangguan Penglihatan", "11", "", "B"},
        {"12",    "Bayi mendapatkan imunisasi, Vitamin, dan Pengobatan Profilaksis:", "", "P", "B"},
        {"12.1",  "Hb 0", "12", "", "B"},
        {"12.2",  "BCG", "12", "", "B"},
        {"12.3",  "Polio 1,2,3", "12", "", "B"},
        {"12.4",  "DPT-HB-HiB 1,2,3,4", "12", "", "B"},
        {"12.5",  "IPV", "12", "", "B"},
        {"12.6",  "Campak-Rubella", "12", "", "B"},
        {"12.7",  "Vitamin A 100.000 SI", "12", "", "B"},
    };

    /** kode -> daftar spec {tbl, pola}. tbl: d=diagnosa, p=prosedur. */
    private static final Map<String, String[][]> ROW_SPECS = new LinkedHashMap<>();
    static {
        ROW_SPECS.put("2.2", new String[][]{{"d", "P95%"}});
        ROW_SPECS.put("4.2", new String[][]{{"d", "P10%"}, {"d", "P11%"}, {"d", "P12%"}, {"d", "P13%"}, {"d", "P14%"}, {"d", "P15%"}});
        ROW_SPECS.put("4.3", new String[][]{{"d", "P07%"}});
        ROW_SPECS.put("4.4", new String[][]{{"d", "A33%"}});
        ROW_SPECS.put("4.5", new String[][]{{"d", "Q%"}});
        ROW_SPECS.put("4.6", new String[][]{{"d", "U07%"}});
        ROW_SPECS.put("4.7", new String[][]{{"d", "P36%"}, {"d", "P39%"}});
        ROW_SPECS.put("9.1", new String[][]{{"d", "E40%"}, {"d", "E41%"}, {"d", "E42%"}, {"d", "E43%"}, {"d", "E44%"}, {"d", "E45%"}, {"d", "E46%"}});
        ROW_SPECS.put("9.2", new String[][]{{"d", "E40%"}, {"d", "E41%"}, {"d", "E42%"}, {"d", "E43%"}, {"d", "E44%"}, {"d", "E45%"}, {"d", "E46%"}});
    }

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "Kode", "Section", "Jenis Kegiatan", "Jumlah", "Sumber Perhitungan"
        });

        // Patokan pasien_bayi (lahir di RS, ibu Ranap dalam rentang)
        Map<String, Integer> pb = pasienBayi(k, tgl1, tgl2);

        int lahirMati = scalar(k,
            "SELECT COUNT(*) FROM pasien_mati pm "
            + "JOIN pasien p ON p.no_rkm_medis=pm.no_rkm_medis "
            + "WHERE pm.tanggal BETWEEN ? AND ? "
            + "  AND (pm.icd1 LIKE 'P95%' OR pm.icd2 LIKE 'P95%' OR pm.icd3 LIKE 'P95%' OR pm.icd4 LIKE 'P95%' "
            + "       OR TIMESTAMPDIFF(DAY, p.tgl_lahir, pm.tanggal) = 0)", tgl1, tgl2);
        int neoDini = scalar(k,
            "SELECT COUNT(*) FROM pasien_mati pm "
            + "JOIN pasien p ON p.no_rkm_medis=pm.no_rkm_medis "
            + "WHERE pm.tanggal BETWEEN ? AND ? AND TIMESTAMPDIFF(DAY, p.tgl_lahir, pm.tanggal) BETWEEN 0 AND 7", tgl1, tgl2);
        int neoLanjut = scalar(k,
            "SELECT COUNT(*) FROM pasien_mati pm "
            + "JOIN pasien p ON p.no_rkm_medis=pm.no_rkm_medis "
            + "WHERE pm.tanggal BETWEEN ? AND ? AND TIMESTAMPDIFF(DAY, p.tgl_lahir, pm.tanggal) BETWEEN 8 AND 28", tgl1, tgl2);

        int bbl028 = scalar(k,
            "SELECT COUNT(DISTINCT r.no_rawat) FROM reg_periksa r "
            + "JOIN pasien p ON p.no_rkm_medis=r.no_rkm_medis "
            + "WHERE r.tgl_registrasi BETWEEN ? AND ? AND TIMESTAMPDIFF(DAY, p.tgl_lahir, r.tgl_registrasi) BETWEEN 0 AND 28", tgl1, tgl2);
        int bayi2911 = scalar(k,
            "SELECT COUNT(DISTINCT r.no_rawat) FROM reg_periksa r "
            + "JOIN pasien p ON p.no_rkm_medis=r.no_rkm_medis "
            + "WHERE r.tgl_registrasi BETWEEN ? AND ? AND TIMESTAMPDIFF(DAY, p.tgl_lahir, r.tgl_registrasi) BETWEEN 29 AND 334", tgl1, tgl2);
        int balita1259 = scalar(k,
            "SELECT COUNT(DISTINCT r.no_rawat) FROM reg_periksa r "
            + "JOIN pasien p ON p.no_rkm_medis=r.no_rkm_medis "
            + "WHERE r.tgl_registrasi BETWEEN ? AND ? AND TIMESTAMPDIFF(MONTH, p.tgl_lahir, r.tgl_registrasi) BETWEEN 12 AND 59", tgl1, tgl2);

        // Direct: [jumlah, sumber]
        Map<String, Object[]> direct = new HashMap<>();
        direct.put("1.1.1", new Object[]{pb.get("bblr_1500_2500"), "pasien_bayi BB 1500-2499g"});
        direct.put("1.1.2", new Object[]{pb.get("bblsr_1000_1500"), "pasien_bayi BB 1000-1499g"});
        direct.put("1.1.3", new Object[]{pb.get("bbler_lt1000"), "pasien_bayi BB <1000g"});
        direct.put("1.2.2", new Object[]{pb.get("bbln_2500_4000"), "pasien_bayi BB 2500-3999g"});
        direct.put("1.2.3", new Object[]{pb.get("bbll_ge4000"), "pasien_bayi BB >=4000g"});
        direct.put("4.1",   new Object[]{pb.get("asfiksia_apgar1_lt7"), "pasien_bayi Apgar 1' <7 (asfiksia)"});
        direct.put("2.1",   new Object[]{lahirMati, "pasien_mati ICD P95 atau umur=0 hari (lahir mati)"});
        direct.put("3.1",   new Object[]{neoDini, "pasien_mati x umur 0-7 hari"});
        direct.put("3.2",   new Object[]{neoLanjut, "pasien_mati x umur 8-28 hari"});
        direct.put("8.1",   new Object[]{bbl028, "reg_periksa x pasien umur 0-28 hari"});
        direct.put("8.2",   new Object[]{bayi2911, "reg_periksa x pasien umur 29 hari-11 bulan"});
        direct.put("8.3",   new Object[]{balita1259, "reg_periksa x pasien umur 12-59 bulan"});
        // Neonatal & balita dari form SIRS (data_bayi_sirs, key no_rkm_medis).
        direct.put("5",     new Object[]{dataBayi(k, "metode_kanguru", tgl1, tgl2), "data_bayi_sirs metode_kanguru=Ya"});
        direct.put("6",     new Object[]{dataBayi(k, "imd", tgl1, tgl2), "data_bayi_sirs imd=Ya"});
        direct.put("7",     new Object[]{dataBayi(k, "skrining_hipotiroid", tgl1, tgl2), "data_bayi_sirs skrining_hipotiroid=Ya"});
        direct.put("10",    new Object[]{dataBayi(k, "buku_kia", tgl1, tgl2), "data_bayi_sirs buku_kia=Ya"});
        direct.put("11.1",  new Object[]{dataBayi(k, "skr_pertumbuhan", tgl1, tgl2), "data_bayi_sirs skr_pertumbuhan=Ya"});
        direct.put("11.2",  new Object[]{dataBayi(k, "skr_perkembangan", tgl1, tgl2), "data_bayi_sirs skr_perkembangan=Ya"});
        direct.put("11.3",  new Object[]{dataBayi(k, "skr_bicara", tgl1, tgl2), "data_bayi_sirs skr_bicara=Ya"});
        direct.put("11.4",  new Object[]{dataBayi(k, "skr_motorik", tgl1, tgl2), "data_bayi_sirs skr_motorik=Ya"});
        direct.put("11.5",  new Object[]{dataBayi(k, "skr_perilaku", tgl1, tgl2), "data_bayi_sirs skr_perilaku=Ya"});
        direct.put("11.6",  new Object[]{dataBayi(k, "skr_pendengaran", tgl1, tgl2), "data_bayi_sirs skr_pendengaran=Ya"});
        direct.put("11.7",  new Object[]{dataBayi(k, "skr_penglihatan", tgl1, tgl2), "data_bayi_sirs skr_penglihatan=Ya"});
        // Imunisasi (section 12) best-effort via nama barang.
        direct.put("12.1",  new Object[]{imunisasi(k, "HB.?0|HEPATITIS B|EUVAX", tgl1, tgl2), "imunisasi (Hep B/Hb0, best-effort)"});
        direct.put("12.2",  new Object[]{imunisasi(k, "BCG", tgl1, tgl2), "imunisasi (BCG, best-effort)"});
        direct.put("12.3",  new Object[]{imunisasi(k, "OPV|BOPV|POLIO ORAL|POLIO TETES", tgl1, tgl2), "imunisasi (Polio oral, best-effort)"});
        direct.put("12.4",  new Object[]{imunisasi(k, "DPT|DTP|PENTA", tgl1, tgl2), "imunisasi (DPT-HB-HiB, best-effort)"});
        direct.put("12.5",  new Object[]{imunisasi(k, "IPV", tgl1, tgl2), "imunisasi (IPV, best-effort)"});
        direct.put("12.6",  new Object[]{imunisasi(k, "CAMPAK|RUBELLA|MEASLES|(^| )MR( |$)", tgl1, tgl2), "imunisasi (Campak-Rubella, best-effort)"});
        direct.put("12.7",  new Object[]{imunisasi(k, "VIT.*A|VITAMIN A", tgl1, tgl2), "imunisasi/obat (Vitamin A, best-effort)"});

        for (String[] b : MASTER) {
            String kode = b[0], nama = b[1], section = b[4];
            boolean isParent = "P".equals(b[3]);
            String tampilNama = (isParent ? "" : "   ") + nama;
            if (isParent) {
                res.add(kode, section, tampilNama, "", "");
            } else if (direct.containsKey(kode)) {
                Object[] d = direct.get(kode);
                res.add(kode, section, tampilNama, d[0], (String) d[1]);
            } else if (ROW_SPECS.containsKey(kode)) {
                String[][] specs = ROW_SPECS.get(kode);
                int jumlah = distinctCount(k, specs, tgl1, tgl2);
                res.add(kode, section, tampilNama, jumlah, describeSpecs(specs));
            } else {
                res.add(kode, section, tampilNama, "-", "");
            }
        }
        return res;
    }

    /** Breakdown pasien_bayi (lahir di RS) yang ibunya Ranap dalam rentang. */
    private Map<String, Integer> pasienBayi(Connection k, String tgl1, String tgl2) throws Exception {
        String sql = "SELECT "
            + "CAST(COUNT(*) AS SIGNED) total,"
            + "CAST(SUM(CASE WHEN CAST(pb.berat_badan AS UNSIGNED)<1000 THEN 1 ELSE 0 END) AS SIGNED) bbler,"
            + "CAST(SUM(CASE WHEN CAST(pb.berat_badan AS UNSIGNED) BETWEEN 1000 AND 1499 THEN 1 ELSE 0 END) AS SIGNED) bblsr,"
            + "CAST(SUM(CASE WHEN CAST(pb.berat_badan AS UNSIGNED) BETWEEN 1500 AND 2499 THEN 1 ELSE 0 END) AS SIGNED) bblr,"
            + "CAST(SUM(CASE WHEN CAST(pb.berat_badan AS UNSIGNED) BETWEEN 2500 AND 3999 THEN 1 ELSE 0 END) AS SIGNED) bbln,"
            + "CAST(SUM(CASE WHEN CAST(pb.berat_badan AS UNSIGNED) >= 4000 THEN 1 ELSE 0 END) AS SIGNED) bbll,"
            + "CAST(SUM(CASE WHEN CAST(pb.n1 AS UNSIGNED) < 7 AND CAST(pb.n1 AS UNSIGNED) > 0 THEN 1 ELSE 0 END) AS SIGNED) asfiksia "
            + "FROM pasien_bayi pb "
            + "WHERE EXISTS ("
            + "  SELECT 1 FROM reg_periksa r "
            + "  WHERE r.no_rkm_medis = pb.no_rkm_medis AND r.status_lanjut='Ranap' "
            + "    AND r.tgl_registrasi BETWEEN ? AND ?)";
        Map<String, Integer> m = new HashMap<>();
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    m.put("total", rs.getInt("total"));
                    m.put("bbler_lt1000", rs.getInt("bbler"));
                    m.put("bblsr_1000_1500", rs.getInt("bblsr"));
                    m.put("bblr_1500_2500", rs.getInt("bblr"));
                    m.put("bbln_2500_4000", rs.getInt("bbln"));
                    m.put("bbll_ge4000", rs.getInt("bbll"));
                    m.put("asfiksia_apgar1_lt7", rs.getInt("asfiksia"));
                }
            }
        }
        for (String key : new String[]{"total", "bbler_lt1000", "bblsr_1000_1500", "bblr_1500_2500",
                "bbln_2500_4000", "bbll_ge4000", "asfiksia_apgar1_lt7"}) {
            m.putIfAbsent(key, 0);
        }
        return m;
    }

    /** COUNT DISTINCT no_rawat dari gabungan (UNION) pola diagnosa/prosedur dalam rentang. */
    private int distinctCount(Connection k, String[][] specs, String tgl1, String tgl2) throws Exception {
        List<String> unions = new ArrayList<>();
        List<String> binds = new ArrayList<>();
        for (String[] s : specs) {
            String tbl = s[0], pat = s[1];
            if ("p".equals(tbl)) {
                unions.add("SELECT pp.no_rawat FROM prosedur_pasien pp "
                        + "JOIN reg_periksa r ON r.no_rawat=pp.no_rawat "
                        + "WHERE r.tgl_registrasi BETWEEN ? AND ? AND pp.kode LIKE ?");
            } else { // d
                unions.add("SELECT dp.no_rawat FROM diagnosa_pasien dp "
                        + "JOIN reg_periksa r ON r.no_rawat=dp.no_rawat "
                        + "WHERE r.tgl_registrasi BETWEEN ? AND ? AND dp.kd_penyakit LIKE ?");
            }
            binds.add(tgl1); binds.add(tgl2); binds.add(pat);
        }
        String sql = "SELECT COUNT(*) c FROM (" + String.join(" UNION ", unions) + ") x";
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            for (int i = 0; i < binds.size(); i++) ps.setString(i + 1, binds.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("c");
            }
        }
        return 0;
    }

    static String describeSpecs(String[][] specs) {
        List<String> parts = new ArrayList<>();
        for (String[] s : specs) {
            parts.add(("p".equals(s[0]) ? "ICD-9 " : "ICD-10 ") + s[1]);
        }
        return String.join(", ", parts);
    }

    /** Hitung anak (distinct no_rkm_medis) dgn field data_bayi_sirs='Ya' & kunjungan di rentang. */
    private int dataBayi(Connection k, String field, String tgl1, String tgl2) throws Exception {
        java.util.Set<String> ok = new java.util.HashSet<>(java.util.Arrays.asList(
            "metode_kanguru", "imd", "skrining_hipotiroid", "buku_kia", "skr_pertumbuhan",
            "skr_perkembangan", "skr_bicara", "skr_motorik", "skr_perilaku", "skr_pendengaran", "skr_penglihatan"));
        if (!ok.contains(field)) return 0;
        String sql = "SELECT COUNT(DISTINCT db.no_rkm_medis) FROM data_bayi_sirs db "
            + "JOIN reg_periksa r ON r.no_rkm_medis=db.no_rkm_medis AND r.tgl_registrasi BETWEEN ? AND ? "
            + "WHERE db.`" + field + "`='Ya'";
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { /* tabel belum ada -> 0 */ }
        return 0;
    }

    /** Hitung tindakan imunisasi (best-effort via nama barang) dalam rentang. */
    private int imunisasi(Connection k, String regex, String tgl1, String tgl2) throws Exception {
        String sql = "SELECT COUNT(*) FROM imunisasi_pasien ip "
            + "JOIN reg_periksa r ON r.no_rawat=ip.no_rawat "
            + "LEFT JOIN databarang db ON db.kode_brng=ip.kode_brng "
            + "WHERE r.tgl_registrasi BETWEEN ? AND ? "
            + "AND (UPPER(IFNULL(db.nama_brng,'')) REGEXP ? OR UPPER(IFNULL(ip.target_disease_display,'')) REGEXP ?)";
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            ps.setString(3, regex);
            ps.setString(4, regex);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { /* best-effort */ }
        return 0;
    }

    private int scalar(Connection k, String sql, String tgl1, String tgl2) throws Exception {
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }
}
