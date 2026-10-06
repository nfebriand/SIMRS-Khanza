/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

 /*
 * DlgRujuk.java
 *
 * Created on 31 Mei 10, 20:19:56
 */
package rekammedis;

import fungsi.WarnaTable;
import fungsi.batasInput;
import fungsi.koneksiDB;
import fungsi.sekuel;
import fungsi.validasi;
import fungsi.akses;
import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import javax.swing.JOptionPane;
import javax.swing.JTable;
import javax.swing.Timer;
import javax.swing.event.DocumentEvent;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.TableColumn;
import kepegawaian.DlgCariPetugas;


/**
 *
 * @author perpustakaan
 */
public final class RMHandOver extends javax.swing.JDialog {

    private final DefaultTableModel tabMode;
    private Connection koneksi = koneksiDB.condb();
    private sekuel Sequel = new sekuel();
    private validasi Valid = new validasi();
    private PreparedStatement ps;
    private ResultSet rs;
    private int i = 0, pilihan = 0;
    private DlgCariPetugas petugas = new DlgCariPetugas(null, false);
    private String TANGGALMUNDUR = "yes";
    private boolean abaikanEventTanggal = false;
    // Isi shift yang ditarik otomatis dari shift sebelumnya (belum disimpan)
    private String shiftPrefill = "";
    private String teksPrefill = "";
    // true = isi shift sebelumnya hanya ditarik jika shift tersebut sudah divalidasi (validasi_handover_shift).
    // Set false jika ingin selalu ditarik walau belum divalidasi.
    private static final boolean WAJIB_VALIDASI_SEBELUMNYA = true;
    // Jadwal: Pagi 08-14, Siang 14-20, Malam 20-08. Malam dicatat di tanggal saat shift dimulai,
    // jadi Malam yang dicentang sebelum jam ini memakai tanggal kemarin.
    private static final int JAM_MULAI_PAGI = 8;
    private boolean tanggalOtomatisMundur = false;

    /**
     * Creates new form DlgRujuk
     *
     * @param parent
     * @param modal
     */
    public RMHandOver(java.awt.Frame parent, boolean modal) {
        super(parent, modal);
        initComponents();
        this.setLocation(8, 1);
        setSize(628, 674);

        tabMode = new DefaultTableModel(null, new Object[]{
            "P", "No.Rawat", "No.R.M.", "Nama Pasien", "Tgl.Rawat", "Jam", "Shift Pagi", "Shift Siang", "Shift Malam",
            "Shift Keluar", "NIP Keluar", "Nama Petugas Keluar", "Shift Masuk", "NIP Masuk", "Nama Petugas Masuk",
            "Status Verifikasi"}) {
            @Override
            public boolean isCellEditable(int rowIndex, int colIndex) {
                boolean a = false;
                if (colIndex == 0) {
                    a = true;
                }
                return a;
            }
            Class[] types = new Class[]{
                java.lang.Boolean.class, java.lang.Object.class, java.lang.Object.class, java.lang.Object.class,
                java.lang.Object.class, java.lang.Object.class, java.lang.Object.class, java.lang.Object.class,
                java.lang.Object.class, java.lang.Object.class, java.lang.Object.class, java.lang.Object.class,
                java.lang.Object.class, java.lang.Object.class, java.lang.Object.class, java.lang.Object.class
            };

            @Override
            public Class getColumnClass(int columnIndex) {
                return types[columnIndex];
            }
        };
        tbPemeriksaanSbar.setModel(tabMode);
        tbPemeriksaanSbar.setPreferredScrollableViewportSize(new Dimension(500, 500));
        tbPemeriksaanSbar.setAutoResizeMode(JTable.AUTO_RESIZE_OFF);

        int[] lebarKolom = {20, 105, 70, 180, 100, 100, 190, 190, 190, 100, 120, 150, 100, 120, 150, 260};
        for (i = 0; i < lebarKolom.length; i++) {
            TableColumn column = tbPemeriksaanSbar.getColumnModel().getColumn(i);
            column.setPreferredWidth(lebarKolom[i]);
        }
        tbPemeriksaanSbar.setDefaultRenderer(Object.class, new WarnaTable());

        TNoRw.setDocument(new batasInput((byte) 17).getKata(TNoRw));
        NIP.setDocument(new batasInput((byte) 20).getKata(NIP));
        TShiftPagi.setDocument(new batasInput((int) 2000).getKata(TShiftPagi));
        TShiftSiang.setDocument(new batasInput((int) 2000).getKata(TShiftSiang));
        TShiftMalam.setDocument(new batasInput((int) 2000).getKata(TShiftMalam));
        TCari.setDocument(new batasInput((int) 100).getKata(TCari));

        if (koneksiDB.CARICEPAT().equals("aktif")) {
            TCari.getDocument().addDocumentListener(new javax.swing.event.DocumentListener() {
                @Override
                public void insertUpdate(DocumentEvent e) {
                    if (TCari.getText().length() > 2) {
                        tampil();
                    }
                }

                @Override
                public void removeUpdate(DocumentEvent e) {
                    if (TCari.getText().length() > 2) {
                        tampil();
                    }
                }

                @Override
                public void changedUpdate(DocumentEvent e) {
                    if (TCari.getText().length() > 2) {
                        tampil();
                    }
                }
            });
        }

        petugas.addWindowListener(new WindowListener() {
            @Override
            public void windowOpened(WindowEvent e) {
            }

            @Override
            public void windowClosing(WindowEvent e) {
            }

            @Override
            public void windowClosed(WindowEvent e) {
                if (pilihan == 1) {
                    if (petugas.getTable().getSelectedRow() != -1) {
                        NIP.setText(petugas.getTable().getValueAt(petugas.getTable().getSelectedRow(), 0).toString());
                        NamaPetugas.setText(petugas.getTable().getValueAt(petugas.getTable().getSelectedRow(), 1).toString());
                    }
                    NIP.requestFocus();
                } else if (pilihan == 2) {
                    if (petugas.getTable().getSelectedRow() != -1) {
                        NIP2.setText(petugas.getTable().getValueAt(petugas.getTable().getSelectedRow(), 0).toString());
                        NamaPetugas2.setText(petugas.getTable().getValueAt(petugas.getTable().getSelectedRow(), 1).toString());
                    }
                    NIP.requestFocus();
                }

            }

            @Override
            public void windowIconified(WindowEvent e) {
            }

            @Override
            public void windowDeiconified(WindowEvent e) {
            }

            @Override
            public void windowActivated(WindowEvent e) {
            }

            @Override
            public void windowDeactivated(WindowEvent e) {
            }
        });

        try {
            TANGGALMUNDUR = koneksiDB.TANGGALMUNDUR();
        } catch (Exception e) {
            TANGGALMUNDUR = "yes";
        }

        pilihShift("");
        DTPTgl.addItemListener(new java.awt.event.ItemListener() {
            @Override
            public void itemStateChanged(java.awt.event.ItemEvent e) {
                if (e.getStateChange() == java.awt.event.ItemEvent.SELECTED && !abaikanEventTanggal) {
                    muatDataHandover();
                }
            }
        });

        ChkInput.setSelected(false);
        isForm();

        jam();
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jPopupMenu1 = new javax.swing.JPopupMenu();
        MnCatatanADIME = new javax.swing.JMenuItem();
        JK = new widget.TextBox();
        Umur = new widget.TextBox();
        TanggalRegistrasi = new widget.TextBox();
        internalFrame1 = new widget.InternalFrame();
        Scroll = new widget.ScrollPane();
        tbPemeriksaanSbar = new widget.Table();
        jPanel3 = new javax.swing.JPanel();
        panelGlass8 = new widget.panelisi();
        BtnSimpan = new widget.Button();
        BtnBatal = new widget.Button();
        BtnHapus = new widget.Button();
        BtnEdit = new widget.Button();
        BtnPrint = new widget.Button();
        jLabel7 = new widget.Label();
        LCount = new widget.Label();
        BtnKeluar = new widget.Button();
        panelGlass9 = new widget.panelisi();
        jLabel19 = new widget.Label();
        DTPCari1 = new widget.Tanggal();
        jLabel21 = new widget.Label();
        DTPCari2 = new widget.Tanggal();
        jLabel6 = new widget.Label();
        TCari = new widget.TextBox();
        BtnCari = new widget.Button();
        BtnAll = new widget.Button();
        PanelInput = new javax.swing.JPanel();
        ChkInput = new widget.CekBox();
        scrollInput = new widget.ScrollPane();
        FormInput = new widget.PanelBiasa();
        jLabel5 = new widget.Label();
        TNoRw = new widget.TextBox();
        TNoRM = new widget.TextBox();
        TPasien = new widget.TextBox();
        jLabel4 = new widget.Label();
        RuangRawat = new widget.TextBox();
        jLabel9 = new widget.Label();
        DTPTgl = new widget.Tanggal();
        cmbJam = new widget.ComboBox();
        cmbMnt = new widget.ComboBox();
        cmbDtk = new widget.ComboBox();
        ChkKejadian = new widget.CekBox();
        jLabel8 = new widget.Label();
        DiagnosaAwal = new widget.TextBox();
        jLabel96 = new widget.Label();
        ShiftKeluar = new widget.ComboBox();
        NIP = new widget.TextBox();
        NamaPetugas = new widget.TextBox();
        BtnSeekPegawai1 = new widget.Button();
        BtnStatusVerifikasiHandOver = new widget.Button();
        jLabel94 = new widget.Label();
        ShiftMasuk = new widget.ComboBox();
        NIP2 = new widget.TextBox();
        NamaPetugas2 = new widget.TextBox();
        BtnSeekPegawai2 = new widget.Button();
        BtnValidasiHandOver = new widget.Button();
        ChkShiftPagi = new javax.swing.JCheckBox();
        ChkShiftSiang = new javax.swing.JCheckBox();
        ChkShiftMalam = new javax.swing.JCheckBox();
        scrollShiftPagi = new widget.ScrollPane();
        TShiftPagi = new widget.TextArea();
        scrollShiftSiang = new widget.ScrollPane();
        TShiftSiang = new widget.TextArea();
        scrollShiftMalam = new widget.ScrollPane();
        TShiftMalam = new widget.TextArea();

        jPopupMenu1.setName("jPopupMenu1"); // NOI18N

        MnCatatanADIME.setBackground(new java.awt.Color(255, 255, 254));
        MnCatatanADIME.setFont(new java.awt.Font("Tahoma", 0, 11)); // NOI18N
        MnCatatanADIME.setForeground(new java.awt.Color(50, 50, 50));
        MnCatatanADIME.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/category.png"))); // NOI18N
        MnCatatanADIME.setText("Formulir Catatan ADIME Gizi");
        MnCatatanADIME.setName("MnCatatanADIME"); // NOI18N
        MnCatatanADIME.setPreferredSize(new java.awt.Dimension(240, 26));
        MnCatatanADIME.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                MnCatatanADIMEActionPerformed(evt);
            }
        });
        jPopupMenu1.add(MnCatatanADIME);

        JK.setHighlighter(null);
        JK.setName("JK"); // NOI18N

        Umur.setHighlighter(null);
        Umur.setName("Umur"); // NOI18N

        TanggalRegistrasi.setHighlighter(null);
        TanggalRegistrasi.setName("TanggalRegistrasi"); // NOI18N

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        setUndecorated(true);
        setResizable(false);

        internalFrame1.setBorder(javax.swing.BorderFactory.createTitledBorder(javax.swing.BorderFactory.createLineBorder(new java.awt.Color(240, 245, 235)), "::[ Data Hand Over (Serah Terima) Pasien ]::", javax.swing.border.TitledBorder.DEFAULT_JUSTIFICATION, javax.swing.border.TitledBorder.DEFAULT_POSITION, new java.awt.Font("Tahoma", 0, 11), new java.awt.Color(50, 50, 50))); // NOI18N
        internalFrame1.setFont(new java.awt.Font("Tahoma", 2, 12)); // NOI18N
        internalFrame1.setName("internalFrame1"); // NOI18N
        internalFrame1.setLayout(new java.awt.BorderLayout(1, 1));

        Scroll.setName("Scroll"); // NOI18N
        Scroll.setOpaque(true);
        Scroll.setPreferredSize(new java.awt.Dimension(452, 200));

        tbPemeriksaanSbar.setAutoCreateRowSorter(true);
        tbPemeriksaanSbar.setToolTipText("Silahkan klik untuk memilih data yang mau diedit ataupun dihapus");
        tbPemeriksaanSbar.setName("tbPemeriksaanSbar"); // NOI18N
        tbPemeriksaanSbar.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                tbPemeriksaanSbarMouseClicked(evt);
            }
        });
        tbPemeriksaanSbar.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyReleased(java.awt.event.KeyEvent evt) {
                tbPemeriksaanSbarKeyReleased(evt);
            }
        });
        Scroll.setViewportView(tbPemeriksaanSbar);

        internalFrame1.add(Scroll, java.awt.BorderLayout.CENTER);

        jPanel3.setName("jPanel3"); // NOI18N
        jPanel3.setOpaque(false);
        jPanel3.setPreferredSize(new java.awt.Dimension(44, 100));
        jPanel3.setLayout(new java.awt.BorderLayout(1, 1));

        panelGlass8.setName("panelGlass8"); // NOI18N
        panelGlass8.setPreferredSize(new java.awt.Dimension(44, 44));
        panelGlass8.setLayout(new java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 5, 9));

        BtnSimpan.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/save-16x16.png"))); // NOI18N
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

        BtnBatal.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/Cancel-2-16x16.png"))); // NOI18N
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

        BtnHapus.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/stop_f2.png"))); // NOI18N
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

        BtnEdit.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/inventaris.png"))); // NOI18N
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

        BtnPrint.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/b_print.png"))); // NOI18N
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

        jLabel7.setText("Record :");
        jLabel7.setName("jLabel7"); // NOI18N
        jLabel7.setPreferredSize(new java.awt.Dimension(80, 23));
        panelGlass8.add(jLabel7);

        LCount.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
        LCount.setText("0");
        LCount.setName("LCount"); // NOI18N
        LCount.setPreferredSize(new java.awt.Dimension(70, 23));
        panelGlass8.add(LCount);

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

        jPanel3.add(panelGlass8, java.awt.BorderLayout.CENTER);

        panelGlass9.setName("panelGlass9"); // NOI18N
        panelGlass9.setPreferredSize(new java.awt.Dimension(44, 44));
        panelGlass9.setLayout(new java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 5, 9));

        jLabel19.setText("Tanggal :");
        jLabel19.setName("jLabel19"); // NOI18N
        jLabel19.setPreferredSize(new java.awt.Dimension(60, 23));
        panelGlass9.add(jLabel19);

        DTPCari1.setForeground(new java.awt.Color(50, 70, 50));
        DTPCari1.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "17-09-2026" }));
        DTPCari1.setDisplayFormat("dd-MM-yyyy");
        DTPCari1.setName("DTPCari1"); // NOI18N
        DTPCari1.setOpaque(false);
        DTPCari1.setPreferredSize(new java.awt.Dimension(95, 23));
        panelGlass9.add(DTPCari1);

        jLabel21.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        jLabel21.setText("s.d.");
        jLabel21.setName("jLabel21"); // NOI18N
        jLabel21.setPreferredSize(new java.awt.Dimension(23, 23));
        panelGlass9.add(jLabel21);

        DTPCari2.setForeground(new java.awt.Color(50, 70, 50));
        DTPCari2.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "17-09-2026" }));
        DTPCari2.setDisplayFormat("dd-MM-yyyy");
        DTPCari2.setName("DTPCari2"); // NOI18N
        DTPCari2.setOpaque(false);
        DTPCari2.setPreferredSize(new java.awt.Dimension(95, 23));
        panelGlass9.add(DTPCari2);

        jLabel6.setText("Key Word :");
        jLabel6.setName("jLabel6"); // NOI18N
        jLabel6.setPreferredSize(new java.awt.Dimension(90, 23));
        panelGlass9.add(jLabel6);

        TCari.setName("TCari"); // NOI18N
        TCari.setPreferredSize(new java.awt.Dimension(310, 23));
        TCari.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                TCariKeyPressed(evt);
            }
        });
        panelGlass9.add(TCari);

        BtnCari.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/accept.png"))); // NOI18N
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

        BtnAll.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/Search-16x16.png"))); // NOI18N
        BtnAll.setMnemonic('M');
        BtnAll.setToolTipText("Alt+M");
        BtnAll.setName("BtnAll"); // NOI18N
        BtnAll.setPreferredSize(new java.awt.Dimension(28, 23));
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
        panelGlass9.add(BtnAll);

        jPanel3.add(panelGlass9, java.awt.BorderLayout.PAGE_START);

        internalFrame1.add(jPanel3, java.awt.BorderLayout.PAGE_END);

        PanelInput.setToolTipText("");
        PanelInput.setName("PanelInput"); // NOI18N
        PanelInput.setOpaque(false);
        PanelInput.setPreferredSize(new java.awt.Dimension(192, 400));
        PanelInput.setLayout(new java.awt.BorderLayout(1, 1));

        ChkInput.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/143.png"))); // NOI18N
        ChkInput.setMnemonic('I');
        ChkInput.setText(".: Input Data");
        ChkInput.setToolTipText("Alt+I");
        ChkInput.setBorderPainted(true);
        ChkInput.setBorderPaintedFlat(true);
        ChkInput.setFocusable(false);
        ChkInput.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
        ChkInput.setHorizontalTextPosition(javax.swing.SwingConstants.RIGHT);
        ChkInput.setName("ChkInput"); // NOI18N
        ChkInput.setPreferredSize(new java.awt.Dimension(192, 20));
        ChkInput.setRolloverIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/143.png"))); // NOI18N
        ChkInput.setRolloverSelectedIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/145.png"))); // NOI18N
        ChkInput.setSelectedIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/145.png"))); // NOI18N
        ChkInput.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                ChkInputActionPerformed(evt);
            }
        });
        PanelInput.add(ChkInput, java.awt.BorderLayout.PAGE_END);

        scrollInput.setName("scrollInput"); // NOI18N
        scrollInput.setPreferredSize(new java.awt.Dimension(102, 557));

        FormInput.setBackground(new java.awt.Color(250, 255, 245));
        FormInput.setBorder(null);
        FormInput.setName("FormInput"); // NOI18N
        FormInput.setPreferredSize(new java.awt.Dimension(960, 375));
        FormInput.setLayout(null);

        jLabel5.setText("No.Rawat :");
        jLabel5.setName("jLabel5"); // NOI18N
        FormInput.add(jLabel5);
        jLabel5.setBounds(0, 10, 95, 23);

        TNoRw.setHighlighter(null);
        TNoRw.setName("TNoRw"); // NOI18N
        TNoRw.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                TNoRwKeyPressed(evt);
            }
        });
        FormInput.add(TNoRw);
        TNoRw.setBounds(100, 10, 130, 23);

        TNoRM.setEditable(false);
        TNoRM.setHighlighter(null);
        TNoRM.setName("TNoRM"); // NOI18N
        TNoRM.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                TNoRMKeyPressed(evt);
            }
        });
        FormInput.add(TNoRM);
        TNoRM.setBounds(240, 10, 100, 23);

        TPasien.setEditable(false);
        TPasien.setHighlighter(null);
        TPasien.setName("TPasien"); // NOI18N
        TPasien.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                TPasienKeyPressed(evt);
            }
        });
        FormInput.add(TPasien);
        TPasien.setBounds(350, 10, 290, 23);

        jLabel4.setText("Ruang Rawat :");
        jLabel4.setName("jLabel4"); // NOI18N
        FormInput.add(jLabel4);
        jLabel4.setBounds(650, 10, 90, 23);

        RuangRawat.setEditable(false);
        RuangRawat.setHighlighter(null);
        RuangRawat.setName("RuangRawat"); // NOI18N
        FormInput.add(RuangRawat);
        RuangRawat.setBounds(740, 10, 200, 23);

        jLabel9.setText("Tanggal :");
        jLabel9.setName("jLabel9"); // NOI18N
        FormInput.add(jLabel9);
        jLabel9.setBounds(0, 40, 95, 23);

        DTPTgl.setForeground(new java.awt.Color(50, 70, 50));
        DTPTgl.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "17-09-2026" }));
        DTPTgl.setDisplayFormat("dd-MM-yyyy");
        DTPTgl.setName("DTPTgl"); // NOI18N
        DTPTgl.setOpaque(false);
        DTPTgl.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                DTPTglKeyPressed(evt);
            }
        });
        FormInput.add(DTPTgl);
        DTPTgl.setBounds(100, 40, 130, 23);

        cmbJam.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23" }));
        cmbJam.setName("cmbJam"); // NOI18N
        cmbJam.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                cmbJamKeyPressed(evt);
            }
        });
        FormInput.add(cmbJam);
        cmbJam.setBounds(235, 40, 50, 23);

        cmbMnt.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59" }));
        cmbMnt.setName("cmbMnt"); // NOI18N
        cmbMnt.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                cmbMntKeyPressed(evt);
            }
        });
        FormInput.add(cmbMnt);
        cmbMnt.setBounds(285, 40, 50, 23);

        cmbDtk.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59" }));
        cmbDtk.setName("cmbDtk"); // NOI18N
        cmbDtk.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                cmbDtkKeyPressed(evt);
            }
        });
        FormInput.add(cmbDtk);
        cmbDtk.setBounds(335, 40, 50, 23);

        ChkKejadian.setBorder(null);
        ChkKejadian.setSelected(true);
        ChkKejadian.setFont(new java.awt.Font("Tahoma", 1, 11)); // NOI18N
        ChkKejadian.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        ChkKejadian.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
        ChkKejadian.setName("ChkKejadian"); // NOI18N
        FormInput.add(ChkKejadian);
        ChkKejadian.setBounds(385, 40, 23, 23);

        jLabel8.setText("Diagnosa :");
        jLabel8.setName("jLabel8"); // NOI18N
        FormInput.add(jLabel8);
        jLabel8.setBounds(420, 40, 75, 23);

        DiagnosaAwal.setEditable(false);
        DiagnosaAwal.setHighlighter(null);
        DiagnosaAwal.setName("DiagnosaAwal"); // NOI18N
        DiagnosaAwal.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                DiagnosaAwalKeyPressed(evt);
            }
        });
        FormInput.add(DiagnosaAwal);
        DiagnosaAwal.setBounds(495, 40, 445, 23);

        jLabel96.setText("Petugas Menyerahkan :");
        jLabel96.setName("jLabel96"); // NOI18N
        FormInput.add(jLabel96);
        jLabel96.setBounds(0, 70, 140, 23);

        ShiftKeluar.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "Pagi", "Siang", "Malam" }));
        ShiftKeluar.setName("ShiftKeluar"); // NOI18N
        FormInput.add(ShiftKeluar);
        ShiftKeluar.setBounds(140, 70, 80, 23);

        NIP.setHighlighter(null);
        NIP.setName("NIP"); // NOI18N
        NIP.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                NIPActionPerformed(evt);
            }
        });
        NIP.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                NIPKeyPressed(evt);
            }
        });
        FormInput.add(NIP);
        NIP.setBounds(225, 70, 110, 23);

        NamaPetugas.setEditable(false);
        NamaPetugas.setHighlighter(null);
        NamaPetugas.setName("NamaPetugas"); // NOI18N
        NamaPetugas.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                NamaPetugasActionPerformed(evt);
            }
        });
        FormInput.add(NamaPetugas);
        NamaPetugas.setBounds(340, 70, 270, 23);

        BtnSeekPegawai1.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/190.png"))); // NOI18N
        BtnSeekPegawai1.setMnemonic('4');
        BtnSeekPegawai1.setToolTipText("ALt+4");
        BtnSeekPegawai1.setName("BtnSeekPegawai1"); // NOI18N
        BtnSeekPegawai1.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnSeekPegawai1ActionPerformed(evt);
            }
        });
        FormInput.add(BtnSeekPegawai1);
        BtnSeekPegawai1.setBounds(615, 70, 28, 23);

        BtnStatusVerifikasiHandOver.setForeground(new java.awt.Color(0, 0, 0));
        BtnStatusVerifikasiHandOver.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/peminjaman.png"))); // NOI18N
        BtnStatusVerifikasiHandOver.setMnemonic('4');
        BtnStatusVerifikasiHandOver.setText("Validasi HandOver");
        BtnStatusVerifikasiHandOver.setToolTipText("ALt+4");
        BtnStatusVerifikasiHandOver.setFont(new java.awt.Font("Tahoma", 0, 11)); // NOI18N
        BtnStatusVerifikasiHandOver.setGlassColor(new java.awt.Color(255, 153, 153));
        BtnStatusVerifikasiHandOver.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
        BtnStatusVerifikasiHandOver.setName("BtnStatusVerifikasiHandOver"); // NOI18N
        BtnStatusVerifikasiHandOver.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnStatusVerifikasiHandOverActionPerformed(evt);
            }
        });
        FormInput.add(BtnStatusVerifikasiHandOver);
        BtnStatusVerifikasiHandOver.setBounds(800, 69, 140, 26);

        jLabel94.setText("Petugas Penerima :");
        jLabel94.setName("jLabel94"); // NOI18N
        FormInput.add(jLabel94);
        jLabel94.setBounds(0, 100, 140, 23);

        ShiftMasuk.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "Pagi", "Siang", "Malam" }));
        ShiftMasuk.setName("ShiftMasuk"); // NOI18N
        FormInput.add(ShiftMasuk);
        ShiftMasuk.setBounds(140, 100, 80, 23);

        NIP2.setHighlighter(null);
        NIP2.setName("NIP2"); // NOI18N
        NIP2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                NIP2ActionPerformed(evt);
            }
        });
        NIP2.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyPressed(java.awt.event.KeyEvent evt) {
                NIP2KeyPressed(evt);
            }
        });
        FormInput.add(NIP2);
        NIP2.setBounds(225, 100, 110, 23);

        NamaPetugas2.setEditable(false);
        NamaPetugas2.setHighlighter(null);
        NamaPetugas2.setName("NamaPetugas2"); // NOI18N
        NamaPetugas2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                NamaPetugas2ActionPerformed(evt);
            }
        });
        FormInput.add(NamaPetugas2);
        NamaPetugas2.setBounds(340, 100, 270, 23);

        BtnSeekPegawai2.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/190.png"))); // NOI18N
        BtnSeekPegawai2.setMnemonic('4');
        BtnSeekPegawai2.setToolTipText("ALt+4");
        BtnSeekPegawai2.setName("BtnSeekPegawai2"); // NOI18N
        BtnSeekPegawai2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnSeekPegawai2ActionPerformed(evt);
            }
        });
        FormInput.add(BtnSeekPegawai2);
        BtnSeekPegawai2.setBounds(615, 100, 28, 23);

        BtnValidasiHandOver.setForeground(new java.awt.Color(0, 0, 0));
        BtnValidasiHandOver.setIcon(new javax.swing.ImageIcon(getClass().getResource("/picture/peminjaman.png"))); // NOI18N
        BtnValidasiHandOver.setMnemonic('4');
        BtnValidasiHandOver.setText("Status Validasi");
        BtnValidasiHandOver.setToolTipText("ALt+4");
        BtnValidasiHandOver.setFont(new java.awt.Font("Tahoma", 0, 11)); // NOI18N
        BtnValidasiHandOver.setGlassColor(new java.awt.Color(255, 153, 153));
        BtnValidasiHandOver.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
        BtnValidasiHandOver.setName("BtnValidasiHandOver"); // NOI18N
        BtnValidasiHandOver.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnValidasiHandOverActionPerformed(evt);
            }
        });
        FormInput.add(BtnValidasiHandOver);
        BtnValidasiHandOver.setBounds(800, 99, 140, 26);

        ChkShiftPagi.setFont(new java.awt.Font("Tahoma", 0, 11)); // NOI18N
        ChkShiftPagi.setText("Shift Pagi");
        ChkShiftPagi.setName("ChkShiftPagi"); // NOI18N
        ChkShiftPagi.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                ChkShiftPagiActionPerformed(evt);
            }
        });
        FormInput.add(ChkShiftPagi);
        ChkShiftPagi.setBounds(0, 135, 310, 23);

        ChkShiftSiang.setFont(new java.awt.Font("Tahoma", 0, 11)); // NOI18N
        ChkShiftSiang.setText("Shift Siang");
        ChkShiftSiang.setName("ChkShiftSiang"); // NOI18N
        ChkShiftSiang.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                ChkShiftSiangActionPerformed(evt);
            }
        });
        FormInput.add(ChkShiftSiang);
        ChkShiftSiang.setBounds(325, 135, 310, 23);

        ChkShiftMalam.setFont(new java.awt.Font("Tahoma", 0, 11)); // NOI18N
        ChkShiftMalam.setText("Shift Malam");
        ChkShiftMalam.setName("ChkShiftMalam"); // NOI18N
        ChkShiftMalam.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                ChkShiftMalamActionPerformed(evt);
            }
        });
        FormInput.add(ChkShiftMalam);
        ChkShiftMalam.setBounds(650, 135, 290, 23);

        scrollShiftPagi.setName("scrollShiftPagi"); // NOI18N

        TShiftPagi.setColumns(20);
        TShiftPagi.setEditable(false);
        TShiftPagi.setLineWrap(true);
        TShiftPagi.setRows(5);
        TShiftPagi.setWrapStyleWord(true);
        TShiftPagi.setName("TShiftPagi"); // NOI18N
        scrollShiftPagi.setViewportView(TShiftPagi);

        FormInput.add(scrollShiftPagi);
        scrollShiftPagi.setBounds(0, 165, 310, 200);

        scrollShiftSiang.setName("scrollShiftSiang"); // NOI18N

        TShiftSiang.setColumns(20);
        TShiftSiang.setEditable(false);
        TShiftSiang.setLineWrap(true);
        TShiftSiang.setRows(5);
        TShiftSiang.setWrapStyleWord(true);
        TShiftSiang.setName("TShiftSiang"); // NOI18N
        scrollShiftSiang.setViewportView(TShiftSiang);

        FormInput.add(scrollShiftSiang);
        scrollShiftSiang.setBounds(325, 165, 310, 200);

        scrollShiftMalam.setName("scrollShiftMalam"); // NOI18N

        TShiftMalam.setColumns(20);
        TShiftMalam.setEditable(false);
        TShiftMalam.setLineWrap(true);
        TShiftMalam.setRows(5);
        TShiftMalam.setWrapStyleWord(true);
        TShiftMalam.setName("TShiftMalam"); // NOI18N
        scrollShiftMalam.setViewportView(TShiftMalam);

        FormInput.add(scrollShiftMalam);
        scrollShiftMalam.setBounds(650, 165, 290, 200);


        scrollInput.setViewportView(FormInput);

        PanelInput.add(scrollInput, java.awt.BorderLayout.CENTER);

        internalFrame1.add(PanelInput, java.awt.BorderLayout.PAGE_START);

        getContentPane().add(internalFrame1, java.awt.BorderLayout.CENTER);

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void TNoRwKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_TNoRwKeyPressed
        if (evt.getKeyCode() == KeyEvent.VK_PAGE_DOWN) {
            isRawat();
        } else {
            Valid.pindah(evt, TCari, DTPTgl);
        }
}//GEN-LAST:event_TNoRwKeyPressed

    private void TPasienKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_TPasienKeyPressed
        Valid.pindah(evt, TCari, BtnSimpan);
}//GEN-LAST:event_TPasienKeyPressed

    private void BtnSimpanActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnSimpanActionPerformed
        simpanHandover();
}//GEN-LAST:event_BtnSimpanActionPerformed

    private void BtnSimpanKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnSimpanKeyPressed
        /*    if(evt.getKeyCode()==KeyEvent.VK_SPACE){
            BtnSimpanActionPerformed(null);
        }else{
            Valid.pindah(evt,Instruksi,BtnBatal);
        } */
}//GEN-LAST:event_BtnSimpanKeyPressed

    private void BtnBatalActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnBatalActionPerformed
        emptTeks();
        ChkInput.setSelected(true);
        isForm();
}//GEN-LAST:event_BtnBatalActionPerformed

    private void BtnBatalKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnBatalKeyPressed
        if (evt.getKeyCode() == KeyEvent.VK_SPACE) {
            emptTeks();
        } else {
            Valid.pindah(evt, BtnSimpan, BtnHapus);
        }
}//GEN-LAST:event_BtnBatalKeyPressed

    private void BtnHapusActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnHapusActionPerformed
        if (tabMode.getRowCount() == 0) {
            JOptionPane.showMessageDialog(null, "Maaf, data sudah habis...!!!!");
            TNoRw.requestFocus();
        } else {
            for (i = 0; i < tbPemeriksaanSbar.getRowCount(); i++) {
                if (tbPemeriksaanSbar.getValueAt(i, 0).toString().equals("true")) {
                    // kolom 10 = NIP petugas yang menyerahkan
                    // if (akses.getkode().equals("Admin Utama") || akses.getkode().equals(tbPemeriksaanSbar.getValueAt(i, 10).toString())) {
                        Sequel.queryu("delete from handover where no_rawat='" + tbPemeriksaanSbar.getValueAt(i, 1).toString()
                                + "' and tgl_perawatan='" + tbPemeriksaanSbar.getValueAt(i, 4).toString()
                                + "' and jam_rawat='" + tbPemeriksaanSbar.getValueAt(i, 5).toString() + "' ");
                        Sequel.queryu("delete from validasi_handover_shift where no_rawat='" + tbPemeriksaanSbar.getValueAt(i, 1).toString()
                                + "' and tgl_perawatan='" + tbPemeriksaanSbar.getValueAt(i, 4).toString() + "' ");
                    // } else {
                    //     JOptionPane.showMessageDialog(null, "Hanya bisa dihapus oleh dokter/petugas yang bersangkutan..!!");
                    // }
                }
            }
            emptTeks();
            tampil();
        }
}//GEN-LAST:event_BtnHapusActionPerformed

    private void BtnHapusKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnHapusKeyPressed
        if (evt.getKeyCode() == KeyEvent.VK_SPACE) {
            BtnHapusActionPerformed(null);
        } else {
            Valid.pindah(evt, BtnBatal, BtnEdit);
        }
}//GEN-LAST:event_BtnHapusKeyPressed

    private void BtnEditActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnEditActionPerformed
        if (tbPemeriksaanSbar.getSelectedRow() > -1) {
            simpanHandover();
        } else {
            JOptionPane.showMessageDialog(rootPane, "Silahkan pilih data yang mau diganti..!!");
            TCari.requestFocus();
        }
}//GEN-LAST:event_BtnEditActionPerformed

    private void BtnEditKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnEditKeyPressed
        if (evt.getKeyCode() == KeyEvent.VK_SPACE) {
            BtnEditActionPerformed(null);
        } else {
            Valid.pindah(evt, BtnHapus, BtnPrint);
        }
}//GEN-LAST:event_BtnEditKeyPressed

    private void BtnKeluarActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnKeluarActionPerformed
        petugas.dispose();
        dispose();
}//GEN-LAST:event_BtnKeluarActionPerformed

    private void BtnKeluarKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnKeluarKeyPressed
        if (evt.getKeyCode() == KeyEvent.VK_SPACE) {
            BtnKeluarActionPerformed(null);
        } else {
            Valid.pindah(evt, BtnEdit, TCari);
        }
}//GEN-LAST:event_BtnKeluarKeyPressed

    private void BtnPrintActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnPrintActionPerformed

}//GEN-LAST:event_BtnPrintActionPerformed

    private void BtnPrintKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnPrintKeyPressed
        if (evt.getKeyCode() == KeyEvent.VK_SPACE) {
            BtnPrintActionPerformed(null);
        } else {
            Valid.pindah(evt, BtnEdit, BtnKeluar);
        }
}//GEN-LAST:event_BtnPrintKeyPressed

    private void TCariKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_TCariKeyPressed
        if (evt.getKeyCode() == KeyEvent.VK_ENTER) {
            BtnCariActionPerformed(null);
        } else if (evt.getKeyCode() == KeyEvent.VK_PAGE_DOWN) {
            BtnCari.requestFocus();
        } else if (evt.getKeyCode() == KeyEvent.VK_PAGE_UP) {
            BtnKeluar.requestFocus();
        }
}//GEN-LAST:event_TCariKeyPressed

    private void BtnCariActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnCariActionPerformed
        tampil();
}//GEN-LAST:event_BtnCariActionPerformed

    private void BtnCariKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnCariKeyPressed
        if (evt.getKeyCode() == KeyEvent.VK_SPACE) {
            BtnCariActionPerformed(null);
        } else {
            Valid.pindah(evt, TCari, BtnAll);
        }
}//GEN-LAST:event_BtnCariKeyPressed

    private void BtnAllActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnAllActionPerformed
        TCari.setText("");
        tampil();
}//GEN-LAST:event_BtnAllActionPerformed

    private void BtnAllKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_BtnAllKeyPressed
        if (evt.getKeyCode() == KeyEvent.VK_SPACE) {
            tampil();
            TCari.setText("");
        } else {
            Valid.pindah(evt, BtnCari, TPasien);
        }
}//GEN-LAST:event_BtnAllKeyPressed

    private void DTPTglKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_DTPTglKeyPressed
        Valid.pindah2(evt, TCari, cmbJam);
}//GEN-LAST:event_DTPTglKeyPressed

    private void TNoRMKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_TNoRMKeyPressed
        // Valid.pindah(evt, TNm, BtnSimpan);
}//GEN-LAST:event_TNoRMKeyPressed

    private void ChkInputActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ChkInputActionPerformed
        isForm();
    }//GEN-LAST:event_ChkInputActionPerformed

    private void cmbJamKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_cmbJamKeyPressed
        Valid.pindah(evt, DTPTgl, cmbMnt);
    }//GEN-LAST:event_cmbJamKeyPressed

    private void cmbMntKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_cmbMntKeyPressed
        Valid.pindah(evt, cmbJam, cmbDtk);
    }//GEN-LAST:event_cmbMntKeyPressed

    private void cmbDtkKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_cmbDtkKeyPressed
        //   Valid.pindah(evt,Menit,btnPetugas);
    }//GEN-LAST:event_cmbDtkKeyPressed

    private void MnCatatanADIMEActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_MnCatatanADIMEActionPerformed
        if (tbPemeriksaanSbar.getSelectedRow() > -1) {
            Map<String, Object> param = new HashMap<>();
            param.put("diagnosa", Sequel.cariIsi("select kamar_inap.diagnosa_awal from kamar_inap where kamar_inap.diagnosa_awal<>'' and kamar_inap.no_rawat=? ", TNoRw.getText()));
            Valid.MyReportqry("rptFormulirCatatanADIMEGizi.jasper", "report", "::[ Formulir Catatan ADIME Gizi Pasien ]::",
                    "select reg_periksa.no_rawat,pasien.no_rkm_medis,pasien.nm_pasien,reg_periksa.umurdaftar,reg_periksa.sttsumur,"
                    + "pasien.jk,catatan_adime_gizi.tanggal,catatan_adime_gizi.asesmen,catatan_adime_gizi.diagnosis,"
                    + "catatan_adime_gizi.intervensi,catatan_adime_gizi.monitoring,catatan_adime_gizi.evaluasi,catatan_adime_gizi.instruksi,"
                    + "catatan_adime_gizi.nip,petugas.nama "
                    + "from catatan_adime_gizi inner join reg_periksa on catatan_adime_gizi.no_rawat=reg_periksa.no_rawat "
                    + "inner join pasien on reg_periksa.no_rkm_medis=pasien.no_rkm_medis "
                    + "inner join petugas on catatan_adime_gizi.nip=petugas.nip where reg_periksa.no_rawat='" + tbPemeriksaanSbar.getValueAt(tbPemeriksaanSbar.getSelectedRow(), 0).toString() + "'", param);
        }
    }//GEN-LAST:event_MnCatatanADIMEActionPerformed

    private void NIPActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_NIPActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_NIPActionPerformed

    private void NIPKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_NIPKeyPressed
        if (evt.getKeyCode() == KeyEvent.VK_PAGE_DOWN) {
            Sequel.cariIsi("select petugas.nama from petugas where petugas.nip=?", NamaPetugas, NIP.getText());
        } else if (evt.getKeyCode() == KeyEvent.VK_UP) {
            BtnSeekPegawai1ActionPerformed(null);
        } else {
            Valid.pindah(evt, TNoRw, NIP2);
        }
    }//GEN-LAST:event_NIPKeyPressed

    private void NamaPetugasActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_NamaPetugasActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_NamaPetugasActionPerformed

    private void BtnSeekPegawai1ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnSeekPegawai1ActionPerformed
        pilihan = 1;
        petugas.emptTeks();
        petugas.isCek();
        petugas.setSize(internalFrame1.getWidth() - 20, internalFrame1.getHeight() - 20);
        petugas.setLocationRelativeTo(internalFrame1);
        petugas.setVisible(true);
    }//GEN-LAST:event_BtnSeekPegawai1ActionPerformed

    private void tbPemeriksaanSbarMouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_tbPemeriksaanSbarMouseClicked
        if (tabMode.getRowCount() != 0) {
            try {
                getDataPemeriksaanSbar();
            } catch (java.lang.NullPointerException e) {
            }

        }
    }//GEN-LAST:event_tbPemeriksaanSbarMouseClicked

    private void tbPemeriksaanSbarKeyReleased(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_tbPemeriksaanSbarKeyReleased
        // TODO add your handling code here:
    }//GEN-LAST:event_tbPemeriksaanSbarKeyReleased

    private void NIP2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_NIP2ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_NIP2ActionPerformed

    private void NIP2KeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_NIP2KeyPressed
        if (evt.getKeyCode() == KeyEvent.VK_PAGE_DOWN) {
            Sequel.cariIsi("select petugas.nama from petugas where petugas.nip=?", NamaPetugas2, NIP2.getText());
        } else if (evt.getKeyCode() == KeyEvent.VK_UP) {
            BtnSeekPegawai2ActionPerformed(null);
        } else {
            Valid.pindah(evt, NIP, ChkShiftPagi);
        }
    }//GEN-LAST:event_NIP2KeyPressed

    private void NamaPetugas2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_NamaPetugas2ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_NamaPetugas2ActionPerformed

    private void BtnSeekPegawai2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnSeekPegawai2ActionPerformed
        pilihan = 2;
        petugas.emptTeks();
        petugas.isCek();
        petugas.setSize(internalFrame1.getWidth() - 20, internalFrame1.getHeight() - 20);
        petugas.setLocationRelativeTo(internalFrame1);
        petugas.setVisible(true);
    }//GEN-LAST:event_BtnSeekPegawai2ActionPerformed

    private void BtnValidasiHandOverActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnValidasiHandOverActionPerformed
        if (TNoRw.getText().trim().equals("")) {
            JOptionPane.showMessageDialog(null, "Maaf, Silahkan anda pilih dulu dengan menklik data pada table...!!!");
            TCari.requestFocus();
        } else {
            this.setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
            StatusValidasiHandOver soap = new StatusValidasiHandOver(null, false);
            soap.setNoRawat(TNoRw.getText(), TNoRw.getText());
            soap.setSize(internalFrame1.getWidth(), internalFrame1.getHeight());
            soap.setLocationRelativeTo(internalFrame1);
            soap.setVisible(true);
            this.setCursor(Cursor.getDefaultCursor());
        }
    }//GEN-LAST:event_BtnValidasiHandOverActionPerformed

    private void BtnStatusVerifikasiHandOverActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_BtnStatusVerifikasiHandOverActionPerformed
        if (TPasien.getText().trim().equals("") || TNoRw.getText().trim().equals("")) {
            JOptionPane.showMessageDialog(null, "Maaf, Silahkan anda pilih dulu dengan menklik data pada table...!!!");
            TCari.requestFocus();
        } else {
            this.setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
            ValidasiHandOver form = new ValidasiHandOver(null, false);
            form.isCek();
            form.emptTeks();
            form.setNoRm(TNoRw.getText(), DTPCari2.getDate());
            form.tampil();
            form.setSize(internalFrame1.getWidth() - 20, internalFrame1.getHeight() - 20);
            form.setLocationRelativeTo(internalFrame1);
            form.setVisible(true);
            this.setCursor(Cursor.getDefaultCursor());
        }              // TODO add your handling code here:
    }//GEN-LAST:event_BtnStatusVerifikasiHandOverActionPerformed

    private void DiagnosaAwalKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_DiagnosaAwalKeyPressed
        // TODO add your handling code here:
    }//GEN-LAST:event_DiagnosaAwalKeyPressed

    private void ChkShiftPagiActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ChkShiftPagiActionPerformed
        shiftDicentang("Pagi", ChkShiftPagi.isSelected());
    }//GEN-LAST:event_ChkShiftPagiActionPerformed

    private void ChkShiftSiangActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ChkShiftSiangActionPerformed
        shiftDicentang("Siang", ChkShiftSiang.isSelected());
    }//GEN-LAST:event_ChkShiftSiangActionPerformed

    private void ChkShiftMalamActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ChkShiftMalamActionPerformed
        shiftDicentang("Malam", ChkShiftMalam.isSelected());
    }//GEN-LAST:event_ChkShiftMalamActionPerformed

    /**
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(() -> {
            RMHandOver dialog = new RMHandOver(new javax.swing.JFrame(), true);
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
    private widget.Button BtnEdit;
    private widget.Button BtnHapus;
    private widget.Button BtnKeluar;
    private widget.Button BtnPrint;
    private widget.Button BtnSeekPegawai1;
    private widget.Button BtnSeekPegawai2;
    private widget.Button BtnSimpan;
    private widget.Button BtnStatusVerifikasiHandOver;
    private widget.Button BtnValidasiHandOver;
    private widget.CekBox ChkInput;
    private widget.CekBox ChkKejadian;
    private javax.swing.JCheckBox ChkShiftMalam;
    private javax.swing.JCheckBox ChkShiftPagi;
    private javax.swing.JCheckBox ChkShiftSiang;
    private widget.Tanggal DTPCari1;
    private widget.Tanggal DTPCari2;
    private widget.Tanggal DTPTgl;
    private widget.TextBox DiagnosaAwal;
    private widget.PanelBiasa FormInput;
    private widget.TextBox JK;
    private widget.Label LCount;
    private javax.swing.JMenuItem MnCatatanADIME;
    private widget.TextBox NIP;
    private widget.TextBox NIP2;
    private widget.TextBox NamaPetugas;
    private widget.TextBox NamaPetugas2;
    private javax.swing.JPanel PanelInput;
    private widget.TextBox RuangRawat;
    private widget.ScrollPane Scroll;
    private widget.ComboBox ShiftKeluar;
    private widget.ComboBox ShiftMasuk;
    private widget.TextBox TCari;
    private widget.TextBox TNoRM;
    private widget.TextBox TNoRw;
    private widget.TextBox TPasien;
    private widget.TextArea TShiftMalam;
    private widget.TextArea TShiftPagi;
    private widget.TextArea TShiftSiang;
    private widget.TextBox TanggalRegistrasi;
    private widget.TextBox Umur;
    private widget.ComboBox cmbDtk;
    private widget.ComboBox cmbJam;
    private widget.ComboBox cmbMnt;
    private widget.InternalFrame internalFrame1;
    private widget.Label jLabel19;
    private widget.Label jLabel21;
    private widget.Label jLabel4;
    private widget.Label jLabel5;
    private widget.Label jLabel6;
    private widget.Label jLabel7;
    private widget.Label jLabel8;
    private widget.Label jLabel9;
    private widget.Label jLabel94;
    private widget.Label jLabel96;
    private javax.swing.JPanel jPanel3;
    private javax.swing.JPopupMenu jPopupMenu1;
    private widget.panelisi panelGlass8;
    private widget.panelisi panelGlass9;
    private widget.ScrollPane scrollInput;
    private widget.ScrollPane scrollShiftMalam;
    private widget.ScrollPane scrollShiftPagi;
    private widget.ScrollPane scrollShiftSiang;
    private widget.Table tbPemeriksaanSbar;
    // End of variables declaration//GEN-END:variables

    public void tampil() {
        Valid.tabelKosong(tabMode);
        try {
            ps = koneksi.prepareStatement("select handover.no_rawat,reg_periksa.no_rkm_medis,pasien.nm_pasien,"
                    + "handover.tgl_perawatan,handover.jam_rawat,handover.shift_pagi,handover.shift_siang,handover.shift_sore,"
                    + "handover.shift,handover.nip,handover.shift2,handover.nip2,"
                    + "CONCAT('Pagi: '," + statusShiftSql("shift_pagi", "Pagi") + ",' | Siang: '," + statusShiftSql("shift_siang", "Siang")
                    + ",' | Malam: '," + statusShiftSql("shift_sore", "Malam") + ") as status_validasi "
                    + "from pasien inner join reg_periksa on reg_periksa.no_rkm_medis=pasien.no_rkm_medis "
                    + "inner join handover on handover.no_rawat=reg_periksa.no_rawat "
                    + "inner join petugas on handover.nip=petugas.nip "
                    + "where "
                    + "handover.tgl_perawatan between ? and ? "
                    + (TCari.getText().trim().equals("") ? "" : "and (handover.no_rawat like ? or reg_periksa.no_rkm_medis like ? or pasien.nm_pasien like ? or "
                    + "handover.shift_pagi like ? or handover.shift_siang like ? or handover.shift_sore like ?) ")
                    + "order by handover.no_rawat,handover.tgl_perawatan,handover.jam_rawat desc");
            try {
                ps.setString(1, Valid.SetTgl(DTPCari1.getSelectedItem() + ""));
                ps.setString(2, Valid.SetTgl(DTPCari2.getSelectedItem() + ""));
                if (!TCari.getText().trim().equals("")) {
                    for (int p = 3; p <= 8; p++) {
                        ps.setString(p, "%" + TCari.getText().trim() + "%");
                    }
                }

                rs = ps.executeQuery();
                while (rs.next()) {
                    tabMode.addRow(new Object[]{
                        false, rs.getString("no_rawat"), rs.getString("no_rkm_medis"), rs.getString("nm_pasien"),
                        rs.getString("tgl_perawatan"), rs.getString("jam_rawat"),
                        nz(rs.getString("shift_pagi")), nz(rs.getString("shift_siang")), nz(rs.getString("shift_sore")),
                        rs.getString("shift"), rs.getString("nip"), petugas.tampil3(rs.getString("nip")),
                        rs.getString("shift2"), rs.getString("nip2"), petugas.tampil3(rs.getString("nip2")),
                        rs.getString("status_validasi")
                    });
                }
            } catch (Exception e) {
                System.out.println("Notifikasi : " + e);
            } finally {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
            }
        } catch (Exception e) {
            System.out.println("Notifikasi : " + e);
        }
        LCount.setText("" + tabMode.getRowCount());
    }

    // Status validasi satu shift: '-' = shift belum diisi, 'Belum' = belum divalidasi, 'Valid' = sudah (validasi_handover_shift)
    private String statusShiftSql(String kolom, String shift) {
        return "IF(IFNULL(handover." + kolom + ",'')='','-',IF(EXISTS(select 1 from validasi_handover_shift v "
                + "where v.no_rawat=handover.no_rawat and v.tgl_perawatan=handover.tgl_perawatan and v.shift='" + shift + "'),'Valid','Belum'))";
    }

    public void emptTeks() {
        abaikanEventTanggal = true;
        DTPTgl.setDate(new Date());
        abaikanEventTanggal = false;
        tanggalOtomatisMundur = false;
        TNoRw.setText("");
        TNoRM.setText("");
        TPasien.setText("");
        DiagnosaAwal.setText("");
        RuangRawat.setText("");
        resetPrefill();
        TShiftPagi.setText("");
        TShiftSiang.setText("");
        TShiftMalam.setText("");
        NIP.setText("");
        NamaPetugas.setText("");
        NIP2.setText("");
        NamaPetugas2.setText("");
        pilihShift("");
    }

    private void isRawat() {
        try {
            ps = koneksi.prepareStatement(
                    "select reg_periksa.no_rkm_medis,pasien.nm_pasien,pasien.jk,reg_periksa.umurdaftar,reg_periksa.sttsumur,reg_periksa.tgl_registrasi,"
                    + "reg_periksa.jam_reg from reg_periksa inner join pasien on reg_periksa.no_rkm_medis=pasien.no_rkm_medis where reg_periksa.no_rawat=?");
            try {
                ps.setString(1, TNoRw.getText());
                rs = ps.executeQuery();
                if (rs.next()) {
                    TNoRM.setText(rs.getString("no_rkm_medis"));
                    DTPCari1.setDate(rs.getDate("tgl_registrasi"));
                    TPasien.setText(rs.getString("nm_pasien"));
                    JK.setText(rs.getString("jk"));
                    Umur.setText(rs.getString("umurdaftar") + " " + rs.getString("sttsumur"));
                    TanggalRegistrasi.setText(rs.getString("tgl_registrasi") + " " + rs.getString("jam_reg"));
                }
            } catch (Exception e) {
                System.out.println("Notif : " + e);
            } finally {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
            }
        } catch (Exception e) {
            System.out.println("Notif : " + e);
        }
        DiagnosaAwal.setText(Sequel.cariIsi("select diagnosa_awal from kamar_inap where no_rawat=?", TNoRw.getText()));
        RuangRawat.setText(Sequel.cariIsi("SELECT CONCAT(kamar.kd_kamar, ' ', bangsal.nm_bangsal) as ruangrawat FROM bangsal "
                + "INNER JOIN kamar ON bangsal.kd_bangsal = kamar.kd_bangsal "
                + "INNER JOIN kamar_inap ON kamar_inap.kd_kamar = kamar.kd_kamar "
                + "WHERE kamar_inap.no_rawat=? "
                + "ORDER BY kamar_inap.tgl_masuk DESC LIMIT 1", TNoRw.getText()));

        muatDataHandover();
    }

    public void setNoRm(String norwt, Date tgl2) {
        TNoRw.setText(norwt);
        TCari.setText(norwt);
        DTPCari2.setDate(tgl2);
        isRawat();
        ChkInput.setSelected(true);
        isForm();

    }

    private void isForm() {
        if (ChkInput.isSelected() == true) {
            if (internalFrame1.getHeight() > 478) {
                ChkInput.setVisible(false);
                PanelInput.setPreferredSize(new Dimension(WIDTH, 400));
                FormInput.setVisible(true);
                ChkInput.setVisible(true);
            } else {
                ChkInput.setVisible(false);
                PanelInput.setPreferredSize(new Dimension(WIDTH, internalFrame1.getHeight() - 172));
                FormInput.setVisible(true);
                ChkInput.setVisible(true);
            }
        } else if (ChkInput.isSelected() == false) {
            ChkInput.setVisible(false);
            PanelInput.setPreferredSize(new Dimension(WIDTH, 20));
            FormInput.setVisible(false);
            ChkInput.setVisible(true);
        }
    }

    public void isCek() {
        // BtnStatusVerifikasiHandOver.setEnabled(false);
        // BtnValidasiHandOver.setEnabled(false);
        BtnSimpan.setEnabled(akses.getpenilaian_awal_keperawatan_ranap());
        BtnHapus.setEnabled(akses.getpenilaian_awal_keperawatan_ranap());
        BtnEdit.setEnabled(akses.getpenilaian_awal_keperawatan_ranap());
        BtnPrint.setEnabled(akses.getpenilaian_awal_keperawatan_ranap());
        if (akses.getjml2() >= 1) {
            NIP.setEditable(false);
            BtnSeekPegawai1.setEnabled(true);
            NIP.setText(akses.getkode());
            NamaPetugas.setText(petugas.tampil3(NIP.getText()));
            if (NamaPetugas.getText().equals("")) {
                NIP.setText("");
                JOptionPane.showMessageDialog(null, "User login bukan petugas...!!");
            }
        }

        if (TANGGALMUNDUR.equals("no")) {
            if (!akses.getkode().equals("Admin Utama")) {
                DTPTgl.setEditable(false);
                DTPTgl.setEnabled(false);
                ChkKejadian.setEnabled(false);
                cmbJam.setEnabled(false);
                cmbMnt.setEnabled(false);
                cmbDtk.setEnabled(false);
            }
        }

    }


    private void jam() {
        ActionListener taskPerformer = new ActionListener() {
            private int nilai_jam;
            private int nilai_menit;
            private int nilai_detik;

            public void actionPerformed(ActionEvent e) {
                String nol_jam = "";
                String nol_menit = "";
                String nol_detik = "";

                Date now = Calendar.getInstance().getTime();

                // Mengambil nilai JAM, MENIT, dan DETIK sekarang
                if (ChkKejadian.isSelected() == true) {
                    nilai_jam = now.getHours();
                    nilai_menit = now.getMinutes();
                    nilai_detik = now.getSeconds();
                } else if (ChkKejadian.isSelected() == false) {
                    nilai_jam = cmbJam.getSelectedIndex();
                    nilai_menit = cmbMnt.getSelectedIndex();
                    nilai_detik = cmbDtk.getSelectedIndex();
                }

                if (nilai_jam <= 9) {
                    nol_jam = "0";
                }
                if (nilai_menit <= 9) {
                    nol_menit = "0";
                }
                if (nilai_detik <= 9) {
                    nol_detik = "0";
                }
                String jam = nol_jam + Integer.toString(nilai_jam);
                String menit = nol_menit + Integer.toString(nilai_menit);
                String detik = nol_detik + Integer.toString(nilai_detik);
                cmbJam.setSelectedItem(jam);
                cmbMnt.setSelectedItem(menit);
                cmbDtk.setSelectedItem(detik);
            }
        };
        // Timer
        new Timer(1000, taskPerformer).start();
    }

    // ------------------------------------------------------------------
    // Handover per shift: satu baris per no_rawat + tanggal, isi tiap shift
    // disimpan di kolomnya sendiri (shift_pagi / shift_siang / shift_sore).
    // ------------------------------------------------------------------
    private String nz(String s) {
        return s == null ? "" : s;
    }

    private String cell(int row, int col) {
        Object o = tbPemeriksaanSbar.getValueAt(row, col);
        return o == null ? "" : o.toString();
    }

    // Shift yang dicentang: "Pagi" / "Siang" / "Malam" / "" (belum ada)
    private String getShiftTerpilih() {
        if (ChkShiftPagi.isSelected()) {
            return "Pagi";
        } else if (ChkShiftSiang.isSelected()) {
            return "Siang";
        } else if (ChkShiftMalam.isSelected()) {
            return "Malam";
        }
        return "";
    }

    // Kolom tabel handover untuk tiap shift (Malam = shift_sore)
    private String kolomShift(String shift) {
        if (shift.equals("Pagi")) {
            return "shift_pagi";
        } else if (shift.equals("Siang")) {
            return "shift_siang";
        }
        return "shift_sore";
    }

    // Shift petugas penerima = shift sesudahnya
    private String shiftBerikutnya(String shift) {
        if (shift.equals("Pagi")) {
            return "Siang";
        } else if (shift.equals("Siang")) {
            return "Malam";
        }
        return "Pagi";
    }

    private widget.TextArea getAreaShift(String shift) {
        if (shift.equals("Pagi")) {
            return TShiftPagi;
        } else if (shift.equals("Siang")) {
            return TShiftSiang;
        }
        return TShiftMalam;
    }

    private void aturAreaShift(widget.TextArea area, boolean aktif) {
        area.setEditable(aktif);
        area.setBackground(aktif ? java.awt.Color.WHITE : new java.awt.Color(240, 240, 240));
    }

    // Hanya satu shift yang bisa dicentang; hanya kolom shift itu yang bisa diisi/diubah
    private void pilihShift(String shift) {
        ChkShiftPagi.setSelected(shift.equals("Pagi"));
        ChkShiftSiang.setSelected(shift.equals("Siang"));
        ChkShiftMalam.setSelected(shift.equals("Malam"));
        aturAreaShift(TShiftPagi, shift.equals("Pagi"));
        aturAreaShift(TShiftSiang, shift.equals("Siang"));
        aturAreaShift(TShiftMalam, shift.equals("Malam"));
        if (!shift.equals("")) {
            // Shift Keluar = shift yang dicentang, Shift Masuk = shift sesudahnya (masih bisa diubah manual)
            ShiftKeluar.setSelectedItem(shift);
            ShiftMasuk.setSelectedItem(shiftBerikutnya(shift));
        }
    }

    private void shiftDicentang(String shift, boolean dicentang) {
        batalkanPrefillBelumDiubah();
        aturTanggalMalamDiniHari(dicentang && shift.equals("Malam"));
        pilihShift(dicentang ? shift : "");
        if (dicentang) {
            tarikDataShiftSebelumnya(shift);
            getAreaShift(shift).requestFocus();
        }
    }

    // Malam dini hari (sebelum JAM_MULAI_PAGI) -> tanggal form mundur sehari ke tanggal mulai shift.
    // Hanya jika tanggal form masih hari ini (tidak menimpa tanggal yang dipilih manual / dari tabel).
    // Kembali ke hari ini saat Malam dilepas atau diganti shift lain.
    private void aturTanggalMalamDiniHari(boolean malamDicentang) {
        java.time.LocalDate hariIni = java.time.LocalDate.now();
        String tglForm = Valid.SetTgl(DTPTgl.getSelectedItem() + "");
        if (malamDicentang) {
            if (!tanggalOtomatisMundur && java.time.LocalTime.now().getHour() < JAM_MULAI_PAGI
                    && tglForm.equals(hariIni.toString())) {
                DTPTgl.setDate(java.sql.Date.valueOf(hariIni.minusDays(1)));
                tanggalOtomatisMundur = true;
            }
        } else if (tanggalOtomatisMundur) {
            if (tglForm.equals(hariIni.minusDays(1).toString())) {
                DTPTgl.setDate(java.sql.Date.valueOf(hariIni));
            }
            tanggalOtomatisMundur = false;
        }
    }

    private void resetPrefill() {
        shiftPrefill = "";
        teksPrefill = "";
    }

    // Isi hasil tarikan yang belum diubah user & belum disimpan dikosongkan lagi saat shift diganti/dilepas,
    // supaya tidak terlihat seperti data yang sudah tersimpan.
    private void batalkanPrefillBelumDiubah() {
        if (!shiftPrefill.equals("") && getAreaShift(shiftPrefill).getText().equals(teksPrefill)) {
            getAreaShift(shiftPrefill).setText("");
        }
        resetPrefill();
    }

    // Shift Siang <- isi Pagi, Shift Malam <- isi Siang (hari yang sama),
    // Shift Pagi <- isi Malam hari sebelumnya (shift Malam dicatat di tanggal saat shift dimulai).
    // Hanya jika kolom shift tujuan masih kosong, sehingga isian yang sudah ada tidak tertimpa.
    private void tarikDataShiftSebelumnya(String shift) {
        String sebelumnya = shift.equals("Siang") ? "Pagi" : (shift.equals("Malam") ? "Siang" : "Malam");
        if (TNoRw.getText().trim().equals("")) {
            return;
        }
        widget.TextArea tujuan = getAreaShift(shift);
        if (!tujuan.getText().trim().equals("")) {
            return;
        }
        String noRawat = TNoRw.getText().trim();
        String tgl = Valid.SetTgl(DTPTgl.getSelectedItem() + "");
        try {
            if (shift.equals("Pagi")) {
                tgl = java.time.LocalDate.parse(tgl).minusDays(1).toString(); // Malam hari sebelumnya
            }
            if (WAJIB_VALIDASI_SEBELUMNYA && !sudahDivalidasi(noRawat, tgl, sebelumnya)) {
                return;
            }
            String isi = ambilIsiShift(noRawat, tgl, sebelumnya).trim();
            if (!isi.equals("")) {
                tujuan.setText(isi);
                shiftPrefill = shift;
                teksPrefill = tujuan.getText();
            }
        } catch (Exception e) {
            System.out.println("Notif : " + e);
        }
    }

    private String ambilIsiShift(String noRawat, String tgl, String shift) throws SQLException {
        try (PreparedStatement pst = koneksi.prepareStatement("select " + kolomShift(shift)
                + " from handover where no_rawat=? and tgl_perawatan=? order by jam_rawat desc limit 1")) {
            pst.setString(1, noRawat);
            pst.setString(2, tgl);
            try (ResultSet rst = pst.executeQuery()) {
                return rst.next() ? nz(rst.getString(1)) : "";
            }
        }
    }

    private boolean sudahDivalidasi(String noRawat, String tgl, String shift) throws SQLException {
        try (PreparedStatement pst = koneksi.prepareStatement("select 1 from validasi_handover_shift "
                + "where no_rawat=? and tgl_perawatan=? and shift=? limit 1")) {
            pst.setString(1, noRawat);
            pst.setString(2, tgl);
            pst.setString(3, shift);
            try (ResultSet rst = pst.executeQuery()) {
                return rst.next();
            }
        }
    }

    // Tampilkan isi handover (3 shift) untuk no.rawat + tanggal yang dipilih
    private void muatDataHandover() {
        if (TNoRw.getText().trim().equals("")) {
            return;
        }
        resetPrefill();
        TShiftPagi.setText("");
        TShiftSiang.setText("");
        TShiftMalam.setText("");
        PreparedStatement pst = null;
        ResultSet rst = null;
        try {
            pst = koneksi.prepareStatement("select shift_pagi,shift_siang,shift_sore from handover "
                    + "where no_rawat=? and tgl_perawatan=? order by jam_rawat desc limit 1");
            pst.setString(1, TNoRw.getText().trim());
            pst.setString(2, Valid.SetTgl(DTPTgl.getSelectedItem() + ""));
            rst = pst.executeQuery();
            if (rst.next()) {
                TShiftPagi.setText(nz(rst.getString("shift_pagi")));
                TShiftSiang.setText(nz(rst.getString("shift_siang")));
                TShiftMalam.setText(nz(rst.getString("shift_sore")));
            }
        } catch (Exception e) {
            System.out.println("Notif : " + e);
        } finally {
            try {
                if (rst != null) {
                    rst.close();
                }
                if (pst != null) {
                    pst.close();
                }
            } catch (Exception ex) {
            }
        }
    }

    // Simpan handover untuk shift yang dicentang.
    // Belum ada baris untuk no.rawat + tanggal -> INSERT; sudah ada -> UPDATE hanya kolom shift tsb
    // (isi shift lain tidak ikut tertimpa).
    private void simpanHandover() {
        String shift = getShiftTerpilih();
        if (TNoRw.getText().trim().equals("") || TPasien.getText().trim().equals("")) {
            JOptionPane.showMessageDialog(rootPane, "Silahkan pilih pasien terlebih dahulu..!!");
            TNoRw.requestFocus();
            return;
        }
        if (shift.equals("")) {
            JOptionPane.showMessageDialog(rootPane, "Silahkan centang shift yang akan diupdate..!!");
            return;
        }
        widget.TextArea area = getAreaShift(shift);
        if (area.getText().trim().equals("")) {
            JOptionPane.showMessageDialog(rootPane, "Isi handover shift " + shift + " masih kosong..!!");
            area.requestFocus();
            return;
        }
        if (NIP.getText().trim().equals("") || NamaPetugas.getText().trim().equals("")) {
            Valid.textKosong(NIP, "Dokter/Paramedis masih kosong...!!");
            return;
        }
        // if (!akses.getkode().equals("Admin Utama") && !akses.getkode().equals(NIP.getText())) {
        //     JOptionPane.showMessageDialog(null, "Hanya bisa disimpan oleh dokter/petugas yang bersangkutan..!!");
        //     return;
        // }

        String noRawat = TNoRw.getText().trim();
        String tgl = Valid.SetTgl(DTPTgl.getSelectedItem() + "");
        String isi = area.getText().trim();

        try {
            if (sudahDivalidasi(noRawat, tgl, shift)) {
                JOptionPane.showMessageDialog(rootPane, "Handover shift " + shift + " sudah divalidasi, tidak bisa diubah lagi..!!");
                return;
            }
            if (adaBaris(noRawat, tgl)) {
                updateHandover(noRawat, tgl, shift, isi);
            } else {
                try {
                    insertHandover(noRawat, tgl, shift, isi);
                } catch (SQLException ex) {
                    // 1062 = duplicate key (unique no_rawat+tgl_perawatan): user lain baru saja menyimpan -> ubah saja
                    if (ex.getErrorCode() == 1062) {
                        updateHandover(noRawat, tgl, shift, isi);
                    } else {
                        throw ex;
                    }
                }
            }
            tampil();
            BtnBatalActionPerformed(null);
        } catch (Exception e) {
            System.out.println("Notifikasi : " + e);
            JOptionPane.showMessageDialog(rootPane, "Gagal menyimpan data handover..!!");
        }
    }

    private boolean adaBaris(String noRawat, String tgl) throws SQLException {
        try (PreparedStatement pst = koneksi.prepareStatement("select 1 from handover where no_rawat=? and tgl_perawatan=? limit 1")) {
            pst.setString(1, noRawat);
            pst.setString(2, tgl);
            try (ResultSet rst = pst.executeQuery()) {
                return rst.next();
            }
        }
    }

    // Petugas pemberi/penerima disimpan per shift (nip_pagi/nip_siang/nip_sore & nip2_*),
    // selain nip/nip2/shift/shift2 yang tetap mencatat update terakhir.
    private String sufiksShift(String shift) {
        return kolomShift(shift).substring(6); // shift_pagi -> pagi, shift_siang -> siang, shift_sore -> sore
    }

    // Baris hari itu sudah ada: ubah hanya kolom shift yang dicentang + petugas shift tsb.
    // jam_rawat tidak diubah supaya tetap konsisten dengan data lain yang merujuknya.
    private void updateHandover(String noRawat, String tgl, String shift, String isi) throws SQLException {
        String suf = sufiksShift(shift);
        String nip = NIP.getText().trim();
        String nip2 = NIP2.getText().trim().isEmpty() ? "-" : NIP2.getText().trim();
        try (PreparedStatement pst = koneksi.prepareStatement("update handover set " + kolomShift(shift)
                + "=?,nip_" + suf + "=?,nip2_" + suf + "=?,shift=?,nip=?,shift2=?,nip2=? where no_rawat=? and tgl_perawatan=?")) {
            pst.setString(1, isi);
            pst.setString(2, nip);
            pst.setString(3, nip2);
            pst.setString(4, ShiftKeluar.getSelectedItem().toString());
            pst.setString(5, nip);
            pst.setString(6, ShiftMasuk.getSelectedItem().toString());
            pst.setString(7, nip2);
            pst.setString(8, noRawat);
            pst.setString(9, tgl);
            pst.executeUpdate();
        }
    }

    private void insertHandover(String noRawat, String tgl, String shift, String isi) throws SQLException {
        String nip = NIP.getText().trim();
        String nip2 = NIP2.getText().trim().isEmpty() ? "-" : NIP2.getText().trim();
        try (PreparedStatement pst = koneksi.prepareStatement("insert into handover(no_rawat,tgl_perawatan,jam_rawat,"
                + "shift_pagi,shift_siang,shift_sore,nip_pagi,nip_siang,nip_sore,nip2_pagi,nip2_siang,nip2_sore,"
                + "shift,nip,shift2,nip2) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")) {
            pst.setString(1, noRawat);
            pst.setString(2, tgl);
            pst.setString(3, cmbJam.getSelectedItem() + ":" + cmbMnt.getSelectedItem() + ":" + cmbDtk.getSelectedItem());
            pst.setString(4, "Pagi".equals(shift) ? isi : "");
            pst.setString(5, "Siang".equals(shift) ? isi : "");
            pst.setString(6, "Malam".equals(shift) ? isi : "");
            pst.setString(7, "Pagi".equals(shift) ? nip : "");
            pst.setString(8, "Siang".equals(shift) ? nip : "");
            pst.setString(9, "Malam".equals(shift) ? nip : "");
            pst.setString(10, "Pagi".equals(shift) ? nip2 : "");
            pst.setString(11, "Siang".equals(shift) ? nip2 : "");
            pst.setString(12, "Malam".equals(shift) ? nip2 : "");
            pst.setString(13, ShiftKeluar.getSelectedItem().toString());
            pst.setString(14, nip);
            pst.setString(15, ShiftMasuk.getSelectedItem().toString());
            pst.setString(16, nip2);
            pst.executeUpdate();
        }
    }

    private void getDataPemeriksaanSbar() {
        int r = tbPemeriksaanSbar.getSelectedRow();
        if (r != -1) {
            TNoRw.setText(cell(r, 1));
            TNoRM.setText(cell(r, 2));
            TPasien.setText(cell(r, 3));
            abaikanEventTanggal = true;
            Valid.SetTgl(DTPTgl, cell(r, 4));
            abaikanEventTanggal = false;
            tanggalOtomatisMundur = false;
            resetPrefill();
            TShiftPagi.setText(cell(r, 6));
            TShiftSiang.setText(cell(r, 7));
            TShiftMalam.setText(cell(r, 8));
            NIP.setText(cell(r, 10));
            NamaPetugas.setText(cell(r, 11));
            String nipPenerima = cell(r, 13);
            if ("-".equals(nipPenerima)) {
                NIP2.setText("");
                NamaPetugas2.setText("");
            } else {
                NIP2.setText(nipPenerima);
                NamaPetugas2.setText(cell(r, 14));
            }
            DiagnosaAwal.setText(Sequel.cariIsi("select diagnosa_awal from kamar_inap where no_rawat=?", TNoRw.getText()));
            RuangRawat.setText(Sequel.cariIsi("SELECT CONCAT(kamar.kd_kamar, ' ', bangsal.nm_bangsal) as ruangrawat FROM bangsal "
                    + "INNER JOIN kamar ON bangsal.kd_bangsal = kamar.kd_bangsal "
                    + "INNER JOIN kamar_inap ON kamar_inap.kd_kamar = kamar.kd_kamar "
                    + "WHERE kamar_inap.no_rawat=? "
                    + "ORDER BY kamar_inap.tgl_masuk DESC LIMIT 1", TNoRw.getText()));
            // centang shift yang terakhir diupdate, lalu isi Shift Keluar/Masuk sesuai data tersimpan
            pilihShift(cell(r, 9));
            ShiftKeluar.setSelectedItem(cell(r, 9));
            ShiftMasuk.setSelectedItem(cell(r, 12));
        }
    }
}
