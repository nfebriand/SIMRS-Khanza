package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

/**
 * RL 3.16 — Rekapitulasi Pelayanan Keluarga Berencana (JUKNIS SIRS 6.3).
 * Baris = 8 metode; kolom = Pelayanan KB (Pasca Persalinan/Keguguran/Interval/
 * Total) + Komplikasi/Kegagalan/Efek Samping/Drop Out. Metode 1-4 dari
 * prosedur_pasien ICD-9 (Tubektomi 66.2/66.3, Vasektomi 63.7, Implan 99.23,
 * IUD 69.7); Suntik/Pil/Kondom/MAL tak terderivasi (=0). Pasca Persalinan =
 * no_rawat ada tindakan persalinan (72/73/74) / diagnosis O8x/Z39; Pasca
 * Keguguran = abortus O03-O08; selain itu Interval. 4 kolom terakhir tak
 * dicatat terstruktur di Khanza (=0).
 */
public class Rl316 implements SirsBuilder {

    private static final String[][] MASTER = {
        {"1", "Tubektomi / MOW / Sterilisasi Wanita"},
        {"2", "Vasektomi / MOP / Sterilisasi Pria"},
        {"3", "Implan"},
        {"4", "AKDR / IUD"},
        {"5", "Suntik"},
        {"6", "Pil"},
        {"7", "Kondom"},
        {"8", "MAL (Metode Amenore Laktasi)"},
    };

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "No.", "Jenis Pelayanan KB", "Pasca Persalinan", "Pasca Keguguran", "Interval", "Total",
            "Komplikasi KB", "Kegagalan KB", "Efek Samping", "Drop Out"
        });

        String sql = "SELECT metode,"
                + " SUM(timing='PP') AS pp, SUM(timing='PK') AS pk, SUM(timing='INT') AS itv, COUNT(*) AS total"
                + " FROM ("
                + "   SELECT DISTINCT pp.no_rawat AS no_rawat,"
                + "     CASE WHEN pp.kode LIKE '66.2%' OR pp.kode LIKE '66.3%' THEN 1"
                + "          WHEN pp.kode LIKE '63.7%' THEN 2 WHEN pp.kode LIKE '99.23%' THEN 3"
                + "          WHEN pp.kode LIKE '69.7%' THEN 4 END AS metode,"
                + "     CASE"
                + "       WHEN EXISTS(SELECT 1 FROM prosedur_pasien x WHERE x.no_rawat=pp.no_rawat AND (x.kode LIKE '72%' OR x.kode LIKE '73%' OR x.kode LIKE '74%'))"
                + "         OR EXISTS(SELECT 1 FROM diagnosa_pasien d WHERE d.no_rawat=pp.no_rawat AND (d.kd_penyakit LIKE 'O8%' OR d.kd_penyakit LIKE 'Z39%')) THEN 'PP'"
                + "       WHEN EXISTS(SELECT 1 FROM diagnosa_pasien d WHERE d.no_rawat=pp.no_rawat AND (d.kd_penyakit LIKE 'O03%' OR d.kd_penyakit LIKE 'O04%' OR d.kd_penyakit LIKE 'O05%' OR d.kd_penyakit LIKE 'O06%' OR d.kd_penyakit LIKE 'O07%' OR d.kd_penyakit LIKE 'O08%')) THEN 'PK'"
                + "       ELSE 'INT' END AS timing"
                + "   FROM prosedur_pasien pp JOIN reg_periksa r ON r.no_rawat=pp.no_rawat"
                + "   WHERE r.tgl_registrasi BETWEEN ? AND ?"
                + "     AND (pp.kode LIKE '66.2%' OR pp.kode LIKE '66.3%' OR pp.kode LIKE '63.7%' OR pp.kode LIKE '99.23%' OR pp.kode LIKE '69.7%')"
                + " ) v GROUP BY metode";

        Map<Integer, long[]> map = new HashMap<>(); // metode -> [pp, pk, int, total]
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getInt("metode"), new long[]{
                        rs.getLong("pp"), rs.getLong("pk"), rs.getLong("itv"), rs.getLong("total")});
                }
            }
        }

        long total = 0;
        int no = 0;
        for (String[] row : MASTER) {
            long[] v = map.getOrDefault(Integer.parseInt(row[0]), new long[4]);
            res.add(++no, row[1], v[0], v[1], v[2], v[3], 0, 0, 0, 0);
            total += v[3];
        }
        res.add("", "TOTAL", "", "", "", total, "", "", "", "");
        res.catatan = "8 metode JUKNIS. Metode 1-4 dari prosedur ICD-9; Pasca Persalinan/Keguguran dari "
            + "diagnosis/tindakan pada no_rawat sama. Komplikasi/Kegagalan/Efek Samping/Drop Out & "
            + "Suntik/Pil/Kondom/MAL tak tercatat terstruktur di Khanza (=0).";
        return res;
    }
}
