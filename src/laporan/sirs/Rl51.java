package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * RL 5.1 — Kompilasi Morbiditas Pasien Rawat Jalan (bulanan, realtime).
 * Port controller web Rl5Controller::matriks / rl51.
 *
 * Basis = diagnosa utama rawat jalan (diagnosa_pasien status='Ralan',
 * prioritas=1) per ICD-10 3-digit, dipecah 25 kelompok umur (JUKNIS SIRS 6.3)
 * x jenis kelamin. Kasus baru = status_penyakit='Baru'. Umur dihitung dari
 * pasien.tgl_lahir sampai reg_periksa.tgl_registrasi.
 *
 * Matriks: kolom Baru L/P per kelompok umur, lalu Total Baru (L/P/Tot) dan
 * Total Kunjungan (L/P/Tot). Urut Total Kunjungan desc; tie -&gt; kode asc.
 */
public class Rl51 implements SirsBuilder {

    /** 25 label kelompok umur (index 0..24), persis Rl5Controller::UMUR_LABELS. */
    static final String[] UMUR_LABELS = {
        "<1 jam", "1-23 jam", "1-7 hari", "8-28 hari", "29 hari-<3 bln",
        "3-<6 bln", "6-11 bln", "1-4 th", "5-9 th", "10-14 th",
        "15-19 th", "20-24 th", "25-29 th", "30-34 th", "35-39 th",
        "40-44 th", "45-49 th", "50-54 th", "55-59 th", "60-64 th",
        "65-69 th", "70-74 th", "75-79 th", "80-84 th", ">=85 th"
    };

    /** Satu baris agregasi ICD-10 3-digit (dipakai juga RL 5.2/5.3). */
    static final class Agg {
        String kd;
        String nm = "";
        final int[] baruL = new int[25];
        final int[] baruP = new int[25];
        int totalBaruL, totalBaruP, totalBaru;
        int kunjunganL, kunjunganP, kunjunganTotal;
    }

    /** CASE klasifikasi umur -> index 0..24 (persis Rl5Controller::rl4_umur_case). */
    private static final String UMUR_CASE =
        "CASE "
        + "WHEN TIMESTAMPDIFF(HOUR, p.tgl_lahir, r.tgl_registrasi) < 1 THEN 0 "
        + "WHEN TIMESTAMPDIFF(DAY, p.tgl_lahir, r.tgl_registrasi) < 1 THEN 1 "
        + "WHEN TIMESTAMPDIFF(DAY, p.tgl_lahir, r.tgl_registrasi) <= 7 THEN 2 "
        + "WHEN TIMESTAMPDIFF(DAY, p.tgl_lahir, r.tgl_registrasi) <= 28 THEN 3 "
        + "WHEN TIMESTAMPDIFF(MONTH, p.tgl_lahir, r.tgl_registrasi) < 3 THEN 4 "
        + "WHEN TIMESTAMPDIFF(MONTH, p.tgl_lahir, r.tgl_registrasi) < 6 THEN 5 "
        + "WHEN TIMESTAMPDIFF(MONTH, p.tgl_lahir, r.tgl_registrasi) < 12 THEN 6 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 5  THEN 7 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 10 THEN 8 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 15 THEN 9 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 20 THEN 10 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 25 THEN 11 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 30 THEN 12 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 35 THEN 13 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 40 THEN 14 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 45 THEN 15 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 50 THEN 16 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 55 THEN 17 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 60 THEN 18 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 65 THEN 19 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 70 THEN 20 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 75 THEN 21 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 80 THEN 22 "
        + "WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, r.tgl_registrasi) < 85 THEN 23 "
        + "ELSE 24 END";

    /**
     * Basis agregasi RL 5.1 (juga dipakai RL 5.2/5.3). Belum diurut/difilter.
     * Meniru Rl5Controller::matriks: GROUP BY kd, umur_idx, jk lalu pivot di Java.
     */
    static List<Agg> matriks(Connection k, String tgl1, String tgl2) throws Exception {
        String sql =
            "SELECT LEFT(dp.kd_penyakit,3) AS kd, "
            + "MAX(pk.nm_penyakit) AS nm, "
            + "CAST(" + UMUR_CASE + " AS SIGNED) AS umur_idx, "
            + "p.jk AS jk, "
            + "CAST(SUM(CASE WHEN dp.status_penyakit='Baru' THEN 1 ELSE 0 END) AS SIGNED) AS baru, "
            + "CAST(COUNT(*) AS SIGNED) AS kunjungan "
            + "FROM diagnosa_pasien dp "
            + "JOIN reg_periksa r ON r.no_rawat=dp.no_rawat "
            + "JOIN pasien p ON p.no_rkm_medis=r.no_rkm_medis "
            + "LEFT JOIN penyakit pk ON pk.kd_penyakit=dp.kd_penyakit "
            + "WHERE r.tgl_registrasi BETWEEN ? AND ? "
            + "AND dp.status='Ralan' AND dp.prioritas=1 "
            + "GROUP BY kd, umur_idx, jk";

        Map<String, Agg> map = new LinkedHashMap<>();
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String kd = rs.getString("kd");
                    if (kd == null) continue;
                    kd = kd.toUpperCase();
                    String nm = rs.getString("nm");

                    Agg a = map.get(kd);
                    if (a == null) {
                        a = new Agg();
                        a.kd = kd;
                        a.nm = (nm == null) ? "" : nm;
                        map.put(kd, a);
                    }
                    if (a.nm.isEmpty() && nm != null && !nm.isEmpty()) a.nm = nm;

                    int idx = rs.getInt("umur_idx");
                    if (idx < 0) idx = 0;
                    if (idx > 24) idx = 24;
                    int baru = rs.getInt("baru");
                    int kunj = rs.getInt("kunjungan");
                    String jk = rs.getString("jk");

                    if ("L".equals(jk)) {
                        a.baruL[idx] += baru;
                        a.totalBaruL += baru;
                        a.kunjunganL += kunj;
                    } else if ("P".equals(jk)) {
                        a.baruP[idx] += baru;
                        a.totalBaruP += baru;
                        a.kunjunganP += kunj;
                    }
                    a.totalBaru += baru;
                    a.kunjunganTotal += kunj;
                }
            }
        }

        List<Agg> rows = new ArrayList<>(map.values());
        for (Agg a : rows) if (a.nm.isEmpty()) a.nm = "-";
        // Urut Total Kunjungan desc; tie -> kode asc (persis usort matriks()).
        rows.sort(Comparator
            .comparingInt((Agg a) -> a.kunjunganTotal).reversed()
            .thenComparing(a -> a.kd));
        return rows;
    }

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        String[] kolom = new String[3 + 25 * 2 + 6];
        int c = 0;
        kolom[c++] = "No.";
        kolom[c++] = "Kode ICD-10";
        kolom[c++] = "Nama Penyakit";
        for (String l : UMUR_LABELS) {
            kolom[c++] = l + " L";
            kolom[c++] = l + " P";
        }
        kolom[c++] = "Baru L";
        kolom[c++] = "Baru P";
        kolom[c++] = "Total Baru";
        kolom[c++] = "Kunjungan L";
        kolom[c++] = "Kunjungan P";
        kolom[c++] = "Total Kunjungan";

        SirsResult res = new SirsResult(kolom);
        List<Agg> rows = matriks(k, tgl1, tgl2);
        int no = 0;
        for (Agg a : rows) {
            Object[] row = new Object[kolom.length];
            int j = 0;
            row[j++] = ++no;
            row[j++] = a.kd;
            row[j++] = a.nm;
            for (int u = 0; u < 25; u++) {
                row[j++] = a.baruL[u];
                row[j++] = a.baruP[u];
            }
            row[j++] = a.totalBaruL;
            row[j++] = a.totalBaruP;
            row[j++] = a.totalBaru;
            row[j++] = a.kunjunganL;
            row[j++] = a.kunjunganP;
            row[j++] = a.kunjunganTotal;
            res.rows.add(row);
        }
        return res;
    }
}
