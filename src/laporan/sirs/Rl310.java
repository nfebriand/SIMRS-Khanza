package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * RL 3.10 — Rekapitulasi Kegiatan Pelayanan Rujukan (bulanan, realtime).
 * Port Rl310Controller.php. Dihitung realtime dari rujuk_masuk (rujukan masuk)
 * + rujuk (rujukan keluar) join reg_periksa untuk klasifikasi spesialisasi via
 * kd_poli. Asal perujuk (rujuk_masuk.perujuk) diklasifikasi via pola nama:
 * Puskesmas, RS, sisanya Faskes Lain. 20 baris spesialisasi JUKNIS; kd_poli
 * tak terpetakan masuk baris 20 "Spesialisasi Lain" (catch-all).
 */
public class Rl310 implements SirsBuilder {

    /** {kode, nama} — urut sesuai JUKNIS. */
    private static final String[][] MASTER = {
        {"1",  "Penyakit Dalam"},
        {"2",  "Bedah"},
        {"3",  "Kesehatan Anak"},
        {"4",  "Kesehatan Remaja"},
        {"5",  "Obstetri"},
        {"6",  "Ginekologi"},
        {"7",  "Keluarga Berencana"},
        {"8",  "Saraf (Non Stroke)"},
        {"9",  "Jiwa"},
        {"10", "THT"},
        {"11", "Mata"},
        {"12", "Kulit dan Kelamin"},
        {"13", "Gigi dan Mulut"},
        {"14", "Radiologi"},
        {"15", "Paru"},
        {"16", "Kardiologi"},
        {"17", "Kanker"},
        {"18", "Uronefrologi"},
        {"19", "Saraf (Stroke)"},
        {"20", "Spesialisasi Lain"},
    };

    /** Peta kd_poli Trimitra -> kode spesialisasi JUKNIS (kd_poli lain -> "20"). */
    private static final Map<String, String> POLI_MAP = new HashMap<>();
    static {
        POLI_MAP.put("INTR", "1"); POLI_MAP.put("INT", "1");
        POLI_MAP.put("BED", "2"); POLI_MAP.put("BDH", "2"); POLI_MAP.put("ORT", "2");
        POLI_MAP.put("ANAK", "3"); POLI_MAP.put("ANA", "3"); POLI_MAP.put("U0043", "3");
        POLI_MAP.put("OBS", "5"); POLI_MAP.put("OBG", "5");
        POLI_MAP.put("SAR", "8"); POLI_MAP.put("SRF", "8");
        POLI_MAP.put("KJ", "9");
        POLI_MAP.put("THT", "10");
        POLI_MAP.put("MAT", "11");
        POLI_MAP.put("KLT", "12");
        POLI_MAP.put("BM", "13"); POLI_MAP.put("GIG", "13");
        POLI_MAP.put("RAD", "14");
        POLI_MAP.put("PAR", "15"); POLI_MAP.put("PARU", "15");
        POLI_MAP.put("JAN", "16");
        POLI_MAP.put("URO", "18");
    }

    /** Satu baris agregat rujukan per spesialisasi. */
    private static final class Row {
        int rmPus, rmRs, rmFaskes, rmTotal, rkRujukan, rkSendiri, rkTotal;
    }

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "No.", "Jenis Spesialisasi",
            "RM Diterima Pusk", "RM Diterima RS", "RM Diterima Faskes", "Total Rujukan Masuk",
            "RM Dikembalikan Pusk", "RM Dikembalikan RS", "RM Dikembalikan Faskes", "Total Dikembalikan",
            "Keluar Pasien Rujukan", "Keluar Datang Sendiri", "Total Dirujuk Keluar", "Diterima Kembali"
        });

        // Inisialisasi 20 baris (menjaga urutan JUKNIS).
        Map<String, Row> rows = new LinkedHashMap<>();
        for (String[] b : MASTER) rows.put(b[0], new Row());

        // Rujukan masuk per kd_poli + klasifikasi asal faskes via bridging_sep
        // (asal_rujukan Faskes 1/2 + nmppkrujukan), fallback rujuk_masuk.perujuk.
        String sqlMasuk = "SELECT kd_poli, SUM(fas='PUS') AS pus, SUM(fas='RS') AS rs, "
            + "SUM(fas='LAIN') AS faskes, COUNT(*) AS total FROM ("
            + "  SELECT kd_poli, CASE"
            + "    WHEN asal='2. Faskes 2(RS)' OR src REGEXP 'RUMAH SAKIT|(^| )RS|RSU|RSUD|HOSPITAL' THEN 'RS'"
            + "    WHEN src REGEXP 'KLINIK|KLNK|BIDAN|BPM|PMB|DOKTER|(^| )DR |PRAKTIK|APOTE' THEN 'LAIN'"
            + "    WHEN asal LIKE '1.%' OR src REGEXP 'PUSKESMAS|PUSKES|PKM|PUSTU' THEN 'PUS'"
            + "    ELSE 'LAIN' END AS fas"
            + "  FROM ("
            + "    SELECT r.kd_poli AS kd_poli,"
            + "      COALESCE((SELECT bs.asal_rujukan FROM bridging_sep bs WHERE bs.no_rawat=rm.no_rawat LIMIT 1),'') AS asal,"
            + "      UPPER(COALESCE((SELECT bs.nmppkrujukan FROM bridging_sep bs WHERE bs.no_rawat=rm.no_rawat LIMIT 1), rm.perujuk, '')) AS src"
            + "    FROM rujuk_masuk rm JOIN reg_periksa r ON r.no_rawat = rm.no_rawat"
            + "    WHERE r.tgl_registrasi BETWEEN ? AND ?"
            + "  ) a"
            + ") b GROUP BY kd_poli";
        try (PreparedStatement ps = k.prepareStatement(sqlMasuk)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Row row = rows.get(mapPoli(rs.getString("kd_poli")));
                    row.rmPus += rs.getInt("pus");
                    row.rmRs += rs.getInt("rs");
                    row.rmFaskes += rs.getInt("faskes");
                    row.rmTotal += rs.getInt("total");
                }
            }
        }

        // Dirujuk keluar per kd_poli, dipisah pasien rujukan vs datang sendiri (rule 7/8).
        String sqlKeluar = "SELECT r.kd_poli AS kd_poli, "
            + "SUM(EXISTS(SELECT 1 FROM rujuk_masuk rm WHERE rm.no_rawat=rj.no_rawat)) AS rk_rujukan, "
            + "SUM(NOT EXISTS(SELECT 1 FROM rujuk_masuk rm WHERE rm.no_rawat=rj.no_rawat)) AS rk_sendiri, "
            + "COUNT(*) AS rk_total "
            + "FROM rujuk rj "
            + "JOIN reg_periksa r ON r.no_rawat = rj.no_rawat "
            + "WHERE rj.tgl_rujuk BETWEEN ? AND ? "
            + "GROUP BY r.kd_poli";
        try (PreparedStatement ps = k.prepareStatement(sqlKeluar)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Row row = rows.get(mapPoli(rs.getString("kd_poli")));
                    row.rkRujukan += rs.getInt("rk_rujukan");
                    row.rkSendiri += rs.getInt("rk_sendiri");
                    row.rkTotal += rs.getInt("rk_total");
                }
            }
        }

        int no = 1, tp = 0, tr = 0, tf = 0, tt = 0, trj = 0, trs = 0, trk = 0;
        for (String[] b : MASTER) {
            Row row = rows.get(b[0]);
            res.add(no++, b[1], row.rmPus, row.rmRs, row.rmFaskes, row.rmTotal,
                0, 0, 0, 0, row.rkRujukan, row.rkSendiri, row.rkTotal, 0);
            tp += row.rmPus; tr += row.rmRs; tf += row.rmFaskes; tt += row.rmTotal;
            trj += row.rkRujukan; trs += row.rkSendiri; trk += row.rkTotal;
        }
        res.add("", "TOTAL", tp, tr, tf, tt, 0, 0, 0, 0, trj, trs, trk, 0);
        res.catatan = "20 spesialisasi JUKNIS (klasifikasi via kd_poli). Diterima Dari = rujuk_masuk; "
            + "Dirujuk Keluar dipisah Pasien Rujukan/Datang Sendiri (rule 7/8). Dikembalikan ke Asal & "
            + "Diterima Kembali tak dicatat terpisah di Khanza (=0).";
        return res;
    }

    private String mapPoli(String kd) {
        if (kd == null) return "20";
        String v = POLI_MAP.get(kd.toUpperCase());
        return v != null ? v : "20";
    }
}
