package laporan.sirs;

import java.util.ArrayList;
import java.util.List;

/**
 * Registry 30 formulir SIRS RL 6.3 (JUKNIS Kemenkes 2025) versi Khanza.
 * Sejalan dengan versi web simrs-dt-trimitra. Report = realtime dari DB Khanza;
 * RL 1.x & 2 = tampilan data entri (sirs_rl* tables, edit via web).
 */
public final class SirsRLRegistry {

    private SirsRLRegistry() { }

    public static List<SirsRLDef> all() {
        List<SirsRLDef> list = new ArrayList<>();
        list.add(new SirsRLDef("1.1", "Profil Rumah Sakit", "Update", new Rl11()));
        list.add(new SirsRLDef("1.2", "Ketersediaan Pelayanan", "Update", new Rl12()));
        list.add(new SirsRLDef("1.3", "Ketersediaan Tempat Tidur", "Update", new Rl13()));
        list.add(new SirsRLDef("1.4", "Sarana Prasarana & Alkes (ASPAK)", "Update", new Rl14()));
        list.add(new SirsRLDef("2", "Ketenagaan (SISDMK)", "Update", new Rl2()));
        list.add(new SirsRLDef("3.1", "Indikator Pelayanan (BOR/ALOS/BTO/TOI/NDR/GDR)", "Bulanan", new Rl31()));
        list.add(new SirsRLDef("3.2", "Rekapitulasi Kegiatan Rawat Inap", "Bulanan", new Rl32()));
        list.add(new SirsRLDef("3.3", "Rekapitulasi Kegiatan Rawat Darurat", "Bulanan", new Rl33()));
        list.add(new SirsRLDef("3.4", "Rekapitulasi Pengunjung", "Bulanan", new Rl34()));
        list.add(new SirsRLDef("3.5", "Rekapitulasi Kunjungan", "Bulanan", new Rl35()));
        list.add(new SirsRLDef("3.6", "Kegiatan Pelayanan Kebidanan", "Bulanan", new Rl36()));
        list.add(new SirsRLDef("3.7", "Neonatal, Bayi, dan Balita", "Bulanan", new Rl37()));
        list.add(new SirsRLDef("3.8", "Kegiatan Pelayanan Laboratorium", "Bulanan", new Rl38()));
        list.add(new SirsRLDef("3.9", "Kegiatan Pelayanan Radiologi", "Bulanan", new Rl39()));
        list.add(new SirsRLDef("3.10", "Rekapitulasi Rujukan", "Bulanan", new Rl310()));
        list.add(new SirsRLDef("3.11", "Kegiatan Pelayanan Gigi & Mulut", "Bulanan", new Rl311()));
        list.add(new SirsRLDef("3.12", "Kegiatan Pembedahan", "Bulanan", new Rl312()));
        list.add(new SirsRLDef("3.13", "Rehabilitasi Medik", "Tahunan", new Rl313()));
        list.add(new SirsRLDef("3.14", "Pelayanan Khusus", "Bulanan", new Rl314()));
        list.add(new SirsRLDef("3.15", "Kesehatan Jiwa", "Bulanan", new Rl315()));
        list.add(new SirsRLDef("3.16", "Keluarga Berencana", "Bulanan", new Rl316()));
        list.add(new SirsRLDef("3.17", "Farmasi RS - Pengadaan Obat", "Tahunan", new Rl317()));
        list.add(new SirsRLDef("3.18", "Farmasi RS - Resep", "Tahunan", new Rl318()));
        list.add(new SirsRLDef("3.19", "Rekapitulasi Cara Bayar", "Tahunan", new Rl319()));
        list.add(new SirsRLDef("4.1", "Kompilasi Morbiditas Pasien Rawat Inap (ICD-10)", "Bulanan", new Rl41()));
        list.add(new SirsRLDef("4.2", "10 Besar Penyakit Rawat Inap", "Bulanan", new Rl42()));
        list.add(new SirsRLDef("4.3", "10 Besar Kematian Rawat Inap", "Bulanan", new Rl43()));
        list.add(new SirsRLDef("5.1", "Kompilasi Morbiditas Pasien Rawat Jalan (ICD-10)", "Bulanan", new Rl51()));
        list.add(new SirsRLDef("5.2", "10 Besar Kasus Baru Rawat Jalan", "Bulanan", new Rl52()));
        list.add(new SirsRLDef("5.3", "10 Besar Kunjungan Rawat Jalan", "Bulanan", new Rl53()));
        return list;
    }
}
