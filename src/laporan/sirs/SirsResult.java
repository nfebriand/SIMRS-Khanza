package laporan.sirs;

import java.util.ArrayList;
import java.util.List;

/**
 * Hasil satu formulir SIRS RL: definisi kolom + baris data siap tampil.
 * Setiap builder mengembalikan objek ini agar tiap form men-deskripsikan
 * kolomnya sendiri (mendukung form matriks berkolom banyak sekalipun).
 */
public final class SirsResult {

    /** Judul kolom tabel (termasuk kolom No. bila diinginkan builder). */
    public final String[] kolom;

    /** Baris data; tiap Object[] panjangnya = kolom.length. */
    public final List<Object[]> rows;

    /** Catatan/keterangan opsional (mis. rentang ideal), ditampilkan di atas tabel. */
    public String catatan = "";

    public SirsResult(String[] kolom) {
        this.kolom = kolom;
        this.rows = new ArrayList<>();
    }

    public SirsResult(String[] kolom, List<Object[]> rows) {
        this.kolom = kolom;
        this.rows = rows;
    }

    public void add(Object... nilai) {
        rows.add(nilai);
    }
}
