package rekammedis;

import fungsi.koneksiDB;
import java.awt.Component;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.swing.JComboBox;
import javax.swing.JOptionPane;
import javax.swing.text.JTextComponent;

public final class AmbilTTVSOAPSMC {
    private static final String SQL_KUNJUNGAN = "select no_rkm_medis,status_lanjut from reg_periksa where no_rawat=?";

    private static final String SQL_TTV_TERAKHIR = "select %1$s.no_rawat,%1$s.tgl_perawatan,%1$s.jam_rawat,%1$s.tensi,%1$s.nadi,%1$s.respirasi,"
            + "%1$s.suhu_tubuh,%1$s.spo2,%1$s.berat,%1$s.tinggi,%1$s.gcs,%1$s.kesadaran "
            + "from %1$s inner join reg_periksa on %1$s.no_rawat=reg_periksa.no_rawat "
            + "where reg_periksa.no_rkm_medis=? and (trim(ifnull(%1$s.suhu_tubuh,''))<>'' or trim(%1$s.tensi)<>'' or trim(ifnull(%1$s.nadi,''))<>'' or "
            + "trim(ifnull(%1$s.respirasi,''))<>'' or trim(ifnull(%1$s.tinggi,''))<>'' or trim(ifnull(%1$s.berat,''))<>'' or "
            + "trim(%1$s.spo2)<>'' or trim(ifnull(%1$s.gcs,''))<>'') "
            + "order by %1$s.tgl_perawatan desc,%1$s.jam_rawat desc limit 1";

    private AmbilTTVSOAPSMC() {
    }

    private static String bersih(String nilai) {
        if (nilai == null) {
            return "";
        }
        return nilai.trim();
    }

    private static String padanKesadaran(String nilai) {
        if ("Somnolence".equals(nilai)) {
            return "Somnolen";
        }
        if ("Coma".equals(nilai)) {
            return "Koma";
        }
        return "";
    }

    private static boolean adaPilihan(JComboBox<?> combo, String nilai) {
        if ("".equals(nilai)) {
            return false;
        }
        for (int i = 0; i < combo.getItemCount(); i++) {
            if (nilai.equals(String.valueOf(combo.getItemAt(i)))) {
                return true;
            }
        }
        return false;
    }

    private static String pilihanKesadaran(JComboBox<?> combo, String nilai) {
        if (combo == null || "".equals(nilai)) {
            return "";
        }
        if (adaPilihan(combo, nilai)) {
            return nilai;
        }
        String padan = padanKesadaran(nilai);
        if (adaPilihan(combo, padan)) {
            return padan;
        }
        return "";
    }

    private static void tambahBaris(StringBuilder pesan, String label, JTextComponent kolom, String nilai) {
        if (kolom != null && !"".equals(nilai)) {
            pesan.append(label).append(" : ").append(nilai).append("\n");
        }
    }

    private static void isiKolom(JTextComponent kolom, String nilai) {
        if (kolom != null && !"".equals(nilai)) {
            kolom.setText(nilai);
        }
    }

    public static void ambil(Component parent, String noRawat, JTextComponent td, JTextComponent nadi, JTextComponent rr, JTextComponent suhu,
            JTextComponent spo, JTextComponent bb, JTextComponent tb, JTextComponent gcs, JComboBox<?> kesadaran) {
        if ("".equals(bersih(noRawat))) {
            JOptionPane.showMessageDialog(parent, "Pasien belum dipilih...!!");
            return;
        }
        String noRM = "", sumber = "", tabel = "";
        String rawatSumber = "", tanggal = "", jam = "";
        String tensi = "", denyut = "", napas = "", suhuTubuh = "", saturasi = "", berat = "", tinggi = "", skorGcs = "", tingkatKesadaran = "";
        boolean ditemukan = false;
        try {
            try (PreparedStatement ps = koneksiDB.condb().prepareStatement(SQL_KUNJUNGAN)) {
                ps.setString(1, noRawat.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        noRM = bersih(rs.getString("no_rkm_medis"));
                        if ("Ranap".equals(rs.getString("status_lanjut"))) {
                            tabel = "pemeriksaan_ranap";
                            sumber = "Rawat Inap";
                        } else {
                            tabel = "pemeriksaan_ralan";
                            sumber = "Rawat Jalan";
                        }
                    }
                }
            }
            if ("".equals(noRM)) {
                JOptionPane.showMessageDialog(parent, "Data registrasi pasien tidak ditemukan...!!");
                return;
            }
            try (PreparedStatement ps = koneksiDB.condb().prepareStatement(String.format(SQL_TTV_TERAKHIR, tabel))) {
                ps.setString(1, noRM);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        ditemukan = true;
                        rawatSumber = bersih(rs.getString("no_rawat"));
                        tanggal = bersih(rs.getString("tgl_perawatan"));
                        jam = bersih(rs.getString("jam_rawat"));
                        tensi = bersih(rs.getString("tensi"));
                        denyut = bersih(rs.getString("nadi"));
                        napas = bersih(rs.getString("respirasi"));
                        suhuTubuh = bersih(rs.getString("suhu_tubuh"));
                        saturasi = bersih(rs.getString("spo2"));
                        berat = bersih(rs.getString("berat"));
                        tinggi = bersih(rs.getString("tinggi"));
                        skorGcs = bersih(rs.getString("gcs"));
                        tingkatKesadaran = bersih(rs.getString("kesadaran"));
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("Notif : " + e);
            JOptionPane.showMessageDialog(parent, "Gagal mengambil data TTV...!!");
            return;
        }
        if (!ditemukan) {
            JOptionPane.showMessageDialog(parent, "Pasien ini belum memiliki data TTV pada SOAP " + sumber + "...!!");
            return;
        }
        String pilihanKesadaran = pilihanKesadaran(kesadaran, tingkatKesadaran);
        StringBuilder pesan = new StringBuilder();
        pesan.append("Data TTV dari SOAP ").append(sumber).append(" terakhir pasien berikut akan disalin ke form ini :\n\n");
        pesan.append("No.Rawat : ").append(rawatSumber).append("\n");
        pesan.append("Tanggal/Jam : ").append(tanggal).append(" ").append(jam).append("\n\n");
        tambahBaris(pesan, "TD", td, tensi);
        tambahBaris(pesan, "Nadi", nadi, denyut);
        tambahBaris(pesan, "RR", rr, napas);
        tambahBaris(pesan, "Suhu", suhu, suhuTubuh);
        tambahBaris(pesan, "SpO2", spo, saturasi);
        tambahBaris(pesan, "BB", bb, berat);
        tambahBaris(pesan, "TB", tb, tinggi);
        tambahBaris(pesan, "GCS", gcs, skorGcs);
        if (kesadaran != null && !"".equals(tingkatKesadaran)) {
            if ("".equals(pilihanKesadaran)) {
                pesan.append("Kesadaran : ").append(tingkatKesadaran).append(" (tidak ada di pilihan form ini, tidak disalin)");
            } else if (pilihanKesadaran.equals(tingkatKesadaran)) {
                pesan.append("Kesadaran : ").append(pilihanKesadaran);
            } else {
                pesan.append("Kesadaran : ").append(pilihanKesadaran).append(" (SOAP : ").append(tingkatKesadaran).append(")");
            }
            pesan.append("\n");
        }
        pesan.append("\nData TTV yang sudah ada akan ditimpa. Lanjut?");
        if (JOptionPane.showConfirmDialog(parent, pesan.toString(), "Konfirmasi", JOptionPane.OK_CANCEL_OPTION, JOptionPane.QUESTION_MESSAGE) != JOptionPane.OK_OPTION) {
            return;
        }
        isiKolom(td, tensi);
        isiKolom(nadi, denyut);
        isiKolom(rr, napas);
        isiKolom(suhu, suhuTubuh);
        isiKolom(spo, saturasi);
        isiKolom(bb, berat);
        isiKolom(tb, tinggi);
        isiKolom(gcs, skorGcs);
        if (!"".equals(pilihanKesadaran)) {
            kesadaran.setSelectedItem(pilihanKesadaran);
        }
    }
}
