<?php
include '../conf/conf.php';

reportsqlinjection();

$usere      = trim(isset($_GET['usere']))  ? trim($_GET['usere'])      : NULL;
$passwordte = trim(isset($_GET['passwordte'])) ? trim($_GET['passwordte']) : NULL;

if (!((USERHYBRIDWEB == $usere) && (PASHYBRIDWEB == $passwordte))) {
    exit(header("Location:../index.php"));
}

$tanggal1 = validTeks4($_GET['tanggal1'], 20);
$tanggal2 = validTeks4($_GET['tanggal2'], 20);
$kamar    = validTeks4($_GET['kamar'], 50);

$tgl1_fmt = date('d/m/Y', strtotime($tanggal1));
$tgl2_fmt = date('d/m/Y', strtotime($tanggal2));

/* ─── Query Pasien Masuk ─── */
$sqlMasuk = "
    SELECT ki.no_rawat, rp.no_rkm_medis, p.nm_pasien, pj.png_jawab,
           k.kelas, ki.kd_kamar, b.nm_bangsal,
           ki.tgl_masuk, ki.jam_masuk, d.nm_dokter
    FROM kamar_inap ki
    INNER JOIN reg_periksa rp  ON ki.no_rawat    = rp.no_rawat
    INNER JOIN pasien p        ON rp.no_rkm_medis = p.no_rkm_medis
    INNER JOIN kamar k         ON ki.kd_kamar     = k.kd_kamar
    INNER JOIN bangsal b       ON k.kd_bangsal    = b.kd_bangsal
    INNER JOIN dokter d        ON rp.kd_dokter    = d.kd_dokter
    INNER JOIN penjab pj       ON rp.kd_pj        = pj.kd_pj
    WHERE ki.tgl_masuk BETWEEN '$tanggal1' AND '$tanggal2'
      AND b.nm_bangsal LIKE '%$kamar%'
    GROUP BY ki.no_rawat
    ORDER BY ki.tgl_masuk, ki.jam_masuk
";

/* ─── Query Pasien Keluar ─── */
$sqlKeluar = "
    SELECT ki.no_rawat, rp.no_rkm_medis, p.nm_pasien, pj.png_jawab,
           k.kelas, ki.kd_kamar, b.nm_bangsal,
           ki.tgl_masuk, ki.tgl_keluar, ki.stts_pulang, d.nm_dokter
    FROM kamar_inap ki
    INNER JOIN reg_periksa rp  ON ki.no_rawat     = rp.no_rawat
    INNER JOIN pasien p        ON rp.no_rkm_medis  = p.no_rkm_medis
    INNER JOIN kamar k         ON ki.kd_kamar      = k.kd_kamar
    INNER JOIN bangsal b       ON k.kd_bangsal     = b.kd_bangsal
    INNER JOIN dokter d        ON rp.kd_dokter     = d.kd_dokter
    INNER JOIN penjab pj       ON rp.kd_pj         = pj.kd_pj
    WHERE ki.tgl_masuk BETWEEN '$tanggal1' AND '$tanggal2'
      AND b.nm_bangsal LIKE '%$kamar%'
      AND ki.tgl_keluar <> '0000-00-00'
    GROUP BY ki.no_rawat
    ORDER BY ki.tgl_keluar
";

/* ─── Ambil data ─── */
$hasilMasuk  = bukaquery($sqlMasuk);
$rowsMasuk   = [];
while ($r = mysqli_fetch_assoc($hasilMasuk)) { $rowsMasuk[] = $r; }

$hasilKeluar = bukaquery($sqlKeluar);
$rowsKeluar  = [];
while ($r = mysqli_fetch_assoc($hasilKeluar)) { $rowsKeluar[] = $r; }

$totalMasuk  = count($rowsMasuk);
$totalKeluar = count($rowsKeluar);

/* ─── Helper: cek rujukan ─── */
function cekRujukan($no_rawat) {
    return getOne("SELECT COUNT(no_rawat) FROM rujuk_masuk WHERE no_rawat='$no_rawat'") > 0;
}
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Sensus Harian Rawat Inap</title>

    <!-- SheetJS (Excel export) -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <!-- jsPDF + AutoTable (PDF export) -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js"></script>

<style>
    /* ══════════════════ RESET & BASE ══════════════════ */
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body {
        font-family: 'Segoe UI', Arial, sans-serif;
        font-size: 12px;
        background: #f0f4f8;
        color: #1a2533;
    }

    /* ══════════════════ HEADER ══════════════════ */
    .page-header {
        background: linear-gradient(135deg, #1a6fc4 0%, #0d4a8a 100%);
        color: #fff;
        padding: 18px 24px 14px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        box-shadow: 0 3px 8px rgba(0,0,0,.25);
    }
    .page-header .logo-area h1 {
        font-size: 16px;
        font-weight: 700;
        letter-spacing: .5px;
    }
    .page-header .logo-area p {
        font-size: 11px;
        opacity: .85;
        margin-top: 2px;
    }
    .page-header .btn-group { display: flex; gap: 8px; flex-wrap: wrap; }

    /* ══════════════════ BUTTONS ══════════════════ */
    .btn {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 7px 14px;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        font-size: 11.5px;
        font-weight: 600;
        transition: filter .15s, transform .1s;
        white-space: nowrap;
    }
    .btn:hover  { filter: brightness(1.08); transform: translateY(-1px); }
    .btn:active { filter: brightness(.95); transform: translateY(0); }
    .btn-excel  { background: #217346; color: #fff; }
    .btn-pdf    { background: #c0392b; color: #fff; }
    .btn-print  { background: #fff;    color: #1a6fc4; border: 1.5px solid #1a6fc4; }

    /* ══════════════════ SUMMARY CARDS ══════════════════ */
    .summary-bar {
        display: flex;
        gap: 12px;
        padding: 14px 20px;
        background: #fff;
        border-bottom: 1px solid #dde3ec;
        flex-wrap: wrap;
    }
    .card {
        flex: 1 1 140px;
        background: #f7faff;
        border: 1px solid #cdd9ec;
        border-radius: 8px;
        padding: 10px 14px;
        display: flex;
        flex-direction: column;
        gap: 4px;
    }
    .card .label  { font-size: 10.5px; color: #5a7094; text-transform: uppercase; letter-spacing: .4px; }
    .card .value  { font-size: 20px; font-weight: 700; color: #1a2533; line-height: 1; }
    .card.masuk   .value { color: #1a6fc4; }
    .card.keluar  .value { color: #217346; }

    /* ══════════════════ MAIN CONTENT ══════════════════ */
    .content { padding: 16px 20px; display: flex; flex-direction: column; gap: 20px; }

    /* ══════════════════ SECTION ══════════════════ */
    .section { background: #fff; border-radius: 8px; box-shadow: 0 1px 4px rgba(0,0,0,.1); overflow: hidden; }
    .section-header {
        padding: 10px 16px;
        font-weight: 700;
        font-size: 12.5px;
        display: flex;
        align-items: center;
        gap: 8px;
        color: #fff;
    }
    .section-header.masuk  { background: #1a6fc4; }
    .section-header.keluar { background: #217346; }
    .section-header .badge {
        background: rgba(255,255,255,.25);
        padding: 2px 8px;
        border-radius: 10px;
        font-size: 11px;
    }

    /* ══════════════════ TABLE ══════════════════ */
    .table-wrap { overflow-x: auto; }

    table {
        width: 100%;
        border-collapse: collapse;
        font-size: 11.5px;
    }
    thead th {
        background: #e9f0fb;
        color: #1a2533;
        padding: 8px 10px;
        text-align: center;
        font-weight: 700;
        border: 1px solid #cdd9ec;
        white-space: nowrap;
    }
    thead th.sub { background: #f4f7fd; font-weight: 600; font-size: 10.5px; }
    tbody td {
        padding: 7px 10px;
        border: 1px solid #dde3ec;
        vertical-align: middle;
        text-align: center;
    }
    tbody tr:nth-child(even) td { background: #f9fbff; }
    tbody tr:hover td { background: #eaf2ff; }

    /* Status badges */
    .badge-ya  { background:#d4edda; color:#155724; padding:2px 8px; border-radius:4px; font-size:10px; font-weight:700; }
    .badge-tdk { background:#f8d7da; color:#721c24; padding:2px 8px; border-radius:4px; font-size:10px; font-weight:700; }

    .no-data td {
        text-align: center;
        color: #8a9bbf;
        padding: 20px;
        font-style: italic;
    }

    /* ══════════════════ FOOTER ══════════════════ */
    .page-footer {
        text-align: center;
        color: #8a9bbf;
        font-size: 10px;
        padding: 12px 0 20px;
    }

    /* ══════════════════ PRINT ══════════════════ */
    @media print {
        body { background: #fff; font-size: 10px; }
        .page-header { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
        .btn-group, .summary-bar .card:last-child { display: none; }
        .section { box-shadow: none; border: 1px solid #ccc; page-break-inside: avoid; }
        .section-header { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
        .content { padding: 8px; }
    }
</style>
</head>
<body>

<!-- ══ HEADER ══ -->
<div class="page-header">
    <div class="logo-area">
        <h1>&#x1F3E5; Sensus Harian Rawat Inap</h1>
        <p>
            Bangsal: <strong><?= htmlspecialchars(str_replace('_',' ',$kamar) ?: 'Semua') ?></strong>
            &nbsp;|&nbsp;
            Periode: <strong><?= $tgl1_fmt ?></strong> s.d. <strong><?= $tgl2_fmt ?></strong>
        </p>
    </div>
    <div class="btn-group">
        <button class="btn btn-excel" onclick="exportExcel()">&#x1F4C4; Export Excel</button>
        <button class="btn btn-pdf"   onclick="exportPDF()">&#x1F4CB; Export PDF</button>
        <button class="btn btn-print" onclick="window.print()">&#x1F5A8; Cetak</button>
    </div>
</div>

<!-- ══ SUMMARY CARDS ══ -->
<div class="summary-bar">
    <div class="card masuk">
        <span class="label">Pasien Masuk</span>
        <span class="value"><?= $totalMasuk ?></span>
    </div>
    <div class="card keluar">
        <span class="label">Pasien Keluar</span>
        <span class="value"><?= $totalKeluar ?></span>
    </div>
    <div class="card">
        <span class="label">Masih Dirawat</span>
        <span class="value"><?= $totalMasuk - $totalKeluar ?></span>
    </div>
    <div class="card">
        <span class="label">Tanggal Cetak</span>
        <span class="value" style="font-size:13px"><?= date('d/m/Y H:i') ?></span>
    </div>
</div>

<!-- ══ CONTENT ══ -->
<div class="content">

    <!-- ─── PASIEN MASUK ─── -->
    <div class="section">
        <div class="section-header masuk">
            &#x2B06; Pasien Masuk
            <span class="badge"><?= $totalMasuk ?> pasien</span>
        </div>
        <div class="table-wrap">
            <table id="tblMasuk">
                <thead>
                    <tr>
                        <th rowspan="2">No</th>
                        <th rowspan="2">No. RM</th>
                        <th rowspan="2">Nama Pasien</th>
                        <th colspan="2">Rujukan</th>
                        <th rowspan="2">Kelas</th>
                        <th rowspan="2">Kamar</th>
                        <th rowspan="2">Jaminan</th>
                        <th rowspan="2">Tgl Masuk</th>
                        <th rowspan="2">Dokter</th>
                    </tr>
                    <tr>
                        <th class="sub">Ya</th>
                        <th class="sub">Tidak</th>
                    </tr>
                </thead>
                <tbody>
<?php if (empty($rowsMasuk)): ?>
                    <tr class="no-data"><td colspan="10">Tidak ada data pasien masuk pada periode ini.</td></tr>
<?php else: $no = 1; foreach ($rowsMasuk as $r):
    $rujukan = cekRujukan($r['no_rawat']);
    $tglMasukFmt = date('d/m/Y', strtotime($r['tgl_masuk']));
?>
                    <tr>
                        <td><?= $no++ ?></td>
                        <td><?= htmlspecialchars($r['no_rkm_medis']) ?></td>
                        <td style="text-align:left"><?= htmlspecialchars($r['nm_pasien']) ?></td>
                        <td><?= $rujukan ? '<span class="badge-ya">Ya</span>'  : '' ?></td>
                        <td><?= !$rujukan ? '<span class="badge-tdk">Tdk</span>' : '' ?></td>
                        <td><?= htmlspecialchars($r['kelas']) ?></td>
                        <td><?= htmlspecialchars($r['kd_kamar']) ?></td>
                        <td><?= htmlspecialchars($r['png_jawab']) ?></td>
                        <td><?= $tglMasukFmt ?></td>
                        <td style="text-align:left"><?= htmlspecialchars($r['nm_dokter']) ?></td>
                    </tr>
<?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>

    <!-- ─── PASIEN KELUAR ─── -->
    <div class="section">
        <div class="section-header keluar">
            &#x2B07; Pasien Keluar
            <span class="badge"><?= $totalKeluar ?> pasien</span>
        </div>
        <div class="table-wrap">
            <table id="tblKeluar">
                <thead>
                    <tr>
                        <th rowspan="2">No</th>
                        <th rowspan="2">No. RM</th>
                        <th rowspan="2">Nama Pasien</th>
                        <th colspan="2">Rujukan</th>
                        <th rowspan="2">Cara Pulang</th>
                        <th rowspan="2">Kelas</th>
                        <th rowspan="2">Kamar</th>
                        <th rowspan="2">Jaminan</th>
                        <th rowspan="2">Tgl Masuk</th>
                        <th rowspan="2">Tgl Keluar</th>
                        <th rowspan="2">Dokter</th>
                    </tr>
                    <tr>
                        <th class="sub">Ya</th>
                        <th class="sub">Tidak</th>
                    </tr>
                </thead>
                <tbody>
<?php if (empty($rowsKeluar)): ?>
                    <tr class="no-data"><td colspan="12">Tidak ada data pasien keluar pada periode ini.</td></tr>
<?php else: $no = 1; foreach ($rowsKeluar as $r):
    $rujukan = cekRujukan($r['no_rawat']);
    $tglMasukFmt  = date('d/m/Y', strtotime($r['tgl_masuk']));
    $tglKeluarFmt = date('d/m/Y', strtotime($r['tgl_keluar']));
?>
                    <tr>
                        <td><?= $no++ ?></td>
                        <td><?= htmlspecialchars($r['no_rkm_medis']) ?></td>
                        <td style="text-align:left"><?= htmlspecialchars($r['nm_pasien']) ?></td>
                        <td><?= $rujukan ? '<span class="badge-ya">Ya</span>'  : '' ?></td>
                        <td><?= !$rujukan ? '<span class="badge-tdk">Tdk</span>' : '' ?></td>
                        <td><?= htmlspecialchars($r['stts_pulang']) ?></td>
                        <td><?= htmlspecialchars($r['kelas']) ?></td>
                        <td><?= htmlspecialchars($r['kd_kamar']) ?></td>
                        <td><?= htmlspecialchars($r['png_jawab']) ?></td>
                        <td><?= $tglMasukFmt ?></td>
                        <td><?= $tglKeluarFmt ?></td>
                        <td style="text-align:left"><?= htmlspecialchars($r['nm_dokter']) ?></td>
                    </tr>
<?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>

</div><!-- /content -->

<div class="page-footer">
    Dicetak oleh SIMRS Khanza &mdash; <?= date('d/m/Y H:i:s') ?>
</div>

<!-- ══════════════════ JAVASCRIPT ══════════════════ -->
<script>
const INFO = {
    bangsal : "<?= htmlspecialchars(str_replace('_',' ',$kamar) ?: 'Semua') ?>",
    periode : "<?= $tgl1_fmt ?> s.d. <?= $tgl2_fmt ?>",
    cetak   : "<?= date('d/m/Y H:i') ?>"
};

/* ─── EXPORT EXCEL ─── */
function exportExcel() {
    const wb = XLSX.utils.book_new();

    /* Pasien Masuk */
    addSheetMasuk(wb);
    /* Pasien Keluar */
    addSheetKeluar(wb);

    const fname = `SensusHarian_${INFO.periode.replace(/ /g,'').replace(/\//g,'-')}.xlsx`;
    XLSX.writeFile(wb, fname);
}

function tableToArr(tableId, skipBadge) {
    const table = document.getElementById(tableId);
    const rows  = Array.from(table.querySelectorAll('tr'));
    return rows.map(row => {
        const cells = Array.from(row.querySelectorAll('th,td'));
        return cells.map(c => c.innerText.trim());
    });
}

function addSheetMasuk(wb) {
    const title  = [['SENSUS HARIAN RAWAT INAP – PASIEN MASUK']];
    const info   = [['Bangsal: ' + INFO.bangsal], ['Periode: ' + INFO.periode], ['Dicetak: ' + INFO.cetak], []];
    const header = [['No','No. RM','Nama Pasien','Rujukan Ya','Rujukan Tidak','Kelas','Kamar','Jaminan','Tgl Masuk','Dokter']];

    const tbody  = document.querySelectorAll('#tblMasuk tbody tr');
    const data   = [];
    tbody.forEach(row => {
        const cells = row.querySelectorAll('td');
        if (cells.length < 2) return;
        data.push([
            cells[0].innerText.trim(),
            cells[1].innerText.trim(),
            cells[2].innerText.trim(),
            cells[3].innerText.trim(),
            cells[4].innerText.trim(),
            cells[5].innerText.trim(),
            cells[6].innerText.trim(),
            cells[7].innerText.trim(),
            cells[8].innerText.trim(),
            cells[9].innerText.trim(),
        ]);
    });

    const aoa = [...title, ...info, ...header, ...data];
    const ws  = XLSX.utils.aoa_to_sheet(aoa);

    /* Style lebar kolom */
    ws['!cols'] = [4,12,30,10,10,8,10,16,12,30].map(w=>({wch:w}));

    /* Merge title */
    ws['!merges'] = [{s:{r:0,c:0},e:{r:0,c:9}}];

    XLSX.utils.book_append_sheet(wb, ws, 'Pasien Masuk');
}

function addSheetKeluar(wb) {
    const title  = [['SENSUS HARIAN RAWAT INAP – PASIEN KELUAR']];
    const info   = [['Bangsal: ' + INFO.bangsal], ['Periode: ' + INFO.periode], ['Dicetak: ' + INFO.cetak], []];
    const header = [['No','No. RM','Nama Pasien','Rujukan Ya','Rujukan Tidak','Cara Pulang','Kelas','Kamar','Jaminan','Tgl Masuk','Tgl Keluar','Dokter']];

    const tbody = document.querySelectorAll('#tblKeluar tbody tr');
    const data  = [];
    tbody.forEach(row => {
        const cells = row.querySelectorAll('td');
        if (cells.length < 2) return;
        data.push([
            cells[0].innerText.trim(),
            cells[1].innerText.trim(),
            cells[2].innerText.trim(),
            cells[3].innerText.trim(),
            cells[4].innerText.trim(),
            cells[5].innerText.trim(),
            cells[6].innerText.trim(),
            cells[7].innerText.trim(),
            cells[8].innerText.trim(),
            cells[9].innerText.trim(),
            cells[10].innerText.trim(),
            cells[11].innerText.trim(),
        ]);
    });

    const aoa = [...title, ...info, ...header, ...data];
    const ws  = XLSX.utils.aoa_to_sheet(aoa);
    ws['!cols'] = [4,12,30,10,10,16,8,10,16,12,12,30].map(w=>({wch:w}));
    ws['!merges'] = [{s:{r:0,c:0},e:{r:0,c:11}}];

    XLSX.utils.book_append_sheet(wb, ws, 'Pasien Keluar');
}

/* ─── EXPORT PDF ─── */
function exportPDF() {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' });

    const headerBg  = [26, 111, 196];   // #1a6fc4
    const headerBg2 = [33, 115, 70];    // #217346

    const addTitle = (doc, text, color) => {
        doc.setFillColor(...color);
        doc.rect(10, 10, 277, 10, 'F');
        doc.setTextColor(255,255,255);
        doc.setFontSize(11);
        doc.setFont('helvetica','bold');
        doc.text(text, 148.5, 17, {align:'center'});
        doc.setTextColor(80,80,80);
        doc.setFontSize(8.5);
        doc.setFont('helvetica','normal');
        doc.text(`Bangsal: ${INFO.bangsal}   |   Periode: ${INFO.periode}   |   Dicetak: ${INFO.cetak}`, 148.5, 26, {align:'center'});
    };

    /* --- Halaman 1: Pasien Masuk --- */
    addTitle(doc, 'SENSUS HARIAN RAWAT INAP – PASIEN MASUK', headerBg);

    const headMasuk = [['No','No. RM','Nama Pasien','Rujukan\nYa','Rujukan\nTidak','Kelas','Kamar','Jaminan','Tgl Masuk','Dokter']];
    const bodyMasuk = [];
    document.querySelectorAll('#tblMasuk tbody tr').forEach(row => {
        const cells = row.querySelectorAll('td');
        if (cells.length < 2) return;
        bodyMasuk.push(Array.from(cells).map(c => c.innerText.trim()));
    });

    doc.autoTable({
        startY: 30,
        head: headMasuk,
        body: bodyMasuk.length ? bodyMasuk : [['','','Tidak ada data','','','','','','','']],
        styles: { fontSize: 7.5, cellPadding: 2, halign: 'center', valign: 'middle' },
        headStyles: { fillColor: headerBg, textColor: 255, fontStyle: 'bold', halign: 'center' },
        columnStyles: { 2: {halign:'left', cellWidth:40}, 9: {halign:'left', cellWidth:35} },
        alternateRowStyles: { fillColor: [234, 242, 255] },
        margin: { left: 10, right: 10 },
        tableWidth: 277,
    });

    /* --- Halaman 2: Pasien Keluar --- */
    doc.addPage();
    addTitle(doc, 'SENSUS HARIAN RAWAT INAP – PASIEN KELUAR', headerBg2);

    const headKeluar = [['No','No. RM','Nama Pasien','Rujukan\nYa','Rujukan\nTidak','Cara Pulang','Kelas','Kamar','Jaminan','Tgl Masuk','Tgl Keluar','Dokter']];
    const bodyKeluar = [];
    document.querySelectorAll('#tblKeluar tbody tr').forEach(row => {
        const cells = row.querySelectorAll('td');
        if (cells.length < 2) return;
        bodyKeluar.push(Array.from(cells).map(c => c.innerText.trim()));
    });

    doc.autoTable({
        startY: 30,
        head: headKeluar,
        body: bodyKeluar.length ? bodyKeluar : [['','','Tidak ada data','','','','','','','','','']],
        styles: { fontSize: 7.5, cellPadding: 2, halign: 'center', valign: 'middle' },
        headStyles: { fillColor: headerBg2, textColor: 255, fontStyle: 'bold', halign: 'center' },
        columnStyles: { 2: {halign:'left', cellWidth:38}, 11: {halign:'left', cellWidth:32} },
        alternateRowStyles: { fillColor: [234, 255, 240] },
        margin: { left: 10, right: 10 },
        tableWidth: 277,
    });

    /* --- Nomor halaman --- */
    const pageCount = doc.internal.getNumberOfPages();
    for (let i = 1; i <= pageCount; i++) {
        doc.setPage(i);
        doc.setFontSize(7.5);
        doc.setTextColor(150);
        doc.text(`Halaman ${i} dari ${pageCount}`, 148.5, 205, {align:'center'});
    }

    const fname = `SensusHarian_${INFO.periode.replace(/ /g,'').replace(/\//g,'-')}.pdf`;
    doc.save(fname);
}
</script>

</body>
</html>
