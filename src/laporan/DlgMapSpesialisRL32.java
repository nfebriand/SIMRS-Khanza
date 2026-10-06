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

/**
 * Form pemetaan kd_sps (spesialis DPJP) -> jenis pelayanan JUKNIS (SIRS RL 3.2).
 *
 * Dipakai laporan RL 3.2 mode HIBRIDA: untuk bangsal umum/campur, jenis pelayanan
 * pasien ditentukan dari SPESIALIS DPJP-nya. Baris menampilkan semua spesialis;
 * kolom Jenis Pelayanan bisa diedit lewat combo. Tombol "Auto-isi" mengisi ulang
 * tebakan otomatis dari nama spesialis. Tabel sirs_rl32_map_spesialis.
 */
public final class DlgMapSpesialisRL32 extends javax.swing.JDialog {

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

    public DlgMapSpesialisRL32(java.awt.Frame parent, boolean modal) {
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
        setTitle("Mapping Spesialis - Jenis Pelayanan RL 3.2");
        setUndecorated(true);
        setResizable(false);

        internalFrame1.setBorder(javax.swing.BorderFactory.createTitledBorder(
                javax.swing.BorderFactory.createLineBorder(new java.awt.Color(240, 245, 235)),
                "::[ Mapping Spesialis DPJP -> Jenis Pelayanan JUKNIS (RL 3.2) ]::",
                javax.swing.border.TitledBorder.DEFAULT_JUSTIFICATION,
                javax.swing.border.TitledBorder.DEFAULT_POSITION,
                new java.awt.Font("Tahoma", 0, 11), new java.awt.Color(50, 50, 50)));
        internalFrame1.setLayout(new BorderLayout(1, 1));

        tabMode = new DefaultTableModel(null, new String[]{"Kd Spesialis", "Nama Spesialis", "Jenis Pelayanan (JUKNIS)"}) {
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
        widget.Button btnHapus = tombol("Hapus", "/picture/delete-16x16.png", evt -> hapusBaris());
        widget.Button btnSimpan = tombol("Simpan", "/picture/accept.png", evt -> simpan());
        widget.Button btnAuto = tombol("Auto-isi", "/picture/refresh.png", evt -> autoIsi());
        widget.Button btnKeluar = tombol("Keluar", "/picture/exit.png", evt -> dispose());
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

    /** Muat semua spesialis; jenis dari mapping bila ada, selain itu tebakan otomatis. */
    private void muat() {
        tabMode.setRowCount(0);
        String sql = "SELECT sp.kd_sps, sp.nm_sps, m.jenis_pelayanan jmap "
                + "FROM spesialis sp "
                + "LEFT JOIN sirs_rl32_map_spesialis m ON m.kd_sps=sp.kd_sps "
                + "ORDER BY sp.nm_sps";
        try (PreparedStatement ps = koneksi.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String nm = rs.getString("nm_sps");
                String jmap = rs.getString("jmap");
                String jenis = (jmap == null || jmap.isEmpty()) ? tebak(nm == null ? "" : nm.toUpperCase()) : jmap;
                tabMode.addRow(new Object[]{rs.getString("kd_sps"), nm, jenis});
            }
        } catch (Exception e) {
            // Tabel override belum dibuat -> tetap tampilkan spesialis + tebakan otomatis.
            System.out.println("DlgMapSpesialisRL32 muat (tabel map belum ada?) : " + e);
            try (PreparedStatement ps = koneksi.prepareStatement("SELECT kd_sps, nm_sps FROM spesialis ORDER BY nm_sps");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String nm = rs.getString("nm_sps");
                    tabMode.addRow(new Object[]{rs.getString("kd_sps"), nm, tebak(nm == null ? "" : nm.toUpperCase())});
                }
            } catch (Exception e2) {
                JOptionPane.showMessageDialog(this, "Gagal memuat spesialis :\n" + e2);
            }
        }
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
        if (JOptionPane.showConfirmDialog(this, "Hapus mapping spesialis '" + nm + "'?",
                "Konfirmasi", JOptionPane.YES_NO_OPTION) != JOptionPane.YES_OPTION) return;
        try (PreparedStatement ps = koneksi.prepareStatement("DELETE FROM sirs_rl32_map_spesialis WHERE kd_sps=?")) {
            ps.setString(1, kd);
            ps.executeUpdate();
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "Gagal menghapus :\n" + e);
            return;
        }
        // kembalikan ke tebakan otomatis (bukan hapus baris — spesialisnya tetap ada).
        tabMode.setValueAt(tebak(nm.toUpperCase()), mr, 2);
    }

    /** Isi ulang kolom jenis dari tebakan otomatis nama spesialis. */
    private void autoIsi() {
        if (tbData.isEditing()) tbData.getCellEditor().stopCellEditing();
        for (int r = 0; r < tabMode.getRowCount(); r++) {
            String nm = String.valueOf(tabMode.getValueAt(r, 1)).toUpperCase();
            tabMode.setValueAt(tebak(nm), r, 2);
        }
    }

    /** Heuristik nama spesialis -> jenis pelayanan JUKNIS (mirror seed SQL 078). */
    private String tebak(String u) {
        if (u.contains("ORTHOP") || u.contains("ORTOP")) return "Bedah Orthopedi";
        if (u.contains("BEDAH") && (u.contains("SARAF") || u.contains("SYARAF"))) return "Bedah Saraf";
        if (u.contains("BEDAH")) return "Bedah";
        if (u.contains("DALAM") || u.contains("INTERNA")) return "Penyakit Dalam";
        if (u.contains("ANAK")) return "Kesehatan Anak";
        if (u.contains("GINEKOLOG")) return "Ginekologi";
        if (u.contains("OBSTETRI") || u.contains("KANDUNGAN") || u.contains("KEBIDANAN")
                || u.contains("OBGYN") || u.contains("OBSGYN") || u.contains("OBGIN")
                || u.contains("OBSGIN") || u.contains("GYN")) return "Obstetri";
        if (u.contains("SARAF") || u.contains("SYARAF") || u.contains("NEUROLOG")) return "Saraf";
        if (u.contains("JIWA") || u.contains("PSIKIATRI")) return "Jiwa";
        if (u.contains("THT")) return "THT";
        if (u.contains("MATA")) return "Mata";
        if (u.contains("KULIT")) return "Kulit dan Kelamin";
        if (u.contains("JANTUNG") || u.contains("KARDIO")) return "Kardiologi";
        if (u.contains("PARU") || u.contains("PULMONO")) return "Paru";
        if (u.contains("KANKER") || u.contains("ONKOLOG")) return "Kanker";
        if (u.contains("UROLOG") || u.contains("NEFROLOG")) return "Uronefrologi";
        if (u.contains("GERIATRI")) return "Geriatri";
        if (u.contains("GIGI") || u.contains("MULUT")) return "Gigi dan Mulut";
        if (u.contains("REHAB")) return "Rehabilitasi Medik";
        if (u.contains("RADIOTERAPI")) return "Radioterapi";
        if (u.contains("NUKLIR")) return "Kedokteran Nuklir";
        if (u.contains("KUSTA")) return "Kusta";
        return "Umum";
    }

    /** Simpan seluruh baris (upsert). */
    private void simpan() {
        if (tbData.isEditing()) tbData.getCellEditor().stopCellEditing();
        String u = akses.getkode() == null ? "" : akses.getkode();
        if (u.length() > 20) u = u.substring(0, 20);
        String sql = "INSERT INTO sirs_rl32_map_spesialis (kd_sps, jenis_pelayanan, updated_by) VALUES (?,?,?) "
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
            JOptionPane.showMessageDialog(this, "Mapping spesialis RL 3.2 berhasil disimpan.");
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "Gagal menyimpan :\n" + e);
            System.out.println("DlgMapSpesialisRL32 simpan : " + e);
        }
        this.setCursor(Cursor.getDefaultCursor());
    }

    public static void main(String[] args) {
        java.awt.EventQueue.invokeLater(() -> {
            DlgMapSpesialisRL32 d = new DlgMapSpesialisRL32(new javax.swing.JFrame(), true);
            d.addWindowListener(new java.awt.event.WindowAdapter() {
                @Override
                public void windowClosing(java.awt.event.WindowEvent e) { System.exit(0); }
            });
            d.setVisible(true);
        });
    }
}
