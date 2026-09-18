package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/**
 * RL 3.13 — Rekapitulasi Pelayanan Rehabilitasi Medik (TAHUNAN, realtime).
 * Port Rl313Controller::rl313/compute. CATATAN: form ini TAHUNAN — param
 * tgl1..tgl2 sudah berupa rentang satu tahun (mis. 2026-01-01..2026-12-31),
 * dipakai langsung. Dihitung realtime dari rawat_jl_dr + rawat_jl_drpr ×
 * jns_perawatan (pattern nm_perawatan LIKE). Baris parent = header (tanpa
 * angka); leaf yang punya pattern diisi hitungan, leaf tanpa pattern = 0.
 * Kolom: Kode / Jenis Tindakan / Jumlah.
 */
public class Rl313 implements SirsBuilder {

    /** {kode, nama, isParent("1"/"0")} — mirror master() simcb. */
    private static final String[][] MASTER = {
        {"1",   "Medis", "1"},
        {"1.1", "Gait Analyzer", "0"},
        {"1.2", "E M G", "0"},
        {"1.3", "Uro Dinamic", "0"},
        {"1.4", "Side Back", "0"},
        {"1.5", "E N Tree", "0"},
        {"1.6", "Spyrometer", "0"},
        {"1.7", "Static Bicycle", "0"},
        {"1.8", "Tread Mill", "0"},
        {"1.9", "Body Platysmograf", "0"},
        {"1.10", "Lain-lain", "0"},
        {"2",   "Fisioterapi", "1"},
        {"2.1", "Latihan Fisik", "0"},
        {"2.2", "Aktinoterapi", "0"},
        {"2.3", "Elektroterapi", "0"},
        {"2.4", "Hidroterapi", "0"},
        {"2.5", "Traksi Lumbal dan Cervical", "0"},
        {"2.6", "Fisioterapi Anak", "0"},
        {"2.7", "Lain-lain", "0"},
        {"3",   "Okupasiterapi", "1"},
        {"3.1", "Snoosien Room", "0"},
        {"3.2", "Sensori Integrasi", "0"},
        {"3.3", "Latihan aktivitas kehidupan sehari-hari", "0"},
        {"3.4", "Proper Body Mekanik", "0"},
        {"3.5", "Pembuatan Alat Lontar dan Adaptasi Alat", "0"},
        {"3.6", "Analisa Persiapan Kerja", "0"},
        {"3.7", "Latihan Relaksasi", "0"},
        {"3.8", "Analisa dan Intervensi, Persepsi, Kognitif, Psikomotorik", "0"},
        {"3.9", "Okupasiterapi Anak", "0"},
        {"3.10", "Lain-lain", "0"},
        {"4",   "Terapi Wicara", "1"},
        {"4.1", "Fungsi Bicara", "0"},
        {"4.2", "Fungsi Bahasa / Laku", "0"},
        {"4.3", "Fungsi Menelan", "0"},
        {"4.4", "Terapi Wicara Anak", "0"},
        {"4.5", "Lain-lain", "0"},
        {"5",   "Psikologi", "1"},
        {"5.1", "Psikologi Anak", "0"},
        {"5.2", "Psikologi Dewasa", "0"},
        {"5.3", "Lain-lain", "0"},
        {"6",   "Sosial Medik", "1"},
        {"6.1", "Evaluasi Lingkungan Rumah", "0"},
        {"6.2", "Evaluasi Ekonomi", "0"},
        {"6.3", "Evaluasi Pekerjaan", "0"},
        {"6.4", "Lain-lain", "0"},
        {"7",   "Ortotik Prostetik", "1"},
        {"7.1", "Pembuatan Alat Bantu", "0"},
        {"7.2", "Pembuatan Alat Anggota Tiruan", "0"},
        {"7.3", "Lain-Lain", "0"},
    };

    /** {kode, includes(|), excludes(|)} — mirror rowSpecs() simcb. */
    private static final String[][] SPECS = {
        {"1.1", "%GAIT%", ""},
        {"1.2", "EMG%|% EMG%|%ELEKTROMYOGRAF%", ""},
        {"1.6", "%SPIROMETR%", ""},
        {"1.8", "%TREADMILL%|%TREAD MILL%", ""},
        {"2.1", "%LATIHAN FISIK%|%LATIHAN BERAT%|%LATIHAN RINGAN%|%LATIHAN SEDANG%|%STRETCHING%", "%GERAK BAHASA%|%ARTIKULASI%"},
        {"2.2", "%INFRARED%|%INFRA RED%|IR %|%AKTINOTERAPI%", ""},
        {"2.3", "%USD%|%SWD%|%TENS%|%ELEKTROTERAPI%|%ELECTRO%|%ULTRASOUND%|%DIATHERM%", ""},
        {"2.4", "%PARAFIN%|%PARAFFIN%|%HIDROTERAPI%|%HYDRO%", ""},
        {"2.5", "%TRAKSI LUMBAL%|%TRAKSI CERVICAL%|%TRAKSI%", "%EKSTRAKSI%"},
        {"2.6", "%FISIOTERAPI ANAK%|%FISIO ANAK%", ""},
        {"2.7", "%NEBULIZER%|%INHALASI%", ""},
        {"4.1", "%TERAPI WICARA%|%FUNGSI BICARA%|%ARTIKULASI%", ""},
        {"4.2", "%FUNGSI BAHASA%|%GERAK BAHASA%", ""},
        {"4.3", "%MENELAN%|%ORAL MOTOR%|%MASSAGE ORAL%", ""},
        {"5.1", "%PSIKOLOG%ANAK%", ""},
        {"5.2", "%PSIKOLOG%", "%ANAK%"},
    };

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{"Kode", "Jenis Tindakan", "Jumlah"});

        // Ambil semua nama tindakan rawat jalan (dr + drpr) + total dalam rentang tahun.
        List<String[]> tindakan = fetchTindakan(k, tgl1, tgl2);

        for (String[] m : MASTER) {
            String kode = m[0], nama = m[1];
            boolean isParent = "1".equals(m[2]);
            if (isParent) {
                res.add(kode, nama, "");
                continue;
            }
            int jumlah = 0;
            String[] spec = findSpec(kode);
            if (spec != null) {
                Pattern[] inc = compileList(spec[1]);
                Pattern[] exc = compileList(spec[2]);
                for (String[] t : tindakan) {
                    if (matchAny(t[0], inc) && !matchAny(t[0], exc)) {
                        jumlah += Integer.parseInt(t[1]);
                    }
                }
            }
            res.add(kode, nama, jumlah);
        }
        return res;
    }

    private static String[] findSpec(String kode) {
        for (String[] s : SPECS) if (s[0].equals(kode)) return s;
        return null;
    }

    /** Gabungan rawat_jl_dr + rawat_jl_drpr × jns_perawatan → {nmUpper, total}. */
    static List<String[]> fetchTindakan(Connection k, String tgl1, String tgl2) throws Exception {
        String sql = "SELECT nm_perawatan, SUM(jml) AS total FROM ("
                + " SELECT m.nm_perawatan AS nm_perawatan, COUNT(*) AS jml"
                + "   FROM rawat_jl_dr rj"
                + "   LEFT JOIN jns_perawatan m ON m.kd_jenis_prw=rj.kd_jenis_prw"
                + "   WHERE rj.tgl_perawatan BETWEEN ? AND ?"
                + "   GROUP BY m.nm_perawatan"
                + " UNION ALL"
                + " SELECT m.nm_perawatan AS nm_perawatan, COUNT(*) AS jml"
                + "   FROM rawat_jl_drpr rj"
                + "   LEFT JOIN jns_perawatan m ON m.kd_jenis_prw=rj.kd_jenis_prw"
                + "   WHERE rj.tgl_perawatan BETWEEN ? AND ?"
                + "   GROUP BY m.nm_perawatan"
                + " ) c GROUP BY nm_perawatan";
        List<String[]> out = new ArrayList<>();
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            ps.setString(3, tgl1);
            ps.setString(4, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String nm = rs.getString("nm_perawatan");
                    if (nm == null) continue;
                    nm = nm.toUpperCase();
                    if (nm.isEmpty()) continue;
                    out.add(new String[]{nm, String.valueOf(rs.getInt("total"))});
                }
            }
        }
        return out;
    }

    static Pattern[] compileList(String joined) {
        if (joined == null || joined.isEmpty()) return new Pattern[0];
        String[] parts = joined.split("\\|");
        Pattern[] out = new Pattern[parts.length];
        for (int i = 0; i < parts.length; i++) out[i] = likeToRegex(parts[i]);
        return out;
    }

    static Pattern likeToRegex(String like) {
        String[] lits = like.toUpperCase().split("%", -1);
        StringBuilder rx = new StringBuilder("^");
        for (int i = 0; i < lits.length; i++) {
            if (i > 0) rx.append(".*");
            if (!lits[i].isEmpty()) rx.append(Pattern.quote(lits[i]));
        }
        rx.append("$");
        return Pattern.compile(rx.toString(), Pattern.DOTALL);
    }

    static boolean matchAny(String hay, Pattern[] pats) {
        for (Pattern p : pats) if (p.matcher(hay).matches()) return true;
        return false;
    }
}
