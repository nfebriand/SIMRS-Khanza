package laporan.sirs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * RL 3.8 — Kegiatan Pelayanan Laboratorium (bulanan, realtime).
 * Port dari laporan.DlgRl38 (method tampil() + array STRUKTUR).
 * Tiap baris item (tipe "I") mencocokkan keyword ke katalog lab RS
 * (template_laboratorium.Pemeriksaan) lalu:
 *   Jumlah (L/P)   = jumlah KEGIATAN pemeriksaan per jenis kelamin (JUKNIS rule 3),
 *   RATA-RATA(L/P) = SUM(nilai numerik) / jumlah hasil numerik.
 * Header kategori (K), grup (G), dan sub-display (D) tampil tanpa data.
 * Kolom: No./Jenis Kegiatan/Jumlah (L)/Jumlah (P)/RATA-RATA (L)/RATA-RATA (P).
 */
public class Rl38 implements SirsBuilder {

    /** {no, nama, tipe, keyword} — tipe: K=kategori, G=grup, D=sub-display, I=item berdata. */
    private static final String[][] STRUKTUR = {
        {"A","PATOLOGI KLINIK","K",""},
        {"1","Hematologi","G",""},
        {"1.1","Kadar Hemoglobin","I","hemoglobin|haemoglobin"},
        {"1.2","Nilai Hematokrit","I","hematokrit|hematocrit|hematokrid|pcv"},
        {"1.3","Hitung Lekosit","I","lekosit|leukosit|leucocyte|leukocyte"},
        {"1.4","Hitung Eritrosit","I","eritrosit|erythrocyte|erytrosit"},
        {"1.5","Hitung Eosinophil","I","eosinophil|eosinofil|easinofil"},
        {"1.6","Hitung Jenis Lekosit (%/absolut)","I","hitung jenis|diff count|differential|jenis lekosit|jenis leukosit"},
        {"1.7","Laju Endap Darah","I","laju endap|led|bse|esr"},
        {"1.8","Hitung Retikulosit","I","retikulosit|reticulocyte"},
        {"1.9","Hitung Trombosit","I","trombosit|platelet|thrombocyte"},
        {"2","Kimia Klinik","G",""},
        {"2.1","Protein Total","I","protein total|total protein"},
        {"2.2","Albumin","I","albumin"},
        {"2.3","Globulin","I","globulin"},
        {"2.4","Bilirubin Total/Direk/Indirek","I","bilirubin total|bilirubin direk|bilirubin indirek|bilirubin direct"},
        {"2.5","SGOT/AST","I","sgot|aspartat|ast "},
        {"2.6","SGPT/ALT","I","sgpt|alanin|alt "},
        {"2.7","Ureum/BUN","I","ureum|urea|bun"},
        {"2.8","Kreatinin (eGFR)","I","kreatinin|creatinin|egfr"},
        {"2.9","Asam Urat","I","asam urat|uric acid"},
        {"2.10","Trigliserida","I","trigliserida|triglyceride|trigliserid"},
        {"2.11","Kolesterol Total","I","kolesterol total|cholesterol total|colesterol total"},
        {"2.12","Kolesterol HDL","I","hdl"},
        {"2.13","Kolesterol LDL (direk)","I","ldl"},
        {"2.14","Glukosa Sewaktu/Puasa/2jam PP","I","glukosa|glucose|gula darah|gds|gdp|gd2pp|gd 2 jam|gd puasa|gd sewaktu"},
        {"2.15","HbA1c","I","hba1c|hb a1|a1c|hba1-c|a1-c"},
        {"2.16","Fosfatase alkali","I","fosfatase|alkali phosphatase|alkaline phosphatase|alp "},
        {"2.17","Gamma GT","I","gamma gt|gamma-gt|ggt"},
        {"2.18","LDH","I","ldh|lactat dehidrogenase|lactate dehydrogenase"},
        {"2.19","G 6 PD","I","g6pd|g 6 pd|g-6-pd|glucose-6"},
        {"2.20","Amilase","I","amilase|amylase"},
        {"2.21","Lipase","I","lipase"},
        {"2.22","Cholinesterase","I","cholinesterase|kolinesterase"},
        {"2.23","CK Total -CK MB","I","ck-mb|ckmb|ck mb|ck total|ck-total|creatin kinase|creatine kinase|cpk"},
        {"2.24","SI/TIBC","I","tibc|serum iron|si/tibc|serum besi|zat besi|iron"},
        {"2.25","Elektrolit Darah (Na, K, Cl, Ca, Mg, P)","I","elektrolit|natrium|kalium|klorida|chlorida|kalsium|calcium|magnesium|fosfat anorganik"},
        {"2.26","Analisa Gas Darah","I","gas darah|analisa gas|blood gas|agd|bga"},
        {"3","Imunologi Klinik","G",""},
        {"3.1","Widal","I","widal"},
        {"3.2","Antibodi anti SARS-CoV-2","I","antibodi sars|antibody sars|antibodi covid|antibodi anti sars|igg sars|igm sars"},
        {"3.3","Antigen SARS-CoV-2","I","antigen sars|swab antigen|rapid antigen|antigen covid|ag sars"},
        {"3.4","Dengue IgG-IgM","I","dengue igg|dengue igm|igg-igm dengue|anti dengue|igg/igm dengue"},
        {"3.5","HBs Ag","I","hbsag|hbs ag"},
        {"3.6","Anti HBs","I","anti hbs|anti-hbs"},
        {"3.7","Anti HBc","I","anti hbc|anti-hbc"},
        {"3.8","Anti HBe","I","anti hbe|anti-hbe"},
        {"3.9","Hbe Ag","I","hbeag|hbe ag"},
        {"3.10","Anti HCV","I","anti hcv|anti-hcv"},
        {"3.11","IgM Anti HAV","I","anti hav|igm hav|igm anti hav"},
        {"3.12","Anti HIV","I","anti hiv|hiv"},
        {"3.13","NS1 (non structure antigen) Dengue","I","ns1"},
        {"3.14","Tes Antigen Malaria","I","antigen malaria|malaria rdt|rdt malaria|malaria antigen"},
        {"3.15","T3/T4 total","I","total t3|total t4|tt3|tt4|t3 total|t4 total"},
        {"3.16","FT3/FT4","I","ft3|ft4|free t3|free t4"},
        {"3.17","TSH","I","tsh"},
        {"4","Urinalisis dan analisis cairan","G",""},
        {"4.1","Protein/albumin","I","protein urin|albumin urin|protein/albumin|urine protein|protein urine"},
        {"4.2","Urobilinogen","I","urobilinogen"},
        {"4.3","Bilirubin","I","bilirubin urin|bilirubin urine"},
        {"4.4","Sedimen Urine","I","sedimen|sediment"},
        {"4.5","NAPZA Skrining","I","napza|amphetamin|amphetamine|amphethamin|benzodiazepin|morfin|morphin|opiat|opiate|cocain|kokain|methamphetamin|thc|ganja|narkoba"},
        {"5","Hemostasis","G",""},
        {"5.1","Masa perdarahan","I","masa perdarahan|bleeding time"},
        {"5.2","Masa pembekuan","I","masa pembekuan|clotting time"},
        {"5.3","Masa prothrombin plasma","I","prothrombin|protrombin|pt/inr|masa protrombin|inr"},
        {"5.4","Masa tromboplastin partial teraktivasi","I","aptt|tromboplastin|ptt"},
        {"5.5","Masa thrombin","I","masa thrombin|thrombin time|masa trombin"},
        {"5.6","Fibrinogen","I","fibrinogen"},
        {"5.7","D-dimer","I","d-dimer|d dimer|ddimer"},
        {"5.8","Lupus anticoagulant","I","lupus anticoagulant|lupus antikoagulan"},
        {"B","MIKROBIOLOGI KLINIK","K",""},
        {"6","Pemeriksaan dahak mikroskopis TBC Bakteri Tahan Asam (Mycobacterium tuberculosis)","I","bta|tahan asam|ziehl|dahak mikroskopis|sputum bta|mikroskopis tb|zn "},
        {"6.1","Negatif","D",""},
        {"6.2","1-9","D",""},
        {"6.3","1+","D",""},
        {"6.4","2+","D",""},
        {"6.5","3+","D",""},
        {"6.6","Tidak Dilakukan","D",""},
        {"7","Biakan dan identifikasi bakteri aerob, serta uji kepekaan terhadap antibiotik","I","kultur|biakan|culture|resistensi|kepekaan|sensitivity|sensitivitas"},
        {"8","Biakan virus dan uji kepekaan terhadap antivirus","I","biakan virus|kultur virus"},
        {"9","Biakan dan identifikasi M. tuberculosis dan uji kepekaan terhadap OAT","I","kultur mtb|biakan tb|kultur tuberculosis|mgit|media lj"},
        {"10","Pemeriksaan berbasis molekuler untuk deteksi virus DNA dan RNA terutama virus Influenza, SARS-CoV 1 dan 2, HIV","G",""},
        {"10.1","PCR","D",""},
        {"10.2","Real time PCR","D",""},
        {"10.3","Tes Cepat Molekuler","D",""},
        {"10.4","Hibridisasi","D",""},
        {"10.5","Sekuensing","D",""},
        {"10.6","Metode lainnya","D",""},
        {"11","Pemeriksaan Tes Cepat Molekuler (TCM) untuk TBC dan TBC Resistan Obat (RO)","I","tcm|genexpert|gene xpert|cepat molekuler tb|mtb/rif"},
        {"11.1","Negatif","D",""},
        {"11.2","Rif Sen","D",""},
        {"11.3","Rif Res","D",""},
        {"11.4","Rif Indet","D",""},
        {"11.5","Invalid","D",""},
        {"11.6","Error","D",""},
        {"11.7","No Result","D",""},
        {"11.8","Tidak Dilakukan","D",""},
        {"12","Pemeriksaan berbasis molekuler untuk deteksi bakteri aerob, anaerob dan bakteri fastidious lainnya","G",""},
        {"12.1","PCR","D",""},
        {"12.2","Real time PCR","D",""},
        {"12.3","Tes Cepat Molekuler","D",""},
        {"12.4","Hibridisasi","D",""},
        {"12.5","Sekuensing","D",""},
        {"12.6","Metode lainnya","D",""},
        {"13","Pemeriksaan berbasis molekuler untuk deteksi gen pengkode resistensi antimikroba","G",""},
        {"13.1","PCR","D",""},
        {"13.2","Real time PCR","D",""},
        {"13.3","Tes Cepat Molekuler","D",""},
        {"13.4","Hibridisasi","D",""},
        {"13.5","Sekuensing","D",""},
        {"13.6","Metode lainnya","D",""},
        {"14","Pemeriksaan berbasis molekuler untuk deteksi jamur","G",""},
        {"14.1","PCR","D",""},
        {"14.2","Real time PCR","D",""},
        {"14.3","Tes Cepat Molekuler","D",""},
        {"14.4","Hibridisasi","D",""},
        {"14.5","Sekuensing","D",""},
        {"14.6","Metode lainnya","D",""},
        {"C","PARASITOLOGI KLINIK","K",""},
        {"15","Pemeriksaan Mikroskopis","G",""},
        {"15.1","Identifikasi cacing, larva/proglottid","I","cacing|telur cacing|ascaris|proglottid|kremi|helminth"},
        {"15.2","Identifikasi arthropoda (tuma, tungau, pinjal, kutu, arachnida, crustacea)","I","tungau|pinjal|kutu|arthropoda|scabies|sarcoptes"},
        {"15.3","Identifikasi nyamuk, larva nyamuk","I","nyamuk|larva nyamuk"},
        {"15.4","Identifikasi lalat dan larva lalat","I","lalat|myiasis|larva lalat"},
        {"16","Pemeriksaan Jamur","G",""},
        {"16.1","Pemeriksaan langsung KOH","I","koh"},
        {"16.2","Pemeriksaan langsung LPCB/tinta India","I","lpcb|tinta india|india ink"},
        {"16.3","Pemeriksaan jamur dengan pulasan khusus","I","pulasan jamur|gms|pas jamur|pulasan khusus jamur"},
        {"16.4","Kultur dan identifikasi jamur dari spesimen","I","kultur jamur|biakan jamur|fungi culture"},
        {"16.5","Identifikasi jamur dari biakan","I","identifikasi jamur"},
        {"16.6","Uji kepekaan jamur ragi (manual/semiotomatis)","I","kepekaan ragi|yeast|kandida|candida"},
        {"16.7","Uji kepekaan jamur kapang (manual)","I","kapang|mould|aspergillus"},
        {"D","PATOLOGI ANATOMI","K",""},
        {"17","Pemeriksaan tindakan biopsi aspirasi jarum halus dan/atau tindakan kedokteran lainnya","I","fnab|biopsi aspirasi|fine needle|bajah|fnac"},
        {"18","Pemeriksaan Sitopatologi","G",""},
        {"18.1","Pemeriksaan Pap's Smear","I","pap smear|pap's|papsmear|pap smir"},
        {"18.2","Pemeriksaan sitologi apus non ginekologi","I","sitologi apus|apus non gin"},
        {"18.3","Pemeriksaan sitologi cairan","I","sitologi cairan"},
        {"19","Pemeriksaan Histopatologi","G",""},
        {"19.1","Pemeriksaan jaringan kecil","I","jaringan kecil|histopatologi kecil|biopsi kecil"},
        {"19.2","Pemeriksaan jaringan sedang","I","jaringan sedang|histopatologi sedang"},
        {"19.3","Pemeriksaan jaringan besar","I","jaringan besar|histopatologi besar|reseksi"},
        {"20","Pemeriksaan Imunopatologi","G",""},
        {"20.1","Pemeriksaan imunohistokimia Payudara","I","ihk payudara|imunohistokimia payudara|er/pr|her2"},
        {"20.2","Pemeriksaan imunohistokimia Limfoma","I","ihk limfoma|imunohistokimia limfoma"},
        {"20.3","Pemeriksaan imunohistokimia lanjutan","I","pd-l1|alk|gist|ihk lanjutan|imunohistokimia lanjutan"},
        {"20.4","Pemeriksaan imunositokimia","I","imunositokimia"},
        {"20.5","Pemeriksaan imunofluoresensi","I","imunofluoresensi|immunofluorescence"},
        {"21","Pemeriksaan Patologi Molekuler","G",""},
        {"21.1","Deteksi mutasi EGFR","I","egfr"},
        {"21.2","Deteksi mutasi all-RAS","I","kras|nras|all-ras| ras "},
        {"21.3","Deteksi mutasi BRAF","I","braf"},
        {"21.4","Deteksi HPV Genotyping","I","hpv genotyping|hpv geno|genotyping hpv"},
        {"21.5","ISH","I","ish "},
        {"21.6","CISH","I","cish"},
        {"21.7","FISH","I","fish"},
        {"22","Pemeriksaan Potong Beku","I","potong beku|frozen section|vries coupe"},
        {"23","Pemeriksaan Otopsi Klinik","I","otopsi|autopsy|autopsi"},
    };

    @Override
    public SirsResult build(Connection k, String tgl1, String tgl2) throws Exception {
        SirsResult res = new SirsResult(new String[]{
            "No.", "Jenis Kegiatan", "Jumlah (L)", "Jumlah (P)", "RATA-RATA (L)", "RATA-RATA (P)"
        });

        int totL = 0, totP = 0, totCntL = 0, totCntP = 0;
        double totSumL = 0, totSumP = 0;

        for (String[] b : STRUKTUR) {
            String no = b[0], nama = b[1], tipe = b[2], kw = b[3];
            boolean header = "K".equals(tipe) || "G".equals(tipe) || "D".equals(tipe);

            if (header) {
                res.add(no, indentNama(tipe, nama), "", "", "", "");
                continue;
            }

            // tipe "I": cocokkan keyword ke katalog lab (template_laboratorium.Pemeriksaan).
            List<String> pola = new ArrayList<>();
            for (String key : kw.split("\\|")) {
                key = key.trim();
                if (!key.isEmpty()) pola.add("%" + key + "%");
            }
            StringBuilder like = new StringBuilder();
            for (int i = 0; i < pola.size(); i++) {
                if (i > 0) like.append(" OR ");
                like.append("t.Pemeriksaan LIKE ?");
            }
            if (pola.isEmpty()) like.append("1=0");

            // JUKNIS rule 3: Jumlah = jumlah KEGIATAN pemeriksaan (bukan distinct pasien).
            // Nilai rata-rata = SUM(hasil numerik) / jumlah hasil numerik.
            String sql = "SELECT "
                + "SUM(p.jk='L') jl,"
                + "SUM(p.jk='P') jp,"
                + "SUM(CASE WHEN p.jk='L' AND d.nilai REGEXP '^[0-9]+(\\.[0-9]+)?$' THEN CAST(d.nilai AS DECIMAL(15,4)) END) sl,"
                + "SUM(CASE WHEN p.jk='P' AND d.nilai REGEXP '^[0-9]+(\\.[0-9]+)?$' THEN CAST(d.nilai AS DECIMAL(15,4)) END) sp,"
                + "SUM(p.jk='L' AND d.nilai REGEXP '^[0-9]+(\\.[0-9]+)?$') cl,"
                + "SUM(p.jk='P' AND d.nilai REGEXP '^[0-9]+(\\.[0-9]+)?$') cp "
                + "FROM detail_periksa_lab d "
                + "INNER JOIN template_laboratorium t ON d.id_template=t.id_template "
                + "INNER JOIN reg_periksa r ON d.no_rawat=r.no_rawat "
                + "INNER JOIN pasien p ON r.no_rkm_medis=p.no_rkm_medis "
                + "WHERE d.tgl_periksa BETWEEN ? AND ? AND (" + like + ")";

            int jl = 0, jp = 0, cl = 0, cp = 0;
            double sl = 0, sp = 0;
            try (PreparedStatement ps = k.prepareStatement(sql)) {
                ps.setString(1, tgl1);
                ps.setString(2, tgl2);
                for (int i = 0; i < pola.size(); i++) ps.setString(3 + i, pola.get(i));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        jl = rs.getInt("jl");
                        jp = rs.getInt("jp");
                        sl = rs.getDouble("sl");
                        sp = rs.getDouble("sp");
                        cl = rs.getInt("cl");
                        cp = rs.getInt("cp");
                    }
                }
            }
            double rl = cl > 0 ? sl / cl : 0;
            double rp = cp > 0 ? sp / cp : 0;
            res.add(no, indentNama(tipe, nama), jl, jp,
                String.format("%.2f", rl), String.format("%.2f", rp));
            totL += jl;
            totP += jp;
            totSumL += sl;
            totSumP += sp;
            totCntL += cl;
            totCntP += cp;
        }

        res.add("", "TOTAL", totL, totP,
            String.format("%.2f", totCntL > 0 ? totSumL / totCntL : 0),
            String.format("%.2f", totCntP > 0 ? totSumP / totCntP : 0));
        return res;
    }

    /** Indentasi teks sesuai level. */
    private String indentNama(String tipe, String nama) {
        if ("K".equals(tipe)) return nama;              // kategori A-D
        if ("G".equals(tipe)) return "   " + nama;      // grup 1-23
        if ("D".equals(tipe)) return "        " + nama; // sub-display (tanpa data)
        return "      " + nama;                          // item berdata
    }
}
