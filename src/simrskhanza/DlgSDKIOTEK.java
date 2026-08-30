package simrskhanza;

import fungsi.koneksiDB;
import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.ListSelectionModel;
import javax.swing.table.DefaultTableModel;

/**
 * Pemilih SDKI -> OTEK -> SIKI.
 * Hasil dikembalikan ke DlgRawatInap:
 * getAsesmen(), getPlan(), getInstruksi().
 */
public class DlgSDKIOTEK extends JDialog {
    private final Connection koneksi = koneksiDB.condb();
    private final JTextField txtCari = new JTextField();
    private final JTable tblSDKI = new JTable();
    private final JTable tblSIKI = new JTable();
    private final JPanel pnlOtek = new JPanel(new GridLayout(1, 4, 4, 4));
    private final List<JCheckBox> cekOtek = new ArrayList<>();
    private DefaultTableModel modelSDKI, modelSIKI;

    private int sdkiId = -1;
    private String sdkiKode = "", sdkiNama = "";
    private boolean simpan = false;
    private String asesmen = "", plan = "", instruksi = "";

    public DlgSDKIOTEK(java.awt.Frame parent, boolean modal) {
        super(parent, modal);
        initDialog();
    }

    private void initDialog() {
        setTitle("SDKI / OTEK / SIKI");
        setSize(1050, 680);
        setLocationRelativeTo(getOwner());
        setDefaultCloseOperation(DISPOSE_ON_CLOSE);

        modelSDKI = new DefaultTableModel(new Object[]{"ID", "Kode", "Diagnosis SDKI"}, 0) {
            public boolean isCellEditable(int r, int c) { return false; }
        };
        tblSDKI.setModel(modelSDKI);
        tblSDKI.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        tblSDKI.getColumnModel().getColumn(0).setMinWidth(0);
        tblSDKI.getColumnModel().getColumn(0).setMaxWidth(0);
        tblSDKI.getColumnModel().getColumn(0).setPreferredWidth(0);

        modelSIKI = new DefaultTableModel(
                new Object[]{"Pilih", "DetailID", "OtekID", "OTEK", "Tindakan SIKI"}, 0) {
            public Class<?> getColumnClass(int c) {
                if (c == 0) return Boolean.class;
                if (c == 1 || c == 2) return Long.class;
                return String.class;
            }

            public boolean isCellEditable(int r, int c) {
                return c == 0;
            }
        };
        tblSIKI.setModel(modelSIKI);
        for (int col = 1; col <= 2; col++) {
            tblSIKI.getColumnModel().getColumn(col).setMinWidth(0);
            tblSIKI.getColumnModel().getColumn(col).setMaxWidth(0);
            tblSIKI.getColumnModel().getColumn(col).setPreferredWidth(0);
        }

        JButton btnCari = new JButton("Cari");
        JButton btnPilih = new JButton("Pilih SDKI");
        JButton btnTerapkan = new JButton("Terapkan");
        JButton btnBatal = new JButton("Batal");

        JPanel cari = new JPanel(new BorderLayout(5, 5));
        cari.setBorder(BorderFactory.createTitledBorder("Cari Diagnosis SDKI"));
        cari.add(txtCari, BorderLayout.CENTER);
        cari.add(btnCari, BorderLayout.EAST);

        JPanel kiri = new JPanel(new BorderLayout(5, 5));
        kiri.setBorder(BorderFactory.createTitledBorder("Diagnosis SDKI"));
        kiri.add(new JScrollPane(tblSDKI), BorderLayout.CENTER);
        kiri.add(btnPilih, BorderLayout.SOUTH);

        JPanel kananAtas = new JPanel(new BorderLayout(5, 5));
        kananAtas.setBorder(BorderFactory.createTitledBorder("OTEK"));
        kananAtas.add(pnlOtek, BorderLayout.CENTER);

        JPanel kanan = new JPanel(new BorderLayout(5, 5));
        kanan.add(kananAtas, BorderLayout.NORTH);
        kanan.add(new JScrollPane(tblSIKI), BorderLayout.CENTER);

        JSplitPane split = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, kiri, kanan);
        split.setResizeWeight(.38);

        JPanel bawah = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        bawah.add(btnTerapkan);
        bawah.add(btnBatal);

        JPanel root = new JPanel(new BorderLayout(5, 5));
        root.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
        root.add(cari, BorderLayout.NORTH);
        root.add(split, BorderLayout.CENTER);
        root.add(bawah, BorderLayout.SOUTH);
        setContentPane(root);

        btnCari.addActionListener(e -> cariSDKI());
        txtCari.addActionListener(e -> cariSDKI());
        btnPilih.addActionListener(e -> pilihSDKI());
        tblSDKI.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent e) {
                if (e.getClickCount() == 2) pilihSDKI();
            }
        });
        btnTerapkan.addActionListener(e -> terapkan());
        btnBatal.addActionListener(e -> dispose());

        loadOtek();
        cariSDKI();
    }

    private void loadOtek() {
        pnlOtek.removeAll();
        cekOtek.clear();
        String sql = "SELECT id,kode,nama FROM kep_otek WHERE aktif='Y' ORDER BY urutan,id";
        try (PreparedStatement ps = koneksi.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                JCheckBox cb = new JCheckBox(rs.getString("nama"));
                cb.putClientProperty("id", rs.getInt("id"));
                cb.putClientProperty("nama", rs.getString("nama"));
                cb.setSelected(true);
                cb.addActionListener(e -> loadSIKI());
                cekOtek.add(cb);
                pnlOtek.add(cb);
            }
        } catch (Exception e) {
            error("Gagal membaca OTEK", e);
        }
        pnlOtek.revalidate();
        pnlOtek.repaint();
    }

    private void cariSDKI() {
        modelSDKI.setRowCount(0);
        String q = "%" + txtCari.getText().trim() + "%";
        String sql = "SELECT id,kode,nama_diagnosis FROM kep_sdki "
                   + "WHERE aktif='Y' AND (kode LIKE ? OR nama_diagnosis LIKE ?) "
                   + "ORDER BY kode,nama_diagnosis LIMIT 300";
        try (PreparedStatement ps = koneksi.prepareStatement(sql)) {
            ps.setString(1, q); ps.setString(2, q);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) modelSDKI.addRow(new Object[]{rs.getInt(1),rs.getString(2),rs.getString(3)});
            }
        } catch (Exception e) { error("Gagal mencari SDKI", e); }
    }

    private void pilihSDKI() {
        int r = tblSDKI.getSelectedRow();
        if (r < 0) { JOptionPane.showMessageDialog(this, "Pilih diagnosis SDKI terlebih dahulu."); return; }
        sdkiId = Integer.parseInt(modelSDKI.getValueAt(r,0).toString());
        sdkiKode = modelSDKI.getValueAt(r,1).toString();
        sdkiNama = modelSDKI.getValueAt(r,2).toString();
        for (JCheckBox cb : cekOtek) cb.setSelected(true);
        modelSIKI.setRowCount(0);
        setTitle("SDKI: " + sdkiKode + " - " + sdkiNama);
    }

    private List<Integer> selectedOtek() {
        List<Integer> out = new ArrayList<>();
        for (JCheckBox cb : cekOtek) if (cb.isSelected()) out.add((Integer)cb.getClientProperty("id"));
        return out;
    }

    private void loadSIKI() {
        modelSIKI.setRowCount(0);
        if (sdkiId < 0) return;
        List<Integer> ids = selectedOtek();
        if (ids.isEmpty()) return;
        StringBuilder in = new StringBuilder();
        for (int i=0;i<ids.size();i++) { if(i>0) in.append(","); in.append("?"); }
        String sql = "SELECT DISTINCT d.id AS detail_id, o.id AS otek_id, "
                   + "o.nama AS otek, d.tindakan "
                   + "FROM kep_sdki_otek_siki r "
                   + "JOIN kep_otek o ON o.id=r.otek_id "
                   + "JOIN kep_siki_detail d ON d.siki_id=r.siki_id "
                   + "WHERE r.sdki_id=? AND r.otek_id IN ("+in+") AND d.aktif='Y' "
                   + "ORDER BY o.urutan,d.urutan,d.id";
        try (PreparedStatement ps = koneksi.prepareStatement(sql)) {
            int n=1; ps.setInt(n++,sdkiId); for(Integer id:ids) ps.setInt(n++,id);
            try(ResultSet rs=ps.executeQuery()) {
                while(rs.next()) {
                    modelSIKI.addRow(new Object[]{
                        false,
                        rs.getLong("detail_id"),
                        rs.getLong("otek_id"),
                        rs.getString("otek"),
                        rs.getString("tindakan")
                    });
                }
            }
        } catch(Exception e) { error("Gagal membaca SIKI",e); }
    }

    private void terapkan() {
        if(sdkiId<0) { JOptionPane.showMessageDialog(this,"Pilih diagnosis SDKI."); return; }
        if(selectedOtek().isEmpty()) { JOptionPane.showMessageDialog(this,"Pilih minimal satu OTEK."); return; }

        // detailID -> OTEK; LinkedHashMap menjaga urutan OTEK pada Plan.
        Map<Integer,List<String>> tindakan = new LinkedHashMap<>();
        Map<Integer,String> namaOtek = new LinkedHashMap<>();
        for(JCheckBox cb:cekOtek) if(cb.isSelected()) {
            int id=(Integer)cb.getClientProperty("id");
            namaOtek.put(id,(String)cb.getClientProperty("nama"));
            tindakan.put(id,new ArrayList<>());
        }

        for(int r=0;r<modelSIKI.getRowCount();r++) {
            if(!Boolean.TRUE.equals(modelSIKI.getValueAt(r,0))) continue;

            int oid = Integer.parseInt(
                modelSIKI.getValueAt(r,2).toString()
            );

            String tindakanSIKI =
                modelSIKI.getValueAt(r,4).toString();

            if(tindakan.containsKey(oid)) {
                tindakan.get(oid).add(tindakanSIKI);
            }
        }

        StringBuilder p=new StringBuilder(), i=new StringBuilder();
        boolean ada=false;
        for(Map.Entry<Integer,String> e:namaOtek.entrySet()) {
            List<String> list=tindakan.get(e.getKey());
            if(list==null || list.isEmpty()) continue;
            ada=true;
            p.append(e.getValue()).append("\n");
            for(String s:list) {
                p.append("  - ").append(s).append("\n");
                i.append(toInstruksi(s)).append("\n");
            }
            p.append("\n");
        }
        if(!ada) { JOptionPane.showMessageDialog(this,"Centang minimal satu tindakan SIKI."); return; }

        asesmen=sdkiKode+" - "+sdkiNama;
        plan=trim(p.toString());
        instruksi=trim(i.toString());
        simpan=true;
        dispose();
    }

    private String toInstruksi(String s) {
        s=s.trim(); if(s.isEmpty()) return s;
        String[] a=s.split("\\s+",2); String w=a[0], rest=a.length>1?" "+a[1]:"";
        String l=w.toLowerCase();
        Map<String,String> m=new LinkedHashMap<>();
        m.put("identifikasi","Mengidentifikasi"); m.put("monitor","Memonitor");
        m.put("berikan","Memberikan"); m.put("jelaskan","Menjelaskan");
        m.put("anjurkan","Menganjurkan"); m.put("fasilitasi","Memfasilitasi");
        m.put("observasi","Mengobservasi"); m.put("evaluasi","Mengevaluasi");
        m.put("ajarkan","Mengajarkan"); m.put("ukur","Mengukur");
        m.put("pantau","Memantau"); m.put("lakukan","Melakukan");
        m.put("catat","Mencatat"); m.put("atur","Mengatur"); m.put("bantu","Membantu");
        if(m.containsKey(l)) return m.get(l)+rest;
        if(l.startsWith("me") || l.startsWith("meng") || l.startsWith("men") || l.startsWith("mem")) {
            return w + rest;
        }

        return "Melakukan " +
               Character.toLowerCase(w.charAt(0)) +
               w.substring(1) + rest;
    }

    private String trim(String s) { return s.replaceFirst("\\s+$",""); }
    private void error(String title,Exception e) { JOptionPane.showMessageDialog(this,title+":\n"+e.getMessage(),"Error",JOptionPane.ERROR_MESSAGE); }
    public boolean isSimpan(){return simpan;}
    public String getAsesmen(){return asesmen;}
    public String getPlan(){return plan;}
    public String getInstruksi(){return instruksi;}
}