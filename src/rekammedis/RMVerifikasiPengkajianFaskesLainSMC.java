package rekammedis;

import fungsi.WarnaTable;
import fungsi.akses;
import fungsi.batasInput;
import fungsi.koneksiDB;
import fungsi.sekuel;
import fungsi.validasi;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JTable;
import javax.swing.Timer;
import javax.swing.WindowConstants;
import javax.swing.border.TitledBorder;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.TableColumn;
import kepegawaian.DlgCariPetugas;

public class RMVerifikasiPengkajianFaskesLainSMC extends JDialog {
    private final DefaultTableModel tabMode;
    private Connection koneksi = koneksiDB.condb();
    private sekuel Sequel = new sekuel();
    private validasi Valid = new validasi();
    private PreparedStatement ps;
    private ResultSet rs;
    private int i = 0;
    private DlgCariPetugas petugas = new DlgCariPetugas(null, false);

    private widget.TextBox AsalFaskes;
    private widget.Button BtnAll;
    private widget.Button BtnBatal;
    private widget.Button BtnCari;
    private widget.Button BtnEdit;
    private widget.Button BtnHapus;
    private widget.Button BtnKeluar;
    private widget.Button BtnPetugas;
    private widget.Button BtnPrint;
    private widget.Button BtnSimpan;
    private widget.CekBox ChkInput;
    private widget.CekBox ChkKejadian;
    private widget.ComboBox CmbAlergiObat;
    private widget.ComboBox CmbAnamnesis;
    private widget.ComboBox CmbDiagnosis;
    private widget.ComboBox CmbPemeriksaanFisik;
    private widget.ComboBox CmbPemeriksaanPenunjang;
    private widget.ComboBox CmbTerapiTindakan;
    private widget.Tanggal DTPCari1;
    private widget.Tanggal DTPCari2;
    private widget.Tanggal DTPTgl;
    private widget.PanelBiasa FormInput;
    private widget.TextBox HasilAlergiObat;
    private widget.TextBox HasilAnamnesis;
    private widget.TextBox HasilDiagnosis;
    private widget.TextBox HasilPemeriksaanFisik;
    private widget.TextBox HasilPemeriksaanPenunjang;
    private widget.TextBox HasilTerapiTindakan;
    private widget.TextBox JK;
    private widget.TextBox KdPetugas;
    private widget.ComboBox Kesimpulan;
    private widget.Label LCount;
    private widget.TextBox NmPetugas;
    private javax.swing.JPanel PanelInput;
    private widget.ScrollPane Scroll;
    private widget.TextBox TCari;
    private widget.TextBox TNoRM;
    private widget.TextBox TNoRw;
    private widget.TextBox TPasien;
    private widget.TextBox TglLahir;
    private widget.ComboBox cmbDtk;
    private widget.ComboBox cmbJam;
    private widget.ComboBox cmbMnt;
    private widget.InternalFrame internalFrame1;
    private widget.Label jLabel10;
    private widget.Label jLabel11;
    private widget.Label jLabel12;
    private widget.Label jLabel13;
    private widget.Label jLabel14;
    private widget.Label jLabel15;
    private widget.Label jLabel16;
    private widget.Label jLabel17;
    private widget.Label jLabel18;
    private widget.Label jLabel19;
    private widget.Label jLabel20;
    private widget.Label jLabel21;
    private widget.Label jLabel22;
    private widget.Label jLabel23;
    private widget.Label jLabel24;
    private widget.Label jLabel25;
    private widget.Label jLabel26;
    private widget.Label jLabel27;
    private widget.Label jLabel3;
    private widget.Label jLabel4;
    private widget.Label jLabel6;
    private widget.Label jLabel7;
    private widget.Label jLabel8;
    private widget.panelisi panelGlass8;
    private widget.panelisi panelGlass9;
    private widget.Table tbObat;

    public RMVerifikasiPengkajianFaskesLainSMC(JFrame parent, boolean modal) {
        super(parent, modal);
        initComponents();

        tabMode = new DefaultTableModel(null, new Object[]{
            "No.Rawat", "No.RM", "Nama Pasien", "Tgl.Lahir", "J.K.", "Tgl.Verifikasi", "Jam", "Asal Faskes",
            "Anamnesis", "Hasil Anamnesis", "Pem.Fisik", "Hasil Pem.Fisik", "Penunjang", "Hasil Penunjang",
            "Diagnosis", "Hasil Diagnosis", "Terapi/Tindakan", "Hasil Terapi/Tindakan", "Alergi Obat", "Hasil Alergi Obat",
            "Kesimpulan", "NIP", "Nama Petugas"
        }) {
            @Override
            public boolean isCellEditable(int rowIndex, int colIndex) {
                return false;
            }
        };
        tbObat.setModel(tabMode);
        tbObat.setPreferredScrollableViewportSize(new Dimension(500, 500));
        tbObat.setAutoResizeMode(JTable.AUTO_RESIZE_OFF);

        for (i = 0; i < 23; i++) {
            TableColumn column = tbObat.getColumnModel().getColumn(i);
            if (i == 0) {
                column.setPreferredWidth(105);
            } else if (i == 1) {
                column.setPreferredWidth(70);
            } else if (i == 2) {
                column.setPreferredWidth(150);
            } else if (i == 3) {
                column.setPreferredWidth(65);
            } else if (i == 4) {
                column.setPreferredWidth(35);
            } else if (i == 5) {
                column.setPreferredWidth(75);
            } else if (i == 6) {
                column.setPreferredWidth(55);
            } else if (i == 7) {
                column.setPreferredWidth(130);
            } else if (i == 8) {
                column.setPreferredWidth(70);
            } else if (i == 9) {
                column.setPreferredWidth(150);
            } else if (i == 10) {
                column.setPreferredWidth(70);
            } else if (i == 11) {
                column.setPreferredWidth(150);
            } else if (i == 12) {
                column.setPreferredWidth(70);
            } else if (i == 13) {
                column.setPreferredWidth(150);
            } else if (i == 14) {
                column.setPreferredWidth(70);
            } else if (i == 15) {
                column.setPreferredWidth(150);
            } else if (i == 16) {
                column.setPreferredWidth(90);
            } else if (i == 17) {
                column.setPreferredWidth(150);
            } else if (i == 18) {
                column.setPreferredWidth(70);
            } else if (i == 19) {
                column.setPreferredWidth(150);
            } else if (i == 20) {
                column.setPreferredWidth(160);
            } else if (i == 21) {
                column.setPreferredWidth(80);
            } else if (i == 22) {
                column.setPreferredWidth(150);
            }
        }
        tbObat.setDefaultRenderer(Object.class, new WarnaTable());

        TNoRw.setDocument(new batasInput((byte) 17).getKata(TNoRw));
        AsalFaskes.setDocument(new batasInput((byte) 100).getKata(AsalFaskes));
        HasilAnamnesis.setDocument(new batasInput((int) 255).getKata(HasilAnamnesis));
        HasilPemeriksaanFisik.setDocument(new batasInput((int) 255).getKata(HasilPemeriksaanFisik));
        HasilPemeriksaanPenunjang.setDocument(new batasInput((int) 255).getKata(HasilPemeriksaanPenunjang));
        HasilDiagnosis.setDocument(new batasInput((int) 255).getKata(HasilDiagnosis));
        HasilTerapiTindakan.setDocument(new batasInput((int) 255).getKata(HasilTerapiTindakan));
        HasilAlergiObat.setDocument(new batasInput((int) 255).getKata(HasilAlergiObat));
        KdPetugas.setDocument(new batasInput((byte) 20).getKata(KdPetugas));
        TCari.setDocument(new batasInput((int) 100).getKata(TCari));

        if ("aktif".equals(koneksiDB.CARICEPAT())) {
            TCari.getDocument().addDocumentListener(new DocumentListener() {
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
            public void windowOpened(WindowEvent e) {}

            @Override
            public void windowClosing(WindowEvent e) {}

            @Override
            public void windowClosed(WindowEvent e) {
                if (petugas.getTable().getSelectedRow() != -1) {
                    KdPetugas.setText(petugas.getTable().getValueAt(petugas.getTable().getSelectedRow(), 0).toString());
                    NmPetugas.setText(petugas.getTable().getValueAt(petugas.getTable().getSelectedRow(), 1).toString());
                }
                KdPetugas.requestFocus();
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

        ChkInput.setSelected(false);
        isForm();
        jam();
    }

    private void initComponents() {
        internalFrame1 = new widget.InternalFrame();
        Scroll = new widget.ScrollPane();
        tbObat = new widget.Table();
        jPanel3 = new javax.swing.JPanel();
        panelGlass8 = new widget.panelisi();
        BtnSimpan = new widget.Button();
        BtnBatal = new widget.Button();
        BtnHapus = new widget.Button();
        BtnEdit = new widget.Button();
        BtnPrint = new widget.Button();
        jLabel10 = new widget.Label();
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
        jLabel3 = new widget.Label();
        TNoRw = new widget.TextBox();
        TNoRM = new widget.TextBox();
        TPasien = new widget.TextBox();
        jLabel8 = new widget.Label();
        TglLahir = new widget.TextBox();
        jLabel4 = new widget.Label();
        JK = new widget.TextBox();
        jLabel11 = new widget.Label();
        DTPTgl = new widget.Tanggal();
        cmbJam = new widget.ComboBox();
        cmbMnt = new widget.ComboBox();
        cmbDtk = new widget.ComboBox();
        ChkKejadian = new widget.CekBox();
        jLabel12 = new widget.Label();
        AsalFaskes = new widget.TextBox();
        jLabel13 = new widget.Label();
        KdPetugas = new widget.TextBox();
        NmPetugas = new widget.TextBox();
        BtnPetugas = new widget.Button();
        jLabel14 = new widget.Label();
        Kesimpulan = new widget.ComboBox();
        jLabel15 = new widget.Label();
        CmbAnamnesis = new widget.ComboBox();
        jLabel16 = new widget.Label();
        HasilAnamnesis = new widget.TextBox();
        jLabel17 = new widget.Label();
        CmbPemeriksaanFisik = new widget.ComboBox();
        jLabel18 = new widget.Label();
        HasilPemeriksaanFisik = new widget.TextBox();
        jLabel20 = new widget.Label();
        CmbPemeriksaanPenunjang = new widget.ComboBox();
        jLabel22 = new widget.Label();
        HasilPemeriksaanPenunjang = new widget.TextBox();
        jLabel23 = new widget.Label();
        CmbDiagnosis = new widget.ComboBox();
        jLabel24 = new widget.Label();
        HasilDiagnosis = new widget.TextBox();
        jLabel25 = new widget.Label();
        CmbTerapiTindakan = new widget.ComboBox();
        jLabel26 = new widget.Label();
        HasilTerapiTindakan = new widget.TextBox();
        jLabel27 = new widget.Label();
        CmbAlergiObat = new widget.ComboBox();
        jLabel7 = new widget.Label();
        HasilAlergiObat = new widget.TextBox();

        setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
        setUndecorated(true);
        setResizable(false);

        internalFrame1.setBorder(BorderFactory.createTitledBorder(BorderFactory.createLineBorder(new Color(240, 245, 235)), "::[ Formulir Verifikasi Pengkajian Dari Fasilitas Kesehatan Lain ]::", TitledBorder.DEFAULT_JUSTIFICATION, TitledBorder.DEFAULT_POSITION, new Font("Tahoma", 0, 11), new Color(50, 50, 50)));
        internalFrame1.setFont(new Font("Tahoma", 2, 12));
        internalFrame1.setName("internalFrame1");
        internalFrame1.setLayout(new BorderLayout(1, 1));

        Scroll.setName("Scroll");
        Scroll.setOpaque(true);

        tbObat.setToolTipText("Silahkan klik untuk memilih data yang mau diedit ataupun dihapus");
        tbObat.setName("tbObat");
        tbObat.addMouseListener(new MouseListener() {
            @Override
            public void mouseClicked(MouseEvent evt) {
                tbObatMouseClicked(evt);
            }

            @Override
            public void mousePressed(MouseEvent evt) {}

            @Override
            public void mouseReleased(MouseEvent evt) {}

            @Override
            public void mouseEntered(MouseEvent evt) {}

            @Override
            public void mouseExited(MouseEvent evt) {}
        });
        tbObat.addKeyListener(new KeyListener() {
            @Override
            public void keyTyped(KeyEvent evt) {}

            @Override
            public void keyPressed(KeyEvent evt) {
                tbObatKeyPressed(evt);
            }

            @Override
            public void keyReleased(KeyEvent evt) {}
        });
        Scroll.setViewportView(tbObat);

        internalFrame1.add(Scroll, BorderLayout.CENTER);

        jPanel3.setName("jPanel3");
        jPanel3.setOpaque(false);
        jPanel3.setPreferredSize(new Dimension(44, 100));
        jPanel3.setLayout(new BorderLayout(1, 1));

        panelGlass8.setName("panelGlass8");
        panelGlass8.setPreferredSize(new Dimension(44, 44));
        panelGlass8.setLayout(new FlowLayout(FlowLayout.LEFT, 5, 9));

        BtnSimpan.setIcon(new ImageIcon(getClass().getResource("/picture/save-16x16.png")));
        BtnSimpan.setMnemonic('S');
        BtnSimpan.setText("Simpan");
        BtnSimpan.setToolTipText("Alt+S");
        BtnSimpan.setName("BtnSimpan");
        BtnSimpan.setPreferredSize(new Dimension(100, 30));
        BtnSimpan.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent evt) {
                BtnSimpanActionPerformed(evt);
            }
        });
        BtnSimpan.addKeyListener(new KeyListener() {
            @Override
            public void keyTyped(KeyEvent evt) {}

            @Override
            public void keyPressed(KeyEvent evt) {
                BtnSimpanKeyPressed(evt);
            }

            @Override
            public void keyReleased(KeyEvent evt) {}
        });
        panelGlass8.add(BtnSimpan);

        BtnBatal.setIcon(new ImageIcon(getClass().getResource("/picture/Cancel-1-16x16.png")));
        BtnBatal.setMnemonic('B');
        BtnBatal.setText("Baru");
        BtnBatal.setToolTipText("Alt+B");
        BtnBatal.setName("BtnBatal");
        BtnBatal.setPreferredSize(new Dimension(100, 30));
        BtnBatal.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent evt) {
                BtnBatalActionPerformed(evt);
            }
        });
        BtnBatal.addKeyListener(new KeyListener() {
            @Override
            public void keyTyped(KeyEvent evt) {}

            @Override
            public void keyPressed(KeyEvent evt) {
                BtnBatalKeyPressed(evt);
            }

            @Override
            public void keyReleased(KeyEvent evt) {}
        });
        panelGlass8.add(BtnBatal);

        BtnHapus.setIcon(new ImageIcon(getClass().getResource("/picture/stop_f2.png")));
        BtnHapus.setMnemonic('H');
        BtnHapus.setText("Hapus");
        BtnHapus.setToolTipText("Alt+H");
        BtnHapus.setName("BtnHapus");
        BtnHapus.setPreferredSize(new Dimension(100, 30));
        BtnHapus.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent evt) {
                BtnHapusActionPerformed(evt);
            }
        });
        BtnHapus.addKeyListener(new KeyListener() {
            @Override
            public void keyTyped(KeyEvent evt) {}

            @Override
            public void keyPressed(KeyEvent evt) {
                BtnHapusKeyPressed(evt);
            }

            @Override
            public void keyReleased(KeyEvent evt) {}
        });
        panelGlass8.add(BtnHapus);

        BtnEdit.setIcon(new ImageIcon(getClass().getResource("/picture/inventaris.png")));
        BtnEdit.setMnemonic('G');
        BtnEdit.setText("Ganti");
        BtnEdit.setToolTipText("Alt+G");
        BtnEdit.setName("BtnEdit");
        BtnEdit.setPreferredSize(new Dimension(100, 30));
        BtnEdit.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent evt) {
                BtnEditActionPerformed(evt);
            }
        });
        BtnEdit.addKeyListener(new KeyListener() {
            @Override
            public void keyTyped(KeyEvent evt) {}

            @Override
            public void keyPressed(KeyEvent evt) {
                BtnEditKeyPressed(evt);
            }

            @Override
            public void keyReleased(KeyEvent evt) {}
        });
        panelGlass8.add(BtnEdit);

        BtnPrint.setIcon(new ImageIcon(getClass().getResource("/picture/b_print.png")));
        BtnPrint.setMnemonic('T');
        BtnPrint.setText("Cetak");
        BtnPrint.setToolTipText("Alt+T");
        BtnPrint.setName("BtnPrint");
        BtnPrint.setPreferredSize(new Dimension(100, 30));
        BtnPrint.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent evt) {
                BtnPrintActionPerformed(evt);
            }
        });
        BtnPrint.addKeyListener(new KeyListener() {
            @Override
            public void keyTyped(KeyEvent evt) {}

            @Override
            public void keyPressed(KeyEvent evt) {
                BtnPrintKeyPressed(evt);
            }

            @Override
            public void keyReleased(KeyEvent evt) {}
        });
        panelGlass8.add(BtnPrint);

        jLabel10.setText("Record :");
        jLabel10.setName("jLabel10");
        jLabel10.setPreferredSize(new Dimension(60, 23));
        panelGlass8.add(jLabel10);

        LCount.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
        LCount.setText("0");
        LCount.setName("LCount");
        LCount.setPreferredSize(new Dimension(50, 23));
        panelGlass8.add(LCount);

        BtnKeluar.setIcon(new ImageIcon(getClass().getResource("/picture/exit.png")));
        BtnKeluar.setMnemonic('K');
        BtnKeluar.setText("Keluar");
        BtnKeluar.setToolTipText("Alt+K");
        BtnKeluar.setName("BtnKeluar");
        BtnKeluar.setPreferredSize(new Dimension(100, 30));
        BtnKeluar.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent evt) {
                BtnKeluarActionPerformed(evt);
            }
        });
        BtnKeluar.addKeyListener(new KeyListener() {
            @Override
            public void keyTyped(KeyEvent evt) {}

            @Override
            public void keyPressed(KeyEvent evt) {
                BtnKeluarKeyPressed(evt);
            }

            @Override
            public void keyReleased(KeyEvent evt) {}
        });
        panelGlass8.add(BtnKeluar);

        jPanel3.add(panelGlass8, BorderLayout.CENTER);

        panelGlass9.setName("panelGlass9");
        panelGlass9.setPreferredSize(new Dimension(44, 44));
        panelGlass9.setLayout(new FlowLayout(FlowLayout.LEFT, 5, 9));

        jLabel19.setText("Tgl. Verifikasi :");
        jLabel19.setName("jLabel19");
        jLabel19.setPreferredSize(new Dimension(85, 23));
        panelGlass9.add(jLabel19);

        DTPCari1.setModel(new javax.swing.DefaultComboBoxModel(new String[]{"06-10-2026"}));
        DTPCari1.setDisplayFormat("dd-MM-yyyy");
        DTPCari1.setName("DTPCari1");
        DTPCari1.setOpaque(false);
        DTPCari1.setPreferredSize(new Dimension(90, 23));
        panelGlass9.add(DTPCari1);

        jLabel21.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        jLabel21.setText("s.d.");
        jLabel21.setName("jLabel21");
        jLabel21.setPreferredSize(new Dimension(23, 23));
        panelGlass9.add(jLabel21);

        DTPCari2.setModel(new javax.swing.DefaultComboBoxModel(new String[]{"06-10-2026"}));
        DTPCari2.setDisplayFormat("dd-MM-yyyy");
        DTPCari2.setName("DTPCari2");
        DTPCari2.setOpaque(false);
        DTPCari2.setPreferredSize(new Dimension(90, 23));
        panelGlass9.add(DTPCari2);

        jLabel6.setText("Key Word :");
        jLabel6.setName("jLabel6");
        jLabel6.setPreferredSize(new Dimension(70, 23));
        panelGlass9.add(jLabel6);

        TCari.setName("TCari");
        TCari.setPreferredSize(new Dimension(205, 23));
        TCari.addKeyListener(new KeyListener() {
            @Override
            public void keyTyped(KeyEvent evt) {}

            @Override
            public void keyPressed(KeyEvent evt) {
                TCariKeyPressed(evt);
            }

            @Override
            public void keyReleased(KeyEvent evt) {}
        });
        panelGlass9.add(TCari);

        BtnCari.setIcon(new ImageIcon(getClass().getResource("/picture/accept.png")));
        BtnCari.setMnemonic('3');
        BtnCari.setToolTipText("Alt+3");
        BtnCari.setName("BtnCari");
        BtnCari.setPreferredSize(new Dimension(28, 23));
        BtnCari.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent evt) {
                BtnCariActionPerformed(evt);
            }
        });
        BtnCari.addKeyListener(new KeyListener() {
            @Override
            public void keyTyped(KeyEvent evt) {}

            @Override
            public void keyPressed(KeyEvent evt) {
                BtnCariKeyPressed(evt);
            }

            @Override
            public void keyReleased(KeyEvent evt) {}
        });
        panelGlass9.add(BtnCari);

        BtnAll.setIcon(new ImageIcon(getClass().getResource("/picture/Search-16x16.png")));
        BtnAll.setMnemonic('M');
        BtnAll.setToolTipText("Alt+M");
        BtnAll.setName("BtnAll");
        BtnAll.setPreferredSize(new Dimension(28, 23));
        BtnAll.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent evt) {
                BtnAllActionPerformed(evt);
            }
        });
        BtnAll.addKeyListener(new KeyListener() {
            @Override
            public void keyTyped(KeyEvent evt) {}

            @Override
            public void keyPressed(KeyEvent evt) {
                BtnAllKeyPressed(evt);
            }

            @Override
            public void keyReleased(KeyEvent evt) {}
        });
        panelGlass9.add(BtnAll);

        jPanel3.add(panelGlass9, BorderLayout.PAGE_START);

        internalFrame1.add(jPanel3, BorderLayout.PAGE_END);

        PanelInput.setName("PanelInput");
        PanelInput.setOpaque(false);
        PanelInput.setPreferredSize(new Dimension(192, 315));
        PanelInput.setLayout(new BorderLayout(1, 1));

        ChkInput.setIcon(new ImageIcon(getClass().getResource("/picture/143.png")));
        ChkInput.setMnemonic('I');
        ChkInput.setText(".: Input Data");
        ChkInput.setRolloverIcon(new ImageIcon(getClass().getResource("/picture/143.png")));
        ChkInput.setRolloverSelectedIcon(new ImageIcon(getClass().getResource("/picture/145.png")));
        ChkInput.setSelectedIcon(new ImageIcon(getClass().getResource("/picture/145.png")));
        ChkInput.setName("ChkInput");
        ChkInput.setPreferredSize(new Dimension(192, 20));
        ChkInput.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent evt) {
                ChkInputActionPerformed(evt);
            }
        });
        PanelInput.add(ChkInput, BorderLayout.PAGE_END);

        scrollInput.setName("scrollInput");
        scrollInput.setOpaque(true);

        FormInput.setBackground(new Color(255, 255, 255));
        FormInput.setName("FormInput");
        FormInput.setPreferredSize(new Dimension(760, 285));
        FormInput.setLayout(null);

        jLabel3.setText("No. Rawat :");
        jLabel3.setName("jLabel3");
        FormInput.add(jLabel3);
        jLabel3.setBounds(0, 10, 100, 23);

        TNoRw.setEditable(false);
        TNoRw.setHighlighter(null);
        TNoRw.setName("TNoRw");
        FormInput.add(TNoRw);
        TNoRw.setBounds(103, 10, 130, 23);

        TNoRM.setEditable(false);
        TNoRM.setHighlighter(null);
        TNoRM.setName("TNoRM");
        FormInput.add(TNoRM);
        TNoRM.setBounds(236, 10, 80, 23);

        TPasien.setEditable(false);
        TPasien.setHighlighter(null);
        TPasien.setName("TPasien");
        FormInput.add(TPasien);
        TPasien.setBounds(319, 10, 200, 23);

        jLabel8.setText("Tgl. Lahir :");
        jLabel8.setName("jLabel8");
        FormInput.add(jLabel8);
        jLabel8.setBounds(522, 10, 70, 23);

        TglLahir.setEditable(false);
        TglLahir.setHighlighter(null);
        TglLahir.setName("TglLahir");
        FormInput.add(TglLahir);
        TglLahir.setBounds(595, 10, 80, 23);

        jLabel4.setText("J.K. :");
        jLabel4.setName("jLabel4");
        FormInput.add(jLabel4);
        jLabel4.setBounds(678, 10, 35, 23);

        JK.setEditable(false);
        JK.setHighlighter(null);
        JK.setName("JK");
        FormInput.add(JK);
        JK.setBounds(716, 10, 30, 23);

        jLabel11.setText("Tgl. Verifikasi :");
        jLabel11.setName("jLabel11");
        FormInput.add(jLabel11);
        jLabel11.setBounds(0, 40, 100, 23);

        DTPTgl.setModel(new javax.swing.DefaultComboBoxModel(new String[]{"06-10-2026"}));
        DTPTgl.setDisplayFormat("dd-MM-yyyy");
        DTPTgl.setName("DTPTgl");
        DTPTgl.setOpaque(false);
        FormInput.add(DTPTgl);
        DTPTgl.setBounds(103, 40, 90, 23);

        cmbJam.setModel(new javax.swing.DefaultComboBoxModel(new String[]{"00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"}));
        cmbJam.setName("cmbJam");
        FormInput.add(cmbJam);
        cmbJam.setBounds(196, 40, 45, 23);

        cmbMnt.setModel(new javax.swing.DefaultComboBoxModel(new String[]{"00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59"}));
        cmbMnt.setName("cmbMnt");
        FormInput.add(cmbMnt);
        cmbMnt.setBounds(244, 40, 45, 23);

        cmbDtk.setModel(new javax.swing.DefaultComboBoxModel(new String[]{"00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59"}));
        cmbDtk.setName("cmbDtk");
        FormInput.add(cmbDtk);
        cmbDtk.setBounds(292, 40, 45, 23);

        ChkKejadian.setBorder(null);
        ChkKejadian.setSelected(true);
        ChkKejadian.setFont(new Font("Tahoma", 1, 11));
        ChkKejadian.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        ChkKejadian.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
        ChkKejadian.setName("ChkKejadian");
        FormInput.add(ChkKejadian);
        ChkKejadian.setBounds(340, 40, 23, 23);

        jLabel12.setText("Asal Faskes :");
        jLabel12.setName("jLabel12");
        FormInput.add(jLabel12);
        jLabel12.setBounds(370, 40, 100, 23);

        AsalFaskes.setHighlighter(null);
        AsalFaskes.setName("AsalFaskes");
        FormInput.add(AsalFaskes);
        AsalFaskes.setBounds(473, 40, 273, 23);

        jLabel13.setText("Petugas :");
        jLabel13.setName("jLabel13");
        FormInput.add(jLabel13);
        jLabel13.setBounds(0, 70, 100, 23);

        KdPetugas.setEditable(false);
        KdPetugas.setHighlighter(null);
        KdPetugas.setName("KdPetugas");
        FormInput.add(KdPetugas);
        KdPetugas.setBounds(103, 70, 100, 23);

        NmPetugas.setEditable(false);
        NmPetugas.setHighlighter(null);
        NmPetugas.setName("NmPetugas");
        FormInput.add(NmPetugas);
        NmPetugas.setBounds(206, 70, 220, 23);

        BtnPetugas.setIcon(new ImageIcon(getClass().getResource("/picture/190.png")));
        BtnPetugas.setMnemonic('2');
        BtnPetugas.setToolTipText("Alt+2");
        BtnPetugas.setName("BtnPetugas");
        BtnPetugas.setPreferredSize(new Dimension(28, 23));
        BtnPetugas.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent evt) {
                BtnPetugasActionPerformed(evt);
            }
        });
        FormInput.add(BtnPetugas);
        BtnPetugas.setBounds(429, 70, 28, 23);

        jLabel14.setText("Kesimpulan :");
        jLabel14.setName("jLabel14");
        FormInput.add(jLabel14);
        jLabel14.setBounds(460, 70, 90, 23);

        Kesimpulan.setModel(new javax.swing.DefaultComboBoxModel(new String[]{"Pengkajian dapat digunakan", "Pengkajian perlu dilengkapi", "Pengkajian perlu dilakukan ulang"}));
        Kesimpulan.setName("Kesimpulan");
        FormInput.add(Kesimpulan);
        Kesimpulan.setBounds(553, 70, 193, 23);

        jLabel15.setText("1. Anamnesis/Pengkajian Awal :");
        jLabel15.setName("jLabel15");
        FormInput.add(jLabel15);
        jLabel15.setBounds(0, 100, 210, 23);

        CmbAnamnesis.setModel(new javax.swing.DefaultComboBoxModel(new String[]{"Ada", "Tidak Ada"}));
        CmbAnamnesis.setName("CmbAnamnesis");
        FormInput.add(CmbAnamnesis);
        CmbAnamnesis.setBounds(213, 100, 80, 23);

        jLabel16.setText("Hasil :");
        jLabel16.setName("jLabel16");
        FormInput.add(jLabel16);
        jLabel16.setBounds(296, 100, 45, 23);

        HasilAnamnesis.setHighlighter(null);
        HasilAnamnesis.setName("HasilAnamnesis");
        FormInput.add(HasilAnamnesis);
        HasilAnamnesis.setBounds(344, 100, 402, 23);

        jLabel17.setText("2. Pemeriksaan Fisik :");
        jLabel17.setName("jLabel17");
        FormInput.add(jLabel17);
        jLabel17.setBounds(0, 130, 210, 23);

        CmbPemeriksaanFisik.setModel(new javax.swing.DefaultComboBoxModel(new String[]{"Ada", "Tidak Ada"}));
        CmbPemeriksaanFisik.setName("CmbPemeriksaanFisik");
        FormInput.add(CmbPemeriksaanFisik);
        CmbPemeriksaanFisik.setBounds(213, 130, 80, 23);

        jLabel18.setText("Hasil :");
        jLabel18.setName("jLabel18");
        FormInput.add(jLabel18);
        jLabel18.setBounds(296, 130, 45, 23);

        HasilPemeriksaanFisik.setHighlighter(null);
        HasilPemeriksaanFisik.setName("HasilPemeriksaanFisik");
        FormInput.add(HasilPemeriksaanFisik);
        HasilPemeriksaanFisik.setBounds(344, 130, 402, 23);

        jLabel20.setText("3. Hasil Pemeriksaan Penunjang :");
        jLabel20.setName("jLabel20");
        FormInput.add(jLabel20);
        jLabel20.setBounds(0, 160, 210, 23);

        CmbPemeriksaanPenunjang.setModel(new javax.swing.DefaultComboBoxModel(new String[]{"Ada", "Tidak Ada"}));
        CmbPemeriksaanPenunjang.setName("CmbPemeriksaanPenunjang");
        FormInput.add(CmbPemeriksaanPenunjang);
        CmbPemeriksaanPenunjang.setBounds(213, 160, 80, 23);

        jLabel22.setText("Hasil :");
        jLabel22.setName("jLabel22");
        FormInput.add(jLabel22);
        jLabel22.setBounds(296, 160, 45, 23);

        HasilPemeriksaanPenunjang.setHighlighter(null);
        HasilPemeriksaanPenunjang.setName("HasilPemeriksaanPenunjang");
        FormInput.add(HasilPemeriksaanPenunjang);
        HasilPemeriksaanPenunjang.setBounds(344, 160, 402, 23);

        jLabel23.setText("4. Diagnosis/Masalah Kesehatan :");
        jLabel23.setName("jLabel23");
        FormInput.add(jLabel23);
        jLabel23.setBounds(0, 190, 210, 23);

        CmbDiagnosis.setModel(new javax.swing.DefaultComboBoxModel(new String[]{"Ada", "Tidak Ada"}));
        CmbDiagnosis.setName("CmbDiagnosis");
        FormInput.add(CmbDiagnosis);
        CmbDiagnosis.setBounds(213, 190, 80, 23);

        jLabel24.setText("Hasil :");
        jLabel24.setName("jLabel24");
        FormInput.add(jLabel24);
        jLabel24.setBounds(296, 190, 45, 23);

        HasilDiagnosis.setHighlighter(null);
        HasilDiagnosis.setName("HasilDiagnosis");
        FormInput.add(HasilDiagnosis);
        HasilDiagnosis.setBounds(344, 190, 402, 23);

        jLabel25.setText("5. Terapi/Tindakan Diberikan :");
        jLabel25.setName("jLabel25");
        FormInput.add(jLabel25);
        jLabel25.setBounds(0, 220, 210, 23);

        CmbTerapiTindakan.setModel(new javax.swing.DefaultComboBoxModel(new String[]{"Ada", "Tidak Ada"}));
        CmbTerapiTindakan.setName("CmbTerapiTindakan");
        FormInput.add(CmbTerapiTindakan);
        CmbTerapiTindakan.setBounds(213, 220, 80, 23);

        jLabel26.setText("Hasil :");
        jLabel26.setName("jLabel26");
        FormInput.add(jLabel26);
        jLabel26.setBounds(296, 220, 45, 23);

        HasilTerapiTindakan.setHighlighter(null);
        HasilTerapiTindakan.setName("HasilTerapiTindakan");
        FormInput.add(HasilTerapiTindakan);
        HasilTerapiTindakan.setBounds(344, 220, 402, 23);

        jLabel27.setText("6. Alergi/Riwayat Penggunaan Obat :");
        jLabel27.setName("jLabel27");
        FormInput.add(jLabel27);
        jLabel27.setBounds(0, 250, 210, 23);

        CmbAlergiObat.setModel(new javax.swing.DefaultComboBoxModel(new String[]{"Ada", "Tidak Ada"}));
        CmbAlergiObat.setName("CmbAlergiObat");
        FormInput.add(CmbAlergiObat);
        CmbAlergiObat.setBounds(213, 250, 80, 23);

        jLabel7.setText("Hasil :");
        jLabel7.setName("jLabel7");
        FormInput.add(jLabel7);
        jLabel7.setBounds(296, 250, 45, 23);

        HasilAlergiObat.setHighlighter(null);
        HasilAlergiObat.setName("HasilAlergiObat");
        FormInput.add(HasilAlergiObat);
        HasilAlergiObat.setBounds(344, 250, 402, 23);

        scrollInput.setViewportView(FormInput);
        PanelInput.add(scrollInput, BorderLayout.CENTER);
        internalFrame1.add(PanelInput, BorderLayout.PAGE_START);

        getContentPane().add(internalFrame1, BorderLayout.CENTER);
        pack();
    }

    private void BtnSimpanActionPerformed(ActionEvent evt) {
        if ("".equals(TNoRw.getText().trim()) || "".equals(TPasien.getText().trim())) {
            Valid.textKosong(TNoRw, "Pasien");
        } else if ("".equals(KdPetugas.getText().trim()) || "".equals(NmPetugas.getText().trim())) {
            Valid.textKosong(KdPetugas, "Petugas Verifikator");
        } else {
            String tgl = Valid.SetTgl(DTPTgl.getSelectedItem() + "");
            String jam = cmbJam.getSelectedItem() + ":" + cmbMnt.getSelectedItem() + ":" + cmbDtk.getSelectedItem();
            if (Sequel.menyimpantfSmc("verifikasi_pengkajian_faskes_lain_smc",
                    "no_rawat, tgl_verifikasi, jam_verifikasi, asal_faskes, anamnesis, hasil_anamnesis, "
                    + "pemeriksaan_fisik, hasil_pemeriksaan_fisik, pemeriksaan_penunjang, hasil_pemeriksaan_penunjang, "
                    + "diagnosis, hasil_diagnosis, terapi_tindakan, hasil_terapi_tindakan, alergi_obat, hasil_alergi_obat, "
                    + "kesimpulan, nip",
                    TNoRw.getText(), tgl, jam, AsalFaskes.getText(),
                    CmbAnamnesis.getSelectedItem().toString(), HasilAnamnesis.getText(),
                    CmbPemeriksaanFisik.getSelectedItem().toString(), HasilPemeriksaanFisik.getText(),
                    CmbPemeriksaanPenunjang.getSelectedItem().toString(), HasilPemeriksaanPenunjang.getText(),
                    CmbDiagnosis.getSelectedItem().toString(), HasilDiagnosis.getText(),
                    CmbTerapiTindakan.getSelectedItem().toString(), HasilTerapiTindakan.getText(),
                    CmbAlergiObat.getSelectedItem().toString(), HasilAlergiObat.getText(),
                    Kesimpulan.getSelectedItem().toString(), KdPetugas.getText())) {
                tampil();
                emptTeks();
            }
        }
    }

    private void BtnSimpanKeyPressed(KeyEvent evt) {
        if (evt.getKeyCode() == KeyEvent.VK_SPACE) {
            BtnSimpanActionPerformed(null);
        } else {
            Valid.pindah(evt, HasilAlergiObat, BtnBatal);
        }
    }

    private void BtnBatalActionPerformed(ActionEvent evt) {
        emptTeks();
        ChkInput.setSelected(true);
        isForm();
    }

    private void BtnBatalKeyPressed(KeyEvent evt) {
        if (evt.getKeyCode() == KeyEvent.VK_SPACE) {
            emptTeks();
        } else {
            Valid.pindah(evt, BtnSimpan, BtnHapus);
        }
    }

    private void BtnHapusActionPerformed(ActionEvent evt) {
        if (tbObat.getSelectedRow() > -1) {
            if (Sequel.menghapustfSmc("verifikasi_pengkajian_faskes_lain_smc",
                    "no_rawat = ? and tgl_verifikasi = ? and jam_verifikasi = ?",
                    tbObat.getValueAt(tbObat.getSelectedRow(), 0).toString(),
                    tbObat.getValueAt(tbObat.getSelectedRow(), 5).toString(),
                    tbObat.getValueAt(tbObat.getSelectedRow(), 6).toString())) {
                tabMode.removeRow(tbObat.getSelectedRow());
                LCount.setText("" + tabMode.getRowCount());
                emptTeks();
            }
        } else {
            JOptionPane.showMessageDialog(rootPane, "Silahkan pilih data yang mau dihapus..!!");
        }
    }

    private void BtnHapusKeyPressed(KeyEvent evt) {
        if (evt.getKeyCode() == KeyEvent.VK_SPACE) {
            BtnHapusActionPerformed(null);
        } else {
            Valid.pindah(evt, BtnBatal, BtnEdit);
        }
    }

    private void BtnEditActionPerformed(ActionEvent evt) {
        if ("".equals(TNoRw.getText().trim()) || "".equals(TPasien.getText().trim())) {
            Valid.textKosong(TNoRw, "Pasien");
        } else if ("".equals(KdPetugas.getText().trim()) || "".equals(NmPetugas.getText().trim())) {
            Valid.textKosong(KdPetugas, "Petugas Verifikator");
        } else if (tbObat.getSelectedRow() > -1) {
            String tgl = Valid.SetTgl(DTPTgl.getSelectedItem() + "");
            String jam = cmbJam.getSelectedItem() + ":" + cmbMnt.getSelectedItem() + ":" + cmbDtk.getSelectedItem();
            if (Sequel.mengupdatetfSmc("verifikasi_pengkajian_faskes_lain_smc",
                    "asal_faskes=?, anamnesis=?, hasil_anamnesis=?, pemeriksaan_fisik=?, hasil_pemeriksaan_fisik=?, "
                    + "pemeriksaan_penunjang=?, hasil_pemeriksaan_penunjang=?, diagnosis=?, hasil_diagnosis=?, "
                    + "terapi_tindakan=?, hasil_terapi_tindakan=?, alergi_obat=?, hasil_alergi_obat=?, "
                    + "kesimpulan=?, nip=?",
                    "no_rawat=? and tgl_verifikasi=? and jam_verifikasi=?",
                    AsalFaskes.getText(),
                    CmbAnamnesis.getSelectedItem().toString(), HasilAnamnesis.getText(),
                    CmbPemeriksaanFisik.getSelectedItem().toString(), HasilPemeriksaanFisik.getText(),
                    CmbPemeriksaanPenunjang.getSelectedItem().toString(), HasilPemeriksaanPenunjang.getText(),
                    CmbDiagnosis.getSelectedItem().toString(), HasilDiagnosis.getText(),
                    CmbTerapiTindakan.getSelectedItem().toString(), HasilTerapiTindakan.getText(),
                    CmbAlergiObat.getSelectedItem().toString(), HasilAlergiObat.getText(),
                    Kesimpulan.getSelectedItem().toString(), KdPetugas.getText(),
                    tbObat.getValueAt(tbObat.getSelectedRow(), 0).toString(),
                    tbObat.getValueAt(tbObat.getSelectedRow(), 5).toString(),
                    tbObat.getValueAt(tbObat.getSelectedRow(), 6).toString())) {
                tampil();
                emptTeks();
            }
        } else {
            JOptionPane.showMessageDialog(rootPane, "Silahkan pilih data yang mau diganti..!!");
        }
    }

    private void BtnEditKeyPressed(KeyEvent evt) {
        if (evt.getKeyCode() == KeyEvent.VK_SPACE) {
            BtnEditActionPerformed(null);
        } else {
            Valid.pindah(evt, BtnHapus, BtnPrint);
        }
    }

    private void BtnPrintActionPerformed(ActionEvent evt) {
        if (tbObat.getSelectedRow() > -1) {
            this.setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
            Map<String, Object> param = new HashMap<>();
            param.put("namars", akses.getnamars());
            param.put("alamatrs", akses.getalamatrs());
            param.put("kotars", akses.getkabupatenrs());
            param.put("propinsirs", akses.getpropinsirs());
            param.put("kontakrs", akses.getkontakrs());
            param.put("emailrs", akses.getemailrs());
            param.put("logo", Sequel.cariGambar("select logo from setting"));
            Valid.MyReportqry("rptFormulirVerifikasiPengkajianFaskesLainSMC.jasper", "report", "::[ Formulir Verifikasi Pengkajian Dari Faskes Lain ]::",
                    "select verifikasi_pengkajian_faskes_lain_smc.no_rawat,reg_periksa.no_rkm_medis,pasien.nm_pasien, "
                    + "pasien.tgl_lahir,pasien.jk,reg_periksa.tgl_registrasi,verifikasi_pengkajian_faskes_lain_smc.tgl_verifikasi, "
                    + "verifikasi_pengkajian_faskes_lain_smc.jam_verifikasi,verifikasi_pengkajian_faskes_lain_smc.asal_faskes, "
                    + "verifikasi_pengkajian_faskes_lain_smc.anamnesis,verifikasi_pengkajian_faskes_lain_smc.hasil_anamnesis, "
                    + "verifikasi_pengkajian_faskes_lain_smc.pemeriksaan_fisik,verifikasi_pengkajian_faskes_lain_smc.hasil_pemeriksaan_fisik, "
                    + "verifikasi_pengkajian_faskes_lain_smc.pemeriksaan_penunjang,verifikasi_pengkajian_faskes_lain_smc.hasil_pemeriksaan_penunjang, "
                    + "verifikasi_pengkajian_faskes_lain_smc.diagnosis,verifikasi_pengkajian_faskes_lain_smc.hasil_diagnosis, "
                    + "verifikasi_pengkajian_faskes_lain_smc.terapi_tindakan,verifikasi_pengkajian_faskes_lain_smc.hasil_terapi_tindakan, "
                    + "verifikasi_pengkajian_faskes_lain_smc.alergi_obat,verifikasi_pengkajian_faskes_lain_smc.hasil_alergi_obat, "
                    + "verifikasi_pengkajian_faskes_lain_smc.kesimpulan,verifikasi_pengkajian_faskes_lain_smc.nip,petugas.nama "
                    + "from verifikasi_pengkajian_faskes_lain_smc "
                    + "inner join reg_periksa on verifikasi_pengkajian_faskes_lain_smc.no_rawat=reg_periksa.no_rawat "
                    + "inner join pasien on reg_periksa.no_rkm_medis=pasien.no_rkm_medis "
                    + "inner join petugas on verifikasi_pengkajian_faskes_lain_smc.nip=petugas.nip "
                    + "where verifikasi_pengkajian_faskes_lain_smc.no_rawat='" + tbObat.getValueAt(tbObat.getSelectedRow(), 0).toString() + "' "
                    + "and verifikasi_pengkajian_faskes_lain_smc.tgl_verifikasi='" + tbObat.getValueAt(tbObat.getSelectedRow(), 5).toString() + "' "
                    + "and verifikasi_pengkajian_faskes_lain_smc.jam_verifikasi='" + tbObat.getValueAt(tbObat.getSelectedRow(), 6).toString() + "'", param);
            this.setCursor(Cursor.getDefaultCursor());
        } else {
            JOptionPane.showMessageDialog(rootPane, "Silahkan pilih data yang mau dicetak..!!");
        }
    }

    private void BtnPrintKeyPressed(KeyEvent evt) {
        if (evt.getKeyCode() == KeyEvent.VK_SPACE) {
            BtnPrintActionPerformed(null);
        } else {
            Valid.pindah(evt, BtnEdit, BtnKeluar);
        }
    }

    private void BtnKeluarActionPerformed(ActionEvent evt) {
        dispose();
    }

    private void BtnKeluarKeyPressed(KeyEvent evt) {
        if (evt.getKeyCode() == KeyEvent.VK_SPACE) {
            dispose();
        } else {
            Valid.pindah(evt, BtnPrint, TCari);
        }
    }

    private void TCariKeyPressed(KeyEvent evt) {
        if (evt.getKeyCode() == KeyEvent.VK_ENTER) {
            BtnCariActionPerformed(null);
        } else if (evt.getKeyCode() == KeyEvent.VK_PAGE_DOWN) {
            BtnCari.requestFocus();
        } else if (evt.getKeyCode() == KeyEvent.VK_PAGE_UP) {
            BtnKeluar.requestFocus();
        }
    }

    private void BtnCariActionPerformed(ActionEvent evt) {
        tampil();
    }

    private void BtnCariKeyPressed(KeyEvent evt) {
        if (evt.getKeyCode() == KeyEvent.VK_SPACE) {
            BtnCariActionPerformed(null);
        } else {
            Valid.pindah(evt, TCari, BtnAll);
        }
    }

    private void BtnAllActionPerformed(ActionEvent evt) {
        TCari.setText("");
        tampil();
    }

    private void BtnAllKeyPressed(KeyEvent evt) {
        if (evt.getKeyCode() == KeyEvent.VK_SPACE) {
            BtnAllActionPerformed(null);
        } else {
            Valid.pindah(evt, BtnCari, TPasien);
        }
    }

    private void ChkInputActionPerformed(ActionEvent evt) {
        isForm();
    }

    private void BtnPetugasActionPerformed(ActionEvent evt) {
        petugas.emptTeks();
        petugas.isCek();
        petugas.setSize(internalFrame1.getWidth() - 20, internalFrame1.getHeight() - 20);
        petugas.setLocationRelativeTo(internalFrame1);
        petugas.setVisible(true);
    }

    private void tbObatMouseClicked(MouseEvent evt) {
        if (tabMode.getRowCount() != 0) {
            try {
                getData();
            } catch (java.lang.NullPointerException e) {}
        }
    }

    private void tbObatKeyPressed(KeyEvent evt) {
        if (tabMode.getRowCount() != 0) {
            if ((evt.getKeyCode() == KeyEvent.VK_ENTER) || (evt.getKeyCode() == KeyEvent.VK_UP) || (evt.getKeyCode() == KeyEvent.VK_DOWN)) {
                try {
                    getData();
                } catch (java.lang.NullPointerException e) {}
            }
        }
    }

    private void isForm() {
        if (ChkInput.isSelected()) {
            ChkInput.setVisible(false);
            PanelInput.setPreferredSize(new Dimension(WIDTH, 315));
            FormInput.setVisible(true);
            ChkInput.setVisible(true);
        } else {
            ChkInput.setVisible(false);
            PanelInput.setPreferredSize(new Dimension(WIDTH, 20));
            FormInput.setVisible(false);
            ChkInput.setVisible(true);
        }
    }

    public void isCek() {
        BtnSimpan.setEnabled(akses.getadmin() || akses.getuser() || akses.getpenilaian_awal_keperawatan_ranap());
        BtnHapus.setEnabled(akses.getadmin() || akses.getuser() || akses.getpenilaian_awal_keperawatan_ranap());
        BtnEdit.setEnabled(akses.getadmin() || akses.getuser() || akses.getpenilaian_awal_keperawatan_ranap());
        BtnPrint.setEnabled(akses.getadmin() || akses.getuser() || akses.getpenilaian_awal_keperawatan_ranap());
        if (akses.getjml2() >= 1) {
            KdPetugas.setEditable(false);
            BtnPetugas.setEnabled(false);
            KdPetugas.setText(akses.getkode());
            NmPetugas.setText(petugas.tampil3(KdPetugas.getText()));
            if ("".equals(NmPetugas.getText())) {
                KdPetugas.setText("");
                JOptionPane.showMessageDialog(null, "User login bukan petugas...!!");
            }
        }
    }

    private void jam() {
        ActionListener taskPerformer = new ActionListener() {
            private int nilai_jam;
            private int nilai_menit;
            private int nilai_detik;

            @Override
            public void actionPerformed(ActionEvent e) {
                String nol_jam = "";
                String nol_menit = "";
                String nol_detik = "";

                Date now = Calendar.getInstance().getTime();

                if (ChkKejadian.isSelected()) {
                    nilai_jam = now.getHours();
                    nilai_menit = now.getMinutes();
                    nilai_detik = now.getSeconds();
                } else {
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
        new Timer(1000, taskPerformer).start();
    }

    public void emptTeks() {
        DTPTgl.setDate(new Date());
        AsalFaskes.setText("");
        CmbAnamnesis.setSelectedIndex(0);
        HasilAnamnesis.setText("");
        CmbPemeriksaanFisik.setSelectedIndex(0);
        HasilPemeriksaanFisik.setText("");
        CmbPemeriksaanPenunjang.setSelectedIndex(0);
        HasilPemeriksaanPenunjang.setText("");
        CmbDiagnosis.setSelectedIndex(0);
        HasilDiagnosis.setText("");
        CmbTerapiTindakan.setSelectedIndex(0);
        HasilTerapiTindakan.setText("");
        CmbAlergiObat.setSelectedIndex(0);
        HasilAlergiObat.setText("");
        Kesimpulan.setSelectedIndex(0);
        AsalFaskes.requestFocus();
    }

    public void setNoRm(String norwt, Date tgl2) {
        TNoRw.setText(norwt);
        TCari.setText(norwt);
        DTPCari2.setDate(tgl2);
        isRawat();
        ChkInput.setSelected(true);
        isForm();
    }

    private void isRawat() {
        try {
            ps = koneksi.prepareStatement(
                    "select reg_periksa.no_rkm_medis,pasien.nm_pasien,pasien.jk,pasien.tgl_lahir,reg_periksa.tgl_registrasi "
                    + "from reg_periksa inner join pasien on reg_periksa.no_rkm_medis=pasien.no_rkm_medis where reg_periksa.no_rawat=?");
            try {
                ps.setString(1, TNoRw.getText());
                rs = ps.executeQuery();
                if (rs.next()) {
                    TNoRM.setText(rs.getString("no_rkm_medis"));
                    DTPCari1.setDate(rs.getDate("tgl_registrasi"));
                    TPasien.setText(rs.getString("nm_pasien"));
                    JK.setText(rs.getString("jk"));
                    TglLahir.setText(rs.getString("tgl_lahir"));
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
    }

    public void tampil() {
        Valid.tabelKosong(tabMode);
        try {
            ps = koneksi.prepareStatement(
                    "select verifikasi_pengkajian_faskes_lain_smc.no_rawat,reg_periksa.no_rkm_medis,pasien.nm_pasien, "
                    + "pasien.tgl_lahir,pasien.jk,verifikasi_pengkajian_faskes_lain_smc.tgl_verifikasi, "
                    + "verifikasi_pengkajian_faskes_lain_smc.jam_verifikasi,verifikasi_pengkajian_faskes_lain_smc.asal_faskes, "
                    + "verifikasi_pengkajian_faskes_lain_smc.anamnesis,verifikasi_pengkajian_faskes_lain_smc.hasil_anamnesis, "
                    + "verifikasi_pengkajian_faskes_lain_smc.pemeriksaan_fisik,verifikasi_pengkajian_faskes_lain_smc.hasil_pemeriksaan_fisik, "
                    + "verifikasi_pengkajian_faskes_lain_smc.pemeriksaan_penunjang,verifikasi_pengkajian_faskes_lain_smc.hasil_pemeriksaan_penunjang, "
                    + "verifikasi_pengkajian_faskes_lain_smc.diagnosis,verifikasi_pengkajian_faskes_lain_smc.hasil_diagnosis, "
                    + "verifikasi_pengkajian_faskes_lain_smc.terapi_tindakan,verifikasi_pengkajian_faskes_lain_smc.hasil_terapi_tindakan, "
                    + "verifikasi_pengkajian_faskes_lain_smc.alergi_obat,verifikasi_pengkajian_faskes_lain_smc.hasil_alergi_obat, "
                    + "verifikasi_pengkajian_faskes_lain_smc.kesimpulan,verifikasi_pengkajian_faskes_lain_smc.nip,petugas.nama "
                    + "from verifikasi_pengkajian_faskes_lain_smc "
                    + "inner join reg_periksa on verifikasi_pengkajian_faskes_lain_smc.no_rawat=reg_periksa.no_rawat "
                    + "inner join pasien on reg_periksa.no_rkm_medis=pasien.no_rkm_medis "
                    + "inner join petugas on verifikasi_pengkajian_faskes_lain_smc.nip=petugas.nip "
                    + "where verifikasi_pengkajian_faskes_lain_smc.tgl_verifikasi between ? and ? "
                    + ("".equals(TCari.getText().trim()) ? "" : "and (verifikasi_pengkajian_faskes_lain_smc.no_rawat like ? "
                    + "or reg_periksa.no_rkm_medis like ? or pasien.nm_pasien like ? or verifikasi_pengkajian_faskes_lain_smc.asal_faskes like ?) ")
                    + "order by verifikasi_pengkajian_faskes_lain_smc.tgl_verifikasi desc, verifikasi_pengkajian_faskes_lain_smc.jam_verifikasi desc");
            try {
                ps.setString(1, Valid.SetTgl(DTPCari1.getSelectedItem() + ""));
                ps.setString(2, Valid.SetTgl(DTPCari2.getSelectedItem() + ""));
                if (!"".equals(TCari.getText().trim())) {
                    ps.setString(3, "%" + TCari.getText().trim() + "%");
                    ps.setString(4, "%" + TCari.getText().trim() + "%");
                    ps.setString(5, "%" + TCari.getText().trim() + "%");
                    ps.setString(6, "%" + TCari.getText().trim() + "%");
                }
                rs = ps.executeQuery();
                while (rs.next()) {
                    tabMode.addRow(new Object[]{
                        rs.getString("no_rawat"), rs.getString("no_rkm_medis"), rs.getString("nm_pasien"),
                        rs.getString("tgl_lahir"), rs.getString("jk"), rs.getString("tgl_verifikasi"),
                        rs.getString("jam_verifikasi"), rs.getString("asal_faskes"), rs.getString("anamnesis"),
                        rs.getString("hasil_anamnesis"), rs.getString("pemeriksaan_fisik"), rs.getString("hasil_pemeriksaan_fisik"),
                        rs.getString("pemeriksaan_penunjang"), rs.getString("hasil_pemeriksaan_penunjang"),
                        rs.getString("diagnosis"), rs.getString("hasil_diagnosis"), rs.getString("terapi_tindakan"),
                        rs.getString("hasil_terapi_tindakan"), rs.getString("alergi_obat"), rs.getString("hasil_alergi_obat"),
                        rs.getString("kesimpulan"), rs.getString("nip"), rs.getString("nama")
                    });
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
            System.out.println("Notifikasi : " + e);
        }
        LCount.setText("" + tabMode.getRowCount());
    }

    private void getData() {
        if (tbObat.getSelectedRow() != -1) {
            TNoRw.setText(tbObat.getValueAt(tbObat.getSelectedRow(), 0).toString());
            TNoRM.setText(tbObat.getValueAt(tbObat.getSelectedRow(), 1).toString());
            TPasien.setText(tbObat.getValueAt(tbObat.getSelectedRow(), 2).toString());
            TglLahir.setText(tbObat.getValueAt(tbObat.getSelectedRow(), 3).toString());
            JK.setText(tbObat.getValueAt(tbObat.getSelectedRow(), 4).toString());
            Valid.SetTgl(DTPTgl, tbObat.getValueAt(tbObat.getSelectedRow(), 5).toString());
            String[] jam = tbObat.getValueAt(tbObat.getSelectedRow(), 6).toString().split(":");
            if (jam.length >= 3) {
                cmbJam.setSelectedItem(jam[0]);
                cmbMnt.setSelectedItem(jam[1]);
                cmbDtk.setSelectedItem(jam[2]);
            }
            ChkKejadian.setSelected(false);
            AsalFaskes.setText(tbObat.getValueAt(tbObat.getSelectedRow(), 7).toString());
            CmbAnamnesis.setSelectedItem(tbObat.getValueAt(tbObat.getSelectedRow(), 8).toString());
            HasilAnamnesis.setText(tbObat.getValueAt(tbObat.getSelectedRow(), 9).toString());
            CmbPemeriksaanFisik.setSelectedItem(tbObat.getValueAt(tbObat.getSelectedRow(), 10).toString());
            HasilPemeriksaanFisik.setText(tbObat.getValueAt(tbObat.getSelectedRow(), 11).toString());
            CmbPemeriksaanPenunjang.setSelectedItem(tbObat.getValueAt(tbObat.getSelectedRow(), 12).toString());
            HasilPemeriksaanPenunjang.setText(tbObat.getValueAt(tbObat.getSelectedRow(), 13).toString());
            CmbDiagnosis.setSelectedItem(tbObat.getValueAt(tbObat.getSelectedRow(), 14).toString());
            HasilDiagnosis.setText(tbObat.getValueAt(tbObat.getSelectedRow(), 15).toString());
            CmbTerapiTindakan.setSelectedItem(tbObat.getValueAt(tbObat.getSelectedRow(), 16).toString());
            HasilTerapiTindakan.setText(tbObat.getValueAt(tbObat.getSelectedRow(), 17).toString());
            CmbAlergiObat.setSelectedItem(tbObat.getValueAt(tbObat.getSelectedRow(), 18).toString());
            HasilAlergiObat.setText(tbObat.getValueAt(tbObat.getSelectedRow(), 19).toString());
            Kesimpulan.setSelectedItem(tbObat.getValueAt(tbObat.getSelectedRow(), 20).toString());
            KdPetugas.setText(tbObat.getValueAt(tbObat.getSelectedRow(), 21).toString());
            NmPetugas.setText(tbObat.getValueAt(tbObat.getSelectedRow(), 22).toString());
        }
    }
}
