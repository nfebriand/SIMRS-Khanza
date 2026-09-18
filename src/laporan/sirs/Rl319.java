package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * RL 3.19 — Rekapitulasi Cara Bayar (Tahunan, realtime). Port Rl319Controller.
 * Ranap (pasien keluar + total lama dirawat) dari kamar_inap; Ralan (kunjungan,
 * lab, radiologi) dari reg_periksa. Tiap kd_pj dipetakan ke baris JUKNIS (11
 * baris master; baris parent = jumlah anak). Rentang: ki.tgl_keluar (ranap) &
 * r.tgl_registrasi (ralan).
 */
public class Rl319 implements SirsBuilder {

    /** {kode, nama, parent, isParent}. Mirror simcb rl319_master(). */
    private static final Object[][] MASTER = {
        {"1",   "Membayar Sendiri",                        null, false},
        {"2",   "Asuransi",                                null, true},
        {"2.1", "Asuransi JKN (BPJS Kesehatan)",           "2",  false},
        {"2.2", "Asuransi Pemerintah Daerah (Jamkesda)",   "2",  false},
        {"2.3", "Asuransi Pemerintah Lainnya",             "2",  false},
        {"2.4", "Asuransi Swasta",                         "2",  false},
        {"3",   "Keringanan (Cost Sharing)",               null, false},
        {"4",   "Gratis",                                  null, true},
        {"4.1", "Kartu Sehat",                             "4",  false},
        {"4.2", "Keterangan Tidak Mampu",                  "4",  false},
        {"4.3", "Lain-Lain",                               "4",  false},
    };

    /** Akumulator 5 metrik per baris JUKNIS / per kd_pj. */
    private static final class Acc {
        int keluar, lama, lab, rad, lain, total;
    }

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "Kode", "Cara Pembayaran", "Pasien Keluar (Ranap)", "Lama Dirawat (Ranap)",
            "Pasien Rawat Jalan", "Lab (Ralan)", "Radiologi (Ralan)", "Lain-lain (Ralan)"
        });

        // Per kd_pj: kumpulan mentah ranap + ralan.
        Map<String, String[]> pjName = new LinkedHashMap<>(); // key -> {kd_pj, png_jawab}
        Map<String, Acc> byKd = new LinkedHashMap<>();

        // Ranap: pasien keluar + total lama dirawat per kd_pj.
        String sqlRanap = "SELECT p.kd_pj, p.png_jawab, "
                + "CAST(COUNT(*) AS SIGNED) AS keluar, "
                + "CAST(SUM(GREATEST(DATEDIFF(IFNULL(ki.tgl_keluar, CURDATE()), ki.tgl_masuk), 0)) AS SIGNED) AS lama "
                + "FROM kamar_inap ki "
                + "JOIN reg_periksa r ON r.no_rawat = ki.no_rawat "
                + "LEFT JOIN penjab p ON p.kd_pj = r.kd_pj "
                + "WHERE ki.tgl_keluar BETWEEN ? AND ? AND ki.stts_pulang != '' "
                + "GROUP BY p.kd_pj, p.png_jawab";
        try (PreparedStatement ps = k.prepareStatement(sqlRanap)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String kd = rs.getString("kd_pj");
                    String pj = rs.getString("png_jawab");
                    String key = ensure(byKd, pjName, kd, pj);
                    Acc a = byKd.get(key);
                    a.keluar = rs.getInt("keluar");
                    a.lama = rs.getInt("lama");
                }
            }
        }

        // Ralan: distinct kunjungan ralan + yang punya lab/radiologi, per kd_pj.
        String sqlRalan = "SELECT p.kd_pj, p.png_jawab, "
                + "CAST(COUNT(DISTINCT CASE WHEN pl.no_rawat IS NOT NULL THEN r.no_rawat END) AS SIGNED) AS lab, "
                + "CAST(COUNT(DISTINCT CASE WHEN pr.no_rawat IS NOT NULL THEN r.no_rawat END) AS SIGNED) AS rad, "
                + "CAST(COUNT(DISTINCT r.no_rawat) AS SIGNED) AS total "
                + "FROM reg_periksa r "
                + "LEFT JOIN penjab p ON p.kd_pj = r.kd_pj "
                + "LEFT JOIN periksa_lab pl ON pl.no_rawat = r.no_rawat AND pl.status = 'Ralan' "
                + "LEFT JOIN periksa_radiologi pr ON pr.no_rawat = r.no_rawat AND pr.status = 'Ralan' "
                + "WHERE r.tgl_registrasi BETWEEN ? AND ? AND r.status_lanjut = 'Ralan' "
                + "GROUP BY p.kd_pj, p.png_jawab";
        try (PreparedStatement ps = k.prepareStatement(sqlRalan)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String kd = rs.getString("kd_pj");
                    String pj = rs.getString("png_jawab");
                    String key = ensure(byKd, pjName, kd, pj);
                    String[] nm = pjName.get(key);
                    if (nm[1] == null) nm[1] = pj;
                    Acc a = byKd.get(key);
                    a.lab = rs.getInt("lab");
                    a.rad = rs.getInt("rad");
                    a.total = rs.getInt("total");
                }
            }
        }

        // Aggregate per baris JUKNIS via mapping.
        Map<String, Acc> agg = new LinkedHashMap<>();
        for (Map.Entry<String, Acc> e : byKd.entrySet()) {
            String[] nm = pjName.get(e.getKey());
            String kdPj = nm[0] == null ? "?" : nm[0];
            String pngJawab = nm[1] == null ? "" : nm[1];
            String target = mapKdPj(kdPj, pngJawab);
            if (target == null) continue;
            Acc raw = e.getValue();
            int lain = Math.max(raw.total - raw.lab - raw.rad, 0);
            Acc t = agg.computeIfAbsent(target, x -> new Acc());
            t.keluar += raw.keluar;
            t.lama += raw.lama;
            t.lab += raw.lab;
            t.rad += raw.rad;
            t.lain += lain;
        }

        // Leaf per kode (non-parent).
        Map<String, Acc> leaf = new LinkedHashMap<>();
        for (Object[] m : MASTER) {
            boolean isParent = (Boolean) m[3];
            if (!isParent) {
                String kode = (String) m[0];
                leaf.put(kode, agg.getOrDefault(kode, new Acc()));
            }
        }

        // Build 11 baris + total (leaf saja agar parent tak dobel-hitung).
        Acc tot = new Acc();
        for (Object[] m : MASTER) {
            String kode = (String) m[0];
            String nama = (String) m[1];
            boolean isParent = (Boolean) m[3];
            Acc v;
            if (isParent) {
                v = new Acc();
                for (Map.Entry<String, Acc> le : leaf.entrySet()) {
                    if (le.getKey().startsWith(kode + ".")) {
                        Acc lv = le.getValue();
                        v.keluar += lv.keluar;
                        v.lama += lv.lama;
                        v.lab += lv.lab;
                        v.rad += lv.rad;
                        v.lain += lv.lain;
                    }
                }
            } else {
                v = leaf.get(kode);
            }
            int ralanTotal = v.lab + v.rad + v.lain;
            res.add(kode, nama, v.keluar, v.lama, ralanTotal, v.lab, v.rad, v.lain);
            if (!isParent) {
                tot.keluar += v.keluar;
                tot.lama += v.lama;
                tot.lab += v.lab;
                tot.rad += v.rad;
                tot.lain += v.lain;
            }
        }
        int totRalan = tot.lab + tot.rad + tot.lain;
        res.add("", "TOTAL", tot.keluar, tot.lama, totRalan, tot.lab, tot.rad, tot.lain);
        return res;
    }

    /** Buat/temukan bucket per kd_pj (kunci = kd_pj, atau '?' bila null). */
    private static String ensure(Map<String, Acc> byKd, Map<String, String[]> pjName,
                                 String kd, String pj) {
        String key = kd == null ? "?" : kd;
        if (!byKd.containsKey(key)) {
            byKd.put(key, new Acc());
            pjName.put(key, new String[]{kd, pj});
        }
        return key;
    }

    /** Mapping kd_pj Khanza → kode baris JUKNIS RL 3.19. Mirror simcb rl319_map_kd_pj. */
    private String mapKdPj(String kdPj, String pngJawab) {
        switch (kdPj) {
            case "A01": return "1";
            case "A02":
            case "BPJ": return "2.1";
            case "C03": return "2.2";
            case "C06": return "4.1";
            case "FRE": return "4.3";
            case "D01":
            case "D02": return "3";
        }
        String pj = pngJawab.toUpperCase();
        if (pj.contains("JASA RAHARJA") || pj.contains("ASABRI") || pj.contains("POLISI")
                || pj.contains("POLDA") || pj.contains("KEPOLISIAN") || pj.contains("TNI")
                || pj.contains("KETENAGAKERJAAN")) return "2.3";
        if (pj.contains("BPJS") || pj.contains("KIS") || pj.contains("JKN")) return "2.1";
        if (pj.contains("JAMKESDA") || pj.contains("PEMDA")) return "2.2";
        if (pj.contains("UMUM") || pj.contains("TUNAI") || pj.contains("MEMBAYAR")) return "1";
        if (pj.contains("GRATIS") || pj.contains("KARTU SEHAT")) return "4.1";
        if (pj.contains("SKTM") || pj.contains("TIDAK MAMPU")) return "4.2";
        if (pj.contains("KARYAWAN") || pj.contains("PEGAWAI")) return "3";
        if (pj.equals("-") || pj.isEmpty()) return null;
        return "2.4"; // default asuransi non-pemerintah → swasta
    }
}
