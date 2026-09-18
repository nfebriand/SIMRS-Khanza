package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

/**
 * RL 3.5 — Rekapitulasi Kunjungan (JUKNIS SIRS 6.3), bulanan. Port controller
 * web Rl35Controller. Baris = 34 jenis kegiatan baku + 99 TOTAL + 66 Rata-Rata
 * Hari Poliklinik Buka + 77 Rata-Rata Kunjungan per Hari. Kolom = Dalam Kab/Kota
 * (L/P), Luar Kab/Kota (L/P), Total. Poli dipetakan via sirs_rl35_map_poli.
 */
public class Rl35 implements SirsBuilder {

    /** 34 jenis kegiatan baku JUKNIS (urutan resmi). */
    private static final String[] JENIS = {
        "Penyakit Dalam", "Bedah", "Kesehatan Anak (Neonatal)", "Kesehatan Anak (Lainnya)",
        "Obstetri & Ginekologi (Ibu Hamil)", "Obstetri & Ginekologi (Lainnya)", "Keluarga Berencana",
        "Jiwa", "Napza", "Psikologi", "THT", "Mata", "Kulit dan Kelamin", "Gigi & Mulut", "Geriatri",
        "Kardiologi", "Radiologi", "Bedah Orthopedi", "Paru - Paru", "Kanker", "Uronefrologi", "Kusta",
        "Umum", "Rawat Darurat", "Rehabilitasi Medik", "Akupungtur Medik", "Konsultasi Gizi", "Day Care",
        "Medical Check Up", "Bedah Saraf (Stroke)", "Bedah Saraf (Lainnya)", "Saraf (Stroke)",
        "Saraf (Lainnya)", "Lain - Lain"
    };

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "No.", "Jenis Kegiatan", "Dalam L", "Dalam P", "Luar L", "Luar P", "Total Kunjungan"
        });

        // Kabupaten RS dari setting (normalisasi buang prefiks Kab/Kota).
        String kabRs = "";
        try (PreparedStatement ps = k.prepareStatement("SELECT kabupaten FROM setting LIMIT 1");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) kabRs = rs.getString("kabupaten") == null ? "" : rs.getString("kabupaten");
        }
        String kabNorm = kabRs.toUpperCase()
            .replace("KAB.", "").replace("KABUPATEN", "").replace("KOTA", "").replace("KAB", "").trim();
        String kabLike = "%" + kabNorm + "%";

        // Agregasi per (jenis, jk, domisili) — distinct pasien x hari per jenis.
        Map<String, long[]> map = new HashMap<>(); // [dalam_l, dalam_p, luar_l, luar_p]
        String sql = "SELECT jenis, jk, dom, COUNT(DISTINCT no_rkm_medis, tgl) AS cnt FROM ("
            + "  SELECT IFNULL(m.jenis_kunjungan,'Lain - Lain') AS jenis, p.jk AS jk,"
            + "    CASE WHEN UPPER(kab.nm_kab) LIKE ? THEN 'D' ELSE 'L' END AS dom,"
            + "    r.no_rkm_medis AS no_rkm_medis, r.tgl_registrasi AS tgl"
            + "  FROM reg_periksa r"
            + "  JOIN pasien p ON p.no_rkm_medis = r.no_rkm_medis"
            + "  LEFT JOIN kabupaten kab ON kab.kd_kab = p.kd_kab"
            + "  LEFT JOIN sirs_rl35_map_poli m ON m.kd_poli = r.kd_poli"
            + "  WHERE r.tgl_registrasi BETWEEN ? AND ?"
            + ") v GROUP BY jenis, jk, dom";
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            ps.setString(1, kabLike);
            ps.setString(2, tgl1);
            ps.setString(3, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String jenis = rs.getString("jenis");
                    String jk = rs.getString("jk");
                    String dom = rs.getString("dom");
                    long cnt = rs.getLong("cnt");
                    long[] v = map.computeIfAbsent(jenis, x -> new long[4]);
                    int idx = "D".equals(dom) ? ("L".equals(jk) ? 0 : 1) : ("L".equals(jk) ? 2 : 3);
                    v[idx] += cnt;
                }
            }
        }

        long tdl = 0, tdp = 0, tll = 0, tlp = 0, tt = 0;
        for (int i = 0; i < JENIS.length; i++) {
            long[] v = map.getOrDefault(JENIS[i], new long[4]);
            long t = v[0] + v[1] + v[2] + v[3];
            res.add(String.valueOf(i + 1), JENIS[i], v[0], v[1], v[2], v[3], t);
            tdl += v[0]; tdp += v[1]; tll += v[2]; tlp += v[3]; tt += t;
        }
        res.add("99", "TOTAL", tdl, tdp, tll, tlp, tt);

        // Rata-rata hari poliklinik buka = avg(distinct hari kunjungan per poli).
        double rataHari = 0;
        String sqlHari = "SELECT AVG(hari) rata FROM ("
            + "  SELECT kd_poli, COUNT(DISTINCT tgl_registrasi) hari FROM reg_periksa"
            + "  WHERE tgl_registrasi BETWEEN ? AND ? GROUP BY kd_poli) t";
        try (PreparedStatement ps = k.prepareStatement(sqlHari)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) rataHari = rs.getDouble("rata");
            }
        }
        double rataHari1 = Math.round(rataHari * 10.0) / 10.0;
        double rataKunjungan = rataHari1 > 0 ? Math.round((tt / rataHari1) * 10.0) / 10.0 : 0;
        res.add("66", "Rata-Rata Hari Poliklinik Buka", "", "", "", "", rataHari1);
        res.add("77", "Rata-Rata Kunjungan per Hari", "", "", "", "", rataKunjungan);

        res.catatan = "34 jenis kegiatan JUKNIS (pemetaan poli via menu 'RL 3.5 Mapping Poli'). Dalam/Luar "
            + "Kab/Kota dari domisili pasien vs kabupaten RS (" + kabRs + "). 1 pasien beberapa unit 1 hari = 1 kunjungan/jenis.";
        return res;
    }
}
