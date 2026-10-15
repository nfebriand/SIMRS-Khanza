package fungsi;

import java.awt.Component;
import javax.swing.JTable;

public class WarnaTableRegistrasiSMC extends WarnaTableRegistrasi {
    private final int kolomPasien;
    private final int kolomPrioritas;

    public WarnaTableRegistrasiSMC(int kolomPasien, int kolomPrioritas) {
        this.kolomPasien = kolomPasien;
        this.kolomPrioritas = kolomPrioritas;
    }

    @Override
    public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int column) {
        Component component = super.getTableCellRendererComponent(table, value, isSelected, hasFocus, row, column);
        PrioritasPasienSMC.hias(component, table, row, column, kolomPasien, kolomPrioritas);
        return component;
    }
}
