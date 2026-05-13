<?php
include '../conf/conf.php';

reportsqlinjection();

$usere      = trim(isset($_GET['usere']))      ? trim($_GET['usere'])      : NULL;
$passwordte = trim(isset($_GET['passwordte'])) ? trim($_GET['passwordte']) : NULL;

if (!((USERHYBRIDWEB == $usere) && (PASHYBRIDWEB == $passwordte))) {
    exit(header("Location:../index.php"));
}

$tanggal1 = validTeks4($_GET['tanggal1'], 20);
$tanggal2 = validTeks4($_GET['tanggal2'], 20);
$kamar    = validTeks4($_GET['kamar'],    50);

$tgl1_fmt = date('d/m/Y', strtotime($tanggal1));
$tgl2_fmt = date('d/m/Y', strtotime($tanggal2));

/* ══════════════════════════════════════════════════════════
   QUERY PASIEN MASUK
   stts_pulang diambil langsung dari kamar_inap.
   rujuk_masuk di-LEFT JOIN agar tidak gandakan row
   ══════════════════════════════════════════════════════════ */
$sqlMasuk = "
    SELECT
        ki.no_rawat,
        rp.no_rkm_medis,
        p.nm_pasien,
        pj.png_jawab,
        k.kelas,
        ki.kd_kamar,
        b.nm_bangsal,
        ki.tgl_masuk,
        ki.jam_masuk,
        ki.stts_pulang,
        ki.lama,
        d.nm_dokter,
        IF(rm.no_rawat IS NOT NULL, 'Ya', 'Tidak') AS rujuk_masuk
    FROM kamar_inap ki
    INNER JOIN reg_periksa rp  ON ki.no_rawat      = rp.no_rawat
    INNER JOIN pasien p        ON rp.no_rkm_medis  = p.no_rkm_medis
    INNER JOIN kamar k         ON ki.kd_kamar      = k.kd_kamar
    INNER JOIN bangsal b       ON k.kd_bangsal     = b.kd_bangsal
    INNER JOIN dokter d        ON rp.kd_dokter     = d.kd_dokter
    INNER JOIN penjab pj       ON rp.kd_pj         = pj.kd_pj
    LEFT  JOIN (SELECT DISTINCT no_rawat FROM rujuk_masuk) rm
               ON ki.no_rawat = rm.no_rawat
    WHERE ki.tgl_masuk BETWEEN '$tanggal1' AND '$tanggal2'
      AND b.nm_bangsal LIKE '%$kamar%'
    GROUP BY ki.no_rawat
    ORDER BY ki.tgl_masuk, ki.jam_masuk
";

/* ══════════════════════════════════════════════════════════
   QUERY PASIEN KELUAR
   Hanya yang tgl_keluar sudah terisi (bukan 0000-00-00).
   ══════════════════════════════════════════════════════════ */
$sqlKeluar = "
    SELECT
        ki.no_rawat,
        rp.no_rkm_medis,
        p.nm_pasien,
        pj.png_jawab,
        k.kelas,
        ki.kd_kamar,
        b.nm_bangsal,
        ki.tgl_masuk,
        ki.jam_masuk,
        ki.tgl_keluar,
        ki.jam_keluar,
        ki.stts_pulang,
        ki.lama,
        d.nm_dokter,
        IF(rm.no_rawat IS NOT NULL, 'Ya', 'Tidak') AS rujuk_masuk
    FROM kamar_inap ki
    INNER JOIN reg_periksa rp  ON ki.no_rawat      = rp.no_rawat
    INNER JOIN pasien p        ON rp.no_rkm_medis  = p.no_rkm_medis
    INNER JOIN kamar k         ON ki.kd_kamar      = k.kd_kamar
    INNER JOIN bangsal b       ON k.kd_bangsal     = b.kd_bangsal
    INNER JOIN dokter d        ON rp.kd_dokter     = d.kd_dokter
    INNER JOIN penjab pj       ON rp.kd_pj         = pj.kd_pj
    LEFT  JOIN (SELECT DISTINCT no_rawat FROM rujuk_masuk) rm
               ON ki.no_rawat = rm.no_rawat
    WHERE ki.tgl_masuk BETWEEN '$tanggal1' AND '$tanggal2'
      AND b.nm_bangsal LIKE '%$kamar%'
      AND ki.tgl_keluar <> '0000-00-00'
    GROUP BY ki.no_rawat
    ORDER BY ki.tgl_keluar, ki.jam_keluar
";

/* ─── Fetch ke array PHP ─── */
$hasilMasuk  = bukaquery($sqlMasuk);
$rowsMasuk   = [];
while ($r = mysqli_fetch_assoc($hasilMasuk))  { $rowsMasuk[]  = $r; }

$hasilKeluar = bukaquery($sqlKeluar);
$rowsKeluar  = [];
while ($r = mysqli_fetch_assoc($hasilKeluar)) { $rowsKeluar[] = $r; }

$totalMasuk  = count($rowsMasuk);
$totalKeluar = count($rowsKeluar);

/* ─── Rekap per status keluar (dari data DB langsung) ─── */
$rekapStatus = [];
foreach ($rowsKeluar as $r) {
    $st = trim($r['stts_pulang'] ?? '');
    if ($st === '' || $st === null) $st = '-';
    $rekapStatus[$st] = ($rekapStatus[$st] ?? 0) + 1;
}
arsort($rekapStatus);

/* ─── Hitung sub-total penting ─── */
$jmlMeninggal = ($rekapStatus['Meninggal'] ?? 0) + ($rekapStatus['+'] ?? 0);
$jmlRujuk     = $rekapStatus['Rujuk'] ?? 0;
$jmlDirawat   = max(0, $totalMasuk - $totalKeluar);

/* ──────────────────────────────────────────────────────────
   HELPER: kembalikan label & warna badge dari stts_pulang
   Nilai asli di DB (dari cmbStatus di Java):
     Sehat | Rujuk | APS | + | Meninggal | Sembuh | Membaik
     Pulang Paksa | - | Pindah Kamar | Status Belum Lengkap
     Atas Persetujuan Dokter | Atas Permintaan Sendiri
     Isoman | Lain-lain
   ────────────────────────────────────────────────────────── */
function statusBadge(string $raw): array {
    static $map = [
        'Atas Persetujuan Dokter' => ['Persetujuan Dokter', '#1a4e8a', '#dbeafe'],
        '1. Atas Persetujuan Dokter' => ['Persetujuan Dokter', '#1a4e8a', '#dbeafe'],
        'Sembuh'                  => ['Sembuh',             '#155724', '#d4edda'],
        'Sehat'                   => ['Sehat',              '#155724', '#d4edda'],
        'Membaik'                 => ['Membaik',            '#0c5460', '#d1ecf1'],
        'APS'                     => ['APS',                '#856404', '#fff3cd'],
        'Atas Permintaan Sendiri' => ['APS',                '#856404', '#fff3cd'],
        '3. Atas Permintaan Sendiri' => ['APS',             '#856404', '#fff3cd'],
        'Pulang Paksa'            => ['Pulang Paksa',       '#7b2d00', '#ffe5d0'],
        'Rujuk'                   => ['Dirujuk',            '#5a2d82', '#ede2f7'],
        'Meninggal'               => ['Meninggal',          '#ffffff', '#721c24'],
        '+'                       => ['Meninggal',          '#ffffff', '#721c24'],
        '4. Meninggal'            => ['Meninggal',          '#ffffff', '#721c24'],
        'Isoman'                  => ['Isoman',             '#0c4a6e', '#e0f2fe'],
        'Lain-lain'               => ['Lain-lain',          '#4a4a4a', '#e9e9e9'],
        '5. Lain-lain'            => ['Lain-lain',          '#4a4a4a', '#e9e9e9'],
        'Status Belum Lengkap'    => ['Belum Lengkap',      '#6c3a00', '#fef3c7'],
        'Pindah Kamar'            => ['Pindah Kamar',       '#1a4971', '#e0f0ff'],
        '-'                       => ['Masih Dirawat',      '#1a4971', '#e0f0ff'],
    ];
    $raw = trim($raw);
    if (isset($map[$raw])) {
        return ['label' => $map[$raw][0], 'color' => $map[$raw][1], 'bg' => $map[$raw][2]];
    }
    return ['label' => ($raw ?: 'Belum Diisi'), 'color' => '#4a4a4a', 'bg' => '#e9e9e9'];
}
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Sensus Harian Rawat Inap</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js"></script>
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',Arial,sans-serif;font-size:12px;background:#f0f4f8;color:#1a2533}

/* ── Header ── */
.page-header{
    background:linear-gradient(135deg,#1a6fc4 0%,#0d4a8a 100%);
    color:#fff;padding:16px 22px 12px;
    display:flex;align-items:center;justify-content:space-between;gap:12px;
    box-shadow:0 3px 8px rgba(0,0,0,.25)
}
.page-header h1{font-size:15px;font-weight:700}
.page-header p{font-size:11px;opacity:.85;margin-top:3px}
.btn-group{display:flex;gap:8px;flex-wrap:wrap}
.btn{
    display:inline-flex;align-items:center;gap:5px;
    padding:7px 13px;border:none;border-radius:5px;
    cursor:pointer;font-size:11.5px;font-weight:600;
    transition:filter .15s,transform .1s;white-space:nowrap
}
.btn:hover{filter:brightness(1.09);transform:translateY(-1px)}
.btn:active{filter:brightness(.95)}
.btn-excel{background:#217346;color:#fff}
.btn-pdf{background:#c0392b;color:#fff}
.btn-print{background:#fff;color:#1a6fc4;border:1.5px solid #1a6fc4}

/* ── Summary Cards ── */
.summary-bar{
    display:flex;gap:10px;padding:14px 20px;
    background:#fff;border-bottom:1px solid #dde3ec;flex-wrap:wrap
}
.card{
    flex:1 1 120px;background:#f7faff;
    border:1px solid #cdd9ec;border-radius:8px;padding:10px 14px
}
.card .lbl{font-size:10px;color:#5a7094;text-transform:uppercase;letter-spacing:.4px}
.card .val{font-size:22px;font-weight:700;line-height:1.1;margin-top:3px}
.c-masuk  .val{color:#1a6fc4}
.c-keluar .val{color:#217346}
.c-rawat  .val{color:#856404}
.c-mening .val{color:#721c24}
.c-rujuk  .val{color:#5a2d82}

/* ── Rekap Bar ── */
.rekap-bar{
    padding:9px 20px 8px;background:#fff;
    border-bottom:1px solid #dde3ec;
    display:flex;flex-wrap:wrap;gap:7px;align-items:center
}
.rekap-bar strong{font-size:11px;margin-right:4px}
.ri{
    display:inline-flex;align-items:center;gap:4px;
    font-size:11px;padding:3px 10px;border-radius:12px;
    border:1px solid rgba(0,0,0,.1);font-weight:600
}

/* ── Content ── */
.content{padding:16px 20px;display:flex;flex-direction:column;gap:18px}
.section{background:#fff;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.1);overflow:hidden}
.section-header{
    padding:10px 16px;font-weight:700;font-size:12.5px;
    display:flex;align-items:center;gap:8px;color:#fff
}
.section-header.masuk {background:#1a6fc4}
.section-header.keluar{background:#217346}
.sh-badge{background:rgba(255,255,255,.22);padding:2px 9px;border-radius:10px;font-size:11px}

/* ── Table ── */
.table-wrap{overflow-x:auto}
table{width:100%;border-collapse:collapse;font-size:11.5px}
thead th{
    background:#e9f0fb;color:#1a2533;
    padding:8px 9px;text-align:center;
    font-weight:700;border:1px solid #cdd9ec;white-space:nowrap
}
thead th.sub{background:#f4f7fd;font-weight:600;font-size:10.5px}
tbody td{padding:7px 9px;border:1px solid #dde3ec;vertical-align:middle;text-align:center}
tbody tr:nth-child(even) td{background:#f9fbff}
tbody tr:hover td{background:#eaf2ff}
tfoot td{border:1px solid #cdd9ec}
.tdl{text-align:left!important}

/* ── Badges ── */
.stts{
    display:inline-block;padding:2px 9px;border-radius:4px;
    font-size:10.5px;font-weight:700;white-space:nowrap;
    border:1px solid rgba(0,0,0,.08)
}
.bya {background:#d4edda;color:#155724;font-size:10px;font-weight:700;padding:2px 7px;border-radius:4px}
.btdk{background:#f8d7da;color:#721c24;font-size:10px;font-weight:700;padding:2px 7px;border-radius:4px}

.no-data td{text-align:center;color:#8a9bbf;padding:22px;font-style:italic}

/* ── Footer ── */
.page-footer{text-align:center;color:#8a9bbf;font-size:10px;padding:12px 0 20px}

/* ── Print ── */
@media print{
    body{background:#fff;font-size:10px}
    .page-header,.section-header,.stts,.ri{-webkit-print-color-adjust:exact;print-color-adjust:exact}
    .btn-group{display:none}
    .section{box-shadow:none;border:1px solid #ccc;page-break-inside:avoid}
    .content{padding:8px}
}
</style>
</head>
<body>

<!-- ══ HEADER ══ -->
<div class="page-header">
    <div>
        <h1>&#x1F3E5; Sensus Harian Rawat Inap</h1>
        <p>
            Bangsal: <strong><?= htmlspecialchars(str_replace('_',' ',$kamar) ?: 'Semua') ?></strong>
            &nbsp;|&nbsp; Periode: <strong><?= $tgl1_fmt ?></strong> s.d. <strong><?= $tgl2_fmt ?></strong>
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
    <div class="card c-masuk">
        <div class="lbl">Pasien Masuk</div>
        <div class="val"><?= $totalMasuk ?></div>
    </div>
    <div class="card c-keluar">
        <div class="lbl">Pasien Keluar</div>
        <div class="val"><?= $totalKeluar ?></div>
    </div>
    <div class="card c-rawat">
        <div class="lbl">Masih Dirawat</div>
        <div class="val"><?= $jmlDirawat ?></div>
    </div>
    <div class="card c-mening">
        <div class="lbl">Meninggal</div>
        <div class="val"><?= $jmlMeninggal ?></div>
    </div>
    <div class="card c-rujuk">
        <div class="lbl">Dirujuk Keluar</div>
        <div class="val"><?= $jmlRujuk ?></div>
    </div>
    <div class="card">
        <div class="lbl">Dicetak</div>
        <div class="val" style="font-size:13px"><?= date('d/m/Y H:i') ?></div>
    </div>
</div>

<!-- ══ REKAP STATUS KELUAR ══ -->
<?php if (!empty($rekapStatus)): ?>
<div class="rekap-bar" id="rekapBar">
    <strong>Rekap Status Keluar:</strong>
    <?php foreach ($rekapStatus as $st => $jml):
        $b = statusBadge($st);
    ?>
    <span class="ri" style="background:<?= $b['bg'] ?>;color:<?= $b['color'] ?>">
        <?= htmlspecialchars($b['label']) ?> <span>(<?= $jml ?>)</span>
    </span>
    <?php endforeach; ?>
</div>
<?php endif; ?>

<!-- ══ CONTENT ══ -->
<div class="content">

    <!-- ─── TABEL PASIEN MASUK ─── -->
    <div class="section">
        <div class="section-header masuk">
            &#x2B06; Pasien Masuk
            <span class="sh-badge"><?= $totalMasuk ?> pasien</span>
        </div>
        <div class="table-wrap">
            <table id="tblMasuk">
                <thead>
                    <tr>
                        <th rowspan="2" style="width:32px">No</th>
                        <th rowspan="2">No. RM</th>
                        <th rowspan="2">Nama Pasien</th>
                        <th colspan="2">Rujukan Masuk</th>
                        <th rowspan="2">Kelas</th>
                        <th rowspan="2">Kamar</th>
                        <th rowspan="2">Jaminan</th>
                        <th rowspan="2">Tgl Masuk</th>
                        <th rowspan="2">Jam</th>
                        <th rowspan="2">Status Keluar</th>
                        <th rowspan="2">Dokter P.J.</th>
                    </tr>
                    <tr>
                        <th class="sub">Ya</th>
                        <th class="sub">Tidak</th>
                    </tr>
                </thead>
                <tbody>
<?php if (empty($rowsMasuk)): ?>
                    <tr class="no-data"><td colspan="12">Tidak ada data pasien masuk pada periode ini.</td></tr>
<?php else: $no=1; foreach ($rowsMasuk as $r):
    $isRujuk  = ($r['rujuk_masuk'] === 'Ya');
    $tglMFmt  = date('d/m/Y', strtotime($r['tgl_masuk']));
    $jamM     = substr($r['jam_masuk'] ?? '', 0, 5);
    $badge    = statusBadge($r['stts_pulang'] ?? '');
?>
                    <tr>
                        <td><?= $no++ ?></td>
                        <td><?= htmlspecialchars($r['no_rkm_medis']) ?></td>
                        <td class="tdl"><?= htmlspecialchars($r['nm_pasien']) ?></td>
                        <td><?= $isRujuk  ? '<span class="bya">Ya</span>'  : '' ?></td>
                        <td><?= !$isRujuk ? '<span class="btdk">Tdk</span>': '' ?></td>
                        <td><?= htmlspecialchars($r['kelas']) ?></td>
                        <td><?= htmlspecialchars($r['kd_kamar']) ?></td>
                        <td><?= htmlspecialchars($r['png_jawab']) ?></td>
                        <td><?= $tglMFmt ?></td>
                        <td><?= $jamM ?></td>
                        <td>
                            <span class="stts" style="background:<?= $badge['bg'] ?>;color:<?= $badge['color'] ?>">
                                <?= htmlspecialchars($badge['label']) ?>
                            </span>
                        </td>
                        <td class="tdl"><?= htmlspecialchars($r['nm_dokter']) ?></td>
                    </tr>
<?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>

    <!-- ─── TABEL PASIEN KELUAR ─── -->
    <div class="section">
        <div class="section-header keluar">
            &#x2B07; Pasien Keluar
            <span class="sh-badge"><?= $totalKeluar ?> pasien</span>
        </div>
        <div class="table-wrap">
            <table id="tblKeluar">
                <thead>
                    <tr>
                        <th rowspan="2" style="width:32px">No</th>
                        <th rowspan="2">No. RM</th>
                        <th rowspan="2">Nama Pasien</th>
                        <th colspan="2">Rujukan Masuk</th>
                        <th rowspan="2">Kelas</th>
                        <th rowspan="2">Kamar</th>
                        <th rowspan="2">Jaminan</th>
                        <th rowspan="2">Tgl Masuk</th>
                        <th rowspan="2">Tgl Keluar</th>
                        <th rowspan="2">Lama<br>(hari)</th>
                        <th rowspan="2">Status Keluar</th>
                        <th rowspan="2">Dokter P.J.</th>
                    </tr>
                    <tr>
                        <th class="sub">Ya</th>
                        <th class="sub">Tidak</th>
                    </tr>
                </thead>
                <tbody>
<?php if (empty($rowsKeluar)): ?>
                    <tr class="no-data"><td colspan="13">Tidak ada data pasien keluar pada periode ini.</td></tr>
<?php else: $no=1; foreach ($rowsKeluar as $r):
    $isRujuk  = ($r['rujuk_masuk'] === 'Ya');
    $tglMFmt  = date('d/m/Y', strtotime($r['tgl_masuk']));
    $tglKFmt  = date('d/m/Y', strtotime($r['tgl_keluar']));
    $lama     = is_numeric($r['lama']) ? $r['lama'] : '-';
    $badge    = statusBadge($r['stts_pulang'] ?? '');
?>
                    <tr>
                        <td><?= $no++ ?></td>
                        <td><?= htmlspecialchars($r['no_rkm_medis']) ?></td>
                        <td class="tdl"><?= htmlspecialchars($r['nm_pasien']) ?></td>
                        <td><?= $isRujuk  ? '<span class="bya">Ya</span>'  : '' ?></td>
                        <td><?= !$isRujuk ? '<span class="btdk">Tdk</span>': '' ?></td>
                        <td><?= htmlspecialchars($r['kelas']) ?></td>
                        <td><?= htmlspecialchars($r['kd_kamar']) ?></td>
                        <td><?= htmlspecialchars($r['png_jawab']) ?></td>
                        <td><?= $tglMFmt ?></td>
                        <td><?= $tglKFmt ?></td>
                        <td><strong><?= $lama ?></strong></td>
                        <td>
                            <span class="stts" style="background:<?= $badge['bg'] ?>;color:<?= $badge['color'] ?>">
                                <?= htmlspecialchars($badge['label']) ?>
                            </span>
                        </td>
                        <td class="tdl"><?= htmlspecialchars($r['nm_dokter']) ?></td>
                    </tr>
<?php endforeach; endif; ?>
                </tbody>
                <?php if (!empty($rekapStatus)): ?>
                <tfoot>
                    <tr>
                        <td colspan="13" style="padding:8px 12px;background:#f4f7fd;text-align:left;font-size:11px;border-top:2px solid #cdd9ec">
                            <strong>Rekap Status Keluar —</strong>&nbsp;
                            <?php foreach ($rekapStatus as $st => $jml):
                                $b = statusBadge($st);
                            ?>
                            <span style="display:inline-block;margin:2px 3px;padding:2px 9px;border-radius:4px;
                                  background:<?= $b['bg'] ?>;color:<?= $b['color'] ?>;
                                  border:1px solid rgba(0,0,0,.08);font-size:10.5px;font-weight:700">
                                <?= htmlspecialchars($b['label']) ?>: <?= $jml ?>
                            </span>
                            <?php endforeach; ?>
                        </td>
                    </tr>
                </tfoot>
                <?php endif; ?>
            </table>
        </div>
    </div>

</div><!-- /content -->
<div class="page-footer">Dicetak menggunakan SIMRS Khanza &mdash; <?= date('d/m/Y H:i:s') ?></div>

<!-- ══ JAVASCRIPT ══ -->
<script>
const INFO = {
    bangsal : "<?= htmlspecialchars(str_replace('_',' ',$kamar) ?: 'Semua') ?>",
    periode : "<?= $tgl1_fmt ?> s.d. <?= $tgl2_fmt ?>",
    cetak   : "<?= date('d/m/Y H:i') ?>"
};

/* ── Helpers ── */
function slug() {
    return INFO.periode.replace(/ /g,'').replace(/\//g,'-');
}
function rowsFromTable(id) {
    const out = [];
    document.querySelectorAll(`#${id} tbody tr`).forEach(tr => {
        const cells = tr.querySelectorAll('td');
        if (cells.length < 2) return;
        out.push(Array.from(cells).map(c => c.innerText.trim()));
    });
    return out;
}
function rekapRows() {
    const out = [['Status Keluar','Jumlah']];
    document.querySelectorAll('#rekapBar .ri').forEach(el => {
        const m = el.innerText.trim().match(/^(.+?)\s*\((\d+)\)$/);
        if (m) out.push([m[1].trim(), +m[2]]);
    });
    return out;
}

/* ══ EXPORT EXCEL ══ */
function exportExcel() {
    const wb = XLSX.utils.book_new();

    /* Sheet 1 – Pasien Masuk */
    (function() {
        const aoa = [
            ['SENSUS HARIAN RAWAT INAP \u2013 PASIEN MASUK'],
            ['Bangsal: '+INFO.bangsal],['Periode: '+INFO.periode],['Dicetak: '+INFO.cetak],[],
            ['No','No. RM','Nama Pasien','Rujukan Masuk Ya','Rujukan Masuk Tidak',
             'Kelas','Kamar','Jaminan','Tgl Masuk','Jam Masuk','Status Keluar','Dokter P.J.'],
            ...rowsFromTable('tblMasuk')
        ];
        const ws = XLSX.utils.aoa_to_sheet(aoa);
        ws['!cols'] = [4,13,32,12,12,7,10,18,12,7,22,30].map(w=>({wch:w}));
        ws['!merges'] = [{s:{r:0,c:0},e:{r:0,c:11}}];
        XLSX.utils.book_append_sheet(wb, ws, 'Pasien Masuk');
    })();

    /* Sheet 2 – Pasien Keluar */
    (function() {
        const aoa = [
            ['SENSUS HARIAN RAWAT INAP \u2013 PASIEN KELUAR'],
            ['Bangsal: '+INFO.bangsal],['Periode: '+INFO.periode],['Dicetak: '+INFO.cetak],[],
            ['No','No. RM','Nama Pasien','Rujukan Masuk Ya','Rujukan Masuk Tidak',
             'Kelas','Kamar','Jaminan','Tgl Masuk','Tgl Keluar','Lama (hari)','Status Keluar','Dokter P.J.'],
            ...rowsFromTable('tblKeluar')
        ];
        const ws = XLSX.utils.aoa_to_sheet(aoa);
        ws['!cols'] = [4,13,32,12,12,7,10,18,12,12,8,22,30].map(w=>({wch:w}));
        ws['!merges'] = [{s:{r:0,c:0},e:{r:0,c:12}}];
        XLSX.utils.book_append_sheet(wb, ws, 'Pasien Keluar');
    })();

    /* Sheet 3 – Rekap Status */
    (function() {
        const aoa = [
            ['REKAP STATUS KELUAR'],
            ['Bangsal: '+INFO.bangsal+'   |   Periode: '+INFO.periode],[],
            ...rekapRows()
        ];
        const ws = XLSX.utils.aoa_to_sheet(aoa);
        ws['!cols'] = [{wch:28},{wch:12}];
        ws['!merges'] = [{s:{r:0,c:0},e:{r:0,c:1}},{s:{r:1,c:0},e:{r:1,c:1}}];
        XLSX.utils.book_append_sheet(wb, ws, 'Rekap Status');
    })();

    XLSX.writeFile(wb, `SensusHarian_${slug()}.xlsx`);
}

/* ══ EXPORT PDF ══ */
function exportPDF() {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF({ orientation:'landscape', unit:'mm', format:'a4' });
    const W   = 277;

    function pageHeader(label, rgb) {
        doc.setFillColor(...rgb);
        doc.rect(10, 8, W, 11, 'F');
        doc.setTextColor(255,255,255);
        doc.setFontSize(10.5); doc.setFont('helvetica','bold');
        doc.text(label, 148.5, 15.5, {align:'center'});
        doc.setTextColor(80,80,80);
        doc.setFontSize(8); doc.setFont('helvetica','normal');
        doc.text(`Bangsal: ${INFO.bangsal}   |   Periode: ${INFO.periode}   |   Dicetak: ${INFO.cetak}`,
                 148.5, 24, {align:'center'});
    }

    /* ── Hal 1: Pasien Masuk ── */
    pageHeader('SENSUS HARIAN RAWAT INAP \u2013 PASIEN MASUK', [26,111,196]);
    doc.autoTable({
        startY: 28,
        head: [['No','No. RM','Nama Pasien','Ruj.\nYa','Ruj.\nTdk',
                'Kls','Kamar','Jaminan','Tgl Masuk','Jam','Status Keluar','Dokter P.J.']],
        body: rowsFromTable('tblMasuk').length
              ? rowsFromTable('tblMasuk')
              : [Array(12).fill('')],
        styles:      { fontSize:7, cellPadding:1.8, halign:'center', valign:'middle', overflow:'linebreak' },
        headStyles:  { fillColor:[26,111,196], textColor:255, fontStyle:'bold', halign:'center' },
        columnStyles:{
            0:{cellWidth:7},  1:{cellWidth:18},
            2:{cellWidth:36, halign:'left'},
            10:{cellWidth:24},11:{cellWidth:30, halign:'left'}
        },
        alternateRowStyles:{ fillColor:[234,242,255] },
        margin:{left:10,right:10}, tableWidth:W
    });

    /* ── Hal 2: Pasien Keluar ── */
    doc.addPage();
    pageHeader('SENSUS HARIAN RAWAT INAP \u2013 PASIEN KELUAR', [33,115,70]);
    doc.autoTable({
        startY: 28,
        head: [['No','No. RM','Nama Pasien','Ruj.\nYa','Ruj.\nTdk',
                'Kls','Kamar','Jaminan','Tgl Masuk','Tgl Keluar','Lama\n(hr)','Status Keluar','Dokter P.J.']],
        body: rowsFromTable('tblKeluar').length
              ? rowsFromTable('tblKeluar')
              : [Array(13).fill('')],
        styles:      { fontSize:7, cellPadding:1.8, halign:'center', valign:'middle', overflow:'linebreak' },
        headStyles:  { fillColor:[33,115,70], textColor:255, fontStyle:'bold', halign:'center' },
        columnStyles:{
            0:{cellWidth:7},  1:{cellWidth:17},
            2:{cellWidth:34, halign:'left'},
            11:{cellWidth:22},12:{cellWidth:28, halign:'left'}
        },
        alternateRowStyles:{ fillColor:[234,255,240] },
        margin:{left:10,right:10}, tableWidth:W
    });

    /* Rekap status di bawah tabel keluar */
    const rekapY = (doc.lastAutoTable.finalY ?? 150) + 8;
    if (rekapY < 190) {
        const rkRows = rekapRows().slice(1); // skip header row
        const rkText = rkRows.map(r => `${r[0]}: ${r[1]}`).join('   |   ');
        doc.setFontSize(7.5); doc.setFont('helvetica','bold'); doc.setTextColor(30,30,30);
        doc.text('Rekap Status Keluar:  ' + rkText, 148.5, rekapY,
                 {align:'center', maxWidth: W});
    }

    /* Nomor halaman */
    const total = doc.internal.getNumberOfPages();
    for (let i = 1; i <= total; i++) {
        doc.setPage(i);
        doc.setFontSize(7.5); doc.setTextColor(160);
        doc.text(`Halaman ${i} dari ${total}`, 148.5, 205, {align:'center'});
    }

    doc.save(`SensusHarian_${slug()}.pdf`);
}
</script>
</body>
</html>
