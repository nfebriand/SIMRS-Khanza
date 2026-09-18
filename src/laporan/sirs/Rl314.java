package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/**
 * RL 3.14 — Rekapitulasi Pelayanan Khusus (bulanan, realtime).
 * Port Rl314Controller::rl314/compute. Dihitung realtime dari gabungan 4 tabel
 * (rawat_jl_dr + rawat_jl_drpr × jns_perawatan, rawat_inap_dr + rawat_inap_drpr
 * × jns_perawatan_inap), klasifikasi lewat pattern nm_perawatan LIKE. Baris
 * parent Homecare (16) menampilkan hasil pattern Homecare/Kunjungan Rumah dan
 * TIDAK dijumlahkan ke TOTAL (hindari duplikasi dgn sub 16.x). Baris tanpa
 * pattern (sub 16.x, Lain-Lain) = 0.
 * Kolom: Kode / Jenis Kegiatan / Jumlah.
 */
public class Rl314 implements SirsBuilder {

    /** {kode, nama, isParent("1"/"0")} — mirror master() simcb. */
    private static final String[][] MASTER = {
        {"1",    "Elektro Kardiographi (EKG)",                          "0"},
        {"2",    "Elektro Myographi (EMG)",                             "0"},
        {"3",    "Echo Cardiographi (ECG)",                             "0"},
        {"4",    "Endoskopi (semua bentuk)",                            "0"},
        {"5",    "Hemodialisa",                                         "0"},
        {"6",    "Densometri Tulang",                                   "0"},
        {"7",    "Pungsi",                                              "0"},
        {"8",    "Spirometri",                                          "0"},
        {"9",    "Tes Kulit/Alergi/Histamin",                           "0"},
        {"10",   "Topometri",                                           "0"},
        {"11",   "Akupunktur Medik",                                    "0"},
        {"12",   "Akupunktur Tradisional",                              "0"},
        {"13",   "Akupressur",                                          "0"},
        {"14",   "Herbal/Jamu",                                         "0"},
        {"15",   "Pijat Baduta",                                        "0"},
        {"16",   "Kunjungan Rumah (Homecare)",                          "1"},
        {"16.1", "Kunjungan Rumah (Homecare) Non Lansia",               "0"},
        {"16.2", "Rehabilitasi Medis Lansia",                           "0"},
        {"16.3", "Pemeriksaan Medis Umum dan Spesialis Bagi Lansia",    "0"},
        {"16.4", "Asuhan dan/atau Tindakan Keperawatan Bagi Lansia",    "0"},
        {"16.5", "Kunjungan Rumah (Homecare) Lansia Lainnya",           "0"},
        {"17",   "Tindak lanjut lesi pra Kanker Leher Rahim",           "0"},
        {"18",   "Lain-Lain",                                           "0"},
    };

    /** {kode, includes(|), excludes(|)} — mirror rowSpecs() simcb. */
    private static final String[][] SPECS = {
        {"1",  "%EKG%|%ELEKTROKARDIO%", ""},
        {"2",  "EMG%|% EMG%|%ELEKTROMYOGRAF%", ""},
        {"3",  "%ECHOCARDIO%|%ECG %|%ECHO %|%ECHO%JANTUNG%|USG JANTUNG%", ""},
        {"4",  "%ENDOSCOP%|%ENDOSKOP%|%NASOFARYNGO%", ""},
        {"5",  "%HEMODIA%|%CUCI DARAH%", ""},
        {"6",  "%DENSITOMET%|%BMD%|%BONE DENSIT%", ""},
        {"7",  "%PUNGSI %|%PUNKSI%|% LP %|LUMBAR PUNGSI%|%PLEURAL%|%ASCITES%", "%EKSTRAKSI%"},
        {"8",  "%SPIROMETR%", ""},
        {"9",  "%TES KULIT%|%SKIN TEST%|%ALERGI%", ""},
        {"10", "%TOPOMETR%", ""},
        {"11", "%AKUPUNK%MEDIK%|%ACUPUNCTURE%", ""},
        {"12", "%AKUPUNK%TRADIS%", ""},
        {"13", "%AKUPRES%", ""},
        {"14", "%HERBAL%|%JAMU%", ""},
        {"15", "%PIJAT BADUTA%|%BADUTA%", ""},
        {"16", "%HOMECARE%|%KUNJUNGAN RUMAH%", ""},
        {"17", "IVA%|% IVA%|%PAP SMEAR%|%PAPSMEAR%|%KRIOTERAPI%", ""},
    };

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{"Kode", "Jenis Kegiatan", "Jumlah"});

        List<String[]> tindakan = fetchTindakan(k, tgl1, tgl2);

        for (String[] m : MASTER) {
            String kode = m[0], nama = m[1];
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
            // parent 16 menampilkan angka (info) tetapi konvensinya tidak ikut TOTAL.
            res.add(kode, nama, jumlah);
        }
        return res;
    }

    private static String[] findSpec(String kode) {
        for (String[] s : SPECS) if (s[0].equals(kode)) return s;
        return null;
    }

    /** Gabungan 4 tabel (rawat_jl_dr/drpr × jns_perawatan, rawat_inap_dr/drpr × jns_perawatan_inap). */
    static List<String[]> fetchTindakan(Connection k, String tgl1, String tgl2) throws Exception {
        String sql = "SELECT nm_perawatan, SUM(jml) AS total FROM ("
                + " SELECT m.nm_perawatan AS nm_perawatan, COUNT(*) AS jml"
                + "   FROM rawat_jl_dr rj"
                + "   LEFT JOIN jns_perawatan m ON m.kd_jenis_prw=rj.kd_jenis_prw"
                + "   WHERE rj.tgl_perawatan BETWEEN ? AND ? GROUP BY m.nm_perawatan"
                + " UNION ALL"
                + " SELECT m.nm_perawatan AS nm_perawatan, COUNT(*) AS jml"
                + "   FROM rawat_jl_drpr rj"
                + "   LEFT JOIN jns_perawatan m ON m.kd_jenis_prw=rj.kd_jenis_prw"
                + "   WHERE rj.tgl_perawatan BETWEEN ? AND ? GROUP BY m.nm_perawatan"
                + " UNION ALL"
                + " SELECT m.nm_perawatan AS nm_perawatan, COUNT(*) AS jml"
                + "   FROM rawat_inap_dr rj"
                + "   LEFT JOIN jns_perawatan_inap m ON m.kd_jenis_prw=rj.kd_jenis_prw"
                + "   WHERE rj.tgl_perawatan BETWEEN ? AND ? GROUP BY m.nm_perawatan"
                + " UNION ALL"
                + " SELECT m.nm_perawatan AS nm_perawatan, COUNT(*) AS jml"
                + "   FROM rawat_inap_drpr rj"
                + "   LEFT JOIN jns_perawatan_inap m ON m.kd_jenis_prw=rj.kd_jenis_prw"
                + "   WHERE rj.tgl_perawatan BETWEEN ? AND ? GROUP BY m.nm_perawatan"
                + " ) c GROUP BY nm_perawatan";
        List<String[]> out = new ArrayList<>();
        try (PreparedStatement ps = k.prepareStatement(sql)) {
            ps.setString(1, tgl1); ps.setString(2, tgl2);
            ps.setString(3, tgl1); ps.setString(4, tgl2);
            ps.setString(5, tgl1); ps.setString(6, tgl2);
            ps.setString(7, tgl1); ps.setString(8, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String nm = rs.getString("nm_perawatan");
                    if (nm == null) continue;
                    nm = nm.toUpperCase();
                    if (nm.isEmpty()) continue;
                    // Buang pasangan billing "Jasa Pelayanan ..." agar tak dobel hitung.
                    if (nm.startsWith("JASA PELAYANAN")) continue;
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
