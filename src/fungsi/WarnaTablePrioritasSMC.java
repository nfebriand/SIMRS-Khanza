package fungsi;

import java.awt.Component;
import javax.swing.JTable;
import javax.swing.table.TableCellRenderer;

public class WarnaTablePrioritasSMC implements TableCellRenderer {
    private final TableCellRenderer dasar;
    private final int kolomPasien;
    private final int kolomPrioritas;

    public WarnaTablePrioritasSMC(TableCellRenderer dasar, int kolomPasien, int kolomPrioritas) {
        this.dasar = dasar;
        this.kolomPasien = kolomPasien;
        this.kolomPrioritas = kolomPrioritas;
    }

    @Override
    public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int column) {
        Component component = dasar.getTableCellRendererComponent(table, value, isSelected, hasFocus, row, column);
        PrioritasPasienSMC.hias(component, table, row, column, kolomPasien, kolomPrioritas);
        return component;
    }
}
