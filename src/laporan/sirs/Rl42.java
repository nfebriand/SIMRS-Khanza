package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * RL 4.2 — 10 Besar Penyakit Rawat Inap (bulanan, realtime).
 * Port controller web Rl4Controller::topPenyakit (byMati=false).
 * Agregasi diagnosa utama (diagnosa_pasien Ranap prioritas=1) per ICD-10
 * 3-digit dari kamar_inap yang keluar dalam rentang; exclude O80/O82 & huruf
 * awal R/V/W/X/Y/Z; urut Total desc; top 10.
 */
public class Rl42 implements SirsBuilder {

    protected boolean byMati() { return false; }

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "No.", "Kode ICD-10", "Nama Penyakit", "Laki-laki", "Perempuan", "Total", "Mati"
        });

        String sql = "SELECT LEFT(dp.kd_penyakit,3) kd, MAX(pk.nm_penyakit) nm, "
                + "SUM(p.jk='L') lk, SUM(p.jk='P') pr, COUNT(*) total, "
                + "SUM(ki.stts_pulang='Meninggal') mati "
                + "FROM kamar_inap ki "
                + "JOIN reg_periksa r ON r.no_rawat=ki.no_rawat "
                + "JOIN pasien p ON p.no_rkm_medis=r.no_rkm_medis "
                + "JOIN diagnosa_pasien dp ON dp.no_rawat=ki.no_rawat AND dp.status='Ranap' AND dp.prioritas=1 "
                + "LEFT JOIN penyakit pk ON pk.kd_penyakit=dp.kd_penyakit "
                + "WHERE ki.tgl_keluar BETWEEN ? AND ? "
                + "GROUP BY LEFT(dp.kd_penyakit,3)";

        List<Object[]> tmp = new ArrayList<>();
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String kd = rs.getString("kd");
                    if (kd == null) continue;
                    kd = kd.toUpperCase();
                    int lk = rs.getInt("lk"), pr = rs.getInt("pr"),
                        total = rs.getInt("total"), mati = rs.getInt("mati");
                    if (byMati()) {
                        if (mati == 0) continue;
                    } else {
                        if (excluded(kd)) continue;
                    }
                    String nm = rs.getString("nm");
                    tmp.add(new Object[]{kd, (nm == null || nm.isEmpty()) ? "-" : nm, lk, pr, total, mati});
                }
            }
        }

        // Rows tmp berformat: [kd, nm, lk, pr, total, mati] (index 0..5)
        // urut: byMati -> mati desc, selain itu total desc; tie -> kode asc
        final boolean bm = byMati();
        tmp.sort((a, b) -> {
            int va = bm ? (Integer) a[5] : (Integer) a[4];
            int vb = bm ? (Integer) b[5] : (Integer) b[4];
            if (vb != va) return Integer.compare(vb, va);
            return ((String) a[0]).compareTo((String) b[0]);
        });

        int limit = Math.min(10, tmp.size());
        for (int i = 0; i < limit; i++) {
            Object[] r = tmp.get(i);
            res.add(i + 1, r[0], r[1], r[2], r[3], r[4], r[5]);
        }
        return res;
    }

    /** Exclude per JUKNIS Rule 3 (hanya utk 10 besar penyakit, bukan kematian). */
    static boolean excluded(String kd) {
        if (kd.equals("O80") || kd.equals("O82")) return true;
        char c = kd.isEmpty() ? ' ' : kd.charAt(0);
        return c == 'R' || c == 'V' || c == 'W' || c == 'X' || c == 'Y' || c == 'Z';
    }
}
