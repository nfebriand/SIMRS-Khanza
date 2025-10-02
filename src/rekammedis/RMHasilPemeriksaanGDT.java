/*
 * By Tri RSU Az-Zahra Kalirejo
 */


package rekammedis;

import fungsi.WarnaTable;
import fungsi.batasInput;
import fungsi.koneksiDB;
import fungsi.sekuel;
import fungsi.validasi;
import fungsi.akses;
import java.awt.Cursor;
import java.awt.Desktop;
import java.awt.Dimension;
import java.awt.event.KeyEvent;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import javax.swing.JOptionPane;
import javax.swing.JTable;
import javax.swing.event.DocumentEvent;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.TableColumn;
import javax.swing.text.Document;
import javax.swing.text.html.HTMLEditorKit;
import javax.swing.text.html.StyleSheet;
import kepegawaian.DlgCariDokter;
import kepegawaian.DlgCariPetugas;


/**
 *
 * @author perpustakaan
 */
public final class RMHasilPemeriksaanGDT extends javax.swing.JDialog {
    private final DefaultTableModel tabMode;
    private Connection koneksi=koneksiDB.condb();
    private sekuel Sequel=new sekuel();
    private validasi Valid=new validasi();
    private PreparedStatement ps;
    private ResultSet rs;
    private int i=0;
    private String tgl;
    private DlgCariDokter dokter=new DlgCariDokter(null,false);
    private DlgCariPetugas petugas=new DlgCariPetugas(null,false);
//    private StringBuilder htmlContent;
    private String finger="",finger2="",kamar,namakamar,datapasien="";
    
    /** Creates new form DlgRujuk
     * @param parent
     * @param modal */
    public RMHasilPemeriksaanGDT(java.awt.Frame parent, boolean modal) {
        super(parent, modal);
        initComponents();
        
        tabMode=new DefaultTableModel(null,new Object[]{
            "No.Rawat","No.RM","Nama Pasien","Kode Dokter","Dokter Penanggung Jawab","NIP","Nama Petugas","Kesan Eritrosit","Kesan Leukosit",
            "Kesan Trombosit","Kesan","Kesimpulan","Saran","Diff Manual","HB Alat (gr/dl)","WBC Alat (rb/ul)","PLT Alat (rb/ul)",
        }){
              @Override public boolean isCellEditable(int rowIndex, int colIndex){return false;}
        };
        
        tbObat.setModel(tabMode);
        tbObat.setPreferredScrollableViewportSize(new Dimension(500,500));
        tbObat.setAutoResizeMode(JTable.AUTO_RESIZE_OFF);

        for (i = 0; i < 14; i++) {
            TableColumn column = tbObat.getColumnModel().getColumn(i);
            if(i==0){
                column.setPreferredWidth(105);
            }else if(i==1){
                column.setPreferredWidth(70);
            }else if(i==2){
                column.setPreferredWidth(150);
            }else if(i==3){
                column.setPreferredWidth(65);
            }else if(i==4){
                column.setPreferredWidth(65);
            }else if(i==5){
                column.setPreferredWidth(90);
            }else if(i==6){
                column.setPreferredWidth(150);
            }else if(i==7){
                column.setPreferredWidth(90);
            }else if(i==8){
                column.setPreferredWidth(150);
            }else if(i==9){
                column.setPreferredWidth(150);
            }else if(i==10){
                column.setPreferredWidth(150);
            }else if(i==11){
                column.setPreferredWidth(150);
            }else if(i==12){
                column.setPreferredWidth(150);
            }else if(i==13){
                column.setPreferredWidth(150);               
              
            }
        }
        tbObat.setDefaultRenderer(Object.class, new WarnaTable());
        
        TNoRw.setDocument(new batasInput((byte)17).getKata(TNoRw));
        kesan_eritrosit.setDocument(new batasInput((int)2000).getKata(kesan_eritrosit));
        kesan_leukosit.setDocument(new batasInput((int)2000).getKata(kesan_leukosit));
        kesan_trombosit.setDocument(new batasInput((int)2000).getKata(kesan_trombosit));
        kesan.setDocument(new batasInput((int)2000).getKata(kesan));
        kesimpulan.setDocument(new batasInput((int)2000).getKata(kesimpulan));
        saran.setDocument(new batasInput((int)2000).getKata(saran));
        diff_manual.setDocument(new batasInput((int)2000).getKata(diff_manual));
        HB.setDocument(new batasInput((int)8).getKata(HB));
        WBC.setDocument(new batasInput((int)8).getKata(WBC));
        PLT.setDocument(new batasInput((int)8).getKata(PLT));            
        TCari.setDocument(new batasInput((int)100).getKata(TCari));
        
        if(koneksiDB.CARICEPAT().equals("aktif")){
            TCari.getDocument().addDocumentListener(new javax.swing.event.DocumentListener(){
                @Override
                public void insertUpdate(DocumentEvent e) {
                    if(TCari.getText().length()>2){
                        tampil();
                    }
                }
                @Override
                public void removeUpdate(DocumentEvent e) {
                    if(TCari.getText().length()>2){
                        tampil();
                    }
                }
                @Override
                public void changedUpdate(DocumentEvent e) {
                    if(TCari.getText().length()>2){
                        tampil();
                    }
                }
            });
        }
        
        dokter.addWindowListener(new WindowListener() {
            @Override
            public void windowOpened(WindowEvent e) {}
            @Override
            public void windowClosing(WindowEvent e) {}
            @Override
            public void windowClosed(WindowEvent e) {
                if(dokter.getTable().getSelectedRow()!= -1){
                    KdDokter.setText(dokter.getTable().getValueAt(dokter.getTable().getSelectedRow(),0).toString());
                    NmDokter.setText(dokter.getTable().getValueAt(dokter.getTable().getSelectedRow(),1).toString());
                    KdDokter.requestFocus();
                }
            }
            @Override
            public void windowIconified(WindowEvent e) {}
            @Override
            public void windowDeiconified(WindowEvent e) {}
            @Override
            public void windowActivated(WindowEvent e) {}
            @Override
            public void windowDeactivated(WindowEvent e) {}
        });
        
        petugas.addWindowListener(new WindowListener() {
            @Override
            public void windowOpened(WindowEvent e) {}
            @Override
            public void windowClosing(WindowEvent e) {}
            @Override
            public void windowClosed(WindowEvent e) {
                if(petugas.getTable().getSelectedRow()!= -1){
                    NIP.setText(petugas.getTable().getValueAt(petugas.getTable().getSelectedRow(),0).toString());
                    NmPetugas.setText(petugas.getTable().getValueAt(petugas.getTable().getSelectedRow(),1).toString());
                    NIP.requestFocus();
                }
            }
            @Override
            public void windowIconified(WindowEvent e) {}
            @Override
            public void windowDeiconified(WindowEvent e) {}
            @Override
            public void windowActivated(WindowEvent e) {}
            @Override
            public void windowDeactivated(WindowEvent e) {}
        });
        
        HTMLEditorKit kit = new HTMLEditorKit();
        LoadHTML.setEditable(true);
        LoadHTML.setEditorKit(kit);
        StyleSheet styleSheet = kit.getStyleSheet();
        styleSheet.addRule(
                ".isi td{border-right: 1px solid #e2e7dd;font: 8.5px tahoma;height:12px;border-bottom: 1px solid #e2e7dd;background: #ffffff;color:#323232;}"+
                ".isi2 td{font: 8.5px tahoma;border:none;height:12px;background: #ffffff;color:#323232;}"+
                ".isi3 td{border-right: 1px solid #e2e7dd;font: 8.5px tahoma;height:12px;border-top: 1px solid #e2e7dd;background: #ffffff;color:#323232;}"+
                ".isi4 td{font: 11px tahoma;height:12px;border-top: 1px solid #e2e7dd;background: #ffffff;color:#323232;}"+
                ".isi5 td{font: 8.5px tahoma;border:none;height:12px;background: #ffffff;color:#AA0000;}"+
                ".isi6 td{font: 8.5px tahoma;border:none;height:12px;background: #ffffff;color:#FF0000;}"+
                ".isi7 td{font: 8.5px tahoma;border:none;height:12px;background: #ffffff;color:#C8C800;}"+
                ".isi8 td{font: 8.5px tahoma;border:none;height:12px;background: #ffffff;color:#00AA00;}"+
                ".isi9 td{font: 8.5px tahoma;border:none;height:12px;background: #ffffff;color:#969696;}"
        );
        Document doc = kit.createDefaultDocument();
        LoadHTML.setDocument(doc);
    }


    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        LoadHTML = new widget.editorpane();
        jPopupMenu1 = new javax.swing.JPopupMenu();
        MnHasilPemeriksaanGDT = new javax.swing.JMenuItem();
        TanggalRegistrasi = new widget.TextBox();
        internalFrame1 = new widget.InternalFrame();
        panelGlass8 = new widget.panelisi();
        BtnSimpan = new widget.Button();
        BtnBatal = new widget.Button();
        BtnHapus = new widget.Button();
        BtnEdit = new widget.Button();
        BtnPrint = new widget.Button();
        BtnAll = new widget.Button();
        BtnKeluar = new widget.Button();
        TabRawat = new javax.swing.JTabbedPane();
        internalFrame2 = new widget.InternalFrame();
        scrollInput = new widget.ScrollPane();
        FormInput = new widget.PanelBiasa();
        label14 = new widget.Label();
        KdDokter = new widget.TextBox();
        NmDokter = new widget.TextBox();
        BtnDokter = new widget.Button();
        label15 = new widget.Label();
        NIP = new widget.TextBox();
        NmPetugas = new widget.TextBox();
        BtnPetugas = new widget.Button();
        jSeparator1 = new javax.swing.JSeparator();
        jLabel53 = new widget.Label();
        scrollPane20 = new widget.ScrollPane();
        kesan_eritrosit = new widget.TextArea();
        jLabel54 = new widget.Label();
        scrollPane21 = new widget.ScrollPane();
        kesan_leukosit = new widget.TextArea();
        jLabel55 = new widget.Label();
        scrollPane22 = new widget.ScrollPane();
        kesan_trombosit = new widget.TextArea();
        jLabel56 = new widget.Label();
        scrollPane23 = new widget.ScrollPane();
        kesan = new widget.TextArea();
        jLabel57 = new widget.Label();
        scrollPane24 = new widget.ScrollPane();
        kesimpulan = new widget.TextArea();
        jLabel58 = new widget.Label();
        scrollPane25 = new widget.ScrollPane();
        saran = new widget.TextArea();
        jLabel59 = new widget.Label();
        scrollPane26 = new widget.ScrollPane();
        diff_manual = new widget.TextArea();
        jSeparator5 = new javax.swing.JSeparator();
        jLabel24 = new widget.Label();
        HB = new widget.TextBox();
        jLabel27 = new widget.Label();
        jLabel20 = new widget.Label();
        WBC = new widget.TextBox();
        jLabel17 = new widget.Label();
        jLabel28 = new widget.Label();
        PLT = new widget.TextBox();
        jLabel25 = new widget.Label();
        jLabel4 = new widget.Label();
        TNoRw = new widget.TextBox();
        TNoRM = new widget.TextBox();
        TPasien = new widget.TextBox();
        internalFrame3 = new widget.InternalFrame();
        Scroll = new widget.ScrollPane();
        tbObat = new widget.Table();
        panelGlass9 = new widget.panelisi();
        jLabel19 = new widget.Label();
        DTPCari1 = new widget.Tanggal();
        jLabel21 = new widget.Label();
        DTPCari2 = new widget.Tanggal();
        jLabel6 = new widget.Label();
        TCari = new widget.TextBox();
        BtnCari = new widget.Button();
        jLabel7 = new widget.Label();
        LCount = new widget.Label();

        LoadHTML.setBorder(null);
        LoadHTML.setName("LoadHTML"); // NOI18N

        jPopupMenu1.setName("jPopupMenu1"); // NOI18N

        MnHasilPemeriksaanGDT.setBackground(new java.awt.Color(255, 255, 254));
        MnHasilPemeriksaanGDT.setFont(new java.awt.Font("Tahoma", 0, 11)); // NOI18N
        MnHasilPemeriksaanGDT.setForeground(new java.awt.Color(50, 50, 50));
        MnHasilPemeriksaanGDT.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/category.png"))); // NOI18N
        MnHasilPemeriksaanGDT.setText("Hasil Pemeriksaan GDT");
        MnHasilPemeriksaanGDT.setName("MnHasilPemeriksaanGDT"); // NOI18N
        MnHasilPemeriksaanGDT.setPreferredSize(new java.awt.Dimension(240, 26));
        MnHasilPemeriksaanGDT.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                MnHasilPemeriksaanGDTActionPerformed(evt);
            }
        });
        jPopupMenu1.add(MnHasilPemeriksaanGDT);

        TanggalRegistrasi.setHighlighter(null);
        TanggalRegistrasi.setName("TanggalRegistrasi"); // NOI18N

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        setUndecorated(true);
        setResizable(false);

        internalFrame1.setBorder(javax.swing.BorderFactory.createTitledBorder(new javax.swing.border.LineBorder(new java.awt.Color(0, 142, 137), 2, true), "::[ Data Hasil Pemeriksaan GDT ]::", javax.swing.border.TitledBorder.DEFAULT_JUSTIFICATION, javax.swing.border.TitledBorder.DEFAULT_POSITION, new java.awt.Font("Tahoma", 1, 12), new java.awt.Color(50, 50, 50))); // NOI18N
        internalFrame1.setFont(new java.awt.Font("Tahoma", 2, 12)); // NOI18N
        internalFrame1.setName("internalFrame1"); // NOI18N
        internalFrame1.setPreferredSize(new java.awt.Dimension(467, 500));
        internalFrame1.setLayout(new java.awt.BorderLayout(1, 1));

        panelGlass8.setName("panelGlass8"); // NOI18N
        panelGlass8.setPreferredSize(new java.awt.Dimension(44, 54));
        panelGlass8.setLayout(new java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 5, 9));

        BtnSimpan.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/Save.png"))); // NOI18N
        BtnSimpan.setMnemonic('S');
        BtnSimpan.setText("Simpan");
        BtnSimpan.setToolTipText("Alt+S");
        BtnSimpan.setName("BtnSimpan"); // NOI18N
        BtnSimpan.setPreferredSize(new java.awt.Dimension(100, 30));
        BtnSimpan.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnSimpanActionPerformed(evt);
            }
        });
        BtnSimpan.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                BtnSimpanKeyPressed(evt);
            }
        });
        panelGlass8.add(BtnSimpan);

        BtnBatal.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/baru.png"))); // NOI18N
        BtnBatal.setMnemonic('B');
        BtnBatal.setText("Baru");
        BtnBatal.setToolTipText("Alt+B");
        BtnBatal.setName("BtnBatal"); // NOI18N
        BtnBatal.setPreferredSize(new java.awt.Dimension(100, 30));
        BtnBatal.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnBatalActionPerformed(evt);
            }
        });
        BtnBatal.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                BtnBatalKeyPressed(evt);
            }
        });
        panelGlass8.add(BtnBatal);

        BtnHapus.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/hapus.png"))); // NOI18N
        BtnHapus.setMnemonic('H');
        BtnHapus.setText("Hapus");
        BtnHapus.setToolTipText("Alt+H");
        BtnHapus.setName("BtnHapus"); // NOI18N
        BtnHapus.setPreferredSize(new java.awt.Dimension(100, 30));
        BtnHapus.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnHapusActionPerformed(evt);
            }
        });
        BtnHapus.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                BtnHapusKeyPressed(evt);
            }
        });
        panelGlass8.add(BtnHapus);

        BtnEdit.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/ganti.png"))); // NOI18N
        BtnEdit.setMnemonic('G');
        BtnEdit.setText("Ganti");
        BtnEdit.setToolTipText("Alt+G");
        BtnEdit.setName("BtnEdit"); // NOI18N
        BtnEdit.setPreferredSize(new java.awt.Dimension(100, 30));
        BtnEdit.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnEditActionPerformed(evt);
            }
        });
        BtnEdit.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                BtnEditKeyPressed(evt);
            }
        });
        panelGlass8.add(BtnEdit);

        BtnPrint.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/cetak.png"))); // NOI18N
        BtnPrint.setMnemonic('T');
        BtnPrint.setText("Cetak");
        BtnPrint.setToolTipText("Alt+T");
        BtnPrint.setName("BtnPrint"); // NOI18N
        BtnPrint.setPreferredSize(new java.awt.Dimension(100, 30));
        BtnPrint.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnPrintActionPerformed(evt);
            }
        });
        BtnPrint.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                BtnPrintKeyPressed(evt);
            }
        });
        panelGlass8.add(BtnPrint);

        BtnAll.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/semua.png"))); // NOI18N
        BtnAll.setMnemonic('M');
        BtnAll.setText("Semua");
        BtnAll.setToolTipText("Alt+M");
        BtnAll.setName("BtnAll"); // NOI18N
        BtnAll.setPreferredSize(new java.awt.Dimension(100, 30));
        BtnAll.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnAllActionPerformed(evt);
            }
        });
        BtnAll.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                BtnAllKeyPressed(evt);
            }
        });
        panelGlass8.add(BtnAll);

        BtnKeluar.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/exit.png"))); // NOI18N
        BtnKeluar.setMnemonic('K');
        BtnKeluar.setText("Keluar");
        BtnKeluar.setToolTipText("Alt+K");
        BtnKeluar.setName("BtnKeluar"); // NOI18N
        BtnKeluar.setPreferredSize(new java.awt.Dimension(100, 30));
        BtnKeluar.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnKeluarActionPerformed(evt);
            }
        });
        BtnKeluar.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                BtnKeluarKeyPressed(evt);
            }
        });
        panelGlass8.add(BtnKeluar);

        internalFrame1.add(panelGlass8, java.awt.BorderLayout.PAGE_END);

        TabRawat.setBackground(new java.awt.Color(254, 255, 254));
        TabRawat.setForeground(new java.awt.Color(50, 50, 50));
        TabRawat.setFont(new java.awt.Font("Tahoma", 1, 11)); // NOI18N
        TabRawat.setName("TabRawat"); // NOI18N
        TabRawat.setPreferredSize(new java.awt.Dimension(457, 480));

        internalFrame2.setBorder(null);
        internalFrame2.setName("internalFrame2"); // NOI18N
        internalFrame2.setPreferredSize(new java.awt.Dimension(102, 480));
        internalFrame2.setLayout(new java.awt.BorderLayout(1, 1));

        scrollInput.setName("scrollInput"); // NOI18N
        scrollInput.setPreferredSize(new java.awt.Dimension(102, 557));

        FormInput.setBackground(new java.awt.Color(255, 255, 255));
        FormInput.setBorder(null);
        FormInput.setName("FormInput"); // NOI18N
        FormInput.setPreferredSize(new java.awt.Dimension(750, 712));
        FormInput.setLayout(null);

        label14.setText("Dokter P.J. :");
        label14.setName("label14"); // NOI18N
        label14.setPreferredSize(new java.awt.Dimension(70, 23));
        FormInput.add(label14);
        label14.setBounds(10, 40, 70, 23);

        KdDokter.setEditable(false);
        KdDokter.setName("KdDokter"); // NOI18N
        KdDokter.setPreferredSize(new java.awt.Dimension(80, 23));
        FormInput.add(KdDokter);
        KdDokter.setBounds(90, 40, 90, 23);

        NmDokter.setEditable(false);
        NmDokter.setName("NmDokter"); // NOI18N
        NmDokter.setPreferredSize(new java.awt.Dimension(207, 23));
        FormInput.add(NmDokter);
        NmDokter.setBounds(180, 40, 170, 23);

        BtnDokter.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/190.png"))); // NOI18N
        BtnDokter.setMnemonic('2');
        BtnDokter.setToolTipText("Alt+2");
        BtnDokter.setName("BtnDokter"); // NOI18N
        BtnDokter.setPreferredSize(new java.awt.Dimension(28, 23));
        BtnDokter.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnDokterActionPerformed(evt);
            }
        });
        BtnDokter.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                BtnDokterKeyPressed(evt);
            }
        });
        FormInput.add(BtnDokter);
        BtnDokter.setBounds(350, 40, 28, 23);

        label15.setText("Analis Lab :");
        label15.setName("label15"); // NOI18N
        label15.setPreferredSize(new java.awt.Dimension(70, 23));
        FormInput.add(label15);
        label15.setBounds(370, 40, 70, 23);

        NIP.setEditable(false);
        NIP.setName("NIP"); // NOI18N
        NIP.setPreferredSize(new java.awt.Dimension(80, 23));
        FormInput.add(NIP);
        NIP.setBounds(440, 40, 90, 23);

        NmPetugas.setEditable(false);
        NmPetugas.setName("NmPetugas"); // NOI18N
        NmPetugas.setPreferredSize(new java.awt.Dimension(207, 23));
        FormInput.add(NmPetugas);
        NmPetugas.setBounds(530, 40, 170, 23);

        BtnPetugas.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/190.png"))); // NOI18N
        BtnPetugas.setMnemonic('2');
        BtnPetugas.setToolTipText("Alt+2");
        BtnPetugas.setName("BtnPetugas"); // NOI18N
        BtnPetugas.setPreferredSize(new java.awt.Dimension(28, 23));
        BtnPetugas.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnPetugasActionPerformed(evt);
            }
        });
        BtnPetugas.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                BtnPetugasKeyPressed(evt);
            }
        });
        FormInput.add(BtnPetugas);
        BtnPetugas.setBounds(700, 40, 28, 23);

        jSeparator1.setBackground(new java.awt.Color(239, 244, 234));
        jSeparator1.setForeground(new java.awt.Color(239, 244, 234));
        jSeparator1.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(239, 244, 234)));
        jSeparator1.setName("jSeparator1"); // NOI18N
        FormInput.add(jSeparator1);
        jSeparator1.setBounds(0, 71, 750, 1);

        jLabel53.setText("Kesan Eritrosit :");
        jLabel53.setName("jLabel53"); // NOI18N
        FormInput.add(jLabel53);
        jLabel53.setBounds(10, 80, 100, 23);

        scrollPane20.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
        scrollPane20.setName("scrollPane20"); // NOI18N

        kesan_eritrosit.setBorder(javax.swing.BorderFactory.createEmptyBorder(1, 1, 1, 1));
        kesan_eritrosit.setColumns(20);
        kesan_eritrosit.setRows(20);
        kesan_eritrosit.setName("kesan_eritrosit"); // NOI18N
        kesan_eritrosit.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                kesan_eritrositKeyPressed(evt);
            }
        });
        scrollPane20.setViewportView(kesan_eritrosit);

        FormInput.add(scrollPane20);
        scrollPane20.setBounds(130, 80, 600, 60);

        jLabel54.setText("Kesan Leukosit :");
        jLabel54.setName("jLabel54"); // NOI18N
        FormInput.add(jLabel54);
        jLabel54.setBounds(10, 150, 100, 23);

        scrollPane21.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
        scrollPane21.setName("scrollPane21"); // NOI18N

        kesan_leukosit.setBorder(javax.swing.BorderFactory.createEmptyBorder(1, 1, 1, 1));
        kesan_leukosit.setColumns(20);
        kesan_leukosit.setRows(20);
        kesan_leukosit.setName("kesan_leukosit"); // NOI18N
        kesan_leukosit.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                kesan_leukositKeyPressed(evt);
            }
        });
        scrollPane21.setViewportView(kesan_leukosit);

        FormInput.add(scrollPane21);
        scrollPane21.setBounds(130, 150, 600, 60);

        jLabel55.setText("Kesan Trombosit :");
        jLabel55.setName("jLabel55"); // NOI18N
        FormInput.add(jLabel55);
        jLabel55.setBounds(10, 220, 100, 23);

        scrollPane22.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
        scrollPane22.setName("scrollPane22"); // NOI18N

        kesan_trombosit.setBorder(javax.swing.BorderFactory.createEmptyBorder(1, 1, 1, 1));
        kesan_trombosit.setColumns(20);
        kesan_trombosit.setRows(20);
        kesan_trombosit.setName("kesan_trombosit"); // NOI18N
        kesan_trombosit.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                kesan_trombositKeyPressed(evt);
            }
        });
        scrollPane22.setViewportView(kesan_trombosit);

        FormInput.add(scrollPane22);
        scrollPane22.setBounds(130, 220, 600, 60);

        jLabel56.setText("Kesan :");
        jLabel56.setName("jLabel56"); // NOI18N
        FormInput.add(jLabel56);
        jLabel56.setBounds(10, 290, 100, 23);

        scrollPane23.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
        scrollPane23.setName("scrollPane23"); // NOI18N

        kesan.setBorder(javax.swing.BorderFactory.createEmptyBorder(1, 1, 1, 1));
        kesan.setColumns(20);
        kesan.setRows(20);
        kesan.setName("kesan"); // NOI18N
        kesan.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                kesanKeyPressed(evt);
            }
        });
        scrollPane23.setViewportView(kesan);

        FormInput.add(scrollPane23);
        scrollPane23.setBounds(130, 290, 600, 40);

        jLabel57.setText("Kesimpulan :");
        jLabel57.setName("jLabel57"); // NOI18N
        FormInput.add(jLabel57);
        jLabel57.setBounds(10, 340, 100, 23);

        scrollPane24.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
        scrollPane24.setName("scrollPane24"); // NOI18N

        kesimpulan.setBorder(javax.swing.BorderFactory.createEmptyBorder(1, 1, 1, 1));
        kesimpulan.setColumns(20);
        kesimpulan.setRows(20);
        kesimpulan.setName("kesimpulan"); // NOI18N
        kesimpulan.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                kesimpulanKeyPressed(evt);
            }
        });
        scrollPane24.setViewportView(kesimpulan);

        FormInput.add(scrollPane24);
        scrollPane24.setBounds(130, 340, 600, 120);

        jLabel58.setText("Saran :");
        jLabel58.setName("jLabel58"); // NOI18N
        FormInput.add(jLabel58);
        jLabel58.setBounds(10, 470, 100, 23);

        scrollPane25.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
        scrollPane25.setName("scrollPane25"); // NOI18N

        saran.setBorder(javax.swing.BorderFactory.createEmptyBorder(1, 1, 1, 1));
        saran.setColumns(20);
        saran.setRows(20);
        saran.setName("saran"); // NOI18N
        saran.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                saranKeyPressed(evt);
            }
        });
        scrollPane25.setViewportView(saran);

        FormInput.add(scrollPane25);
        scrollPane25.setBounds(130, 470, 600, 120);

        jLabel59.setText("Diff Manual :");
        jLabel59.setName("jLabel59"); // NOI18N
        FormInput.add(jLabel59);
        jLabel59.setBounds(10, 600, 100, 23);

        scrollPane26.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(0, 0, 0)));
        scrollPane26.setName("scrollPane26"); // NOI18N

        diff_manual.setBorder(javax.swing.BorderFactory.createEmptyBorder(1, 1, 1, 1));
        diff_manual.setColumns(20);
        diff_manual.setRows(20);
        diff_manual.setName("diff_manual"); // NOI18N
        diff_manual.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                diff_manualKeyPressed(evt);
            }
        });
        scrollPane26.setViewportView(diff_manual);

        FormInput.add(scrollPane26);
        scrollPane26.setBounds(130, 600, 600, 60);

        jSeparator5.setBackground(new java.awt.Color(239, 244, 234));
        jSeparator5.setForeground(new java.awt.Color(239, 244, 234));
        jSeparator5.setBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(239, 244, 234)));
        jSeparator5.setName("jSeparator5"); // NOI18N
        FormInput.add(jSeparator5);
        jSeparator5.setBounds(0, 670, 750, 1);

        jLabel24.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
        jLabel24.setText("HB Alat :");
        jLabel24.setName("jLabel24"); // NOI18N
        FormInput.add(jLabel24);
        jLabel24.setBounds(90, 680, 60, 23);

        HB.setFocusTraversalPolicyProvider(true);
        HB.setName("HB"); // NOI18N
        HB.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                HBKeyPressed(evt);
            }
        });
        FormInput.add(HB);
        HB.setBounds(150, 680, 75, 23);

        jLabel27.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
        jLabel27.setText("gr/dl");
        jLabel27.setName("jLabel27"); // NOI18N
        FormInput.add(jLabel27);
        jLabel27.setBounds(240, 680, 40, 23);

        jLabel20.setText("WBC Alat :");
        jLabel20.setName("jLabel20"); // NOI18N
        FormInput.add(jLabel20);
        jLabel20.setBounds(290, 680, 70, 23);

        WBC.setFocusTraversalPolicyProvider(true);
        WBC.setName("WBC"); // NOI18N
        WBC.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                WBCKeyPressed(evt);
            }
        });
        FormInput.add(WBC);
        WBC.setBounds(370, 680, 60, 23);

        jLabel17.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
        jLabel17.setText("rb/ul");
        jLabel17.setName("jLabel17"); // NOI18N
        FormInput.add(jLabel17);
        jLabel17.setBounds(440, 680, 50, 23);

        jLabel28.setText("PLT Alat :");
        jLabel28.setName("jLabel28"); // NOI18N
        FormInput.add(jLabel28);
        jLabel28.setBounds(490, 680, 60, 23);

        PLT.setFocusTraversalPolicyProvider(true);
        PLT.setName("PLT"); // NOI18N
        PLT.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                PLTKeyPressed(evt);
            }
        });
        FormInput.add(PLT);
        PLT.setBounds(570, 680, 60, 23);

        jLabel25.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
        jLabel25.setText("rb/ul");
        jLabel25.setName("jLabel25"); // NOI18N
        FormInput.add(jLabel25);
        jLabel25.setBounds(640, 680, 50, 23);

        jLabel4.setText("No.Rawat :");
        jLabel4.setName("jLabel4"); // NOI18N
        FormInput.add(jLabel4);
        jLabel4.setBounds(0, 10, 95, 23);

        TNoRw.setHighlighter(null);
        TNoRw.setName("TNoRw"); // NOI18N
        TNoRw.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                TNoRwKeyPressed(evt);
            }
        });
        FormInput.add(TNoRw);
        TNoRw.setBounds(99, 10, 141, 23);

        TNoRM.setEditable(false);
        TNoRM.setHighlighter(null);
        TNoRM.setName("TNoRM"); // NOI18N
        TNoRM.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                TNoRMKeyPressed(evt);
            }
        });
        FormInput.add(TNoRM);
        TNoRM.setBounds(242, 10, 111, 23);

        TPasien.setEditable(false);
        TPasien.setHighlighter(null);
        TPasien.setName("TPasien"); // NOI18N
        TPasien.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                TPasienKeyPressed(evt);
            }
        });
        FormInput.add(TPasien);
        TPasien.setBounds(355, 10, 365, 23);

        scrollInput.setViewportView(FormInput);

        internalFrame2.add(scrollInput, java.awt.BorderLayout.CENTER);

        TabRawat.addTab("Input Hasil Pemeriksaan", internalFrame2);

        internalFrame3.setBorder(null);
        internalFrame3.setName("internalFrame3"); // NOI18N
        internalFrame3.setLayout(new java.awt.BorderLayout(1, 1));

        Scroll.setName("Scroll"); // NOI18N
        Scroll.setOpaque(true);
        Scroll.setPreferredSize(new java.awt.Dimension(452, 200));

        tbObat.setToolTipText("Silahkan klik untuk memilih data yang mau diedit ataupun dihapus");
        tbObat.setComponentPopupMenu(jPopupMenu1);
        tbObat.setName("tbObat"); // NOI18N
        tbObat.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                tbObatMouseClicked(evt);
            }
        });
        tbObat.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                tbObatKeyPressed(evt);
            }
        });
        Scroll.setViewportView(tbObat);

        internalFrame3.add(Scroll, java.awt.BorderLayout.CENTER);

        panelGlass9.setName("panelGlass9"); // NOI18N
        panelGlass9.setPreferredSize(new java.awt.Dimension(44, 44));
        panelGlass9.setLayout(new java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 5, 9));

        jLabel19.setText("Tgl.Asuhan :");
        jLabel19.setName("jLabel19"); // NOI18N
        jLabel19.setPreferredSize(new java.awt.Dimension(70, 23));
        panelGlass9.add(jLabel19);

        DTPCari1.setForeground(new java.awt.Color(50, 70, 50));
        DTPCari1.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "31-01-2025" }));
        DTPCari1.setDisplayFormat("dd-MM-yyyy");
        DTPCari1.setName("DTPCari1"); // NOI18N
        DTPCari1.setOpaque(false);
        DTPCari1.setPreferredSize(new java.awt.Dimension(90, 23));
        panelGlass9.add(DTPCari1);

        jLabel21.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        jLabel21.setText("s.d.");
        jLabel21.setName("jLabel21"); // NOI18N
        jLabel21.setPreferredSize(new java.awt.Dimension(23, 23));
        panelGlass9.add(jLabel21);

        DTPCari2.setForeground(new java.awt.Color(50, 70, 50));
        DTPCari2.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "31-01-2025" }));
        DTPCari2.setDisplayFormat("dd-MM-yyyy");
        DTPCari2.setName("DTPCari2"); // NOI18N
        DTPCari2.setOpaque(false);
        DTPCari2.setPreferredSize(new java.awt.Dimension(90, 23));
        panelGlass9.add(DTPCari2);

        jLabel6.setText("Key Word :");
        jLabel6.setName("jLabel6"); // NOI18N
        jLabel6.setPreferredSize(new java.awt.Dimension(80, 23));
        panelGlass9.add(jLabel6);

        TCari.setName("TCari"); // NOI18N
        TCari.setPreferredSize(new java.awt.Dimension(195, 23));
        TCari.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                TCariKeyPressed(evt);
            }
        });
        panelGlass9.add(TCari);

        BtnCari.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/checklist.png"))); // NOI18N
        BtnCari.setMnemonic('3');
        BtnCari.setToolTipText("Alt+3");
        BtnCari.setName("BtnCari"); // NOI18N
        BtnCari.setPreferredSize(new java.awt.Dimension(28, 23));
        BtnCari.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnCariActionPerformed(evt);
            }
        });
        BtnCari.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                BtnCariKeyPressed(evt);
            }
        });
        panelGlass9.add(BtnCari);

        jLabel7.setText("Record :");
        jLabel7.setName("jLabel7"); // NOI18N
        jLabel7.setPreferredSize(new java.awt.Dimension(60, 23));
        panelGlass9.add(jLabel7);

        LCount.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
        LCount.setText("0");
        LCount.setName("LCount"); // NOI18N
        LCount.setPreferredSize(new java.awt.Dimension(70, 23));
        panelGlass9.add(LCount);

        internalFrame3.add(panelGlass9, java.awt.BorderLayout.PAGE_END);

        TabRawat.addTab("Data Hasil Pemeriksaan", internalFrame3);

        internalFrame1.add(TabRawat, java.awt.BorderLayout.CENTER);

        getContentPane().add(internalFrame1, java.awt.BorderLayout.CENTER);

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void BtnSimpanActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnSimpanActionPerformed
        if(TNoRM.getText().trim().equals("")){
            Valid.textKosong(TNoRw,"Nama Pasien");
        }else if(TNoRw.getText().trim().equals("")||TPasien.getText().trim().equals("")){
            Valid.textKosong(TNoRw,"Pasien");
        }else if(KdDokter.getText().trim().equals("")||NmDokter.getText().trim().equals("")){
            Valid.textKosong(TNoRw,"Dokter");
        }else if(NIP.getText().trim().equals("")||NmPetugas.getText().trim().equals("")){
            Valid.textKosong(TNoRw,"Petugas");                          
        }else{   
            if(tbObat.getSelectedRow()!= -1){
                if(Sequel.mengedittf("hasil_pemeriksaan_gdt","no_rawat=?","no_rawat=?,kd_dokter=?,nip=?,kesan_eritorsit=?,kesan_leukosit=?,"+
                "kesan_trombosit=?,kesan=?,kesimpulan=?,saran=?,diff_manual=?,HB=?,WBC=?,PLT=?",13,new String[]{
                TNoRw.getText(),KdDokter.getText(),NIP.getText(),kesan_eritrosit.getText(),kesan_eritrosit.getText(),kesan_leukosit.getText(),kesan_trombosit.getText(),
                kesan.getText(),kesimpulan.getText(),saran.getText(),diff_manual.getText(),HB.getText(),WBC.getText(),PLT.getText(),tbObat.getValueAt(tbObat.getSelectedRow(),0).toString()
                })==true){
                    tampil();
                    emptTeks();
                }
            }
        }
}//GEN-LAST:event_BtnSimpanActionPerformed

    private void BtnSimpanKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnSimpanKeyPressed
        if(evt.getKeyCode()==KeyEvent.VK_SPACE){
            BtnSimpanActionPerformed(null);
        }else{
            Valid.pindah(evt,PLT,BtnBatal);
        }
}//GEN-LAST:event_BtnSimpanKeyPressed

    private void BtnBatalActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnBatalActionPerformed
        emptTeks();
}//GEN-LAST:event_BtnBatalActionPerformed

    private void BtnBatalKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnBatalKeyPressed
        if(evt.getKeyCode()==KeyEvent.VK_SPACE){
            emptTeks();
        }else{Valid.pindah(evt, BtnSimpan, BtnHapus);}
}//GEN-LAST:event_BtnBatalKeyPressed

    private void BtnHapusActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnHapusActionPerformed
        if(tbObat.getSelectedRow()>-1){
            if(akses.getkode().equals("Admin Utama")){
                hapus();
            }else{
                if(KdDokter.getText().equals(tbObat.getValueAt(tbObat.getSelectedRow(),4).toString())){
                    hapus();
                }else{
                    JOptionPane.showMessageDialog(null,"Hanya bisa dihapus oleh dokter yang bersangkutan..!!");
                }
            }
        }else{
            JOptionPane.showMessageDialog(rootPane,"Silahkan anda pilih data terlebih dahulu..!!");
        } 
            
}//GEN-LAST:event_BtnHapusActionPerformed

    private void BtnHapusKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnHapusKeyPressed
        if(evt.getKeyCode()==KeyEvent.VK_SPACE){
            BtnHapusActionPerformed(null);
        }else{
            Valid.pindah(evt, BtnBatal, BtnEdit);
        }
}//GEN-LAST:event_BtnHapusKeyPressed

    private void BtnEditActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnEditActionPerformed
        if(TNoRM.getText().trim().equals("")){
            Valid.textKosong(TNoRw,"Nama Pasien");
        }else if(NmDokter.getText().trim().equals("")){
            Valid.textKosong(BtnDokter,"Dokter Penanggung Jawab");
        }else if(NmPetugas.getText().trim().equals("")){
            Valid.textKosong(BtnPetugas,"Petugas");
        }else if(kesan_eritrosit.getText().trim().equals("")){
            Valid.textKosong(kesan_eritrosit,"Kesan Eritrosit");
        }else if(kesan_leukosit.getText().trim().equals("")){
            Valid.textKosong(kesan_leukosit,"Kesan Leukosit");
        }else if(kesan_trombosit.getText().trim().equals("")){
            Valid.textKosong(kesan_trombosit,"Kesan Trombosit");
        }else if(kesan.getText().trim().equals("")){
            Valid.textKosong(kesan,"Kesan");
        }else if(kesimpulan.getText().trim().equals("")){
            Valid.textKosong(kesimpulan,"Kesimpulan");        
        }else if(saran.getText().trim().equals("")){
            Valid.textKosong(saran,"Saran");
        }else if(diff_manual.getText().trim().equals("")){
            Valid.textKosong(diff_manual,"Diff Manual"); 
        }else{
            if(tbObat.getSelectedRow()>-1){
                if(akses.getkode().equals("Admin Utama")){
                    ganti();
                }else{
                    if(KdDokter.getText().equals(tbObat.getValueAt(tbObat.getSelectedRow(),4).toString())){
                        ganti();
                    }else{
                        JOptionPane.showMessageDialog(null,"Hanya bisa diganti oleh dokter yang bersangkutan..!!");
                    }
                }
            }else{
                JOptionPane.showMessageDialog(rootPane,"Silahkan anda pilih data terlebih dahulu..!!");
            }
        }
}//GEN-LAST:event_BtnEditActionPerformed

    private void BtnEditKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnEditKeyPressed
        if(evt.getKeyCode()==KeyEvent.VK_SPACE){
            BtnEditActionPerformed(null);
        }else{
            Valid.pindah(evt, BtnHapus, BtnPrint);
        }
}//GEN-LAST:event_BtnEditKeyPressed

    private void BtnKeluarActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnKeluarActionPerformed
        dispose();
}//GEN-LAST:event_BtnKeluarActionPerformed

    private void BtnKeluarKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnKeluarKeyPressed
        if(evt.getKeyCode()==KeyEvent.VK_SPACE){
            BtnKeluarActionPerformed(null);
        }else{Valid.pindah(evt,BtnEdit,TCari);}
}//GEN-LAST:event_BtnKeluarKeyPressed

    private void BtnPrintActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnPrintActionPerformed
        this.setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
        if(tabMode.getRowCount()==0){
            JOptionPane.showMessageDialog(null,"Maaf, data sudah habis. Tidak ada data yang bisa anda print...!!!!");
            BtnBatal.requestFocus();
        }else if(tabMode.getRowCount()!=0){
            Map<String, Object> param = new HashMap<>(); 
            param.put("namars",akses.getnamars());
            param.put("alamatrs",akses.getalamatrs());
            param.put("kotars",akses.getkabupatenrs());
            param.put("propinsirs",akses.getpropinsirs());
            param.put("kontakrs",akses.getkontakrs());
            param.put("emailrs",akses.getemailrs());   
            param.put("logo",Sequel.cariGambar("select setting.logo from setting")); 
            Valid.MyReportqry("rptDataHasilPemeriksaanGDT.jasper","report","::[ Data Hasil Pemeriksaan GDT ]::",
                "SELECT reg_periksa.no_rawat,pasien.no_rkm_medis,pasien.nm_pasien,hasil_pemeriksaan_gdt.kd_dokter,hasil_pemeriksaan_gdt.nip "+
                "hasil_pemeriksaan_gdt.kesan_eritorsit,hasil_pemeriksaan_gdt.kesan_leukosit,hasil_pemeriksaan_gdt.kesan_trombosit,hasil_pemeriksaan_gdt.kesan,hasil_pemeriksaan_gdt.kesimpulan,hasil_pemeriksaan_gdt.saran,"+
                "hasil_pemeriksaan_gdt.diff_manual,hasil_pemeriksaan_gdt.HB,hasil_pemeriksaan_gdt.WBC,hasil_pemeriksaan_gdt.PLT, FROM hasil_pemeriksaan_gdt INNER JOIN reg_periksa on hasil_pemeriksaan_gdt.no_rawat=reg_periksa.no_rawat "+
                "INNER JOIN pasien ON reg_periksa.no_rkm_medis=pasien.no_rkm_medis "+
                "INNER JOIN dokter ON hasil_pemeriksaan_gdt.kd_dokter=dokter.kd_dokter "+
                "INNER JOIN petugas ON hasil_pemeriksaan_gdt.nip=petugas.nip "+
                "WHERE hasil_pemeriksaan_gdt.no_rawat between '"+Valid.SetTgl(DTPCari1.getSelectedItem()+"")+"' and '"+Valid.SetTgl(DTPCari2.getSelectedItem()+"")+"' "+
                (TCari.getText().trim().equals("")?"":"and (hasil_pemeriksaan_gdt.no_rawat like '%"+TCari.getText().trim()+"%' or dokter.nm_dokter like '%"+TCari.getText().trim()+"%' "+
                "or pasien.no_rkm_medis like '%"+TCari.getText().trim()+"%' or pasien.nm_pasien like '%"+TCari.getText().trim()+"%' or petugas.nama like '%"+TCari.getText().trim()+"%' "+
                "or hasil_pemeriksaan_gdt.no_rawat like '%"+TCari.getText().trim()+"%')")+" order by hasil_pemeriksaan_gdt.no_rawat",param);
        }
        this.setCursor(Cursor.getDefaultCursor());       
}//GEN-LAST:event_BtnPrintActionPerformed

    private void BtnPrintKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnPrintKeyPressed
        if(evt.getKeyCode()==KeyEvent.VK_SPACE){
            BtnPrintActionPerformed(null);
        }else{
            Valid.pindah(evt, BtnEdit, BtnKeluar);
        }
}//GEN-LAST:event_BtnPrintKeyPressed

    private void TCariKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_TCariKeyPressed
        if(evt.getKeyCode()==KeyEvent.VK_ENTER){
            BtnCariActionPerformed(null);
        }else if(evt.getKeyCode()==KeyEvent.VK_PAGE_DOWN){
            BtnCari.requestFocus();
        }else if(evt.getKeyCode()==KeyEvent.VK_PAGE_UP){
            BtnKeluar.requestFocus();
        }
}//GEN-LAST:event_TCariKeyPressed

    private void BtnCariActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnCariActionPerformed
        tampil();
}//GEN-LAST:event_BtnCariActionPerformed

    private void BtnCariKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnCariKeyPressed
        if(evt.getKeyCode()==KeyEvent.VK_SPACE){
            BtnCariActionPerformed(null);
        }else{
            Valid.pindah(evt, TCari, BtnAll);
        }
}//GEN-LAST:event_BtnCariKeyPressed

    private void BtnAllActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnAllActionPerformed
        TCari.setText("");
        tampil();
}//GEN-LAST:event_BtnAllActionPerformed

    private void BtnAllKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnAllKeyPressed
        if(evt.getKeyCode()==KeyEvent.VK_SPACE){
            TCari.setText("");
            tampil();
        }else{
            Valid.pindah(evt, BtnCari, TPasien);
        }
}//GEN-LAST:event_BtnAllKeyPressed

    private void tbObatMouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_tbObatMouseClicked
        if(tabMode.getRowCount()!=0){
            try {
                getData();
            } catch (java.lang.NullPointerException e) {
            }
            if((evt.getClickCount()==2)&&(tbObat.getSelectedColumn()==0)){
                TabRawat.setSelectedIndex(0);
            }
        }
}//GEN-LAST:event_tbObatMouseClicked

    private void tbObatKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_tbObatKeyPressed
        if(tabMode.getRowCount()!=0){
            if((evt.getKeyCode()==KeyEvent.VK_ENTER)||(evt.getKeyCode()==KeyEvent.VK_UP)||(evt.getKeyCode()==KeyEvent.VK_DOWN)){
                try {
                    getData();
                } catch (java.lang.NullPointerException e) {
                }
            }else if(evt.getKeyCode()==KeyEvent.VK_SPACE){
                try {
                    getData();
                    TabRawat.setSelectedIndex(0);
                } catch (java.lang.NullPointerException e) {
                }
            }
        }
}//GEN-LAST:event_tbObatKeyPressed

    private void BtnDokterActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnDokterActionPerformed
        dokter.isCek();
        dokter.setSize(internalFrame1.getWidth()-20,internalFrame1.getHeight()-20);
        dokter.setLocationRelativeTo(internalFrame1);
        dokter.setAlwaysOnTop(false);
        dokter.setVisible(true);
    }//GEN-LAST:event_BtnDokterActionPerformed

    private void BtnDokterKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnDokterKeyPressed
        Valid.pindah(evt,BtnDokter,NIP);
    }//GEN-LAST:event_BtnDokterKeyPressed

    private void MnHasilPemeriksaanGDTActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_MnHasilPemeriksaanGDTActionPerformed
        if(tbObat.getSelectedRow()>-1){
            Map<String, Object> param = new HashMap<>();
            param.put("namars",akses.getnamars());
            param.put("alamatrs",akses.getalamatrs());
            param.put("kotars",akses.getkabupatenrs());
            param.put("propinsirs",akses.getpropinsirs());
            param.put("kontakrs",akses.getkontakrs());
            param.put("emailrs",akses.getemailrs());          
            param.put("logo",Sequel.cariGambar("select setting.logo from setting")); 
            finger=Sequel.cariIsi("select sha1(sidikjari.sidikjari) from sidikjari INNER JOIN pegawai on pegawai.id=sidikjari.id where pegawai.nik=?",tbObat.getValueAt(tbObat.getSelectedRow(),5).toString());
            param.put("finger","Dikeluarkan di "+akses.getnamars()+", Kabupaten/Kota "+akses.getkabupatenrs()+"\nDitandatangani secara elektronik oleh "+tbObat.getValueAt(tbObat.getSelectedRow(),6).toString()+"\nID "+(finger.equals("")?tbObat.getValueAt(tbObat.getSelectedRow(),5).toString():finger)+"\n"+Valid.SetTgl3(tbObat.getValueAt(tbObat.getSelectedRow(),9).toString())); 
            finger2=Sequel.cariIsi("select sha1(sidikjari.sidikjari) from sidikjari INNER JOIN pegawai on pegawai.id=sidikjari.id where pegawai.nik=?",tbObat.getValueAt(tbObat.getSelectedRow(),7).toString());
            param.put("finger2","Dikeluarkan di "+akses.getnamars()+", Kabupaten/Kota "+akses.getkabupatenrs()+"\nDitandatangani secara elektronik oleh "+tbObat.getValueAt(tbObat.getSelectedRow(),8).toString()+"\nID "+(finger.equals("")?tbObat.getValueAt(tbObat.getSelectedRow(),7).toString():finger)+"\n"+Valid.SetTgl3(tbObat.getValueAt(tbObat.getSelectedRow(),9).toString())); 
            Valid.MyReportqry("rptPeriksaLabPermintaanGDT.jasper","report","::[ Hasil Pemeriksaan GDT ]::",
                "SELECT reg_periksa.no_rawat,pasien.no_rkm_medis,pasien.nm_pasien,hasil_pemeriksaan_gdt.kd_dokter,hasil_pemeriksaan_gdt.nip "+
                "hasil_pemeriksaan_gdt.kesan_eritorsit,hasil_pemeriksaan_gdt.kesan_leukosit,hasil_pemeriksaan_gdt.kesan_trombosit,hasil_pemeriksaan_gdt.kesan,hasil_pemeriksaan_gdt.kesimpulan,hasil_pemeriksaan_gdt.saran,"+
                "hasil_pemeriksaan_gdt.diff_manual,hasil_pemeriksaan_gdt.HB,hasil_pemeriksaan_gdt.WBC,hasil_pemeriksaan_gdt.PLT,"+        
                "dokter.nm_dokter,petugas.nama from reg_periksa INNER JOIN pasien on reg_periksa.no_rkm_medis=pasien.no_rkm_medis "+
                "INNER JOIN hasil_pemeriksaan_gdt on reg_periksa.no_rawat=hasil_pemeriksaan_gdt.no_rawat "+
                "INNER JOIN dokter on hasil_pemeriksaan_gdt.kd_dokter=dokter.kd_dokter "+
                "INNER JOIN petugas on hasil_pemeriksaan_gdt.nip=petugas.nip where hasil_pemeriksaan_gdt.no_rawat='"+tbObat.getValueAt(tbObat.getSelectedRow(),0).toString()+"'",param);
        }
    }//GEN-LAST:event_MnHasilPemeriksaanGDTActionPerformed

    private void kesan_eritrositKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_kesan_eritrositKeyPressed
        Valid.pindah2(evt,kesan_eritrosit,kesan_leukosit);
    }//GEN-LAST:event_kesan_eritrositKeyPressed

    private void BtnPetugasActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnPetugasActionPerformed
        petugas.isCek();
        petugas.setSize(internalFrame1.getWidth()-20,internalFrame1.getHeight()-20);
        petugas.setLocationRelativeTo(internalFrame1);
        petugas.setAlwaysOnTop(false);
        petugas.setVisible(true);
    }//GEN-LAST:event_BtnPetugasActionPerformed

    private void BtnPetugasKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnPetugasKeyPressed
        Valid.pindah(evt,BtnPetugas,kesan_eritrosit);
    }//GEN-LAST:event_BtnPetugasKeyPressed

    private void HBKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_HBKeyPressed
        Valid.pindah(evt,HB,WBC);
    }//GEN-LAST:event_HBKeyPressed

    private void WBCKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_WBCKeyPressed
        Valid.pindah(evt,WBC,PLT);
    }//GEN-LAST:event_WBCKeyPressed

    private void PLTKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_PLTKeyPressed
        Valid.pindah(evt,PLT,BtnSimpan);
    }//GEN-LAST:event_PLTKeyPressed

    private void kesan_leukositKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_kesan_leukositKeyPressed
        Valid.pindah(evt,kesan_leukosit,kesan_trombosit);
    }//GEN-LAST:event_kesan_leukositKeyPressed

    private void kesan_trombositKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_kesan_trombositKeyPressed
        Valid.pindah(evt,kesan_trombosit,kesan);
    }//GEN-LAST:event_kesan_trombositKeyPressed

    private void kesimpulanKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_kesimpulanKeyPressed
        Valid.pindah(evt,kesimpulan,saran);
    }//GEN-LAST:event_kesimpulanKeyPressed

    private void saranKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_saranKeyPressed
        Valid.pindah(evt,saran,diff_manual);
    }//GEN-LAST:event_saranKeyPressed

    private void kesanKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_kesanKeyPressed
        Valid.pindah(evt,kesan,kesimpulan);
    }//GEN-LAST:event_kesanKeyPressed

    private void diff_manualKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_diff_manualKeyPressed
        Valid.pindah(evt,diff_manual,HB);
    }//GEN-LAST:event_diff_manualKeyPressed

    private void TNoRwKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_TNoRwKeyPressed
        if(evt.getKeyCode()==KeyEvent.VK_PAGE_DOWN){
            isRawat();
            isPsien();
        }else{
            //Valid.pindah(evt,TCari,LamaSakit);
        }
    }//GEN-LAST:event_TNoRwKeyPressed

    private void TNoRMKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_TNoRMKeyPressed

    }//GEN-LAST:event_TNoRMKeyPressed

    private void TPasienKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_TPasienKeyPressed
        Valid.pindah(evt,TCari,BtnSimpan);
    }//GEN-LAST:event_TPasienKeyPressed

    /**
    * @param args the command line arguments
    */
    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(() -> {
            RMHasilPemeriksaanGDT dialog = new RMHasilPemeriksaanGDT(new javax.swing.JFrame(), true);
            dialog.addWindowListener(new java.awt.event.WindowAdapter() {
                @Override
                public void windowClosing(java.awt.event.WindowEvent e) {
                    System.exit(0);
                }
            });
            dialog.setVisible(true);
        });
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private widget.Button BtnAll;
    private widget.Button BtnBatal;
    private widget.Button BtnCari;
    private widget.Button BtnDokter;
    private widget.Button BtnEdit;
    private widget.Button BtnHapus;
    private widget.Button BtnKeluar;
    private widget.Button BtnPetugas;
    private widget.Button BtnPrint;
    private widget.Button BtnSimpan;
    private widget.Tanggal DTPCari1;
    private widget.Tanggal DTPCari2;
    private widget.PanelBiasa FormInput;
    private widget.TextBox HB;
    private widget.TextBox KdDokter;
    private widget.Label LCount;
    private widget.editorpane LoadHTML;
    private javax.swing.JMenuItem MnHasilPemeriksaanGDT;
    private widget.TextBox NIP;
    private widget.TextBox NmDokter;
    private widget.TextBox NmPetugas;
    private widget.TextBox PLT;
    private widget.ScrollPane Scroll;
    private widget.TextBox TCari;
    private widget.TextBox TNoRM;
    private widget.TextBox TNoRw;
    private widget.TextBox TPasien;
    private javax.swing.JTabbedPane TabRawat;
    private widget.TextBox TanggalRegistrasi;
    private widget.TextBox WBC;
    private widget.TextArea diff_manual;
    private widget.InternalFrame internalFrame1;
    private widget.InternalFrame internalFrame2;
    private widget.InternalFrame internalFrame3;
    private widget.Label jLabel17;
    private widget.Label jLabel19;
    private widget.Label jLabel20;
    private widget.Label jLabel21;
    private widget.Label jLabel24;
    private widget.Label jLabel25;
    private widget.Label jLabel27;
    private widget.Label jLabel28;
    private widget.Label jLabel4;
    private widget.Label jLabel53;
    private widget.Label jLabel54;
    private widget.Label jLabel55;
    private widget.Label jLabel56;
    private widget.Label jLabel57;
    private widget.Label jLabel58;
    private widget.Label jLabel59;
    private widget.Label jLabel6;
    private widget.Label jLabel7;
    private javax.swing.JPopupMenu jPopupMenu1;
    private javax.swing.JSeparator jSeparator1;
    private javax.swing.JSeparator jSeparator5;
    private widget.TextArea kesan;
    private widget.TextArea kesan_eritrosit;
    private widget.TextArea kesan_leukosit;
    private widget.TextArea kesan_trombosit;
    private widget.TextArea kesimpulan;
    private widget.Label label14;
    private widget.Label label15;
    private widget.panelisi panelGlass8;
    private widget.panelisi panelGlass9;
    private widget.TextArea saran;
    private widget.ScrollPane scrollInput;
    private widget.ScrollPane scrollPane20;
    private widget.ScrollPane scrollPane21;
    private widget.ScrollPane scrollPane22;
    private widget.ScrollPane scrollPane23;
    private widget.ScrollPane scrollPane24;
    private widget.ScrollPane scrollPane25;
    private widget.ScrollPane scrollPane26;
    private widget.Table tbObat;
    // End of variables declaration//GEN-END:variables

    public void tampil() {
        Valid.tabelKosong(tabMode);
        try{
            if(TCari.getText().trim().equals("")){
                ps=koneksi.prepareStatement(
                        "SELECT reg_periksa.no_rawat,pasien.no_rkm_medis,pasien.nm_pasien,"+
                        "hasil_pemeriksaan_gdt.kd_dokter,hasil_pemeriksaan_gdt.nip,hasil_pemeriksaan_gdt.kesan_eritorsit,hasil_pemeriksaan_gdt.kesan_leukosit,hasil_pemeriksaan_gdt.kesan_trombosit,hasil_pemeriksaan_gdt.kesan,hasil_pemeriksaan_gdt.kesimpulan,hasil_pemeriksaan_gdt.saran,"+
                        "hasil_pemeriksaan_gdt.diff_manual,hasil_pemeriksaan_gdt.HB,hasil_pemeriksaan_gdt.WBC,hasil_pemeriksaan_gdt.PLT,"+                                
                        "dokter.nm_dokter,petugas.nama FROM reg_periksa INNER JOIN pasien on reg_periksa.no_rkm_medis=pasien.no_rkm_medis "+
                        "INNER JOIN hasil_pemeriksaan_gdt on reg_periksa.no_rawat=hasil_pemeriksaan_gdt.no_rawat "+
                        "INNER JOIN dokter on hasil_pemeriksaan_gdt.kd_dokter=dokter.kd_dokter "+
                        "INNER JOIN petugas on hasil_pemeriksaan_gdt.nip=petugas.nip ");
            }else{
                ps=koneksi.prepareStatement(
                        "SELECT reg_periksa.no_rawat,pasien.no_rkm_medis,pasien.nm_pasien,"+
                        "hasil_pemeriksaan_gdt.kd_dokter,hasil_pemeriksaan_gdt.nip,hasil_pemeriksaan_gdt.kesan_eritorsit,hasil_pemeriksaan_gdt.kesan_leukosit,hasil_pemeriksaan_gdt.kesan_trombosit,hasil_pemeriksaan_gdt.kesan,hasil_pemeriksaan_gdt.kesimpulan,hasil_pemeriksaan_gdt.saran,"+
                        "hasil_pemeriksaan_gdt.diff_manual,hasil_pemeriksaan_gdt.HB,hasil_pemeriksaan_gdt.WBC,hasil_pemeriksaan_gdt.PLT,"+                                
                        "dokter.nm_dokter,petugas.nama FROM reg_periksa INNER JOIN pasien on reg_periksa.no_rkm_medis=pasien.no_rkm_medis "+
                        "INNER JOIN hasil_pemeriksaan_gdt on reg_periksa.no_rawat=hasil_pemeriksaan_gdt.no_rawat "+
                        "INNER JOIN dokter on hasil_pemeriksaan_gdt.kd_dokter=dokter.kd_dokter "+
                        "INNER JOIN petugas on hasil_pemeriksaan_gdt.nip=petugas.nip ");
            }
                
            try {
                if(TCari.getText().trim().equals("")){
                    ps.setString(1,Valid.SetTgl(DTPCari1.getSelectedItem()+"")+" 00:00:00");
                    ps.setString(2,Valid.SetTgl(DTPCari2.getSelectedItem()+"")+" 23:59:59");
                }else{
                    ps.setString(1,Valid.SetTgl(DTPCari1.getSelectedItem()+"")+" 00:00:00");
                    ps.setString(2,Valid.SetTgl(DTPCari2.getSelectedItem()+"")+" 23:59:59");
                    ps.setString(3,"%"+TCari.getText()+"%");
                    ps.setString(4,"%"+TCari.getText()+"%");
                    ps.setString(5,"%"+TCari.getText()+"%");
                    ps.setString(6,"%"+TCari.getText()+"%");
                    ps.setString(7,"%"+TCari.getText()+"%");
                }   
                rs=ps.executeQuery();
                while(rs.next()){
                    tabMode.addRow(new String[]{
                        rs.getString("no_rawat"),rs.getString("no_rkm_medis"),rs.getString("nm_pasien"),rs.getString("kd_dokter"),rs.getString("nm_dokter"),rs.getString("nip"),rs.getString("nama"),
                        rs.getString("kesan_eritorsit"),rs.getString("kesan_leukosit"),rs.getString("kesan_trombosit"),rs.getString("kesan"),rs.getString("kesimpulan"),rs.getString("saran"),rs.getString("diff_manual"),rs.getString("HB"),
                        rs.getString("WBC"),rs.getString("PLT")
                    });
                }
            } catch (Exception e) {
                System.out.println("Notif : "+e);
            } finally{
                if(rs!=null){
                    rs.close();
                }
                if(ps!=null){
                    ps.close();
                }
            }
            
        }catch(Exception e){
            System.out.println("Notifikasi : "+e);
        }
        LCount.setText(""+tabMode.getRowCount());
    }

    public void emptTeks() {
        kesan_eritrosit.setText("");
        kesan_leukosit.setText("");
        kesan_trombosit.setText("");
        kesan.setText("");
        kesimpulan.setText("");
        saran.setText("");
        diff_manual.setText("");        
        HB.setText("");
        WBC.setText("");
        PLT.setText("");
        kesan_eritrosit.requestFocus();
    } 

    private void getData() {
        if(tbObat.getSelectedRow()!= -1){
            TNoRw.setText(tbObat.getValueAt(tbObat.getSelectedRow(),0).toString()); 
            TNoRM.setText(tbObat.getValueAt(tbObat.getSelectedRow(),1).toString());
            TPasien.setText(tbObat.getValueAt(tbObat.getSelectedRow(),2).toString());                        
            KdDokter.setText(tbObat.getValueAt(tbObat.getSelectedRow(),4).toString()); 
            NmDokter.setText(tbObat.getValueAt(tbObat.getSelectedRow(),5).toString()); 
            kesan_eritrosit.setText(tbObat.getValueAt(tbObat.getSelectedRow(),7).toString());
            kesan_leukosit.setText(tbObat.getValueAt(tbObat.getSelectedRow(),8).toString());
            kesan_trombosit.setText(tbObat.getValueAt(tbObat.getSelectedRow(),9).toString());
            kesan.setText(tbObat.getValueAt(tbObat.getSelectedRow(),10).toString());
            kesimpulan.setText(tbObat.getValueAt(tbObat.getSelectedRow(),11).toString());
            saran.setText(tbObat.getValueAt(tbObat.getSelectedRow(),12).toString());
            diff_manual.setText(tbObat.getValueAt(tbObat.getSelectedRow(),13).toString());
            HB.setText(tbObat.getValueAt(tbObat.getSelectedRow(),14).toString());
            WBC.setText(tbObat.getValueAt(tbObat.getSelectedRow(),15).toString());
            PLT.setText(tbObat.getValueAt(tbObat.getSelectedRow(),16).toString());
            
        }
    }

    private void isRawat() {
         Sequel.cariIsi("select reg_periksa.no_rkm_medis from reg_periksa where reg_periksa.no_rawat='"+TNoRw.getText()+"' ",TNoRM);
    }

    private void isPsien() {
        Sequel.cariIsi("select pasien.nm_pasien from pasien where pasien.no_rkm_medis='"+TNoRM.getText()+"' ",TPasien);
    }
    
    public void setNoRm(String norwt, Date tgl1, Date tgl2) {
        TNoRw.setText(norwt);
        TCari.setText(norwt);
        DTPCari1.setDate(tgl1);
        DTPCari2.setDate(tgl2);
        isRawat();
        isPsien(); 
    }

    public void isCek(){
        BtnSimpan.setEnabled(akses.getsurat_keterangan_covid());
        BtnHapus.setEnabled(akses.getsurat_keterangan_covid());
        BtnEdit.setEnabled(akses.getsurat_keterangan_covid());
        BtnEdit.setEnabled(akses.getsurat_keterangan_covid());
        if(akses.getjml2()>=1){
            NIP.setEditable(false);
            BtnPetugas.setEnabled(false);
            NIP.setText(akses.getkode());
            NmPetugas.setText(petugas.tampil3(NIP.getText()));
            if(NmPetugas.getText().equals("")){
                NIP.setText("");
                JOptionPane.showMessageDialog(null,"User login bukan petugas...!!");
            }
        }           
    }
    
    public void setTampil(){
       TabRawat.setSelectedIndex(1);
    }

    private void hapus() {
        if(Sequel.queryu2tf("delete from hasil_pemeriksaan_gdt where no_rawat=?",1,new String[]{
            tbObat.getValueAt(tbObat.getSelectedRow(),0).toString()
        })==true){
            tabMode.removeRow(tbObat.getSelectedRow());
            LCount.setText(""+tabMode.getRowCount());
            TabRawat.setSelectedIndex(1);
        }else{
            JOptionPane.showMessageDialog(null,"Gagal menghapus..!!");
        }
    }

    private void ganti() {
        if(Sequel.mengedittf("hasil_pemeriksaan_gdt","no_rawat=?","no_rawat=?,kd_dokter=?,nip=?,kesan_eritorsit=?,kesan_leukosit=?,"+
                "kesan_trombosit=?,kesan=?,kesimpulan=?,saran=?,diff_manual=?,HB=?,WBC=?,PLT=? ",13,new String[]{
                TNoRw.getText(),KdDokter.getText(),NIP.getText(),kesan_eritrosit.getText(),kesan_leukosit.getText(),kesan_trombosit.getText(),kesan.getText(),
                kesimpulan.getText(),saran.getText(),diff_manual.getText(),HB.getText(),WBC.getText(),PLT.getText(),tbObat.getValueAt(tbObat.getSelectedRow(),0).toString()
            })==true){
               tbObat.setValueAt(TNoRw.getText(),tbObat.getSelectedRow(),0);
               tbObat.setValueAt(TNoRM.getText(),tbObat.getSelectedRow(),1);
               tbObat.setValueAt(TPasien.getText(),tbObat.getSelectedRow(),2);                            
               tbObat.setValueAt(KdDokter.getText(),tbObat.getSelectedRow(),3);
               tbObat.setValueAt(NmDokter.getText(),tbObat.getSelectedRow(),4);
               tbObat.setValueAt(NIP.getText(),tbObat.getSelectedRow(),5);
               tbObat.setValueAt(NmPetugas.getText(),tbObat.getSelectedRow(),6);               
               tbObat.setValueAt(kesan_eritrosit.getText(),tbObat.getSelectedRow(),7);
               tbObat.setValueAt(kesan_leukosit.getText(),tbObat.getSelectedRow(),8);
               tbObat.setValueAt(kesan_trombosit.getText(),tbObat.getSelectedRow(),9);
               tbObat.setValueAt(kesan.getText(),tbObat.getSelectedRow(),10);
               tbObat.setValueAt(kesimpulan.getText(),tbObat.getSelectedRow(),11);
               tbObat.setValueAt(saran.getText(),tbObat.getSelectedRow(),12);
               tbObat.setValueAt(diff_manual.getText(),tbObat.getSelectedRow(),13);
               tbObat.setValueAt(HB.getText(),tbObat.getSelectedRow(),14);
               tbObat.setValueAt(WBC.getText(),tbObat.getSelectedRow(),15);
               tbObat.setValueAt(PLT.getText(),tbObat.getSelectedRow(),16);
               
               emptTeks();
               TabRawat.setSelectedIndex(1);
        }
    }
           
//    private void simpan() {
//        if(Sequel.menyimpantf("hasil_pemeriksaan_gdt","?,?,?,?,?,?,?,?,?,?,?,?,?","No.Rawat",13,new String[]{
//                TNoRw.getText(),KdDokter.getText(),NIP.getText(),kesan_eritrosit.getText(),kesan_eritrosit.getText(),kesan_leukosit.getText(),kesan_trombosit.getText(),
//                kesan.getText(),kesimpulan.getText(),saran.getText(),diff_manual.getText(),HB.getText(),WBC.getText(),PLT.getText()
//            })==true){
//        
//        tabMode.addRow(new String[]{
//                TNoRw.getText(),KdDokter.getText(),NIP.getText(),kesan_eritrosit.getText(),kesan_eritrosit.getText(),kesan_leukosit.getText(),kesan_trombosit.getText(),
//                kesan.getText(),kesimpulan.getText(),saran.getText(),diff_manual.getText(),HB.getText(),WBC.getText(),PLT.getText()
//            });
//        
//            LCount.setText(""+tabMode.getRowCount());
//            emptTeks();
//        }
//    }

//    public void setNoRm(String toString, Date date, Date date0) {
//        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
//    }
}
