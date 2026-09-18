package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * RL 3.1 — Indikator Pelayanan Rawat Inap (BOR/ALOS/BTO/TOI/NDR/GDR), bulanan.
 * Port controller web Rl31Controller::buildData. Dihitung realtime langsung dari
 * kamar / kamar_inap / bangsal Khanza, diklasifikasi per jenis pelayanan
 * (Non Intensif / ICU / NICU / PICU / Intensif lainnya) dari nama bangsal.
 * Baris terakhir = Rata-rata (mean nilai non-nol tiap indikator).
 */
public class Rl31 implements SirsBuilder {

    private static final String[] JENIS =
        {"Non Intensif", "ICU", "NICU", "PICU", "Intensif lainnya"};

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "Jenis Pelayanan", "Jml TT", "Hari Perawatan", "Pasien Keluar",
            "Mati", "Mati ≥ 48j", "BOR (%)", "ALOS", "BTO", "TOI", "NDR (‰)", "GDR (‰)"
        });
        res.catatan = "Ideal: BOR 60–85% · ALOS 6–9 hari · BTO 40–50×/th · "
                + "TOI 1–3 hari · NDR <25‰ · GDR <45‰";

        // Jumlah hari periode = jumlah hari dalam rentang (inklusif).
        int hariPeriode = (int) (ChronoUnit.DAYS.between(
            LocalDate.parse(tgl1), LocalDate.parse(tgl2)) + 1);

        Map<String, Integer> tt = new LinkedHashMap<>();
        Map<String, Double> hari = new LinkedHashMap<>();
        Map<String, Integer> keluar = new LinkedHashMap<>();
        Map<String, Integer> mati = new LinkedHashMap<>();
        Map<String, Integer> mati48 = new LinkedHashMap<>();
        for (String j : JENIS) {
            tt.put(j, 0); hari.put(j, 0.0); keluar.put(j, 0); mati.put(j, 0); mati48.put(j, 0);
        }

        // TT per bangsal (kamar aktif).
        String sqlTt = "SELECT IFNULL(b.nm_bangsal,'') nm, COUNT(*) jml "
                + "FROM kamar k LEFT JOIN bangsal b ON k.kd_bangsal=b.kd_bangsal "
                + "WHERE k.statusdata='1' AND IFNULL(b.status,'1')='1' "
                + "GROUP BY b.nm_bangsal";
        try (PreparedStatement ps = k.prepareStatement(sqlTt);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String j = jenis(rs.getString("nm"));
                tt.put(j, tt.get(j) + rs.getInt("jml"));
            }
        }

        // Agregasi pasien keluar per bangsal dalam periode.
        String sqlAgg = "SELECT IFNULL(b.nm_bangsal,'') nm, "
                + "CAST(SUM(IFNULL(ki.lama,0)) AS DOUBLE) hari_rawat, "
                + "SUM(CASE WHEN ki.stts_pulang NOT IN ('Pindah Kamar','Status Belum Lengkap') THEN 1 ELSE 0 END) keluar, "
                + "SUM(CASE WHEN ki.stts_pulang='Meninggal' THEN 1 ELSE 0 END) mati, "
                + "SUM(CASE WHEN ki.stts_pulang='Meninggal' AND IFNULL(ki.lama,0)>=2 THEN 1 ELSE 0 END) mati48 "
                + "FROM kamar_inap ki "
                + "INNER JOIN kamar k ON ki.kd_kamar=k.kd_kamar "
                + "LEFT JOIN bangsal b ON k.kd_bangsal=b.kd_bangsal "
                + "WHERE ki.tgl_keluar BETWEEN ? AND ? "
                + "GROUP BY b.nm_bangsal";
        try (PreparedStatement ps = k.prepareStatement(sqlAgg)) {
            ps.setString(1, tgl1);
            ps.setString(2, tgl2);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String j = jenis(rs.getString("nm"));
                    hari.put(j, hari.get(j) + rs.getDouble("hari_rawat"));
                    keluar.put(j, keluar.get(j) + rs.getInt("keluar"));
                    mati.put(j, mati.get(j) + rs.getInt("mati"));
                    mati48.put(j, mati48.get(j) + rs.getInt("mati48"));
                }
            }
        }

        // Akumulator rata-rata (mean nilai non-nol per indikator).
        double sBor = 0, sAlos = 0, sBto = 0, sToi = 0, sNdr = 0, sGdr = 0;
        int nBor = 0, nAlos = 0, nBto = 0, nToi = 0, nNdr = 0, nGdr = 0;

        for (String j : JENIS) {
            int jmlTt = tt.get(j);
            double hr = hari.get(j);
            int kel = keluar.get(j), m = mati.get(j), m48 = mati48.get(j);
            double denom = (double) jmlTt * hariPeriode;

            double bor = denom > 0 ? hr / denom * 100 : 0;
            double alos = kel > 0 ? hr / kel : 0;
            double bto = jmlTt > 0 ? (double) kel / jmlTt : 0;
            double toi = kel > 0 ? (denom - hr) / kel : 0;
            double ndr = kel > 0 ? (double) m48 / kel * 1000 : 0;
            double gdr = kel > 0 ? (double) m / kel * 1000 : 0;

            if (bor != 0)  { sBor += bor;  nBor++; }
            if (alos != 0) { sAlos += alos; nAlos++; }
            if (bto != 0)  { sBto += bto;  nBto++; }
            if (toi != 0)  { sToi += toi;  nToi++; }
            if (ndr != 0)  { sNdr += ndr;  nNdr++; }
            if (gdr != 0)  { sGdr += gdr;  nGdr++; }

            res.add(j, jmlTt, (int) Math.round(hr), kel, m, m48,
                String.format("%.2f", bor), String.format("%.2f", alos),
                String.format("%.2f", bto), String.format("%.2f", toi),
                String.format("%.2f", ndr), String.format("%.2f", gdr));
        }

        double rBor = nBor > 0 ? sBor / nBor : 0;
        double rAlos = nAlos > 0 ? sAlos / nAlos : 0;
        double rBto = nBto > 0 ? sBto / nBto : 0;
        double rToi = nToi > 0 ? sToi / nToi : 0;
        double rNdr = nNdr > 0 ? sNdr / nNdr : 0;
        double rGdr = nGdr > 0 ? sGdr / nGdr : 0;

        res.add("Rata-rata", "", "", "", "", "",
            String.format("%.2f", rBor), String.format("%.2f", rAlos),
            String.format("%.2f", rBto), String.format("%.2f", rToi),
            String.format("%.2f", rNdr), String.format("%.2f", rGdr));

        return res;
    }

    /** Klasifikasi jenis dari nama bangsal (mirror Rl31Controller::jenis). */
    private static String jenis(String nm) {
        String u = (nm == null ? "" : nm).toUpperCase();
        if (u.contains("NICU")) return "NICU";
        if (u.contains("PICU")) return "PICU";
        if (u.contains("ICU") && !u.contains("NICU") && !u.contains("PICU")
                && !u.contains("ICCU") && !u.contains("ICVCU") && !u.contains("RICU")) return "ICU";
        if (u.contains("HCU") || u.contains("ICCU") || u.contains("ICVCU") || u.contains("RICU")) return "Intensif lainnya";
        return "Non Intensif";
    }
}
