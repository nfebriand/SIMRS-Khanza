package laporan.sirs;

/**
 * RL 5.3 — 10 Besar Kunjungan Penyakit Rawat Jalan (bulanan, realtime).
 * Port controller web Rl5Controller::tenBesar(byBaru=false) / rl53.
 *
 * Identik RL 5.2 tetapi urut Total Kunjungan desc (tie Total Baru desc, tie
 * kode asc). Reuse penuh {@link Rl52} lewat hook {@link Rl52#byBaru()}.
 */
public class Rl53 extends Rl52 {

    @Override
    protected boolean byBaru() {
        return false;
    }
}
