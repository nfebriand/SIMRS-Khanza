package simrskhanza;

import fungsi.koneksiDB;
import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.swing.BorderFactory;
import javax.swing.ButtonGroup;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.ListSelectionModel;
import javax.swing.SwingUtilities;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.TableModelEvent;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.TableColumn;
import widget.Button;
import widget.CekBox;
import widget.Label;
import widget.PanelBiasa;
import widget.ScrollPane;
import widget.Table;
import widget.TextBox;

public final class DlgSDKIOTEK extends JDialog {

    private final Connection koneksi = koneksiDB.condb();

    private DefaultTableModel modelSDKI;
    private DefaultTableModel modelSIKI;

    private final Map<Long, Boolean> selectedDetail = new LinkedHashMap<>();
    private final Map<Integer, String> namaOtek = new LinkedHashMap<>();
    private final Map<Integer, String> singkatOtek = new LinkedHashMap<>();

    private final CekBox chkOBS = new CekBox();
    private final CekBox chkTER = new CekBox();
    private final CekBox chkEDU = new CekBox();
    private final CekBox chkKOL = new CekBox();

    private final TextBox TCari = new TextBox();
    private final Button BtnCari = new Button();
    private final Button BtnPilihSDKI = new Button();
    private final Button BtnTerapkan = new Button();
    private final Button BtnBatal = new Button();

    private final Table tbSDKI = new Table();
    private final Table tbSIKI = new Table();
    private final ScrollPane scrollSDKI = new ScrollPane();
    private final ScrollPane scrollSIKI = new ScrollPane();

    private boolean loadingTable = false;
    private boolean sukses = false;

    private int sdkiId = 0;
    private String asesmen = "";
    private String plan = "";
    private String instruksi = "";

    public DlgSDKIOTEK(java.awt.Frame parent, boolean modal) {
        super(parent, modal);
        initComponents();
        loadOtek();
        loadSDKI();
    }

    private void initComponents() {
        setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
        setTitle("Pemilihan SDKI / SIKI / OTEK");
        setMinimumSize(new Dimension(1050, 650));
        setSize(1120, 700);
        setLocationRelativeTo(getOwner());

        JPanel root = new JPanel(new BorderLayout(5, 5));
        root.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));
        setContentPane(root);

        PanelBiasa panelKiri = new PanelBiasa();
        panelKiri.setLayout(new BorderLayout(5, 5));
        panelKiri.setBorder(BorderFactory.createTitledBorder(
                BorderFactory.createLineBorder(new java.awt.Color(210, 215, 205)),
                " Diagnosis SDKI "));

        PanelBiasa panelKanan = new PanelBiasa();
        panelKanan.setLayout(new BorderLayout(5, 5));
        panelKanan.setBorder(BorderFactory.createTitledBorder(
                BorderFactory.createLineBorder(new java.awt.Color(210, 215, 205)),
                " SDKI / SIKI / OTEK "));

        PanelBiasa panelCari = new PanelBiasa(new FlowLayout(FlowLayout.LEFT, 4, 3));
        Label lblCari = new Label();
        lblCari.setText("Cari :");
        lblCari.setPreferredSize(new Dimension(45, 25));

        TCari.setPreferredSize(new Dimension(250, 25));
        BtnCari.setText("Cari");
        BtnCari.setPreferredSize(new Dimension(65, 25));
        BtnCari.setMargin(new Insets(2, 5, 2, 5));

        panelCari.add(lblCari);
        panelCari.add(TCari);
        panelCari.add(BtnCari);

        modelSDKI = new DefaultTableModel(
                new Object[][]{},
                new Object[]{"Kode", "Diagnosis", "ID"}) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };

        tbSDKI.setModel(modelSDKI);
        tbSDKI.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        tbSDKI.setAutoResizeMode(Table.AUTO_RESIZE_LAST_COLUMN);
        tbSDKI.setPreferredScrollableViewportSize(new Dimension(400, 450));
        aturKolomSDKI();

        scrollSDKI.setViewportView(tbSDKI);
        panelKiri.add(panelCari, BorderLayout.NORTH);
        panelKiri.add(scrollSDKI, BorderLayout.CENTER);

        PanelBiasa panelPilihSDKI = new PanelBiasa(new FlowLayout(FlowLayout.RIGHT, 4, 3));
        BtnPilihSDKI.setText("Pilih SDKI");
        BtnPilihSDKI.setPreferredSize(new Dimension(100, 28));
        panelPilihSDKI.add(BtnPilihSDKI);
        panelKiri.add(panelPilihSDKI, BorderLayout.SOUTH);

        PanelBiasa panelFilter = new PanelBiasa(new FlowLayout(FlowLayout.LEFT, 10, 3));

        chkOBS.setText("OBSERVASI");
        chkTER.setText("TERAPEUTIK");
        chkEDU.setText("EDUKASI");
        chkKOL.setText("KOLABORASI");

        chkOBS.setSelected(true);
        chkTER.setSelected(true);
        chkEDU.setSelected(true);
        chkKOL.setSelected(true);

        panelFilter.add(chkOBS);
        panelFilter.add(chkTER);
        panelFilter.add(chkEDU);
        panelFilter.add(chkKOL);

        modelSIKI = new DefaultTableModel(
                new Object[][]{},
                new Object[]{"Pilih", "X", "SIKI", "Tindakan", "DetailID", "OtekID"}) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return column == 0;
            }

            @Override
            public Class<?> getColumnClass(int column) {
                return column == 0 ? Boolean.class : Object.class;
            }
        };

        tbSIKI.setModel(modelSIKI);
        tbSIKI.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        tbSIKI.setAutoResizeMode(Table.AUTO_RESIZE_LAST_COLUMN);
        tbSIKI.setPreferredScrollableViewportSize(new Dimension(600, 450));
        aturKolomSIKI();

        scrollSIKI.setViewportView(tbSIKI);
        panelKanan.add(panelFilter, BorderLayout.NORTH);
        panelKanan.add(scrollSIKI, BorderLayout.CENTER);

        PanelBiasa panelBawah = new PanelBiasa(new FlowLayout(FlowLayout.RIGHT, 5, 3));
        BtnTerapkan.setText("Terapkan");
        BtnTerapkan.setPreferredSize(new Dimension(95, 28));
        BtnBatal.setText("Batal");
        BtnBatal.setPreferredSize(new Dimension(80, 28));

        panelBawah.add(BtnTerapkan);
        panelBawah.add(BtnBatal);

        JPanel tengah = new JPanel(new GridLayout(1, 2, 5, 0));
        tengah.add(panelKiri);
        tengah.add(panelKanan);

        root.add(tengah, BorderLayout.CENTER);
        root.add(panelBawah, BorderLayout.SOUTH);

        BtnCari.addActionListener(this::BtnCariActionPerformed);
        BtnPilihSDKI.addActionListener(this::BtnPilihSDKIActionPerformed);
        BtnTerapkan.addActionListener(this::BtnTerapkanActionPerformed);
        BtnBatal.addActionListener(this::BtnBatalActionPerformed);

        chkOBS.addActionListener(e -> loadSIKI());
        chkTER.addActionListener(e -> loadSIKI());
        chkEDU.addActionListener(e -> loadSIKI());
        chkKOL.addActionListener(e -> loadSIKI());

        TCari.getDocument().addDocumentListener(new DocumentListener() {
            @Override public void insertUpdate(DocumentEvent e) { loadSDKI(); }
            @Override public void removeUpdate(DocumentEvent e) { loadSDKI(); }
            @Override public void changedUpdate(DocumentEvent e) { loadSDKI(); }
        });

        TCari.addKeyListener(new java.awt.event.KeyAdapter() {
            @Override
            public void keyPressed(KeyEvent evt) {
                if (evt.getKeyCode() == KeyEvent.VK_ENTER) {
                    loadSDKI();
                }
            }
        });
        
        tbSDKI.getInputMap(javax.swing.JComponent.WHEN_FOCUSED).put(
                javax.swing.KeyStroke.getKeyStroke(KeyEvent.VK_SPACE, 0),
                "pilihSDKI"
        );

        tbSDKI.getActionMap().put(
                "pilihSDKI",
                new javax.swing.AbstractAction() {
                    @Override
                    public void actionPerformed(java.awt.event.ActionEvent e) {
                        pilihSDKI();
                    }
                }
        );
        
        tbSDKI.getSelectionModel().addListSelectionListener((ListSelectionEvent e) -> {
            if (!e.getValueIsAdjusting()) {
                int row = tbSDKI.getSelectedRow();
                if (row >= 0) {
                    Integer id = getInteger(modelSDKI.getValueAt(row, 2));
                    if (id != null) {
                        // Hanya preview ID; daftar SIKI berubah setelah tombol "Pilih SDKI".
                    }
                }
            }
        });

        modelSIKI.addTableModelListener((TableModelEvent e) -> {
            if (loadingTable) {
                return;
            }
            if (e.getType() == TableModelEvent.UPDATE
                    && e.getColumn() == 0
                    && e.getFirstRow() >= 0) {
                int row = e.getFirstRow();
                if (row < modelSIKI.getRowCount()) {
                    Long detailId = getLong(modelSIKI.getValueAt(row, 4));
                    if (detailId != null) {
                        boolean checked = Boolean.TRUE.equals(modelSIKI.getValueAt(row, 0));
                        selectedDetail.put(detailId, checked);
                    }
                }
            }
        });

        getRootPane().setDefaultButton(BtnTerapkan);
    }

    private void aturKolomSDKI() {
        if (tbSDKI.getColumnModel().getColumnCount() < 3) {
            return;
        }
        TableColumn c0 = tbSDKI.getColumnModel().getColumn(0);
        TableColumn c1 = tbSDKI.getColumnModel().getColumn(1);
        TableColumn c2 = tbSDKI.getColumnModel().getColumn(2);

        c0.setPreferredWidth(75);
        c0.setMinWidth(65);
        c0.setMaxWidth(90);

        c1.setPreferredWidth(300);
        c1.setMinWidth(150);

        c2.setMinWidth(0);
        c2.setMaxWidth(0);
        c2.setPreferredWidth(0);
    }

    private void aturKolomSIKI() {
        if (tbSIKI.getColumnModel().getColumnCount() < 6) {
            return;
        }

        TableColumn pilih = tbSIKI.getColumnModel().getColumn(0);
        TableColumn otek = tbSIKI.getColumnModel().getColumn(1);
        TableColumn siki = tbSIKI.getColumnModel().getColumn(2);
        TableColumn tindakan = tbSIKI.getColumnModel().getColumn(3);
        TableColumn detail = tbSIKI.getColumnModel().getColumn(4);
        TableColumn otekId = tbSIKI.getColumnModel().getColumn(5);

        pilih.setPreferredWidth(35);
        pilih.setMinWidth(30);
        pilih.setMaxWidth(40);

        otek.setPreferredWidth(45);
        otek.setMinWidth(35);
        otek.setMaxWidth(50);

        siki.setPreferredWidth(78);
        siki.setMinWidth(65);
        siki.setMaxWidth(90);

        tindakan.setPreferredWidth(500);
        tindakan.setMinWidth(200);

        for (TableColumn c : new TableColumn[]{detail, otekId}) {
            c.setMinWidth(0);
            c.setMaxWidth(0);
            c.setPreferredWidth(0);
        }
    }

    private void loadOtek() {
        namaOtek.clear();
        singkatOtek.clear();

        String sql = "SELECT id, kode, nama FROM kep_otek "
                + "WHERE aktif='Y' ORDER BY urutan, id";

        try (PreparedStatement ps = koneksi.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                int id = rs.getInt("id");
                String kode = rs.getString("kode");
                String nama = rs.getString("nama");

                namaOtek.put(id, nama);
                singkatOtek.put(id, singkatOtek(kode));
            }

            // Jika master sudah ada, pakai urutan/ID dinamis.
            // Checkbox tetap dipetakan ke ID standar OBS/TER/EDU/KOL.
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this,
                    "Gagal membaca master OTEK:\n" + e.getMessage(),
                    "Database", JOptionPane.ERROR_MESSAGE);
        }
    }

    private String singkatOtek(String kode) {
        if (kode == null) return "";
        String k = kode.trim().toUpperCase();
        switch (k) {
            case "OBS": return "O";
            case "TER": return "T";
            case "EDU": return "E";
            case "KOL": return "K";
            default:
                return k.isEmpty() ? "" : k.substring(0, 1);
        }
    }

    private boolean otekDipilih(int otekId) {
        String s = singkatOtek.get(otekId);
        if ("O".equals(s)) return chkOBS.isSelected();
        if ("T".equals(s)) return chkTER.isSelected();
        if ("E".equals(s)) return chkEDU.isSelected();
        if ("K".equals(s)) return chkKOL.isSelected();
        return false;
    }

    private String placeholdersOtek() {
        StringBuilder sb = new StringBuilder();
        for (Integer id : namaOtek.keySet()) {
            if (otekDipilih(id)) {
                if (sb.length() > 0) sb.append(",");
                sb.append("?");
            }
        }
        return sb.toString();
    }

    private int[] selectedOtekIds() {
        int count = 0;
        for (Integer id : namaOtek.keySet()) {
            if (otekDipilih(id)) count++;
        }

        int[] result = new int[count];
        int i = 0;
        for (Integer id : namaOtek.keySet()) {
            if (otekDipilih(id)) {
                result[i++] = id;
            }
        }
        return result;
    }

    private void loadSDKI() {
        String cari = TCari.getText().trim();

        String sql = "SELECT id, kode, nama_diagnosis FROM kep_sdki "
                + "WHERE aktif='Y' "
                + "AND (kode LIKE ? OR nama_diagnosis LIKE ?) "
                + "ORDER BY kode, id LIMIT 500";

        try (PreparedStatement ps = koneksi.prepareStatement(sql)) {
            String p = "%" + cari + "%";
            ps.setString(1, p);
            ps.setString(2, p);

            try (ResultSet rs = ps.executeQuery()) {
                modelSDKI.setRowCount(0);

                while (rs.next()) {
                    modelSDKI.addRow(new Object[]{
                        rs.getString("kode"),
                        rs.getString("nama_diagnosis"),
                        rs.getInt("id")
                    });
                }
            }
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this,
                    "Gagal membaca master SDKI:\n" + e.getMessage(),
                    "Database", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void pilihSDKI() {
        int row = tbSDKI.getSelectedRow();
        if (row < 0) {
            JOptionPane.showMessageDialog(this, "Silakan pilih diagnosis SDKI terlebih dahulu.");
            return;
        }

        Integer id = getInteger(modelSDKI.getValueAt(row, 2));
        if (id == null) {
            return;
        }

        sdkiId = id;
        asesmen = modelSDKI.getValueAt(row, 0) + " " + modelSDKI.getValueAt(row, 1);

        // Diagnosis berubah -> checklist lama tidak boleh ikut terbawa.
        selectedDetail.clear();

        loadSIKI();
    }

    private void loadSIKI() {
        if (sdkiId <= 0) {
            modelSIKI.setRowCount(0);
            return;
        }

        int[] otekIds = selectedOtekIds();
        if (otekIds.length == 0) {
            modelSIKI.setRowCount(0);
            return;
        }

        StringBuilder in = new StringBuilder();
        for (int i = 0; i < otekIds.length; i++) {
            if (i > 0) in.append(",");
            in.append("?");
        }

        String sql = "SELECT DISTINCT "
                + "d.id AS detail_id, "
                + "d.otek_id, "
                + "o.kode AS otek_kode, "
                + "sk.kode AS siki_kode, "
                + "d.tindakan, "
                + "d.urutan "
                + "FROM kep_sdki_siki r "
                + "JOIN kep_siki sk ON sk.id=r.siki_id AND sk.aktif='Y' "
                + "JOIN kep_siki_detail d ON d.siki_id=r.siki_id "
                + "JOIN kep_otek o ON o.id=d.otek_id AND o.aktif='Y' "
                + "WHERE r.sdki_id=? "
                + "AND d.otek_id IN (" + in + ") "
                + "AND d.aktif='Y' "
                + "ORDER BY o.urutan, d.urutan, d.id";

        loadingTable = true;
        try (PreparedStatement ps = koneksi.prepareStatement(sql)) {
            int n = 1;
            ps.setInt(n++, sdkiId);
            for (int id : otekIds) {
                ps.setInt(n++, id);
            }

            modelSIKI.setRowCount(0);

            while (ps.getResultSet() == null) {
                break;
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    long detailId = rs.getLong("detail_id");
                    int otekId = rs.getInt("otek_id");
                    boolean checked = Boolean.TRUE.equals(selectedDetail.get(detailId));

                    modelSIKI.addRow(new Object[]{
                        checked,
                        singkatOtek(rs.getString("otek_kode")),
                        rs.getString("siki_kode"),
                        rs.getString("tindakan"),
                        detailId,
                        otekId
                    });
                }
            }
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this,
                    "Gagal membaca tindakan SIKI:\n" + e.getMessage(),
                    "Database", JOptionPane.ERROR_MESSAGE);
        } finally {
            loadingTable = false;
        }
    }

    private void terapkan() {
        if (sdkiId <= 0) {
            JOptionPane.showMessageDialog(this, "Silakan pilih diagnosis SDKI terlebih dahulu.");
            return;
        }

        Map<Integer, java.util.List<String>> planGroup = new LinkedHashMap<>();
        java.util.List<String> instruksiList = new java.util.ArrayList<>();

        int[] activeOtekIds = selectedOtekIds();
        if (activeOtekIds.length == 0) {
            JOptionPane.showMessageDialog(this, "Pilih minimal satu OTEK.");
            return;
        }

        for (int row = 0; row < modelSIKI.getRowCount(); row++) {
            Long detailId = getLong(modelSIKI.getValueAt(row, 4));
            Integer otekId = getInteger(modelSIKI.getValueAt(row, 5));

            if (detailId == null || otekId == null) {
                continue;
            }

            if (!Boolean.TRUE.equals(selectedDetail.get(detailId))) {
                continue;
            }

            String tindakan = String.valueOf(modelSIKI.getValueAt(row, 3)).trim();
            if (tindakan.isEmpty()) {
                continue;
            }

            planGroup.computeIfAbsent(otekId, k -> new java.util.ArrayList<>()).add(tindakan);
            instruksiList.add(toInstruksi(tindakan));
        }

        StringBuilder sbPlan = new StringBuilder();
        for (Integer otekId : namaOtek.keySet()) {
            if (!otekDipilih(otekId)) {
                continue;
            }

            java.util.List<String> list = planGroup.get(otekId);
            if (list == null || list.isEmpty()) {
                continue;
            }

            if (sbPlan.length() > 0) {
                sbPlan.append("\n\n");
            }

            sbPlan.append(namaOtek.get(otekId)).append("\n");
            for (String tindakan : list) {
                sbPlan.append("- ").append(tindakan).append("\n");
            }
        }

        if (sbPlan.length() == 0) {
            JOptionPane.showMessageDialog(this,
                    "Belum ada tindakan SIKI yang dicentang.",
                    "Pilih tindakan", JOptionPane.WARNING_MESSAGE);
            return;
        }

        StringBuilder sbInstruksi = new StringBuilder();
        for (String item : instruksiList) {
            if (item.isEmpty()) continue;
            if (sbInstruksi.length() > 0) {
                sbInstruksi.append("\n");
            }
            sbInstruksi.append(item);
        }

        plan = hapusBarisAkhir(sbPlan.toString());
        instruksi = sbInstruksi.toString().trim();
        sukses = true;
        dispose();
    }

    private String toInstruksi(String tindakan) {
        String s = tindakan.trim();
        if (s.isEmpty()) return "";

        String[] parts = s.split("\\s+", 2);
        String first = parts[0];
        String rest = parts.length > 1 ? parts[1] : "";

        // Konversi umum kata kerja SIKI menjadi bentuk instruksi.
        // Jika kata kerja sudah berupa instruksi, biarkan.
        String f = first.toLowerCase();

        Map<String, String> map = new LinkedHashMap<>();
        map.put("identifikasi", "Mengidentifikasi");
        map.put("monitor", "Memonitor");
        map.put("observasi", "Mengobservasi");
        map.put("pantau", "Memantau");
        map.put("berikan", "Memberikan");
        map.put("beri", "Memberikan");
        map.put("atur", "Mengatur");
        map.put("jelaskan", "Menjelaskan");
        map.put("anjurkan", "Menganjurkan");
        map.put("ajarkan", "Mengajarkan");
        map.put("kolaborasi", "Berkolaborasi");
        map.put("periksa", "Memeriksa");
        map.put("ukur", "Mengukur");
        map.put("catat", "Mencatat");
        map.put("evaluasi", "Mengevaluasi");
        map.put("pertahankan", "Mempertahankan");
        map.put("lakukan", "Melakukan");
        map.put("posisikan", "Memposisikan");
        map.put("hentikan", "Menghentikan");
        map.put("batasi", "Membatasi");
        map.put("tingkatkan", "Meningkatkan");
        map.put("turunkan", "Menurunkan");
        map.put("bersihkan", "Membersihkan");
        map.put("pastikan", "Memastikan");

        if (map.containsKey(f)) {
            return map.get(f) + (rest.isEmpty() ? "" : " " + rest);
        }

        // Jika sudah diawali me-/mem-/men-/meng-/meny-/ber-, jangan diubah.
        if (f.startsWith("me") || f.startsWith("ber")) {
            return s;
        }

        // Fallback aman: hanya kapitalisasi kata pertama.
        return Character.toUpperCase(first.charAt(0))
                + first.substring(1)
                + (rest.isEmpty() ? "" : " " + rest);
    }

    private String hapusBarisAkhir(String s) {
        return s.replaceFirst("\\s+$", "");
    }

    private void BtnCariActionPerformed(ActionEvent evt) {
        loadSDKI();
    }

    private void BtnPilihSDKIActionPerformed(ActionEvent evt) {
        pilihSDKI();
    }

    private void BtnTerapkanActionPerformed(ActionEvent evt) {
        terapkan();
    }

    private void BtnBatalActionPerformed(ActionEvent evt) {
        sukses = false;
        dispose();
    }

    private Integer getInteger(Object value) {
        if (value == null) return null;
        if (value instanceof Number) return ((Number) value).intValue();
        try {
            return Integer.valueOf(value.toString());
        } catch (Exception e) {
            return null;
        }
    }

    private Long getLong(Object value) {
        if (value == null) return null;
        if (value instanceof Number) return ((Number) value).longValue();
        try {
            return Long.valueOf(value.toString());
        } catch (Exception e) {
            return null;
        }
    }

    public boolean isSimpan() {
        return sukses;
    }

    public String getAsesmen() {
        return asesmen;
    }

    public String getPlan() {
        return plan;
    }

    public String getInstruksi() {
        return instruksi;
    }
}