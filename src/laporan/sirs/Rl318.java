package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * RL 3.18 — Farmasi RS Resep (Tahunan, realtime). Port Rl318Controller.
 * Jumlah item R/ (resep) per golongan obat × lokasi layanan dari
 * resep_obat × resep_dokter × databarang × kategori_barang × reg_periksa.
 * Lokasi: Ranap = resep_obat.status='ranap'; IGD = reg_periksa.kd_poli IN
 * ('IGD','IGDK'); Ralan = sisanya. Klasifikasi: Generik / Non Generik / Lainnya.
 * Rentang tgl1..tgl2 dipakai pada resep_obat.tgl_perawatan.
 */
public class Rl318 implements SirsBuilder {

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "No.", "Golongan Obat", "Rawat Jalan", "IGD", "Rawat Inap", "Total"
        });

        String sql = "SELECT "
                + "CASE WHEN ro.status = 'ranap' THEN 'Ranap' "
                + "     WHEN rp.kd_poli IN ('IGD','IGDK') THEN 'IGD' "
                + "     ELSE 'Ralan' END AS lokasi, "
                + "kb.nama AS kategori, "
                + "CAST(COUNT(*) AS SIGNED) AS jml "
                + "FROM resep_obat ro "
                + "JOIN resep_dokter rd ON rd.no_resep = ro.no_resep "
                + "JOIN databarang db ON db.kode_brng = rd.kode_brng "
                + "LEFT JOIN kategori_barang kb ON kb.kode = db.kode_kategori "
                + "LEFT JOIN reg_periksa rp ON rp.no_rawat = ro.no_rawat "
                + "WHERE ro.tgl_perawatan BETWEEN ? AND ? "
                + "GROUP BY lokasi, kategori";

        // bucket => [ralan, igd, ranap]
        String[] bucketNames = {
            "Obat Generik", "Obat Non Generik", "Obat Lainnya / Tanpa Kategori"
        };
        Map<String, int[]> buckets = new LinkedHashMap<>();
        for (String b : bucketNames) buckets.put(b, new int[]{0, 0, 0});

        try (PreparedStatement ps = k.prepareStatement(sql)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String kat = rs.getString("kategori");
                    kat = (kat == null) ? "" : kat.toUpperCase();
                    String bucket = kat.equals("GENERIK") ? "Obat Generik"
                            : (kat.equals("NON GENERIK") ? "Obat Non Generik"
                            : "Obat Lainnya / Tanpa Kategori");
                    String lokasi = rs.getString("lokasi");
                    int col;
                    if ("IGD".equals(lokasi)) col = 1;
                    else if ("Ranap".equals(lokasi)) col = 2;
                    else col = 0; // Ralan
                    buckets.get(bucket)[col] += rs.getInt("jml");
                }
            }
        }

        int tRalan = 0, tIgd = 0, tRanap = 0, tTotal = 0;
        int no = 0;
        for (Map.Entry<String, int[]> e : buckets.entrySet()) {
            int[] b = e.getValue();
            int sum = b[0] + b[1] + b[2];
            res.add(++no, e.getKey(), b[0], b[1], b[2], sum);
            tRalan += b[0];
            tIgd += b[1];
            tRanap += b[2];
            tTotal += sum;
        }
        res.add("", "TOTAL", tRalan, tIgd, tRanap, tTotal);
        return res;
    }
}
