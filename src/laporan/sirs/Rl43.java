package laporan.sirs;

/**
 * RL 4.3 — 10 Besar Kematian Rawat Inap (bulanan, realtime).
 * Port controller web Rl4Controller::topPenyakit (byMati=true): identik dengan
 * RL 4.2 tetapi hanya baris berpenyakit dengan kematian (mati &gt; 0) dan urut
 * berdasarkan jumlah kematian (Mati desc). Reuse penuh logika Rl42 lewat hook
 * {@link Rl42#byMati()}.
 */
public class Rl43 extends Rl42 {

    @Override
    protected boolean byMati() {
        return true;
    }
}
