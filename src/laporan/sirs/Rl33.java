package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

/**
 * RL 3.3 — Rekapitulasi Kegiatan Pelayanan Rawat Darurat (JUKNIS SIRS 6.3).
 *
 * Baris baku JUKNIS: 1 Bedah (1.1-1.4), 2 Non Bedah (2.1-2.4), 3 Kebidanan,
 * 4 Psikiatrik, 5 Bayi, 6 Anak, 7 Geriatri + TOTAL. Logika IDENTIK controller
 * web Rl33Controller. Klasifikasi & flag (kondisi keluar, luka-luka, false
 * emergency) diinput lewat form Triase IGD ke data_triase_igd_sirs; kunjungan
 * tanpa data diturunkan otomatis dari kode_kasus (001/002/003) lalu umur.
 */
public class Rl33 implements SirsBuilder {

    // [no, nama, rowkey anak (pisah koma), header?]
    private static final Object[][] DISPLAY = {
        {"1",   "BEDAH",                        "1.1,1.2,1.3,1.4", Boolean.TRUE},
        {"1.1", "Kecelakaan Lalu Lintas Darat", "1.1", Boolean.FALSE},
        {"1.2", "Kecelakaan Lalu Lintas Air",   "1.2", Boolean.FALSE},
        {"1.3", "Kecelakaan Lalu Lintas Udara", "1.3", Boolean.FALSE},
        {"1.4", "Bedah Lainnya",                "1.4", Boolean.FALSE},
        {"2",   "NON BEDAH",                    "2.1,2.2,2.3,2.4", Boolean.TRUE},
        {"2.1", "Kekerasan terhadap Perempuan", "2.1", Boolean.FALSE},
        {"2.2", "Kekerasan terhadap Anak",      "2.2", Boolean.FALSE},
        {"2.3", "Kekerasan Lainnya",            "2.3", Boolean.FALSE},
        {"2.4", "Non Bedah Lainnya",            "2.4", Boolean.FALSE},
        {"3",   "Kebidanan",                    "3", Boolean.FALSE},
        {"4",   "Psikiatrik",                   "4", Boolean.FALSE},
        {"5",   "Bayi",                         "5", Boolean.FALSE},
        {"6",   "Anak",                         "6", Boolean.FALSE},
        {"7",   "Geriatri",                     "7", Boolean.FALSE},
    };

    // indeks metrik: 0 rujukan,1 non_rujukan,2 dirawat,3 dirujuk,4 pulang,
    //                5 mati,6 doa,7 luka,8 fem,9 jml
    private static final int NM = 10;

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "No.", "Jenis Pelayanan", "Rujukan", "Non Rujukan", "Dirawat", "Dirujuk",
            "Pulang", "Mati di IGD", "DOA", "Luka-luka", "False Emergency", "Jumlah"
        });

        Map<String, long[]> byKey = new HashMap<>();
        try (PreparedStatement ps = k.prepareStatement(aggregateSql())) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    long[] v = new long[NM];
                    v[0] = rs.getLong("rujukan");   v[1] = rs.getLong("non_rujukan");
                    v[2] = rs.getLong("dirawat");   v[3] = rs.getLong("dirujuk");
                    v[4] = rs.getLong("pulang");    v[5] = rs.getLong("mati");
                    v[6] = rs.getLong("doa");       v[7] = rs.getLong("luka");
                    v[8] = rs.getLong("fem");       v[9] = rs.getLong("jml");
                    byKey.put(rs.getString("rowkey"), v);
                }
            }
        }

        long[] tot = new long[NM];
        for (Object[] d : DISPLAY) {
            String no = (String) d[0], nama = (String) d[1];
            boolean header = (Boolean) d[3];
            long[] cell = new long[NM];
            for (String key : ((String) d[2]).split(",")) {
                long[] v = byKey.get(key);
                if (v == null) continue;
                for (int i = 0; i < NM; i++) cell[i] += v[i];
            }
            if (!header) {
                for (int i = 0; i < NM; i++) tot[i] += cell[i];
            }
            res.add(no, nama, cell[0], cell[1], cell[2], cell[3], cell[4],
                cell[5], cell[6], cell[7], cell[8], cell[9]);
        }
        res.add("", "TOTAL", tot[0], tot[1], tot[2], tot[3], tot[4],
            tot[5], tot[6], tot[7], tot[8], tot[9]);

        res.catatan = "Baris baku JUKNIS RL 3.3. Klasifikasi & kondisi keluar/luka-luka/false emergency "
            + "diinput di form Triase IGD (panel 'Data SIRS RL 3.3'); tanpa data diturunkan dari kode_kasus + umur. "
            + "Dirawat=ada kamar_inap, Dirujuk=ada rujuk (bila tak dirawat), selain itu Pulang. Batal dikecualikan.";
        return res;
    }

    private static String aggregateSql() {
        return "SELECT rowkey,"
            + " SUM(is_rujukan) rujukan,"
            + " SUM(1-is_rujukan) non_rujukan,"
            + " SUM(is_mati) mati,"
            + " SUM(is_doa) doa,"
            + " SUM(CASE WHEN is_mati=0 AND is_doa=0 AND has_kamar=1 THEN 1 ELSE 0 END) dirawat,"
            + " SUM(CASE WHEN is_mati=0 AND is_doa=0 AND has_kamar=0 AND has_rujuk=1 THEN 1 ELSE 0 END) dirujuk,"
            + " SUM(CASE WHEN is_mati=0 AND is_doa=0 AND has_kamar=0 AND has_rujuk=0 THEN 1 ELSE 0 END) pulang,"
            + " SUM(is_luka) luka,"
            + " SUM(is_false) fem,"
            + " COUNT(*) jml"
            + " FROM ("
            + "   SELECT"
            + "     CASE"
            + "       WHEN s.jenis_kasus='Bedah - Kecelakaan Lalu Lintas Darat' THEN '1.1'"
            + "       WHEN s.jenis_kasus='Bedah - Kecelakaan Lalu Lintas Air' THEN '1.2'"
            + "       WHEN s.jenis_kasus='Bedah - Kecelakaan Lalu Lintas Udara' THEN '1.3'"
            + "       WHEN s.jenis_kasus='Bedah - Lainnya' THEN '1.4'"
            + "       WHEN s.jenis_kasus LIKE 'Non Bedah - Kekerasan terhadap Perempuan%' THEN '2.1'"
            + "       WHEN s.jenis_kasus LIKE 'Non Bedah - Kekerasan terhadap Anak%' THEN '2.2'"
            + "       WHEN s.jenis_kasus='Non Bedah - Kekerasan Lainnya' THEN '2.3'"
            + "       WHEN s.jenis_kasus='Non Bedah - Lainnya' THEN '2.4'"
            + "       WHEN s.jenis_kasus='Kebidanan' THEN '3'"
            + "       WHEN s.jenis_kasus='Psikiatrik' THEN '4'"
            + "       WHEN s.jenis_kasus='Bayi' THEN '5'"
            + "       WHEN s.jenis_kasus='Anak' THEN '6'"
            + "       WHEN s.jenis_kasus='Geriatri' THEN '7'"
            + "       WHEN COALESCE(dti.kode_kasus,'')='001' THEN '1.1'"
            + "       WHEN COALESCE(dti.kode_kasus,'')='002' THEN '1.4'"
            + "       WHEN COALESCE(dti.kode_kasus,'')='003' THEN '2.3'"
            + "       WHEN (rp.sttsumur IN ('Hr','Bl')) OR (rp.sttsumur='Th' AND CAST(rp.umurdaftar AS UNSIGNED)<1) THEN '5'"
            + "       WHEN rp.sttsumur='Th' AND CAST(rp.umurdaftar AS UNSIGNED) BETWEEN 1 AND 17 THEN '6'"
            + "       WHEN rp.sttsumur='Th' AND CAST(rp.umurdaftar AS UNSIGNED)>=60 THEN '7'"
            + "       ELSE '2.4'"
            + "     END AS rowkey,"
            + "     (COALESCE(dti.alasan_kedatangan,'')='Rujukan') AS is_rujukan,"
            + "     CASE WHEN COALESCE(s.kondisi_keluar,'Hidup')='Mati di IGD'"
            + "            OR (COALESCE(s.kondisi_keluar,'Hidup')='Hidup' AND rp.stts='Meninggal') THEN 1 ELSE 0 END AS is_mati,"
            + "     CASE WHEN COALESCE(s.kondisi_keluar,'') LIKE 'DOA%' THEN 1 ELSE 0 END AS is_doa,"
            + "     CASE WHEN EXISTS(SELECT 1 FROM kamar_inap ki WHERE ki.no_rawat=rp.no_rawat) THEN 1 ELSE 0 END AS has_kamar,"
            + "     CASE WHEN EXISTS(SELECT 1 FROM rujuk rj WHERE rj.no_rawat=rp.no_rawat) THEN 1 ELSE 0 END AS has_rujuk,"
            + "     CASE WHEN COALESCE(s.luka_luka,'Tidak')='Ya' THEN 1 ELSE 0 END AS is_luka,"
            + "     CASE WHEN COALESCE(s.false_emergency,'Tidak')='Ya' THEN 1 ELSE 0 END AS is_false"
            + "   FROM reg_periksa rp"
            + "   JOIN pasien p ON p.no_rkm_medis=rp.no_rkm_medis"
            + "   LEFT JOIN data_triase_igd dti ON dti.no_rawat=rp.no_rawat"
            + "   LEFT JOIN data_triase_igd_sirs s ON s.no_rawat=rp.no_rawat"
            + "   WHERE rp.kd_poli IN ('IGD','IGDK') AND rp.stts<>'Batal'"
            + "     AND DATE(rp.tgl_registrasi) BETWEEN ? AND ?"
            + " ) v GROUP BY rowkey";
    }
}
