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
 * Form pemetaan kd_poli -> 34 jenis kegiatan JUKNIS (SIRS RL 3.5).
 *
 * Tabel sirs_rl35_map_poli dipakai laporan RL 3.5 supaya baris mengikuti 34
 * jenis kegiatan baku JUKNIS (bukan nama poli mentah). Baris menampilkan SEMUA
 * poliklinik aktif; kolom Jenis Kegiatan bisa diedit lewat combo. Tombol
 * "Auto-isi" mengisi ulang tebakan otomatis dari nama poli. Sepadan dengan
 * DlgMapBangsalRL32 (RL 3.2).
 */
public final class DlgMapPoliRL35 extends javax.swing.JDialog {

    /** 34 jenis kegiatan baku JUKNIS RL 3.5. */
    private static final String[] JENIS = {
        "Penyakit Dalam", "Bedah", "Kesehatan Anak (Neonatal)", "Kesehatan Anak (Lainnya)",
        "Obstetri & Ginekologi (Ibu Hamil)", "Obstetri & Ginekologi (Lainnya)", "Keluarga Berencana",
        "Jiwa", "Napza", "Psikologi", "THT", "Mata", "Kulit dan Kelamin", "Gigi & Mulut", "Geriatri",
        "Kardiologi", "Radiologi", "Bedah Orthopedi", "Paru - Paru", "Kanker", "Uronefrologi", "Kusta",
        "Umum", "Rawat Darurat", "Rehabilitasi Medik", "Akupungtur Medik", "Konsultasi Gizi", "Day Care",
        "Medical Check Up", "Bedah Saraf (Stroke)", "Bedah Saraf (Lainnya)", "Saraf (Stroke)",
        "Saraf (Lainnya)", "Lain - Lain"
    };

    private final validasi Valid = new validasi();
    private final Connection koneksi = koneksiDB.condb();
    private DefaultTableModel tabMode;

    private widget.InternalFrame internalFrame1;
    private widget.ScrollPane Scroll;
    private widget.Table tbData;
    private widget.panelisi panelBawah;

    public DlgMapPoliRL35(java.awt.Frame parent, boolean modal) {
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
        setTitle("Mapping Poli - Jenis Kegiatan RL 3.5");
        setUndecorated(true);
        setResizable(false);

        internalFrame1.setBorder(javax.swing.BorderFactory.createTitledBorder(
                javax.swing.BorderFactory.createLineBorder(new java.awt.Color(240, 245, 235)),
                "::[ Mapping Poliklinik -> Jenis Kegiatan JUKNIS (RL 3.5) ]::",
                javax.swing.border.TitledBorder.DEFAULT_JUSTIFICATION,
                javax.swing.border.TitledBorder.DEFAULT_POSITION,
                new java.awt.Font("Tahoma", 0, 11), new java.awt.Color(50, 50, 50)));
        internalFrame1.setLayout(new BorderLayout(1, 1));

        tabMode = new DefaultTableModel(null, new String[]{"Kd Poli", "Nama Poliklinik", "Jenis Kegiatan (JUKNIS)"}) {
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
        widget.Button btnTambah = tombol("Tambah", "/picture/add-file-16x16.png", evt -> cariPoliTambah());
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

    /** Muat poli aktif ATAU yang sudah dipetakan manual (LEFT JOIN mapping). */
    private void muat() {
        tabMode.setRowCount(0);
        String sql = "SELECT pl.kd_poli, pl.nm_poli, IFNULL(m.jenis_kunjungan,'Lain - Lain') jenis "
                + "FROM poliklinik pl "
                + "LEFT JOIN sirs_rl35_map_poli m ON m.kd_poli=pl.kd_poli "
                + "WHERE pl.status='1' OR m.kd_poli IS NOT NULL "
                + "ORDER BY pl.nm_poli";
        try (PreparedStatement ps = koneksi.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                tabMode.addRow(new Object[]{rs.getString("kd_poli"), rs.getString("nm_poli"), rs.getString("jenis")});
            }
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "Gagal memuat poliklinik :\n" + e);
            System.out.println("DlgMapPoliRL35 muat : " + e);
        }
    }

    /** Tambah poli manual lewat pencari poli (DlgCariPoli). */
    private void cariPoliTambah() {
        if (tbData.isEditing()) tbData.getCellEditor().stopCellEditing();
        simrskhanza.DlgCariPoli dp = new simrskhanza.DlgCariPoli(null, true);
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
        if (JOptionPane.showConfirmDialog(this, "Hapus mapping poli '" + nm + "'?",
                "Konfirmasi", JOptionPane.YES_NO_OPTION) != JOptionPane.YES_OPTION) return;
        try (PreparedStatement ps = koneksi.prepareStatement("DELETE FROM sirs_rl35_map_poli WHERE kd_poli=?")) {
            ps.setString(1, kd);
            ps.executeUpdate();
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "Gagal menghapus :\n" + e);
            return;
        }
        tabMode.removeRow(mr);
    }

    /** Isi ulang kolom jenis dari tebakan otomatis nama poli. */
    private void autoIsi() {
        if (tbData.isEditing()) tbData.getCellEditor().stopCellEditing();
        for (int r = 0; r < tabMode.getRowCount(); r++) {
            String nm = String.valueOf(tabMode.getValueAt(r, 1)).toUpperCase();
            tabMode.setValueAt(tebak(nm), r, 2);
        }
    }

    /** Heuristik nama poli -> jenis kegiatan JUKNIS (mirror seed SQL). */
    private String tebak(String u) {
        if (u.contains("NEONAT") || u.contains("BAYI BARU LAHIR") || u.contains("PERINA")) return "Kesehatan Anak (Neonatal)";
        if (u.contains("ANAK")) return "Kesehatan Anak (Lainnya)";
        if (u.contains("HAMIL") || u.contains("ANTENATAL") || u.contains("ANC")) return "Obstetri & Ginekologi (Ibu Hamil)";
        if (u.contains("KANDUNGAN") || u.contains("OBSTETRI") || u.contains("GINEKOLOG") || u.contains("KEBIDANAN") || u.contains("OBGYN")) return "Obstetri & Ginekologi (Lainnya)";
        if (u.contains("KELUARGA BERENCANA") || u.matches(".*(^| )KB( |$).*")) return "Keluarga Berencana";
        if (u.contains("ORTHOP") || u.contains("ORTOP")) return "Bedah Orthopedi";
        if (u.contains("BEDAH MULUT")) return "Gigi & Mulut";
        if (u.contains("BEDAH SARAF") || u.contains("BEDAH SYARAF")) return "Bedah Saraf (Lainnya)";
        if (u.contains("BEDAH")) return "Bedah";
        if (u.contains("GIGI") || u.contains("MULUT") || u.contains("KONSERVASI")) return "Gigi & Mulut";
        if (u.contains("JANTUNG") || u.contains("KARDIO")) return "Kardiologi";
        if (u.contains("MATA")) return "Mata";
        if (u.contains("PARU")) return "Paru - Paru";
        if (u.contains("DALAM") || u.contains("INTERNA") || u.contains("INTERNIS")) return "Penyakit Dalam";
        if (u.contains("RADIO")) return "Radiologi";
        if (u.contains("REHAB") || u.contains("FISIOTERAP")) return "Rehabilitasi Medik";
        if (u.contains("STROKE")) return "Saraf (Stroke)";
        if (u.contains("SARAF") || u.contains("SYARAF") || u.contains("NEURO")) return "Saraf (Lainnya)";
        if (u.contains("THT")) return "THT";
        if (u.contains("URO")) return "Uronefrologi";
        if (u.contains("KULIT") || u.contains("KELAMIN")) return "Kulit dan Kelamin";
        if (u.contains("NAPZA")) return "Napza";
        if (u.contains("PSIKOLOG")) return "Psikologi";
        if (u.contains("JIWA") || u.contains("PSIKIATRI")) return "Jiwa";
        if (u.contains("GERIATRI") || u.contains("LANSIA")) return "Geriatri";
        if (u.contains("KANKER") || u.contains("ONKOLOG")) return "Kanker";
        if (u.contains("KUSTA")) return "Kusta";
        if (u.contains("AKUPUN")) return "Akupungtur Medik";
        if (u.contains("GIZI")) return "Konsultasi Gizi";
        if (u.contains("DAY CARE")) return "Day Care";
        if (u.contains("MCU") || u.contains("MEDICAL CHECK")) return "Medical Check Up";
        if (u.contains("IGD") || u.contains("GAWAT DARURAT") || u.contains("UGD")) return "Rawat Darurat";
        if (u.contains("UMUM") || u.contains("VAKSIN") || u.contains("IMUN")) return "Umum";
        return "Lain - Lain";
    }

    /** Simpan seluruh baris (upsert). */
    private void simpan() {
        if (tbData.isEditing()) tbData.getCellEditor().stopCellEditing();
        String u = akses.getkode() == null ? "" : akses.getkode();
        if (u.length() > 20) u = u.substring(0, 20);
        String sql = "INSERT INTO sirs_rl35_map_poli (kd_poli, jenis_kunjungan, updated_by) VALUES (?,?,?) "
                + "ON DUPLICATE KEY UPDATE jenis_kunjungan=VALUES(jenis_kunjungan), updated_by=VALUES(updated_by), updated_at=NOW()";
        this.setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
        try (PreparedStatement ps = koneksi.prepareStatement(sql)) {
            for (int r = 0; r < tabMode.getRowCount(); r++) {
                ps.setString(1, String.valueOf(tabMode.getValueAt(r, 0)));
                ps.setString(2, String.valueOf(tabMode.getValueAt(r, 2)));
                ps.setString(3, u);
                ps.addBatch();
            }
            ps.executeBatch();
            JOptionPane.showMessageDialog(this, "Mapping poli RL 3.5 berhasil disimpan.");
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "Gagal menyimpan :\n" + e);
            System.out.println("DlgMapPoliRL35 simpan : " + e);
        }
        this.setCursor(Cursor.getDefaultCursor());
    }

    public static void main(String[] args) {
        java.awt.EventQueue.invokeLater(() -> {
            DlgMapPoliRL35 d = new DlgMapPoliRL35(new javax.swing.JFrame(), true);
            d.addWindowListener(new java.awt.event.WindowAdapter() {
                @Override
                public void windowClosing(java.awt.event.WindowEvent e) { System.exit(0); }
            });
            d.setVisible(true);
        });
    }
}
