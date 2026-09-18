package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;

/**
 * RL 1.4 — Meta ASPAK (entry-display, read-only).
 * Menampilkan singleton sirs_rl14_aspak_meta (id=1) apa adanya sebagai tabel
 * Field|Nilai. Tidak bergantung tanggal: param tgl1/tgl2 diabaikan.
 * Tabel Khanza read-only — hanya SELECT, tidak menulis.
 */
public class Rl14 implements SirsBuilder {

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{"Field", "Nilai"});
        String sql = "SELECT * FROM sirs_rl14_aspak_meta WHERE id=1";
        try (PreparedStatement ps = k.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            ResultSetMetaData md = rs.getMetaData();
            int n = md.getColumnCount();
            if (rs.next()) {
                for (int i = 1; i <= n; i++) {
                    Object v = rs.getObject(i);
                    res.add(md.getColumnLabel(i), v == null ? "" : String.valueOf(v));
                }
            }
        }
        return res;
    }
}
