package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * RL 3.4 — Rekapitulasi Pengunjung, bulanan (JUKNIS SIRS 6.3). Port controller
 * web Rl34Controller. Kolom baku: No, Jenis Pengunjung, Jumlah.
 *
 * Pengunjung Baru = pertama kali datang ke RS (MIN tgl_registrasi jatuh di
 * bulan ini). Pengunjung Lama = datang kedua kali dst, TERMASUK pasien baru
 * yang datang lagi di bulan yang sama (JUKNIS contoh b). Maka Lama = pasien
 * lama yang berkunjung bulan ini + pasien baru bulan ini dengan >= 2 kunjungan.
 */
public class Rl34 implements SirsBuilder {

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{"No.", "Jenis Pengunjung", "Jumlah"});

        String sql = "SELECT"
            + " (SELECT COUNT(*) FROM ("
            + "    SELECT no_rkm_medis, MIN(tgl_registrasi) fv FROM reg_periksa GROUP BY no_rkm_medis"
            + "  ) f WHERE f.fv BETWEEN ? AND ?) AS baru,"
            + " (SELECT COUNT(DISTINCT r.no_rkm_medis)"
            + "    FROM reg_periksa r"
            + "    JOIN (SELECT no_rkm_medis, MIN(tgl_registrasi) fv FROM reg_periksa GROUP BY no_rkm_medis) f"
            + "      ON f.no_rkm_medis = r.no_rkm_medis"
            + "    WHERE r.tgl_registrasi BETWEEN ? AND ? AND f.fv < ?) AS lama_lama,"
            + " (SELECT COUNT(*) FROM ("
            + "    SELECT r.no_rkm_medis"
            + "    FROM reg_periksa r"
            + "    JOIN (SELECT no_rkm_medis, MIN(tgl_registrasi) fv FROM reg_periksa GROUP BY no_rkm_medis) f"
            + "      ON f.no_rkm_medis = r.no_rkm_medis"
            + "    WHERE f.fv BETWEEN ? AND ? AND r.tgl_registrasi BETWEEN ? AND ?"
            + "    GROUP BY r.no_rkm_medis HAVING COUNT(*) >= 2"
            + "  ) x) AS baru_kembali";

        int baru = 0, lama = 0;
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            ps.setString(1, tgl1); ps.setString(2, tgl2);
            ps.setString(3, tgl1); ps.setString(4, tgl2); ps.setString(5, tgl1);
            ps.setString(6, tgl1); ps.setString(7, tgl2); ps.setString(8, tgl1); ps.setString(9, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    baru = rs.getInt("baru");
                    lama = rs.getInt("lama_lama") + rs.getInt("baru_kembali");
                }
            }
        }

        res.add("1", "Pengunjung Baru", baru);
        res.add("2", "Pengunjung Lama", lama);
        res.add("99", "TOTAL", baru + lama);

        res.catatan = "Pengunjung Baru = pertama kali dapat No.RM (bulan ini). Pengunjung Lama = kunjungan "
            + "kedua dst, termasuk pasien baru yang datang lagi di bulan yang sama (JUKNIS SIRS 6.3). "
            + "Tiap pasien maksimal 1 baru + 1 lama per bulan.";
        return res;
    }
}
