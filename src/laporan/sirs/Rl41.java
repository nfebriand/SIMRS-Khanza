package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * RL 4.1 — Kompilasi Penyakit/Morbiditas Pasien Rawat Inap. Port Rl41Controller.
 * Matriks diagnosa utama (diagnosa_pasien Ranap prioritas=1) ICD-10 3-digit ×
 * 25 kelompok umur × jenis kelamin (+ kolom keluar mati) atas pasien Ranap yang
 * KELUAR (exclude Pindah Kamar) dalam periode ki.tgl_keluar. Umur diklasifikasi
 * via TIMESTAMPDIFF (tgl_lahir vs tgl_keluar) ke index 0..24 seperti controller.
 * Urut Total desc, tie kode asc. Susunan kolom mengikuti view rl41.blade.php.
 */
public class Rl41 implements SirsBuilder {

    /** 25 label kelompok umur per JUKNIS SIRS 6.3 (index 0..24). */
    private static final String[] UMUR_LABELS = {
        "<1 jam", "1-23 jam", "1-7 hari", "8-28 hari", "29 hari-<3 bln",
        "3-<6 bln", "6-11 bln", "1-4 th", "5-9 th", "10-14 th",
        "15-19 th", "20-24 th", "25-29 th", "30-34 th", "35-39 th",
        "40-44 th", "45-49 th", "50-54 th", "55-59 th", "60-64 th",
        "65-69 th", "70-74 th", "75-79 th", "80-84 th", ">=85 th",
    };

    /** Akumulator per ICD-10 3-digit. */
    private static final class Row {
        String kd;
        String nm = "";
        int[] cellsL = new int[25];
        int[] cellsP = new int[25];
        int matiL, matiP, totalL, totalP, total, totalMati;
    }

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        // Kolom: No. / Kode ICD-10 / Nama, lalu 25 × (umur L, umur P),
        // lalu Total L / Total P / Total, lalu Mati L / Mati P / Total Mati.
        List<String> kolom = new ArrayList<>();
        kolom.add("No.");
        kolom.add("Kode ICD-10");
        kolom.add("Nama Penyakit");
        for (String l : UMUR_LABELS) {
            kolom.add(l + " L");
            kolom.add(l + " P");
        }
        kolom.add("Total L");
        kolom.add("Total P");
        kolom.add("Total");
        kolom.add("Mati L");
        kolom.add("Mati P");
        kolom.add("Total Mati");
        SirsResult res = new SirsResult(kolom.toArray(new String[0]));

        String umurCase = umurCase();
        String sql = "SELECT LEFT(dp.kd_penyakit,3) AS kd_penyakit, "
                + "MAX(pk.nm_penyakit) AS nm_penyakit, "
                + "CAST(" + umurCase + " AS SIGNED) AS umur_idx, "
                + "p.jk AS jk, "
                + "CAST(CASE WHEN UPPER(ki.stts_pulang)='MENINGGAL' THEN 1 ELSE 0 END AS SIGNED) AS mati, "
                + "CAST(COUNT(DISTINCT ki.no_rawat) AS SIGNED) AS jml "
                + "FROM kamar_inap ki "
                + "JOIN reg_periksa r ON r.no_rawat=ki.no_rawat "
                + "JOIN pasien p ON p.no_rkm_medis=r.no_rkm_medis "
                + "JOIN diagnosa_pasien dp ON dp.no_rawat=ki.no_rawat AND dp.status='Ranap' AND dp.prioritas=1 "
                + "LEFT JOIN penyakit pk ON pk.kd_penyakit=dp.kd_penyakit "
                + "WHERE ki.tgl_keluar BETWEEN ? AND ? "
                + "  AND ki.stts_pulang!='' "
                + "  AND UPPER(ki.stts_pulang)!='PINDAH KAMAR' "
                + "GROUP BY kd_penyakit, umur_idx, jk, mati";

        Map<String, Row> map = new LinkedHashMap<>();
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String kd = rs.getString("kd_penyakit");
                    if (kd == null) continue;
                    String nm = rs.getString("nm_penyakit");
                    Row row = map.get(kd);
                    if (row == null) {
                        row = new Row();
                        row.kd = kd;
                        row.nm = (nm == null) ? "" : nm;
                        map.put(kd, row);
                    }
                    if (row.nm.isEmpty() && nm != null && !nm.isEmpty()) row.nm = nm;

                    int idx = Math.min(rs.getInt("umur_idx"), 24);
                    if (idx < 0) idx = 0;
                    int jml = rs.getInt("jml");
                    int mati = rs.getInt("mati");
                    String jk = rs.getString("jk");
                    if ("L".equals(jk)) {
                        row.cellsL[idx] += jml;
                        row.totalL += jml;
                        if (mati == 1) row.matiL += jml;
                    } else if ("P".equals(jk)) {
                        row.cellsP[idx] += jml;
                        row.totalP += jml;
                        if (mati == 1) row.matiP += jml;
                    }
                    row.total += jml;
                    if (mati == 1) row.totalMati += jml;
                }
            }
        }

        List<Row> rows = new ArrayList<>(map.values());
        for (Row r : rows) {
            if (r.nm.isEmpty()) r.nm = "-";
        }
        rows.sort((a, b) -> {
            if (b.total != a.total) return Integer.compare(b.total, a.total);
            return a.kd.compareTo(b.kd);
        });

        int no = 0;
        for (Row r : rows) {
            List<Object> line = new ArrayList<>();
            line.add(++no);
            line.add(r.kd);
            line.add(r.nm);
            for (int i = 0; i < 25; i++) {
                line.add(r.cellsL[i]);
                line.add(r.cellsP[i]);
            }
            line.add(r.totalL);
            line.add(r.totalP);
            line.add(r.total);
            line.add(r.matiL);
            line.add(r.matiP);
            line.add(r.totalMati);
            res.add(line.toArray());
        }
        return res;
    }

    /** CASE SQL klasifikasi umur (tgl_lahir vs tgl_keluar) → index 0..24. */
    private String umurCase() {
        String tl = "p.tgl_lahir";
        String ref = "ki.tgl_keluar";
        return "CASE "
                + "  WHEN TIMESTAMPDIFF(HOUR, " + tl + ", " + ref + ") < 1 THEN 0 "
                + "  WHEN TIMESTAMPDIFF(DAY, " + tl + ", " + ref + ") < 1 THEN 1 "
                + "  WHEN TIMESTAMPDIFF(DAY, " + tl + ", " + ref + ") <= 7 THEN 2 "
                + "  WHEN TIMESTAMPDIFF(DAY, " + tl + ", " + ref + ") <= 28 THEN 3 "
                + "  WHEN TIMESTAMPDIFF(MONTH, " + tl + ", " + ref + ") < 3 THEN 4 "
                + "  WHEN TIMESTAMPDIFF(MONTH, " + tl + ", " + ref + ") < 6 THEN 5 "
                + "  WHEN TIMESTAMPDIFF(MONTH, " + tl + ", " + ref + ") < 12 THEN 6 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 5  THEN 7 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 10 THEN 8 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 15 THEN 9 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 20 THEN 10 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 25 THEN 11 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 30 THEN 12 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 35 THEN 13 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 40 THEN 14 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 45 THEN 15 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 50 THEN 16 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 55 THEN 17 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 60 THEN 18 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 65 THEN 19 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 70 THEN 20 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 75 THEN 21 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 80 THEN 22 "
                + "  WHEN TIMESTAMPDIFF(YEAR, " + tl + ", " + ref + ") < 85 THEN 23 "
                + "  ELSE 24 "
                + "END";
    }
}
