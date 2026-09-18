package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * RL 3.15 — Rekapitulasi Pelayanan Kesehatan Jiwa (JUKNIS SIRS 6.3).
 * Baris = 8 jenis kegiatan baku; kolom Laki-laki/Perempuan/Jumlah. Khanza tak
 * mencatat jenis kegiatan jiwa (psikoterapi/konseling/elektro medik) secara
 * terstruktur; kunjungan berdiagnosis jiwa (ICD-10 F) dihitung sebagai
 * "Pemeriksaan Psikiatri" (rule 4). Baris 2-8 = 0.
 */
public class Rl315 implements SirsBuilder {

    private static final String[] KEGIATAN = {
        "Pemeriksaan Psikiatri", "Penatalaksanaan Medikamentosa", "Psikoterapi", "Konseling",
        "Elektro Medik", "Terapi Perilaku", "Rehabilitasi Medik Psikiatrik", "Assessment",
    };

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "No.", "Jenis Kegiatan", "Laki-laki", "Perempuan", "Jumlah"
        });

        int lk = 0, pr = 0;
        String sql = "SELECT SUM(p.jk='L') AS lk, SUM(p.jk='P') AS pr FROM ("
                + "  SELECT DISTINCT dp.no_rawat AS no_rawat"
                + "  FROM diagnosa_pasien dp JOIN reg_periksa r ON r.no_rawat=dp.no_rawat"
                + "  WHERE r.tgl_registrasi BETWEEN ? AND ? AND dp.kd_penyakit LIKE 'F%'"
                + " ) v"
                + " JOIN reg_periksa r ON r.no_rawat=v.no_rawat"
                + " JOIN pasien p ON p.no_rkm_medis=r.no_rkm_medis";
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) { lk = rs.getInt("lk"); pr = rs.getInt("pr"); }
            }
        }

        for (int i = 0; i < KEGIATAN.length; i++) {
            int l = i == 0 ? lk : 0, p = i == 0 ? pr : 0;
            res.add(i + 1, KEGIATAN[i], l, p, l + p);
        }
        res.add("", "TOTAL", lk, pr, lk + pr);
        res.catatan = "8 jenis kegiatan JUKNIS. Kunjungan berdiagnosis jiwa (ICD-10 F) dihitung sebagai "
            + "Pemeriksaan Psikiatri; jenis kegiatan lain tak tercatat terstruktur di Khanza (=0).";
        return res;
    }
}
