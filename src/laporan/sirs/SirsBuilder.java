package laporan.sirs;

import java.sql.Connection;

/**
 * Kontrak satu formulir SIRS RL 6.3 versi Khanza (realtime dari DB Khanza).
 * Implementasi menerjemahkan logika controller web Trimitra (simrs-dt-trimitra)
 * ke JDBC. Rentang tanggal seragam: tgl1..tgl2 (format yyyy-MM-dd).
 * Form bulanan/tahunan cukup memakai rentang tanggal penuh bulan/tahun.
 */
public interface SirsBuilder {

    /**
     * @param k    koneksi DB Khanza (jangan ditutup; milik pemanggil)
     * @param tgl1 tanggal awal (yyyy-MM-dd)
     * @param tgl2 tanggal akhir (yyyy-MM-dd)
     * @return kolom + baris siap tampil
     * @throws Exception dibiarkan naik agar dialog menampilkan pesan
     */
    SirsResult build(Connection k, String tgl1, String tgl2) throws Exception;
}
