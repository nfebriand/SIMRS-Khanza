package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * RL 1.2 — Indikator Pelayanan Rumah Sakit (entry-display, read-only).
 * Menampilkan sirs_rl12_pelayanan apa adanya. Tidak bergantung tanggal:
 * param tgl1/tgl2 diabaikan. Tabel Khanza read-only — hanya SELECT.
 * Kolom: No./Kategori/Sub Pelayanan/Ada(Ya/Tidak).
 */
public class Rl12 implements SirsBuilder {

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "No.", "Kategori", "Sub Pelayanan", "Ada"
        });
        String sql = "SELECT kat_no, kat_name, sub_no, sub_name, ada "
                + "FROM sirs_rl12_pelayanan ORDER BY kat_no, sub_no, id";
        int no = 0;
        try (PreparedStatement ps = k.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                res.add(++no,
                    rs.getString("kat_name"),
                    rs.getString("sub_name"),
                    rs.getInt("ada") == 1 ? "Ya" : "Tidak");
            }
        }
        return res;
    }
}
