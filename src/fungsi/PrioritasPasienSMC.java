package fungsi;

import java.awt.Color;
import java.awt.Component;
import java.awt.Font;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.swing.JTable;
import javax.swing.table.DefaultTableModel;

public final class PrioritasPasienSMC {
    public static final String EKSPRESI = "if(reg_periksa.kd_poli = 'IGDK', '', concat_ws(', ', if(exists(select 1 from prioritas_pasien_smc where prioritas_pasien_smc.no_rawat = reg_periksa.no_rawat), " +
        "'Ibu Hamil', null), if(reg_periksa.sttsumur = 'Th' and reg_periksa.umurdaftar >= 60, 'Lansia', null)))";
    public static final String KOLOM = EKSPRESI + " as prioritas_smc";
    public static final String URUT = "(prioritas_smc <> '') desc, if(prioritas_smc <> '', concat(reg_periksa.tgl_registrasi, ' ', reg_periksa.jam_reg), null), ";
    public static final String BASIS_BANNER = "select " + EKSPRESI + " from reg_periksa where reg_periksa.no_rawat = ?";
    public static final Color WARNA_HAMIL = new Color(214, 51, 132);
    public static final Color WARNA_LANSIA = new Color(255, 193, 7);

    private PrioritasPasienSMC() {
    }

    public static void hias(Component component, JTable table, int row, int column, int kolomPasien, int kolomPrioritas) {
        Object nilai = table.getModel().getValueAt(table.convertRowIndexToModel(row), kolomPrioritas);
        String prioritas = null == nilai ? "" : nilai.toString();
        if ("".equals(prioritas)) {
            return;
        }
        int kolomModel = table.convertColumnIndexToModel(column);
        if (kolomModel == kolomPasien) {
            component.setFont(component.getFont().deriveFont(Font.BOLD));
        } else if (kolomModel == kolomPrioritas) {
            if (prioritas.contains("Ibu Hamil")) {
                component.setBackground(WARNA_HAMIL);
                component.setForeground(new Color(255, 255, 255));
            } else {
                component.setBackground(WARNA_LANSIA);
                component.setForeground(new Color(50, 50, 50));
            }
            component.setFont(component.getFont().deriveFont(Font.BOLD));
        }
    }

    public static void isi(DefaultTableModel model, int kolomNoRawat, int kolomPrioritas) {
        Set<String> kumpulan = new LinkedHashSet<>();
        for (int i = 0; i < model.getRowCount(); i++) {
            Object nilai = model.getValueAt(i, kolomNoRawat);
            if (null != nilai && !nilai.toString().isBlank()) {
                kumpulan.add(nilai.toString());
            }
        }
        if (kumpulan.isEmpty()) {
            return;
        }
        Map<String, String> hasil = new HashMap<>();
        List<String> daftar = new ArrayList<>(kumpulan);
        for (int awal = 0; awal < daftar.size(); awal += 500) {
            List<String> bagian = daftar.subList(awal, Math.min(awal + 500, daftar.size()));
            String tandaTanya = String.join(", ", Collections.nCopies(bagian.size(), "?"));
            try (PreparedStatement ps = koneksiDB.condb().prepareStatement("select reg_periksa.no_rawat, " + KOLOM + " from reg_periksa where reg_periksa.no_rawat in (" + tandaTanya + ")")) {
                for (int i = 0; i < bagian.size(); i++) {
                    ps.setString(i + 1, bagian.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        hasil.put(rs.getString(1), rs.getString(2));
                    }
                }
            } catch (Exception e) {
                System.out.println("Notif : " + e);
            }
        }
        for (int i = 0; i < model.getRowCount(); i++) {
            Object nilai = model.getValueAt(i, kolomNoRawat);
            if (null != nilai && !nilai.toString().isBlank()) {
                String prioritas = hasil.get(nilai.toString());
                model.setValueAt(null == prioritas ? "" : prioritas, i, kolomPrioritas);
            }
        }
    }
}
