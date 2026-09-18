package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/**
 * RL 3.11 — Rekapitulasi Pelayanan Gigi & Mulut (Bulanan, realtime).
 * Port Rl311Controller (get_rl311). Hitung langsung dari rawat_jl_dr +
 * rawat_jl_drpr × jns_perawatan, filter reg_periksa.kd_poli='GIG'. Semua
 * nama tindakan digabung per nama, lalu tiap dari 16 jenis kegiatan JUKNIS
 * diklasifikasi otomatis dari nama tindakan (pola include/exclude LIKE).
 * Sebuah tindakan bisa cocok >1 baris (pola independen).
 * Kolom: No. / Kode / Jenis Kegiatan / Jumlah.
 */
public class Rl311 implements SirsBuilder {

    /** {kode, nama, includes(| dipisah), excludes(| dipisah)} — mirror SPECS simcb. */
    private static final String[][] SPECS = {
        {"1",  "Tumpatan Gigi Tetap",     "%TAMBALAN%|%KOMPOSIT%|%COMPOSITE%|TUMPATAN%|%GLASS IONOMER%|%RMGI%|%AMALGAM%", "%SEMENTARA%|%SULUNG%|%SUSU%|%ANAK%|%DESIDUI%"},
        {"2",  "Tumpatan Gigi Sulung",    "%TUMPATAN%SULUNG%|%TAMBALAN%SULUNG%|%TAMBALAN%ANAK%|%TAMBALAN%DESIDUI%",    ""},
        {"3",  "Pengobatan Pulpa",        "%PULPA%|%PULPEC%|%PULPOT%|%ENDODON%|%PULP CAP%|ROOT CANAL%|RCT%|%CA(OH)2%|%MUMIFIKASI%", ""},
        {"4",  "Pencabutan Gigi Tetap",   "%EKSTRAKSI GIGI TETAP%|%EXO DEWASA%|%EXODONTIA%|%EXTRACTION%",              "%SULUNG%|%SUSU%|%ANAK%|%DESIDUI%"},
        {"5",  "Pencabutan Gigi Sulung",  "%EKSTRAKSI GIGI SULUNG%|%EKSTRAKSI GIGI SUSU%|%EXO ANAK%|%EXO %DESIDUI%|%DESIDUI%", ""},
        {"6",  "Pengobatan Periodontal",  "%PERIODONTAL%|%KURETAS%|%CURETAGE%|%CURRETAGE%|%CURETTAGE%|%ROOT PLAN%",    ""},
        {"7",  "Pengobatan Abses",        "%ABSES%|%INSISI%|%DRAINASE%",                                              ""},
        {"8",  "Pembersihan Karang Gigi", "%SKELING%|%SCALING%|%SCALLING%|%KARANG%",                                  ""},
        {"9",  "Prothese Lengkap",        "%GIGI TIRUAN PENUH%|%PROTHESE PENUH%|%GT LENGKAP%|%GIGI TIRUAN LENGKAP%",  ""},
        {"10", "Prothese Sebagian",       "%GIGI TIRUAN LEPASAN%|%GIGI TIRUAN SEBAGIAN%",                             "%PENUH%"},
        {"11", "Prothese Cekat",          "%GT CEKAT%|%PROTHESE CEKAT%|%INLAY%|%ONLAY%",                              ""},
        {"12", "Orthodonti",              "%ORTHO%|%BRAKET%|%BRACKET%",                                               ""},
        {"13", "Jacket/Bridge",           "%JACKET%|%BRIDGE%|%CROWN%|%MAHKOTA%",                                      ""},
        {"14", "Bedah Mulut",             "%ODONTECTOMY%|%ODONTEKTOMI%|%ALVEOLECTOMY%|%MARSUPIAL%|%BEDAH MULUT%|%OPERKULEKTOMI%|%OPERCULECTOMY%", ""},
        {"15", "Implan Gigi",             "%IMPLAN%|%IMPLANT%",                                                       ""},
        {"16", "Penyakit Mulut",          "",                                                                         ""},
    };

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "No.", "Kode", "Jenis Kegiatan", "Jumlah"
        });

        String poliGigi = "r.kd_poli IN (SELECT kd_poli FROM poliklinik WHERE UPPER(nm_poli) REGEXP 'GIGI|MULUT|KONSERVASI')";
        String sql = "SELECT nm_perawatan, SUM(jml) AS total FROM ("
                + " SELECT m.nm_perawatan AS nm_perawatan, COUNT(*) AS jml"
                + "   FROM rawat_jl_dr rj"
                + "   LEFT JOIN jns_perawatan m ON m.kd_jenis_prw=rj.kd_jenis_prw"
                + "   JOIN reg_periksa r ON r.no_rawat=rj.no_rawat"
                + "   WHERE rj.tgl_perawatan BETWEEN ? AND ? AND " + poliGigi
                + "     AND UPPER(m.nm_perawatan) NOT LIKE 'JASA PELAYANAN%'"
                + "   GROUP BY m.nm_perawatan"
                + " UNION ALL"
                + " SELECT m.nm_perawatan AS nm_perawatan, COUNT(*) AS jml"
                + "   FROM rawat_jl_drpr rj"
                + "   LEFT JOIN jns_perawatan m ON m.kd_jenis_prw=rj.kd_jenis_prw"
                + "   JOIN reg_periksa r ON r.no_rawat=rj.no_rawat"
                + "   WHERE rj.tgl_perawatan BETWEEN ? AND ? AND " + poliGigi
                + "     AND UPPER(m.nm_perawatan) NOT LIKE 'JASA PELAYANAN%'"
                + "   GROUP BY m.nm_perawatan"
                + " ) c GROUP BY nm_perawatan";

        // Kumpulkan semua nama tindakan GIG + total.
        List<String[]> tindakan = new ArrayList<>(); // {nmUpper, total}
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
                    tindakan.add(new String[]{nm, String.valueOf(rs.getInt("total"))});
                }
            }
        }

        // Baris "Bedah Mulut" (14) dari prosedur_pasien ICD-9 (baku), lebih lengkap.
        int bedahMulut = 0;
        String sqlBm = "SELECT COUNT(*) c FROM prosedur_pasien pp JOIN reg_periksa r ON r.no_rawat=pp.no_rawat "
            + "WHERE r.tgl_registrasi BETWEEN ? AND ? AND " + poliGigi
            + " AND (pp.kode LIKE '23.1%' OR pp.kode LIKE '24.4%' OR pp.kode LIKE '24.5%')";
        try (PreparedStatement ps = k.prepareStatement(sqlBm)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) bedahMulut = rs.getInt("c");
            }
        }

        // Klasifikasi tiap nama ke baris JUKNIS.
        int i = 0;
        for (String[] spec : SPECS) {
            String kode = spec[0], nama = spec[1];
            int jumlah;
            if ("14".equals(kode)) {
                jumlah = bedahMulut;
            } else {
                Pattern[] inc = compileList(spec[2]);
                Pattern[] exc = compileList(spec[3]);
                jumlah = 0;
                if (inc.length > 0) {
                    for (String[] t : tindakan) {
                        String hay = t[0];
                        if (matchAny(hay, inc) && !matchAny(hay, exc)) {
                            jumlah += Integer.parseInt(t[1]);
                        }
                    }
                }
            }
            res.add(++i, kode, nama, jumlah);
        }
        return res;
    }

    /** Ubah daftar pola LIKE (dipisah '|') menjadi regex anchored (case-insensitif via UPPER hay). */
    static Pattern[] compileList(String joined) {
        if (joined == null || joined.isEmpty()) return new Pattern[0];
        String[] parts = joined.split("\\|");
        Pattern[] out = new Pattern[parts.length];
        for (int i = 0; i < parts.length; i++) out[i] = likeToRegex(parts[i]);
        return out;
    }

    /** SQL-LIKE (% = wildcard) → regex anchored, mirror preg_quote + str_replace simcb. */
    static Pattern likeToRegex(String like) {
        String upper = like.toUpperCase();
        String[] lits = upper.split("%", -1);
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
