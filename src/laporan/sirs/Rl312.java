package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

/**
 * RL 3.12 — Rekapitulasi Kegiatan Pembedahan (JUKNIS SIRS 6.3), bulanan.
 * Port Rl312Controller. Baris = 16 spesialisasi; kolom = golongan operasi
 * Khusus/Besar/Sedang/Kecil + Total. Sumber = tabel operasi (golongan dari
 * operasi.kategori). Spesialisasi dari prosedur_pasien ICD-9 chapter (&lt;87);
 * fallback paket_operasi (Kebidanan/Sectio->Obgyn, Katarak->Mata), sisanya Lain.
 */
public class Rl312 implements SirsBuilder {

    private static final String[][] MASTER = {
        {"1", "Bedah"}, {"2", "Obstetri dan Ginekologi"}, {"3", "Bedah Saraf (Non Stroke)"},
        {"4", "THT"}, {"5", "Mata"}, {"6", "Kulit dan Kelamin"}, {"7", "Gigi dan Mulut"},
        {"8", "Bedah Anak"}, {"9", "Kardiovaskular"}, {"10", "Bedah Orthopedi"}, {"11", "Thoraks"},
        {"12", "Digestif"}, {"13", "Urologi"}, {"14", "Bedah Saraf (Stroke)"}, {"15", "Kanker"},
        {"16", "Lain-lain"},
    };
    private static final String[] GOL = {"Khusus", "Besar", "Sedang", "Kecil"};

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "No.", "Spesialisasi", "Khusus", "Besar", "Sedang", "Kecil", "Total"
        });
        String sampaiDt = tgl2 + " 23:59:59";

        String sql = "SELECT COALESCE(icd_sp, paket_sp, '16') AS sp, golongan, COUNT(*) AS n FROM ("
            + " SELECT o.kategori AS golongan,"
            + "   (SELECT " + icdCase("pp.kode") + " FROM prosedur_pasien pp"
            + "      WHERE pp.no_rawat=o.no_rawat AND pp.kode < '87' ORDER BY pp.kode LIMIT 1) AS icd_sp,"
            + "   (SELECT CASE"
            + "       WHEN po.kategori='Kebidanan' OR UPPER(po.nm_perawatan) REGEXP 'SECTIO|CAESAR|SESAR|KURET|CURET|PARTUS' THEN '2'"
            + "       WHEN UPPER(po.nm_perawatan) REGEXP 'KATARAK|PHACO|FACO|LENSA' THEN '5'"
            + "       ELSE NULL END FROM paket_operasi po WHERE po.kode_paket=o.kode_paket) AS paket_sp"
            + " FROM operasi o"
            + " WHERE o.tgl_operasi BETWEEN ? AND ? AND o.kategori IN ('Khusus','Besar','Sedang','Kecil')"
            + ") x GROUP BY sp, golongan";

        Map<String, Map<String, Integer>> map = new HashMap<>();
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            ps.setString(1, tgl1);
            ps.setString(2, sampaiDt);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.computeIfAbsent(rs.getString("sp"), x -> new HashMap<>())
                       .put(rs.getString("golongan"), rs.getInt("n"));
                }
            }
        }

        int[] tot = new int[5]; // khusus, besar, sedang, kecil, total
        for (String[] b : MASTER) {
            Map<String, Integer> g = map.getOrDefault(b[0], new HashMap<>());
            int kh = g.getOrDefault("Khusus", 0), be = g.getOrDefault("Besar", 0),
                se = g.getOrDefault("Sedang", 0), ke = g.getOrDefault("Kecil", 0);
            int t = kh + be + se + ke;
            res.add(b[0], b[1], kh, be, se, ke, t);
            tot[0] += kh; tot[1] += be; tot[2] += se; tot[3] += ke; tot[4] += t;
        }
        res.add("99", "TOTAL", tot[0], tot[1], tot[2], tot[3], tot[4]);

        res.catatan = "16 spesialisasi JUKNIS x golongan operasi (operasi.kategori). Spesialisasi via "
            + "prosedur_pasien ICD-9 (<87) + fallback paket_operasi. Golongan Elektive/Emergency/'-' tak dihitung.";
        return res;
    }

    /** CASE ICD-9 chapter (2 digit) -> kode spesialisasi JUKNIS. */
    private static String icdCase(String col) {
        String c2 = "LEFT(" + col + ",2)";
        return "CASE"
            + " WHEN " + c2 + " IN ('40','41','85','86','17') THEN '1'"
            + " WHEN " + c2 + " IN ('65','66','67','68','69','70','71','72','73','74','75') THEN '2'"
            + " WHEN " + c2 + " IN ('01','02','03','04','05') THEN '3'"
            + " WHEN " + c2 + " IN ('18','19','20','21','22','25','26','27','28','29') THEN '4'"
            + " WHEN " + c2 + " IN ('08','09','10','11','12','13','14','15','16') THEN '5'"
            + " WHEN " + c2 + " IN ('64') THEN '6'"
            + " WHEN " + c2 + " IN ('23','24') THEN '7'"
            + " WHEN " + c2 + " IN ('35','36','37','38','39') THEN '9'"
            + " WHEN " + c2 + " IN ('76','77','78','79','80','81','82','83','84') THEN '10'"
            + " WHEN " + c2 + " IN ('30','31','32','33','34') THEN '11'"
            + " WHEN " + c2 + " IN ('42','43','44','45','46','47','48','49','50','51','52','53','54') THEN '12'"
            + " WHEN " + c2 + " IN ('55','56','57','58','59','60','61','62','63') THEN '13'"
            + " WHEN " + c2 + " IN ('06','07') THEN '16'"
            + " ELSE '16' END";
    }
}
