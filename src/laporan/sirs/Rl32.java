package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

/**
 * RL 3.2 — Rekapitulasi Kegiatan Pelayanan Rawat Inap (JUKNIS SIRS 6.3).
 *
 * Baris = 36 jenis pelayanan baku JUKNIS + TOTAL. Klasifikasi HIBRIDA:
 *   1. Bila bangsal dipetakan ke UNIT khusus (ICU/HCU/ICCU/RICU/NICU/PICU/
 *      Isolasi/Perinatologi/Luka Bakar) -> pakai jenis dari bangsal
 *      (sirs_rl32_map_bangsal).
 *   2. Selain itu (bangsal umum/campur) -> pakai SPESIALIS DPJP: DPJP utama =
 *      MIN(kd_dokter) dpjp_ranap (fallback reg_periksa.kd_dokter) -> dokter.kd_sps
 *      -> override sirs_rl32_map_spesialis, lalu auto-match nama spesialis,
 *      lalu fallback jenis bangsal, lalu 'Umum'.
 * Alokasi TT TETAP dari bangsal (tempat tidur fisik per ruangan).
 */
public class Rl32 implements SirsBuilder {

    /** Jenis pelayanan yang ditentukan RUANGAN (unit khusus), bukan spesialis DPJP. */
    private static final String UNIT_KHUSUS =
        "'ICU','HCU','ICCU/ICVCU','RICU','NICU','PICU','Isolasi','Perinatologi','Luka Bakar'";

    /** Auto-match nama spesialis -> jenis JUKNIS (dipakai bila tak ada override). */
    private static final String AUTO_MATCH =
        "CASE"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'ORTHOP|ORTOP' THEN 'Bedah Orthopedi'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'BEDAH.*SARAF|BEDAH.*SYARAF' THEN 'Bedah Saraf'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'BEDAH' THEN 'Bedah'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'DALAM|INTERNA' THEN 'Penyakit Dalam'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'ANAK' THEN 'Kesehatan Anak'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'GINEKOLOG' THEN 'Ginekologi'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'OBSTETRI|KANDUNGAN|KEBIDANAN|OBGYN|OBSGYN|OBGIN|OBSGIN|GYN' THEN 'Obstetri'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'SARAF|SYARAF|NEUROLOG' THEN 'Saraf'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'JIWA|PSIKIATRI' THEN 'Jiwa'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'THT' THEN 'THT'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'MATA' THEN 'Mata'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'KULIT' THEN 'Kulit dan Kelamin'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'JANTUNG|KARDIO' THEN 'Kardiologi'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'PARU|PULMONO' THEN 'Paru'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'KANKER|ONKOLOG' THEN 'Kanker'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'UROLOG|NEFROLOG' THEN 'Uronefrologi'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'GERIATRI' THEN 'Geriatri'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'GIGI|MULUT' THEN 'Gigi dan Mulut'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'REHAB' THEN 'Rehabilitasi Medik'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'RADIOTERAPI' THEN 'Radioterapi'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'NUKLIR' THEN 'Kedokteran Nuklir'"
        + " WHEN UPPER(spx.nm_sps) REGEXP 'KUSTA' THEN 'Kusta'"
        + " ELSE NULL END";

    /** Cek tabel override sirs_rl32_map_spesialis ada — agar report tetap jalan bila belum dibuat. */
    private static boolean adaMapSpesialis(Connection k) {
        try (PreparedStatement ps = k.prepareStatement("SELECT 1 FROM sirs_rl32_map_spesialis LIMIT 1")) {
            ps.executeQuery();
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /** 36 jenis pelayanan baku JUKNIS (urutan resmi). */
    private static final String[] JENIS = {
        "Umum", "Penyakit Dalam", "Kesehatan Anak", "Kesehatan Remaja", "Obstetri",
        "Ginekologi", "Bedah", "Bedah Orthopedi", "Bedah Saraf", "Luka Bakar",
        "Saraf", "Jiwa", "Psikologi", "Penatalaksana Penyalahgunaan NAPZA", "THT",
        "Mata", "Kulit dan Kelamin", "Kardiologi", "Paru", "Kanker",
        "Uronefrologi", "Geriatri", "Kusta", "Radioterapi", "Kedokteran Nuklir",
        "Rehabilitasi Medik", "ICU", "HCU", "ICCU/ICVCU", "RICU",
        "NICU", "PICU", "Isolasi", "Gigi dan Mulut", "Pelayanan Rawat Darurat",
        "Perinatologi"
    };

    // indeks agregat: 0 awal,1 masuk,2 pindahan,3 dipindahkan,4 keluar_hidup,
    // 5 mati_l_lt48,6 mati_l_ge48,7 mati_p_lt48,8 mati_p_ge48,9 lama_dirawat,
    // 10 hp_vvip,11 hp_vip,12 hp_i,13 hp_ii,14 hp_iii,15 hp_khusus
    private static final int NAGG = 16;

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "No.", "Jenis Pelayanan", "Awal Bulan", "Masuk", "Pindahan", "Dipindahkan",
            "Keluar Hidup", "Mati L <48j", "Mati L ≥48j", "Mati P <48j", "Mati P ≥48j",
            "Lama Dirawat", "Akhir Bulan", "Hari Perawatan",
            "HP VVIP", "HP VIP", "HP I", "HP II", "HP III", "HP Khusus", "Alokasi TT"
        });

        String in = "'" + tgl1 + "' AND '" + tgl2 + "'";
        Map<String, long[]> agg = new HashMap<>();
        Map<String, Integer> tt = new HashMap<>();

        // Ekspresi jenis HIBRIDA: unit khusus dari bangsal, selain itu dari DPJP.
        boolean hasMap = adaMapSpesialis(k);
        String override = hasMap ? "msp.jenis_pelayanan, " : "";
        String jenisExpr = "CASE WHEN IFNULL(m.jenis_pelayanan,'') IN (" + UNIT_KHUSUS + ") THEN m.jenis_pelayanan"
            + " ELSE COALESCE(" + override + AUTO_MATCH + ", m.jenis_pelayanan, 'Umum') END";
        String joinMsp = hasMap ? "   LEFT JOIN sirs_rl32_map_spesialis msp ON msp.kd_sps = dok.kd_sps" : "";

        String sql = "SELECT s.jenis jenis,"
            + " SUM(CASE WHEN s.tgl_masuk < '" + tgl1 + "' AND (s.tgl_keluar IS NULL OR s.tgl_keluar='0000-00-00' OR s.tgl_keluar >= '" + tgl1 + "') THEN 1 ELSE 0 END) awal,"
            + " SUM(CASE WHEN s.is_admission=1 AND s.tgl_masuk BETWEEN " + in + " THEN 1 ELSE 0 END) masuk,"
            + " SUM(CASE WHEN s.is_admission=0 AND s.tgl_masuk BETWEEN " + in + " THEN 1 ELSE 0 END) pindahan,"
            + " SUM(CASE WHEN s.stts='Pindah Kamar' AND s.tgl_keluar BETWEEN " + in + " THEN 1 ELSE 0 END) dipindahkan,"
            + " SUM(CASE WHEN s.tgl_keluar BETWEEN " + in + " AND s.stts NOT IN ('Meninggal','Pindah Kamar','Status Belum Lengkap') THEN 1 ELSE 0 END) keluar_hidup,"
            + " SUM(CASE WHEN s.stts='Meninggal' AND s.tgl_keluar BETWEEN " + in + " AND s.jk='L' AND s.lama<2  THEN 1 ELSE 0 END) mati_l_lt48,"
            + " SUM(CASE WHEN s.stts='Meninggal' AND s.tgl_keluar BETWEEN " + in + " AND s.jk='L' AND s.lama>=2 THEN 1 ELSE 0 END) mati_l_ge48,"
            + " SUM(CASE WHEN s.stts='Meninggal' AND s.tgl_keluar BETWEEN " + in + " AND s.jk='P' AND s.lama<2  THEN 1 ELSE 0 END) mati_p_lt48,"
            + " SUM(CASE WHEN s.stts='Meninggal' AND s.tgl_keluar BETWEEN " + in + " AND s.jk='P' AND s.lama>=2 THEN 1 ELSE 0 END) mati_p_ge48,"
            + " SUM(CASE WHEN s.tgl_keluar BETWEEN " + in + " AND s.stts NOT IN ('Pindah Kamar','Status Belum Lengkap') THEN s.lama ELSE 0 END) lama_dirawat,"
            + " SUM(CASE WHEN s.tgl_keluar BETWEEN " + in + " AND s.kelas_grp='VVIP'   THEN s.lama ELSE 0 END) hp_vvip,"
            + " SUM(CASE WHEN s.tgl_keluar BETWEEN " + in + " AND s.kelas_grp='VIP'    THEN s.lama ELSE 0 END) hp_vip,"
            + " SUM(CASE WHEN s.tgl_keluar BETWEEN " + in + " AND s.kelas_grp='I'      THEN s.lama ELSE 0 END) hp_i,"
            + " SUM(CASE WHEN s.tgl_keluar BETWEEN " + in + " AND s.kelas_grp='II'     THEN s.lama ELSE 0 END) hp_ii,"
            + " SUM(CASE WHEN s.tgl_keluar BETWEEN " + in + " AND s.kelas_grp='III'    THEN s.lama ELSE 0 END) hp_iii,"
            + " SUM(CASE WHEN s.tgl_keluar BETWEEN " + in + " AND s.kelas_grp='KHUSUS' THEN s.lama ELSE 0 END) hp_khusus"
            + " FROM ("
            + "   SELECT " + jenisExpr + " jenis, ki.tgl_masuk, ki.tgl_keluar, IFNULL(ki.lama,0) lama,"
            + "     ki.stts_pulang stts, IFNULL(p.jk,'') jk,"
            + "     CASE k.kelas WHEN 'Kelas VVIP' THEN 'VVIP' WHEN 'Kelas VIP' THEN 'VIP' WHEN 'Kelas 1' THEN 'I'"
            + "       WHEN 'Kelas 2' THEN 'II' WHEN 'Kelas 3' THEN 'III' ELSE 'KHUSUS' END kelas_grp,"
            + "     CASE WHEN ROW_NUMBER() OVER (PARTITION BY ki.no_rawat ORDER BY ki.tgl_masuk, ki.jam_masuk)=1 THEN 1 ELSE 0 END is_admission"
            + "   FROM kamar_inap ki"
            + "   INNER JOIN kamar k ON ki.kd_kamar=k.kd_kamar"
            + "   LEFT JOIN bangsal b ON k.kd_bangsal=b.kd_bangsal"
            + "   LEFT JOIN sirs_rl32_map_bangsal m ON m.kd_bangsal=b.kd_bangsal"
            + "   LEFT JOIN reg_periksa rp ON ki.no_rawat=rp.no_rawat"
            + "   LEFT JOIN pasien p ON rp.no_rkm_medis=p.no_rkm_medis"
            + "   LEFT JOIN (SELECT no_rawat, MIN(kd_dokter) kd_dokter FROM dpjp_ranap GROUP BY no_rawat) dp ON dp.no_rawat=ki.no_rawat"
            + "   LEFT JOIN dokter dok ON dok.kd_dokter = COALESCE(dp.kd_dokter, rp.kd_dokter)"
            + "   LEFT JOIN spesialis spx ON spx.kd_sps = dok.kd_sps"
            + joinMsp
            + " ) s GROUP BY s.jenis";

        try (PreparedStatement ps = k.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                long[] v = new long[NAGG];
                v[0] = rs.getLong("awal");        v[1] = rs.getLong("masuk");
                v[2] = rs.getLong("pindahan");    v[3] = rs.getLong("dipindahkan");
                v[4] = rs.getLong("keluar_hidup");
                v[5] = rs.getLong("mati_l_lt48"); v[6] = rs.getLong("mati_l_ge48");
                v[7] = rs.getLong("mati_p_lt48"); v[8] = rs.getLong("mati_p_ge48");
                v[9] = rs.getLong("lama_dirawat");
                v[10] = rs.getLong("hp_vvip");    v[11] = rs.getLong("hp_vip");
                v[12] = rs.getLong("hp_i");       v[13] = rs.getLong("hp_ii");
                v[14] = rs.getLong("hp_iii");     v[15] = rs.getLong("hp_khusus");
                agg.put(rs.getString("jenis"), v);
            }
        }

        // Alokasi TT (proxy realtime): jumlah kamar aktif per jenis.
        String sqlTt = "SELECT IFNULL(m.jenis_pelayanan,'Umum') jenis, COUNT(*) tt "
            + "FROM kamar k LEFT JOIN bangsal b ON k.kd_bangsal=b.kd_bangsal "
            + "LEFT JOIN sirs_rl32_map_bangsal m ON m.kd_bangsal=b.kd_bangsal "
            + "WHERE k.statusdata='1' GROUP BY IFNULL(m.jenis_pelayanan,'Umum')";
        try (PreparedStatement ps = k.prepareStatement(sqlTt);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) tt.put(rs.getString("jenis"), rs.getInt("tt"));
        }

        long[] tot = new long[NAGG + 3]; // + akhir, hari_perawatan, tt
        for (String j : JENIS) {
            long[] v = agg.getOrDefault(j, new long[NAGG]);
            int ttj = tt.getOrDefault(j, 0);
            long matiTotal = v[5] + v[6] + v[7] + v[8];
            long hp = v[10] + v[11] + v[12] + v[13] + v[14] + v[15];
            long akhir = Math.max(0, v[0] + v[1] + v[2] - v[4] - matiTotal - v[3]);

            res.add(idx(j), j, v[0], v[1], v[2], v[3], v[4],
                v[5], v[6], v[7], v[8], v[9], akhir, hp,
                v[10], v[11], v[12], v[13], v[14], v[15], ttj);

            for (int i = 0; i < NAGG; i++) tot[i] += v[i];
            tot[NAGG] += akhir; tot[NAGG + 1] += hp; tot[NAGG + 2] += ttj;
        }
        // baris TOTAL
        res.add("", "TOTAL", tot[0], tot[1], tot[2], tot[3], tot[4],
            tot[5], tot[6], tot[7], tot[8], tot[9], tot[NAGG], tot[NAGG + 1],
            tot[10], tot[11], tot[12], tot[13], tot[14], tot[15], tot[NAGG + 2]);

        res.catatan = "Klasifikasi HIBRIDA: unit khusus (ICU/HCU/NICU/dll) dari bangsal (menu 'RL 3.2 Mapping Bangsal'); "
            + "bangsal umum/campur dari SPESIALIS DPJP (menu 'RL 3.2 Mapping Spesialis'). Alokasi TT dari bangsal. "
            + "Akhir Bulan = Awal+Masuk+Pindahan-KeluarHidup-Mati-Dipindahkan.";
        return res;
    }

    private static int idx(String j) {
        for (int i = 0; i < JENIS.length; i++) if (JENIS[i].equals(j)) return i + 1;
        return 0;
    }
}
