package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * RL 3.6 — Rekapitulasi Kegiatan Pelayanan Kebidanan (JUKNIS SIRS 6.3), bulanan.
 * Port controller web Rl36Controller (matriks penuh). Baris = 30 jenis kegiatan;
 * kolom = Rujukan Medis [RS/Pusk/Bidan/Kesmas/Lainnya + Hidup/Mati/Total],
 * Rujukan Non Medis [Hidup/Mati/Total = 0], Non Rujukan [Hidup/Mati/Total], Dirujuk.
 * Klasifikasi baris via diagnosa_pasien/prosedur_pasien + operasi/paket_operasi +
 * jns_perawatan(_inap). Atribut via rujuk_masuk/bridging_sep, reg_periksa.stts, rujuk.
 */
public class Rl36 implements SirsBuilder {

    // [kode, nama, is_parent("1"/"0")]
    private static final String[][] MASTER = {
        {"1", "Pemberian Buku KIA pada Ibu Hamil", "0"},
        {"2", "Pelayanan Antenatal", "0"},
        {"3", "Persalinan:", "1"},
        {"3.1", "Persalinan pervaginam tanpa penyulit (normal)", "0"},
        {"3.2", "Persalinan pervaginam spontan dengan penyulit", "0"},
        {"3.3", "Persalinan pervaginam dengan bantuan", "0"},
        {"3.4", "Persalinan Sectio caesaria", "0"},
        {"4", "Komplikasi obstetri pada ibu hamil, bersalin, dan nifas", "1"},
        {"4.1", "Perdarahan sebelum persalinan", "0"},
        {"4.2", "Perdarahan setelah persalinan", "0"},
        {"4.3", "Pre eklamsia", "0"},
        {"4.4", "Eklamsia", "0"},
        {"4.5", "Infeksi", "0"},
        {"4.6", "Abortus", "0"},
        {"4.7", "Komplikasi lainnya", "0"},
        {"5", "Aborsi", "1"},
        {"5.1", "Aborsi atas indikasi kedaruratan medis", "0"},
        {"5.2", "Aborsi atas indikasi kehamilan akibat perkosaan", "0"},
        {"6", "Skrining Status Imunisasi Tetanus", "0"},
        {"7", "Komplikasi non obstetri pada ibu hamil, bersalin, dan nifas", "1"},
        {"7.1", "HIV", "0"}, {"7.2", "Hepatitis B", "0"}, {"7.3", "Sifilis", "0"},
        {"7.4", "Tuberkulosis", "0"}, {"7.5", "Penyakit jantung", "0"}, {"7.6", "Anemia", "0"},
        {"7.7", "Diabetes Melitus", "0"}, {"7.8", "Terkonfirmasi COVID-19", "0"}, {"7.9", "Komplikasi lainnya", "0"},
        {"8", "Ibu Hamil berisiko mempunyai bayi prematur", "1"},
        {"8.1", "Diberikan antenatal kortikosteroid", "0"},
        {"8.2", "Tidak diberikan antenatal kortikosteroid", "0"},
        {"9", "Pelayanan Nifas", "0"},
        {"10", "Ibu Nifas mendapat vitamin A", "0"},
    };

    /** kode baris -> daftar spec {tipe, pola}. tipe: d,dr,p,sjl,sinap,op. */
    private static Map<String, String[][]> rowSpecs() {
        Map<String, String[][]> s = new LinkedHashMap<>();
        s.put("2", new String[][]{{"dr", "O%"}, {"p", "88.78"}, {"p", "88.79"}});
        s.put("3.1", new String[][]{{"d", "O80%"}, {"sinap", "PARTUS.*NORMAL|PERSALINAN.*NORMAL|SPONTAN.*NORMAL"}, {"sjl", "PARTUS.*NORMAL|PERSALINAN.*NORMAL"}});
        s.put("3.2", new String[][]{{"d", "O81%"}, {"d", "O83%"}, {"sinap", "INDUKSI|AKSELERASI"}});
        s.put("3.3", new String[][]{{"p", "72%"}, {"sinap", "VAKUM|VACUM|FORCEP|EKSTRAKSI"}, {"sjl", "VAKUM|VACUM|FORCEP"}});
        s.put("3.4", new String[][]{{"d", "O82%"}, {"p", "74%"}, {"op", "SECTIO|CAESAR|SESAR|(^| )SC( |$)"}, {"sinap", "SECTIO|CAESAR"}});
        s.put("4.1", new String[][]{{"d", "O44%"}, {"d", "O45%"}, {"d", "O46%"}});
        s.put("4.2", new String[][]{{"d", "O72%"}});
        s.put("4.3", new String[][]{{"d", "O14%"}});
        s.put("4.4", new String[][]{{"d", "O15%"}});
        s.put("4.5", new String[][]{{"d", "O85%"}, {"d", "O86%"}});
        s.put("4.6", new String[][]{{"d", "O03%"}, {"d", "O05%"}, {"d", "O06%"}, {"d", "O07%"}, {"d", "O08%"}});
        s.put("5.1", new String[][]{{"d", "O04%"}, {"p", "69.5%"}, {"op", "KURET|CURET"}, {"sjl", "KURET|CURET"}, {"sinap", "KURET|CURET"}});
        s.put("6", new String[][]{{"d", "Z23%"}});
        s.put("7.1", new String[][]{{"d", "O98.7%"}});
        s.put("7.2", new String[][]{{"d", "O98.4%"}});
        s.put("7.3", new String[][]{{"d", "O98.1%"}});
        s.put("7.4", new String[][]{{"d", "O98.0%"}});
        s.put("7.5", new String[][]{{"d", "O99.4%"}});
        s.put("7.6", new String[][]{{"d", "O99.0%"}});
        s.put("7.7", new String[][]{{"d", "O24%"}});
        s.put("7.8", new String[][]{{"d", "U07%"}});
        s.put("9", new String[][]{{"d", "Z39%"}, {"d", "O87%"}, {"d", "O88%"}, {"d", "O89%"}, {"d", "O90%"}, {"d", "O91%"}, {"d", "O92%"}});
        return s;
    }

    private static final int NM = 15; // rm_rs..dirujuk

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "Kode", "Jenis Kegiatan", "RM RS", "RM Pusk", "RM Bidan", "RM Kesmas", "RM Lainnya",
            "RM Hidup", "RM Mati", "RM Total", "RNM Hidup", "RNM Mati", "RNM Total",
            "NR Hidup", "NR Mati", "NR Total", "Dirujuk"
        });
        Map<String, String[][]> specs = rowSpecs();
        long[] tot = new long[NM];

        for (String[] m : MASTER) {
            String kode = m[0], nama = m[1];
            boolean parent = "1".equals(m[2]);
            if (parent) {
                res.add(kode, nama, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
                continue;
            }
            long[] v = new long[NM];
            if (specs.containsKey(kode)) {
                v = rowMatrix(k, specs.get(kode), tgl1, tgl2);
                for (int i = 0; i < NM; i++) tot[i] += v[i];
            }
            res.add(kode, nama, v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7],
                v[8], v[9], v[10], v[11], v[12], v[13], v[14]);
        }
        res.add("", "TOTAL", tot[0], tot[1], tot[2], tot[3], tot[4], tot[5], tot[6], tot[7],
            tot[8], tot[9], tot[10], tot[11], tot[12], tot[13], tot[14]);

        res.catatan = "Matriks penuh JUKNIS. Klasifikasi via ICD-10/9 + tindakan operasi/paket_operasi/jns_perawatan. "
            + "Rujukan Medis dari rujuk_masuk/bridging_sep; Mati=reg_periksa.stts='Meninggal'; Dirujuk=ada rujuk. "
            + "Rujukan Non Medis tak dicatat Khanza (=0). Kegiatan (bukan pasien), bisa double counting.";
        return res;
    }

    /** 15 metrik matriks untuk satu baris. */
    private long[] rowMatrix(Connection k, String[][] specs, String tgl1, String tgl2) throws Exception {
        List<String> unions = new ArrayList<>();
        List<String> binds = new ArrayList<>();
        String sampaiDt = tgl2 + " 23:59:59";
        for (String[] sp : specs) {
            String tipe = sp[0], pola = sp[1];
            switch (tipe) {
                case "d":
                    unions.add("SELECT dp.no_rawat FROM diagnosa_pasien dp JOIN reg_periksa r ON r.no_rawat=dp.no_rawat "
                        + "WHERE r.tgl_registrasi BETWEEN ? AND ? AND dp.kd_penyakit LIKE ?");
                    binds.add(tgl1); binds.add(tgl2); binds.add(pola); break;
                case "dr":
                    unions.add("SELECT dp.no_rawat FROM diagnosa_pasien dp JOIN reg_periksa r ON r.no_rawat=dp.no_rawat "
                        + "WHERE r.tgl_registrasi BETWEEN ? AND ? AND dp.status='Ralan' AND dp.kd_penyakit LIKE ?");
                    binds.add(tgl1); binds.add(tgl2); binds.add(pola); break;
                case "p":
                    unions.add("SELECT pp.no_rawat FROM prosedur_pasien pp JOIN reg_periksa r ON r.no_rawat=pp.no_rawat "
                        + "WHERE r.tgl_registrasi BETWEEN ? AND ? AND pp.kode LIKE ?");
                    binds.add(tgl1); binds.add(tgl2); binds.add(pola); break;
                case "sjl":
                    unions.add("SELECT rd.no_rawat FROM rawat_jl_dr rd JOIN jns_perawatan jp ON jp.kd_jenis_prw=rd.kd_jenis_prw "
                        + "JOIN reg_periksa r ON r.no_rawat=rd.no_rawat WHERE r.tgl_registrasi BETWEEN ? AND ? AND UPPER(jp.nm_perawatan) REGEXP ?");
                    binds.add(tgl1); binds.add(tgl2); binds.add(pola); break;
                case "sinap":
                    unions.add("SELECT rd.no_rawat FROM rawat_inap_dr rd JOIN jns_perawatan_inap jp ON jp.kd_jenis_prw=rd.kd_jenis_prw "
                        + "JOIN reg_periksa r ON r.no_rawat=rd.no_rawat WHERE r.tgl_registrasi BETWEEN ? AND ? AND UPPER(jp.nm_perawatan) REGEXP ?");
                    binds.add(tgl1); binds.add(tgl2); binds.add(pola); break;
                case "op":
                    unions.add("SELECT o.no_rawat FROM operasi o JOIN paket_operasi po ON po.kode_paket=o.kode_paket "
                        + "WHERE o.tgl_operasi BETWEEN ? AND ? AND UPPER(po.nm_perawatan) REGEXP ?");
                    binds.add(tgl1); binds.add(sampaiDt); binds.add(pola); break;
                default: break;
            }
        }
        if (unions.isEmpty()) return new long[NM];

        String union = String.join(" UNION ", unions);
        String sql =
            "SELECT SUM(rm=1 AND fas='RS') rm_rs, SUM(rm=1 AND fas='PKM') rm_pkm, SUM(rm=1 AND fas='BIDAN') rm_bidan,"
            + " SUM(rm=1 AND fas='KESMAS') rm_kesmas, SUM(rm=1 AND fas='LAIN') rm_lain,"
            + " SUM(rm=1 AND mati=0) rm_hidup, SUM(rm=1 AND mati=1) rm_mati, SUM(rm=1) rm_total,"
            + " 0 rn_hidup, 0 rn_mati, 0 rn_total,"
            + " SUM(rm=0 AND mati=0) nr_hidup, SUM(rm=0 AND mati=1) nr_mati, SUM(rm=0) nr_total,"
            + " SUM(dirujuk=1) dirujuk FROM ("
            + "  SELECT rm, mati, dirujuk, CASE"
            + "    WHEN rm=0 THEN 'LAIN' WHEN src_rs=1 THEN 'RS'"
            + "    WHEN UPPER(src) REGEXP 'RUMAH SAKIT|RSUD|RSIA|RSU|(^| )RS( |$)' THEN 'RS'"
            + "    WHEN UPPER(src) REGEXP 'BIDAN|BPM|PMB' THEN 'BIDAN'"
            + "    WHEN UPPER(src) REGEXP 'KLINIK|KLNK' THEN 'KESMAS'"
            + "    WHEN UPPER(src) REGEXP 'PUSKESMAS|PKM|PUSTU' THEN 'PKM' ELSE 'PKM' END fas"
            + "  FROM ("
            + "    SELECT (EXISTS(SELECT 1 FROM rujuk_masuk rmk WHERE rmk.no_rawat=nr.no_rawat)"
            + "        OR EXISTS(SELECT 1 FROM bridging_sep bs WHERE bs.no_rawat=nr.no_rawat AND bs.no_rujukan IS NOT NULL AND bs.no_rujukan<>'')) AS rm,"
            + "      COALESCE((SELECT rmk.perujuk FROM rujuk_masuk rmk WHERE rmk.no_rawat=nr.no_rawat LIMIT 1),"
            + "        (SELECT bs.nmppkrujukan FROM bridging_sep bs WHERE bs.no_rawat=nr.no_rawat AND bs.no_rujukan<>'' LIMIT 1),'') AS src,"
            + "      (EXISTS(SELECT 1 FROM bridging_sep bs WHERE bs.no_rawat=nr.no_rawat AND bs.asal_rujukan='2. Faskes 2(RS)')) AS src_rs,"
            + "      (reg.stts='Meninggal') AS mati,"
            + "      EXISTS(SELECT 1 FROM rujuk rk WHERE rk.no_rawat=nr.no_rawat) AS dirujuk"
            + "    FROM (SELECT DISTINCT no_rawat FROM (" + union + ") mm) nr"
            + "    JOIN reg_periksa reg ON reg.no_rawat=nr.no_rawat"
            + "  ) a"
            + ") b";

        long[] v = new long[NM];
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            for (int i = 0; i < binds.size(); i++) ps.setString(i + 1, binds.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    for (int i = 0; i < NM; i++) v[i] = rs.getLong(i + 1);
                }
            }
        }
        return v;
    }
}
