package laporan.sirs;

import java.sql.Connection;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * RL 5.2 — 10 Besar Kasus Baru Penyakit Rawat Jalan (bulanan, realtime).
 * Port controller web Rl5Controller::tenBesar(byBaru=true) / rl52.
 *
 * Basis = agregasi RL 5.1 ({@link Rl51#matriks}); exclude O80/O82 & huruf awal
 * R/V/W/X/Y/Z (per JUKNIS, {@link Rl42#excluded}); urut Total Baru desc, tie
 * Total Kunjungan desc, tie kode asc; ambil 10 besar.
 */
public class Rl52 implements SirsBuilder {

    /** true = urut kasus Baru (RL 5.2); false = urut Kunjungan (RL 5.3). */
    protected boolean byBaru() { return true; }

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "No.", "Kode ICD-10", "Nama Penyakit",
            "Baru L", "Baru P", "Total Baru",
            "Kunjungan L", "Kunjungan P", "Total Kunjungan"
        });

        List<Rl51.Agg> rows = new ArrayList<>();
        for (Rl51.Agg a : Rl51.matriks(k, tgl1, tgl2)) {
            if (!Rl42.excluded(a.kd)) rows.add(a);
        }

        final boolean bb = byBaru();
        rows.sort(new Comparator<Rl51.Agg>() {
            @Override public int compare(Rl51.Agg a, Rl51.Agg b) {
                int p, s;
                if (bb) { p = b.totalBaru - a.totalBaru;      s = b.kunjunganTotal - a.kunjunganTotal; }
                else    { p = b.kunjunganTotal - a.kunjunganTotal; s = b.totalBaru - a.totalBaru; }
                if (p != 0) return p;
                if (s != 0) return s;
                return a.kd.compareTo(b.kd);
            }
        });

        int limit = Math.min(10, rows.size());
        for (int i = 0; i < limit; i++) {
            Rl51.Agg a = rows.get(i);
            res.add(i + 1, a.kd, a.nm,
                a.totalBaruL, a.totalBaruP, a.totalBaru,
                a.kunjunganL, a.kunjunganP, a.kunjunganTotal);
        }
        return res;
    }
}
