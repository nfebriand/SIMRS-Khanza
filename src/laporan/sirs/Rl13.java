package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * RL 1.3 — Fasilitas Tempat Tidur per Ruangan (entry-display, read-only).
 * Menampilkan sirs_rl13_tt apa adanya. Tidak bergantung tanggal: param
 * tgl1/tgl2 diabaikan. Tabel Khanza read-only — hanya SELECT.
 * Kolom: No./Kelas TT/Ruangan/Tersedia/Terpakai/Catatan.
 */
public class Rl13 implements SirsBuilder {

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "No.", "Kelas TT", "Ruangan", "Tersedia", "Terpakai", "Catatan"
        });
        String sql = "SELECT kelas_tt, ruangan, jml_tersedia, jml_terpakai, catatan "
                + "FROM sirs_rl13_tt ORDER BY kelas_tt, ruangan, id";
        int no = 0;
        try (PreparedStatement ps = k.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String cat = rs.getString("catatan");
                res.add(++no,
                    rs.getString("kelas_tt"),
                    rs.getString("ruangan"),
                    rs.getInt("jml_tersedia"),
                    rs.getInt("jml_terpakai"),
                    cat == null ? "" : cat);
            }
        }
        return res;
    }
}
