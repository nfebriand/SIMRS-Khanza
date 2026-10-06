package laporan;

import fungsi.WarnaTable;
import fungsi.akses;
import fungsi.koneksiDB;
import fungsi.validasi;
import java.awt.BorderLayout;
import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.swing.DefaultCellEditor;
import javax.swing.JComboBox;
import javax.swing.JOptionPane;
import javax.swing.JTable;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.TableColumn;

/**
 * Form pemetaan kd_bangsal -> jenis pelayanan JUKNIS (SIRS RL 3.2).
 *
 * Tabel sirs_rl32_map_bangsal dipakai laporan RL 3.2 supaya baris mengikuti 36
 * jenis pelayanan baku JUKNIS (bukan nama bangsal mentah). Baris menampilkan
 * semua bangsal RAWAT INAP (punya kamar aktif); kolom Jenis Pelayanan bisa
 * diedit lewat combo. Tombol "Auto-isi" mengisi ulang tebakan otomatis dari
 * nama bangsal.
 */
public final class DlgMapBangsalRL32 extends javax.swing.JDialog {

    /** 36 jenis pelayanan baku JUKNIS RL 3.2. */
    private static final String[] JENIS = {
        "Umum", "Penyakit Dalam", "Kesehatan Anak", "Kesehatan Remaja", "Obstetri", "Ginekologi",
        "Bedah", "Bedah Orthopedi", "Bedah Saraf", "Luka Bakar", "Saraf", "Jiwa", "Psikologi",
        "Penatalaksana Penyalahgunaan NAPZA", "THT", "Mata", "Kulit dan Kelamin", "Kardiologi",
        "Paru", "Kanker", "Uronefrologi", "Geriatri", "Kusta", "Radioterapi", "Kedokteran Nuklir",
        "Rehabilitasi Medik", "ICU", "HCU", "ICCU/ICVCU", "RICU", "NICU", "PICU", "Isolasi",
        "Gigi dan Mulut", "Pelayanan Rawat Darurat", "Perinatologi"
    };

    private final validasi Valid = new validasi();
    private final Connection koneksi = koneksiDB.condb();
    private DefaultTableModel tabMode;

    private widget.InternalFrame internalFrame1;
    private widget.ScrollPane Scroll;
    private widget.Table tbData;
    private widget.panelisi panelBawah;

    public DlgMapBangsalRL32(java.awt.Frame parent, boolean modal) {
        super(parent, modal);
        initFrame();
        muat();
        pack();
        setSize(720, 560);
        setLocationRelativeTo(null);
    }

    private void initFrame() {
        internalFrame1 = new widget.InternalFrame();
        Scroll = new widget.ScrollPane();
        panelBawah = new widget.panelisi();

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        setTitle("Mapping Bangsal - Jenis Pelayanan RL 3.2");
        setUndecorated(true);
        setResizable(false);

        internalFrame1.setBorder(javax.swing.BorderFactory.createTitledBorder(
                javax.swing.BorderFactory.createLineBorder(new java.awt.Color(240, 245, 235)),
                "::[ Mapping Bangsal -> Jenis Pelayanan JUKNIS (RL 3.2) ]::",
                javax.swing.border.TitledBorder.DEFAULT_JUSTIFICATION,
                javax.swing.border.TitledBorder.DEFAULT_POSITION,
                new java.awt.Font("Tahoma", 0, 11), new java.awt.Color(50, 50, 50)));
        internalFrame1.setLayout(new BorderLayout(1, 1));

        tabMode = new DefaultTableModel(null, new String[]{"Kd Bangsal", "Nama Bangsal", "Jenis Pelayanan (JUKNIS)"}) {
            @Override
            public boolean isCellEditable(int r, int c) { return c == 2; }
        };
        tbData = new widget.Table();
        tbData.setModel(tabMode);
        tbData.setAutoResizeMode(JTable.AUTO_RESIZE_OFF);
        tbData.setDefaultRenderer(Object.class, new WarnaTable());
        tbData.setRowHeight(22);
        Scroll.setViewportView(tbData);
        internalFrame1.add(Scroll, BorderLayout.CENTER);

        int[] w = {90, 260, 300};
        for (int i = 0; i < w.length; i++) tbData.getColumnModel().getColumn(i).setPreferredWidth(w[i]);
        JComboBox<String> cb = new JComboBox<>(JENIS);
        tbData.getColumnModel().getColumn(2).setCellEditor(new DefaultCellEditor(cb));

        panelBawah.setPreferredSize(new Dimension(55, 47));
        panelBawah.setLayout(new FlowLayout(FlowLayout.LEFT, 5, 9));
        widget.Button btnTambah = tombol("Tambah", "/picture/add-file-16x16.png", evt -> cariBangsalTambah());
        widget.Button btnHapus = tombol("Hapus", "/picture/delete-16x16.png", evt -> hapusBaris());
        widget.Button btnSimpan = tombol("Simpan", "/picture/accept.png", evt -> simpan());
        widget.Button btnAuto = tombol("Auto-isi", "/picture/refresh.png", evt -> autoIsi());
        widget.Button btnKeluar = tombol("Keluar", "/picture/exit.png", evt -> dispose());
        panelBawah.add(btnTambah);
        panelBawah.add(btnHapus);
        panelBawah.add(btnSimpan);
        panelBawah.add(btnAuto);
        panelBawah.add(btnKeluar);
        internalFrame1.add(panelBawah, BorderLayout.PAGE_END);

        getContentPane().add(internalFrame1, BorderLayout.CENTER);
    }

    private widget.Button tombol(String teks, String ikonPath, java.awt.event.ActionListener act) {
        widget.Button b = new widget.Button();
        java.net.URL u = getClass().getResource(ikonPath);
        if (u != null) b.setIcon(new javax.swing.ImageIcon(u));
        b.setText(teks);
        b.setPreferredSize(new Dimension(Math.max(100, 24 + teks.length() * 9), 30));
        b.addActionListener(act);
        return b;
    }

    /** Muat bangsal rawat inap (punya kamar) ATAU yang sudah dipetakan manual. */
    private void muat() {
        tabMode.setRowCount(0);
        String sql = "SELECT b.kd_bangsal, b.nm_bangsal, IFNULL(m.jenis_pelayanan,'Umum') jenis "
                + "FROM bangsal b "
                + "LEFT JOIN sirs_rl32_map_bangsal m ON m.kd_bangsal=b.kd_bangsal "
                + "WHERE b.status='1' AND ("
                + "  EXISTS(SELECT 1 FROM kamar k WHERE k.kd_bangsal=b.kd_bangsal AND k.statusdata='1') "
                + "  OR m.kd_bangsal IS NOT NULL) "
                + "ORDER BY b.nm_bangsal";
        try (PreparedStatement ps = koneksi.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                tabMode.addRow(new Object[]{rs.getString("kd_bangsal"), rs.getString("nm_bangsal"), rs.getString("jenis")});
            }
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "Gagal memuat bangsal :\n" + e);
            System.out.println("DlgMapBangsalRL32 muat : " + e);
        }
    }

    /** Tambah bangsal manual lewat pencari bangsal (DlgCariBangsal). */
    private void cariBangsalTambah() {
        if (tbData.isEditing()) tbData.getCellEditor().stopCellEditing();
        simrskhanza.DlgCariBangsal dp = new simrskhanza.DlgCariBangsal(null, true);
        try { dp.emptTeks(); } catch (Exception ignore) { }
        try { dp.isCek(); } catch (Exception ignore) { }
        dp.setSize(700, 450);
        dp.setLocationRelativeTo(this);
        dp.setVisible(true);
        int r = dp.getTable().getSelectedRow();
        if (r < 0) return;
        String kd = String.valueOf(dp.getTable().getValueAt(r, 0));
        String nm = String.valueOf(dp.getTable().getValueAt(r, 1));
        // sudah ada? pilih barisnya.
        for (int i = 0; i < tabMode.getRowCount(); i++) {
            if (kd.equals(String.valueOf(tabMode.getValueAt(i, 0)))) {
                tbData.setRowSelectionInterval(i, i);
                tbData.scrollRectToVisible(tbData.getCellRect(i, 0, true));
                return;
            }
        }
        tabMode.addRow(new Object[]{kd, nm, tebak(nm.toUpperCase())});
        int last = tabMode.getRowCount() - 1;
        tbData.setRowSelectionInterval(last, last);
        tbData.scrollRectToVisible(tbData.getCellRect(last, 0, true));
    }

    /** Hapus mapping baris terpilih (dari DB + tabel). */
    private void hapusBaris() {
        int r = tbData.getSelectedRow();
        if (r < 0) {
            JOptionPane.showMessageDialog(this, "Pilih baris yang akan dihapus dulu.");
            return;
        }
        if (tbData.isEditing()) tbData.getCellEditor().stopCellEditing();
        int mr = tbData.convertRowIndexToModel(r);
        String kd = String.valueOf(tabMode.getValueAt(mr, 0));
        String nm = String.valueOf(tabMode.getValueAt(mr, 1));
        if (JOptionPane.showConfirmDialog(this, "Hapus mapping bangsal '" + nm + "'?",
                "Konfirmasi", JOptionPane.YES_NO_OPTION) != JOptionPane.YES_OPTION) return;
        try (PreparedStatement ps = koneksi.prepareStatement("DELETE FROM sirs_rl32_map_bangsal WHERE kd_bangsal=?")) {
            ps.setString(1, kd);
            ps.executeUpdate();
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "Gagal menghapus :\n" + e);
            return;
        }
        tabMode.removeRow(mr);
    }

    /** Isi ulang kolom jenis dari tebakan otomatis nama bangsal. */
    private void autoIsi() {
        if (tbData.isEditing()) tbData.getCellEditor().stopCellEditing();
        for (int r = 0; r < tabMode.getRowCount(); r++) {
            String nm = String.valueOf(tabMode.getValueAt(r, 1)).toUpperCase();
            tabMode.setValueAt(tebak(nm), r, 2);
        }
    }

    /** Heuristik nama bangsal -> jenis pelayanan JUKNIS (mirror seed SQL). */
    private String tebak(String u) {
        if (u.contains("NICU")) return "NICU";
        if (u.contains("PICU")) return "PICU";
        if (u.contains("ICCU") || u.contains("ICVCU")) return "ICCU/ICVCU";
        if (u.contains("RICU")) return "RICU";
        if (u.contains("HCU")) return "HCU";
        if (u.contains("ICU")) return "ICU";
        if (u.contains("ISOLAS")) return "Isolasi";
        if (u.contains("PERINA") || u.contains("RUANG BAYI") || u.contains("NEONAT")) return "Perinatologi";
        if (u.contains("VK") || u.contains("NIFAS") || u.contains("BERSALIN") || u.contains("OBSTETRI")
                || u.contains("KEBIDANAN") || u.contains("BIDAN")) return "Obstetri";
        if (u.contains("ANAK")) return "Kesehatan Anak";
        if (u.contains("BEDAH") || u.contains("OPERASI") || u.equals("OK") || u.equals("KO")) return "Bedah";
        if (u.contains("PARU")) return "Paru";
        if (u.contains("JANTUNG") || u.contains("KARDIO")) return "Kardiologi";
        if (u.contains("SARAF") || u.contains("SYARAF") || u.contains("STROKE") || u.contains("NEURO")) return "Saraf";
        if (u.contains("DALAM") || u.contains("INTERNA")) return "Penyakit Dalam";
        if (u.contains("IGD") || u.contains("GAWAT DARURAT")) return "Pelayanan Rawat Darurat";
        return "Umum";
    }

    /** Simpan seluruh baris (upsert). */
    private void simpan() {
        if (tbData.isEditing()) tbData.getCellEditor().stopCellEditing();
        String u = akses.getkode() == null ? "" : akses.getkode();
        if (u.length() > 20) u = u.substring(0, 20);
        String sql = "INSERT INTO sirs_rl32_map_bangsal (kd_bangsal, jenis_pelayanan, updated_by) VALUES (?,?,?) "
                + "ON DUPLICATE KEY UPDATE jenis_pelayanan=VALUES(jenis_pelayanan), updated_by=VALUES(updated_by), updated_at=NOW()";
        this.setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
        try (PreparedStatement ps = koneksi.prepareStatement(sql)) {
            for (int r = 0; r < tabMode.getRowCount(); r++) {
                ps.setString(1, String.valueOf(tabMode.getValueAt(r, 0)));
                ps.setString(2, String.valueOf(tabMode.getValueAt(r, 2)));
                ps.setString(3, u);
                ps.addBatch();
            }
            ps.executeBatch();
            JOptionPane.showMessageDialog(this, "Mapping bangsal RL 3.2 berhasil disimpan.");
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "Gagal menyimpan :\n" + e);
            System.out.println("DlgMapBangsalRL32 simpan : " + e);
        }
        this.setCursor(Cursor.getDefaultCursor());
    }

    public static void main(String[] args) {
        java.awt.EventQueue.invokeLater(() -> {
            DlgMapBangsalRL32 d = new DlgMapBangsalRL32(new javax.swing.JFrame(), true);
            d.addWindowListener(new java.awt.event.WindowAdapter() {
                @Override
                public void windowClosing(java.awt.event.WindowEvent e) { System.exit(0); }
            });
            d.setVisible(true);
        });
    }
}
