package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * RL 3.9 — Rekapitulasi Kegiatan Pelayanan Radiologi (bulanan, realtime).
 * Port Rl39Controller.php. Menghitung langsung dari Khanza
 * periksa_radiologi x jns_perawatan_radiologi (join kd_jenis_prw). Tiap baris
 * JUKNIS di-klasifikasi otomatis via pola nama pemeriksaan
 * (UPPER(nm_perawatan) LIKE include ... NOT LIKE exclude); rentang tgl_periksa.
 * Baris 1.1 (Foto tanpa bahan kontras) = sisa (semua kecuali kategori khusus).
 */
public class Rl39 implements SirsBuilder {

    /** {kode, nama, parent, isParent("P"/"")} */
    private static final String[][] MASTER = {
        {"1",   "Radiodiagnostik", "", "P"},
        {"1.1", "Foto tanpa bahan kontras", "1", ""},
        {"1.2", "Foto dengan bahan kontras", "1", ""},
        {"1.3", "Foto dengan rol film", "1", ""},
        {"1.4", "Flouroskopi", "1", ""},
        {"1.5", "Foto Gigi", "1", ""},
        {"1.6", "C.T. Scan", "1", ""},
        {"1.7", "Lymphografi", "1", ""},
        {"1.8", "Angiograpi", "1", ""},
        {"1.9", "Lain-Lain", "1", ""},
        {"2",   "Radioterapi", "", "P"},
        {"2.1", "Radioterapi dengan Linac", "2", ""},
        {"2.2", "Radioterapi dengan Cobalt", "2", ""},
        {"2.3", "Radioterapi dengan Brakhiterapi", "2", ""},
        {"2.4", "Lain-Lain", "2", ""},
        {"3",   "Kedokteran Nuklir", "", "P"},
        {"3.1", "Diagnostik", "3", ""},
        {"3.2", "Therapi", "3", ""},
        {"3.3", "Lain-Lain", "3", ""},
        {"4",   "Imaging/Pencitraan", "", "P"},
        {"4.1", "USG", "4", ""},
        {"4.2", "MRI", "4", ""},
        {"4.3", "Lain-lain", "4", ""},
    };

    /** Pola include/exclude per kode (dicocokkan ke UPPER(nm_perawatan)). */
    private static final String[] KHUSUS_EXCLUDE = {
        "CT %", "CT-%", "%C.T.%", "CTSCAN%",
        "%GIGI%", "DENTAL%", "PANORAMIC%",
        "%FLUOROSC%", "%FLOROSC%",
        "%LYMPHO%", "%ANGIO%",
        "%CONTRAST%", "%KONTRAS%", "IVP%", "BNO IVP%", "%BARIUM%", "%COLON IN LOOP%",
        "USG%", "ULTRASOUND%",
        "MRI%", "MAGNETIC RESONANCE%",
    };

    private static final Map<String, String[][]> ROW_SPECS = new LinkedHashMap<>();
    static {
        ROW_SPECS.put("1.6", new String[][]{{"CT %", "CT-%", "%C.T.%", "CTSCAN%"}, {}});
        ROW_SPECS.put("1.5", new String[][]{{"%GIGI%", "DENTAL%", "PANORAMIC%"}, {}});
        ROW_SPECS.put("1.4", new String[][]{{"%FLUOROSC%", "%FLOROSC%"}, {}});
        ROW_SPECS.put("1.7", new String[][]{{"%LYMPHO%"}, {}});
        ROW_SPECS.put("1.8", new String[][]{{"%ANGIO%"}, {}});
        ROW_SPECS.put("1.2", new String[][]{{"%CONTRAST%", "%KONTRAS%", "IVP%", "BNO IVP%", "%BARIUM%", "%COLON IN LOOP%"}, {}});
        ROW_SPECS.put("4.1", new String[][]{{"USG%", "ULTRASOUND%"}, {}});
        ROW_SPECS.put("4.2", new String[][]{{"MRI%", "MAGNETIC RESONANCE%"}, {}});
        ROW_SPECS.put("1.1", new String[][]{{"%"}, KHUSUS_EXCLUDE});
    }

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "Kode", "Jenis Kegiatan", "Jumlah", "Sumber Klasifikasi"
        });

        int total = 0;
        for (String[] b : MASTER) {
            String kode = b[0], nama = b[1];
            boolean isParent = "P".equals(b[3]);
            String tampilNama = (isParent ? "" : "   ") + nama;
            if (isParent) {
                res.add(kode, tampilNama, "", "");
            } else if (ROW_SPECS.containsKey(kode)) {
                String[][] spec = ROW_SPECS.get(kode);
                String[] inc = spec[0], exc = spec[1];
                int jumlah = classifyCount(k, inc, exc, tgl1, tgl2);
                total += jumlah;
                String sumber = "nm_perawatan LIKE " + inc[0]
                    + (inc.length > 1 ? "/" + inc[1] : "")
                    + (exc.length > 0 ? " (rest)" : "");
                res.add(kode, tampilNama, jumlah, sumber);
            } else {
                res.add(kode, tampilNama, "-", "");
            }
        }
        res.add("99", "TOTAL", total, "");
        return res;
    }

    /** COUNT periksa_radiologi via nm_perawatan LIKE (include OR ... exclude NOT LIKE ...). */
    private int classifyCount(Connection k, String[] includes, String[] excludes,
                              String tgl1, String tgl2) throws Exception {
        StringBuilder incOr = new StringBuilder();
        for (int i = 0; i < includes.length; i++) {
            if (i > 0) incOr.append(" OR ");
            incOr.append("UPPER(m.nm_perawatan) LIKE ?");
        }
        StringBuilder where = new StringBuilder("(").append(incOr).append(")");
        for (int i = 0; i < excludes.length; i++) {
            where.append(" AND UPPER(m.nm_perawatan) NOT LIKE ?");
        }
        String sql = "SELECT COUNT(*) c FROM periksa_radiologi pr "
            + "LEFT JOIN jns_perawatan_radiologi m ON m.kd_jenis_prw=pr.kd_jenis_prw "
            + "WHERE pr.tgl_periksa BETWEEN ? AND ? AND " + where;
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            int idx = 1;
            ps.setString(idx++, tgl1);
            ps.setString(idx++, tgl2);
            for (String p : includes) ps.setString(idx++, p);
            for (String p : excludes) ps.setString(idx++, p);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("c");
            }
        }
        return 0;
    }
}
