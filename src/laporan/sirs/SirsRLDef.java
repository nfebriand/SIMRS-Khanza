package laporan.sirs;

/**
 * Definisi satu entri formulir SIRS RL untuk registry & pemilih di dialog.
 */
public final class SirsRLDef {

    public final String kode;      // mis. "3.1"
    public final String judul;     // nama form
    public final String periode;   // "Bulanan" | "Tahunan" | "Harian/Rentang"
    public final SirsBuilder builder;

    public SirsRLDef(String kode, String judul, String periode, SirsBuilder builder) {
        this.kode = kode;
        this.judul = judul;
        this.periode = periode;
        this.builder = builder;
    }

    @Override
    public String toString() {
        return "RL " + kode + " — " + judul + "  [" + periode + "]";
    }
}
