package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * RL 3.17 — Farmasi RS Pengadaan Obat (Tahunan, realtime). Port Rl317Controller.
 * Breakdown obat aktif (databarang.status='1') per kategori Generik / Non Generik
 * / Tanpa Kategori, exclude golongan Alkes/BMHP/Suplemen/Jamu/Herbal. Kolom
 * "Jumlah Item" & "Tersedia" sama karena Khanza tak menyimpan snapshot stok item.
 * Tidak bergantung rentang tanggal (snapshot master barang saat ini).
 */
public class Rl317 implements SirsBuilder {

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "No.", "Golongan Obat", "Jumlah Item Obat", "Jumlah Item Tersedia di RS"
        });

        String sql = "SELECT "
                + "CAST(SUM(kb.nama = 'GENERIK') AS SIGNED) generik, "
                + "CAST(SUM(kb.nama = 'NON GENERIK') AS SIGNED) non_generik, "
                + "CAST(SUM(kb.nama IS NULL OR kb.nama NOT IN ('GENERIK','NON GENERIK')) AS SIGNED) tanpa, "
                + "COUNT(*) total "
                + "FROM databarang db "
                + "LEFT JOIN kategori_barang kb ON kb.kode = db.kode_kategori "
                + "LEFT JOIN golongan_barang g ON g.kode = db.kode_golongan "
                + "WHERE db.status = '1' "
                + "  AND (g.nama IS NULL OR g.nama NOT IN ('ALAT KESEHATAN','BMHP','SUPLEMEN MAKANAN','JAMU','HERBAL'))";

        int generik = 0, nonGenerik = 0, tanpa = 0, total = 0;
        try (PreparedStatement ps = k.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                generik = rs.getInt("generik");
                nonGenerik = rs.getInt("non_generik");
                tanpa = rs.getInt("tanpa");
                total = rs.getInt("total");
            }
        }

        res.add(1, "Obat Generik", generik, generik);
        res.add(2, "Obat Non Generik", nonGenerik, nonGenerik);
        res.add(3, "Obat Tanpa Kategori Generik/Non-Generik", tanpa, tanpa);
        res.add("", "TOTAL", total, total);
        return res;
    }
}
