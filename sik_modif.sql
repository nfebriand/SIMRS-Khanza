SET FOREIGN_KEY_CHECKS=0;

CREATE TABLE IF NOT EXISTS `antrifotokelahiranbayismc`  (
  `no_rkm_medis` varchar(15) NOT NULL,
  PRIMARY KEY (`no_rkm_medis`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `antriloketcetak_smc`  (
  `nomor` varchar(6) NOT NULL,
  `tanggal` date NOT NULL,
  `jam` time NULL DEFAULT NULL,
  `jam_panggil` time NULL DEFAULT NULL,
  `no_rawat` varchar(17) NULL DEFAULT NULL,
  `no_rkm_medis` varchar(15) NULL DEFAULT NULL,
  PRIMARY KEY (`tanggal`, `nomor`) USING BTREE,
  INDEX `antriloketcetak_smc_jam_IDX`(`jam`) USING BTREE,
  INDEX `antriloketcetak_smc_tanggal_IDX`(`tanggal`) USING BTREE,
  INDEX `antriloketcetak_smc_no_rawat_IDX`(`no_rawat`) USING BTREE,
  INDEX `antriloketcetak_smc_no_rkm_medis_IDX`(`no_rkm_medis`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `antriloketfarmasi_smc`  (
  `nomor` varchar(6) NOT NULL,
  `tanggal` date NOT NULL,
  `jam` time NULL DEFAULT NULL,
  `jam_panggil` time NULL DEFAULT NULL,
  `no_resep` varchar(14) NULL DEFAULT NULL,
  PRIMARY KEY (`tanggal`, `nomor`) USING BTREE,
  INDEX `antriloketfarmasi_smc_jam_IDX`(`jam`) USING BTREE,
  INDEX `antriloketfarmasi_smc_tanggal_IDX`(`tanggal`) USING BTREE,
  INDEX `antriloketfarmasi_smc_no_resep_IDX`(`no_resep`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `antriloketsmc`  (
  `loket` int(11) NOT NULL,
  `antrian` varchar(6) NOT NULL,
  INDEX `loket`(`loket`) USING BTREE,
  INDEX `antrian`(`antrian`) USING BTREE
) ENGINE = MyISAM CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `antripintu_smc`  (
  `kd_pintu` varchar(20) NOT NULL DEFAULT '',
  `no_rawat` varchar(17) NOT NULL,
  `status` enum('0','1','2') NOT NULL
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;


ALTER TABLE `asuhan_gizi` ADD COLUMN IF NOT EXISTS `alergi_ayam` enum('Ya','Tidak') NULL DEFAULT NULL AFTER `nip`;

ALTER TABLE `bayar_piutang` MODIFY COLUMN IF EXISTS `no_rawat` varchar(40) NOT NULL AFTER `catatan`;

ALTER TABLE `billing` DROP INDEX IF EXISTS `noindex`;

ALTER TABLE `booking_operasi` ADD COLUMN IF NOT EXISTS `catatan` varchar(500) NULL DEFAULT NULL AFTER `kd_ruang_ok`;

ALTER TABLE `booking_operasi` ADD INDEX IF NOT EXISTS `booking_operasi_catatan_IDX`(`catatan`) USING BTREE;

ALTER TABLE `booking_registrasi` ADD COLUMN IF NOT EXISTS `no_rawat` varchar(17) NULL DEFAULT NULL AFTER `status`;

ALTER TABLE `booking_registrasi` MODIFY COLUMN IF EXISTS `kd_dokter` varchar(20) NOT NULL AFTER `tanggal_periksa`;

ALTER TABLE `booking_registrasi` MODIFY COLUMN IF EXISTS `status` enum('Terdaftar','Belum','Batal','Dokter Berhalangan','Checkin') NULL DEFAULT NULL AFTER `waktu_kunjungan`;

ALTER TABLE `booking_registrasi` ADD INDEX IF NOT EXISTS `tanggal_booking`(`tanggal_booking`) USING BTREE;

ALTER TABLE `booking_registrasi` ADD INDEX IF NOT EXISTS `tanggal_periksa`(`tanggal_periksa`) USING BTREE;

ALTER TABLE `booking_registrasi` ADD INDEX IF NOT EXISTS `no_rawat`(`no_rawat`) USING BTREE;

CREATE TABLE IF NOT EXISTS `bridging_apotek_bpjs`  (
  `no_sjp` varchar(40) NOT NULL,
  `no_sep` varchar(40) NOT NULL,
  `no_resep` varchar(5) NOT NULL,
  `tgl_resep` datetime NOT NULL,
  `tgl_pelayanan` datetime NOT NULL,
  `jenis_obat` enum('1','2','3') NOT NULL,
  `iterasi` enum('0','1','2') NOT NULL,
  `kd_poli` varchar(10) NULL DEFAULT NULL,
  `nm_poli` varchar(100) NULL DEFAULT NULL,
  `kodedpjp` varchar(10) NULL DEFAULT NULL,
  `nmdpjp` varchar(100) NULL DEFAULT NULL,
  `user` varchar(25) NULL DEFAULT NULL,
  PRIMARY KEY (`no_sjp`) USING BTREE,
  INDEX `no_sep`(`no_sep`) USING BTREE,
  INDEX `no_resep`(`no_resep`) USING BTREE,
  CONSTRAINT `bridging_apotek_bpjs_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `bridging_sep` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `bridging_apotek_bpjs_obat`  (
  `no_sjp` varchar(40) NOT NULL,
  `kode_brng_apotek_bpjs` varchar(15) NOT NULL,
  `nama_brng_apotek_bpjs` varchar(200) NULL DEFAULT NULL,
  `jumlah` double NOT NULL,
  `signa1` double NOT NULL,
  `signa2` double NOT NULL,
  `jml_hari` double NOT NULL,
  `harga` double NOT NULL,
  `subtotal` double NOT NULL,
  `kandungan` varchar(10) NULL DEFAULT NULL,
  `no_racik` varchar(2) NULL DEFAULT NULL,
  PRIMARY KEY (`no_sjp`, `kode_brng_apotek_bpjs`) USING BTREE,
  INDEX `no_racik`(`no_racik`) USING BTREE,
  CONSTRAINT `bridging_apotek_bpjs_obat_ibfk_1` FOREIGN KEY (`no_sjp`) REFERENCES `bridging_apotek_bpjs` (`no_sjp`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `bridging_apotek_bpjs_racikan`  (
  `no_sjp` varchar(40) NOT NULL,
  `nama_racik` varchar(100) NOT NULL,
  `kd_racik` varchar(3) NOT NULL,
  `jml_dr` int(11) NOT NULL,
  `aturan_pakai` varchar(150) NOT NULL,
  `keterangan` varchar(50) NOT NULL,
  `no_racik` varchar(2) NOT NULL,
  PRIMARY KEY (`no_sjp`, `no_racik`) USING BTREE,
  INDEX `kd_racik`(`kd_racik`) USING BTREE,
  CONSTRAINT `bridging_apotek_bpjs_racikan_ibfk_1` FOREIGN KEY (`no_sjp`) REFERENCES `bridging_apotek_bpjs` (`no_sjp`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bridging_apotek_bpjs_racikan_ibfk_2` FOREIGN KEY (`kd_racik`) REFERENCES `metode_racik` (`kd_racik`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `bridging_resep_apotek_bpjs_nonracikan` DROP FOREIGN KEY IF EXISTS `bridging_resep_apotek_bpjs_nonracikan_ibfk_2`;

ALTER TABLE `bridging_resep_apotek_bpjs_nonracikan` DROP FOREIGN KEY IF EXISTS `bridging_resep_apotek_bpjs_nonracikan_ibfk_3`;

ALTER TABLE `bridging_resep_apotek_bpjs_racikan` DROP FOREIGN KEY IF EXISTS `bridging_resep_apotek_bpjs_racikan_ibfk_2`;

ALTER TABLE `bridging_resep_apotek_bpjs_racikan` DROP FOREIGN KEY IF EXISTS `bridging_resep_apotek_bpjs_racikan_ibfk_3`;

ALTER TABLE `bridging_sep` ADD INDEX IF NOT EXISTS `bridging_sep_ibfk_2`(`tglsep`) USING BTREE;

ALTER TABLE `bridging_sep` ADD INDEX IF NOT EXISTS `bridging_sep_ibfk_3`(`jnspelayanan`) USING BTREE;

ALTER TABLE `bridging_sep` ADD INDEX IF NOT EXISTS `bridging_sep_ibfk_4`(`kddpjp`) USING BTREE;

ALTER TABLE `bridging_sep` ADD INDEX IF NOT EXISTS `bridging_sep_ibfk_5`(`tglsep`, `no_sep`) USING BTREE;

ALTER TABLE `bridging_surat_kontrol_bpjs` MODIFY COLUMN IF EXISTS `nm_dokter_bpjs` varchar(100) NULL DEFAULT NULL AFTER `kd_dokter_bpjs`;

CREATE TABLE IF NOT EXISTS `bridging_sep_manual`  (
  `no_sep` varchar(40) NOT NULL,
  `tgl_simpan` datetime NOT NULL,
  PRIMARY KEY (`no_sep`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `catatan_cairan_hemodialisa` ADD COLUMN IF NOT EXISTS `ttl_input` varchar(10) NULL DEFAULT '0' AFTER `nip`;

ALTER TABLE `catatan_cairan_hemodialisa` ADD COLUMN IF NOT EXISTS `ufg` varchar(10) NULL DEFAULT '0' AFTER `ttl_input`;

ALTER TABLE `catatan_cairan_hemodialisa` ADD COLUMN IF NOT EXISTS `ttl_output` varchar(10) NULL DEFAULT '0' AFTER `ufg`;

ALTER TABLE `catatan_cairan_hemodialisa` ADD COLUMN IF NOT EXISTS `balance` varchar(10) NULL DEFAULT '0' AFTER `ttl_output`;

ALTER TABLE `catatan_keseimbangan_cairan` MODIFY COLUMN IF EXISTS `infus` double NOT NULL DEFAULT 0 AFTER `jam_rawat`;

ALTER TABLE `catatan_keseimbangan_cairan` MODIFY COLUMN IF EXISTS `tranfusi` double NOT NULL DEFAULT 0 AFTER `infus`;

ALTER TABLE `catatan_keseimbangan_cairan` MODIFY COLUMN IF EXISTS `minum` double NOT NULL DEFAULT 0 AFTER `tranfusi`;

ALTER TABLE `catatan_keseimbangan_cairan` MODIFY COLUMN IF EXISTS `urine` double NOT NULL DEFAULT 0 AFTER `minum`;

ALTER TABLE `catatan_keseimbangan_cairan` MODIFY COLUMN IF EXISTS `drain` double NOT NULL DEFAULT 0 AFTER `urine`;

ALTER TABLE `catatan_keseimbangan_cairan` MODIFY COLUMN IF EXISTS `ngt` double NOT NULL DEFAULT 0 AFTER `drain`;

ALTER TABLE `catatan_keseimbangan_cairan` MODIFY COLUMN IF EXISTS `iwl` double NOT NULL DEFAULT 0 AFTER `ngt`;

ALTER TABLE `catatan_keseimbangan_cairan` MODIFY COLUMN IF EXISTS `keseimbangan` double NOT NULL DEFAULT 0 AFTER `iwl`;

ALTER TABLE `catatan_observasi_hemodialisa` ADD COLUMN IF NOT EXISTS `rr` varchar(10) NULL DEFAULT NULL AFTER `nip`;

ALTER TABLE `catatan_observasi_hemodialisa` ADD COLUMN IF NOT EXISTS `ufv` varchar(10) NULL DEFAULT NULL AFTER `rr`;

ALTER TABLE `dapuropname` MODIFY COLUMN IF EXISTS `stok` double NOT NULL AFTER `tanggal`;

ALTER TABLE `dapuropname` MODIFY COLUMN IF EXISTS `real` double NOT NULL AFTER `stok`;

ALTER TABLE `dapuropname` MODIFY COLUMN IF EXISTS `selisih` double NOT NULL AFTER `real`;

ALTER TABLE `dapuropname` MODIFY COLUMN IF EXISTS `lebih` double NOT NULL AFTER `nomihilang`;

ALTER TABLE `dapursuplier` MODIFY COLUMN IF EXISTS `alamat` varchar(100) NULL DEFAULT NULL AFTER `nama_suplier`;

ALTER TABLE `dapursuplier` MODIFY COLUMN IF EXISTS `kota` varchar(50) NULL DEFAULT NULL AFTER `alamat`;

ALTER TABLE `dapursuplier` MODIFY COLUMN IF EXISTS `no_telp` varchar(20) NULL DEFAULT NULL AFTER `kota`;

ALTER TABLE `dapursuplier` MODIFY COLUMN IF EXISTS `nama_bank` varchar(50) NULL DEFAULT NULL AFTER `no_telp`;

ALTER TABLE `datasuplier` MODIFY COLUMN IF EXISTS `alamat` varchar(100) NULL DEFAULT NULL AFTER `nama_suplier`;

ALTER TABLE `datasuplier` MODIFY COLUMN IF EXISTS `kota` varchar(50) NULL DEFAULT NULL AFTER `alamat`;

ALTER TABLE `datasuplier` MODIFY COLUMN IF EXISTS `no_telp` varchar(20) NULL DEFAULT NULL AFTER `kota`;

ALTER TABLE `datasuplier` MODIFY COLUMN IF EXISTS `nama_bank` varchar(50) NULL DEFAULT NULL AFTER `no_telp`;

ALTER TABLE `detail_nota_inap` ADD COLUMN IF NOT EXISTS `keterangan` varchar(40) NULL DEFAULT NULL AFTER `besar_bayar`;

ALTER TABLE `detail_nota_jalan` ADD COLUMN IF NOT EXISTS `keterangan` varchar(40) NULL DEFAULT NULL AFTER `besar_bayar`;

ALTER TABLE `detailpiutang` ADD COLUMN IF NOT EXISTS `no_racik` varchar(2) NULL DEFAULT NULL AFTER `aturan_pakai`;

ALTER TABLE `detailpiutang` ADD PRIMARY KEY IF NOT EXISTS (`nota_piutang`, `kode_brng`) USING BTREE;

ALTER TABLE `detailpiutang` DROP CONSTRAINT IF EXISTS `detailpiutang_ibfk_1`;

ALTER TABLE `detailpiutang` MODIFY COLUMN IF EXISTS `nota_piutang` varchar(40) NOT NULL FIRST;

ALTER TABLE `detail_pemberian_obat` ADD COLUMN IF NOT EXISTS `tgl_kadaluarsa` date NULL DEFAULT NULL after `no_faktur`;

CREATE TABLE IF NOT EXISTS `detail_pemberian_obat_selanjutnya`  (
  `tgl_perawatan` date NOT NULL,
  `jam` time NOT NULL,
  `no_rkm_medis` varchar(17) NOT NULL,
  `kode_brng` varchar(15) NOT NULL,
  `tgl_pemberian_selanjutnya` date NULL DEFAULT NULL,
  `total_hari` varchar(100) NULL DEFAULT NULL,
  PRIMARY KEY (`tgl_perawatan`, `jam`, `no_rkm_medis`, `kode_brng`) USING BTREE,
  INDEX `detail_pemberian_obat_selanjutnya_databarang_FK`(`kode_brng`) USING BTREE,
  INDEX `detail_pemberian_obat_selanjutnya_pasien_FK`(`no_rkm_medis`) USING BTREE,
  CONSTRAINT `detail_pemberian_obat_selanjutnya_databarang_FK` FOREIGN KEY (`kode_brng`) REFERENCES `databarang` (`kode_brng`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `detail_pemberian_obat_selanjutnya_pasien_FK` FOREIGN KEY (`no_rkm_medis`) REFERENCES `pasien` (`no_rkm_medis`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `detail_penagihan_piutang` ADD COLUMN IF NOT EXISTS `diskon` double NULL DEFAULT NULL AFTER `sisapiutang`;

ALTER TABLE `detail_pengeluaran_obat_bhp` DROP FOREIGN KEY IF EXISTS `detail_pengeluaran_obat_bhp_ibfk_3`;

ALTER TABLE `detail_pengeluaran_obat_bhp` ADD CONSTRAINT `detail_pengeluaran_obat_bhp_ibfk_3` FOREIGN KEY IF NOT EXISTS (`kode_brng`) REFERENCES `databarang` (`kode_brng`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `detail_periksa_lab` DROP INDEX IF EXISTS `nilai`;

ALTER TABLE `detail_periksa_lab` MODIFY COLUMN IF EXISTS `nilai` varchar(700) NOT NULL AFTER `id_template`;

ALTER TABLE `detail_periksa_lab` MODIFY COLUMN IF EXISTS `nilai_rujukan` varchar(700) NOT NULL AFTER `nilai`;

ALTER TABLE `detail_piutang_pasien` ADD INDEX IF NOT EXISTS `detail_piutang_pasien_ibfk_1`(`kd_pj`, `sisapiutang`) USING BTREE;

ALTER TABLE `detailjurnal` ADD INDEX IF NOT EXISTS `detailjurnal_no_jurnal_kd_rek_idx`(`no_jurnal`, `kd_rek`) USING BTREE;

ALTER TABLE `dokter` MODIFY COLUMN IF EXISTS `nm_dokter` varchar(80) NULL DEFAULT NULL AFTER `kd_dokter`;

ALTER TABLE `dokter` MODIFY COLUMN IF EXISTS `almt_tgl` varchar(100) NULL DEFAULT NULL AFTER `agama`;

CREATE TABLE IF NOT EXISTS `dokter_ttdbasah`  (
  `kd_dokter` varchar(20) NOT NULL,
  `gambar_ttd` longblob NULL DEFAULT NULL,
  PRIMARY KEY (`kd_dokter`) USING BTREE,
  CONSTRAINT `dokter_ttdbasah_ibfk_1` FOREIGN KEY (`kd_dokter`) REFERENCES `dokter` (`kd_dokter`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `emergency_index` MODIFY COLUMN IF EXISTS `nama_emergency` varchar(200) NULL DEFAULT NULL AFTER `kode_emergency`;

CREATE TABLE IF NOT EXISTS `idrg_diagnosa_pasien_smc`  (
  `no_sep` varchar(40) NOT NULL,
  `kode_icd10` varchar(7) NOT NULL,
  `urut` int(10) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`no_sep`, `kode_icd10`) USING BTREE,
  INDEX `idrg_dx_smc_icd10_im`(`kode_icd10`) USING BTREE,
  CONSTRAINT `idrg_diagnosa_pasien_smc_ibfk_1` FOREIGN KEY (`kode_icd10`) REFERENCES `idrg_referensi_icd10_smc` (`code1`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `idrg_dx_smc_no_sep` FOREIGN KEY (`no_sep`) REFERENCES `bridging_sep` (`no_sep`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `idrg_grouping_smc`  (
  `no_sep` varchar(40) NOT NULL,
  `mdc_number` varchar(4) NOT NULL,
  `mdc_description` varchar(150) NULL DEFAULT NULL,
  `drg_code` varchar(10) NOT NULL,
  `drg_description` varchar(250) NULL DEFAULT NULL,
  `kelas_rs` varchar(3) DEFAULT NULL,
  `cost_weight` double DEFAULT NULL,
  `sub_acute_weight` double DEFAULT NULL,
  `chronic_weight` double DEFAULT NULL,
  `total_cost_weight` double DEFAULT NULL,
  `nbr` double DEFAULT NULL,
  `topup_weight` double DEFAULT NULL,
  `top_up` enum('Tidak Ada','Belum','Sudah') NOT NULL DEFAULT 'Tidak Ada',
  PRIMARY KEY (`no_sep`) USING BTREE,
  CONSTRAINT `idrg_grouping_smc_bridging_sep_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `inacbg_klaim_baru2` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `idrg_grouping_topup_smc`  (
  `no_sep` varchar(40) NOT NULL,
  `code` varchar(10) NOT NULL,
  `description` varchar(100) NULL DEFAULT NULL,
  `type` varchar(50) NULL DEFAULT NULL,
  `weight` double NOT NULL DEFAULT 0,
  PRIMARY KEY (`no_sep`, `code`) USING BTREE,
  CONSTRAINT `idrg_grouping_topup_smc_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `idrg_grouping_smc` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `idrg_klaim_final_smc`  (
  `no_sep` varchar(40) NOT NULL,
  `nik` varchar(30) NOT NULL,
  PRIMARY KEY (`no_sep`) USING BTREE,
  CONSTRAINT `idrg_klaim_final_smc_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `idrg_grouping_smc` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `idrg_prosedur_pasien_smc`  (
  `no_sep` varchar(40) NOT NULL,
  `kode_icd9` varchar(7) NOT NULL,
  `multiplicity` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `urut` int(10) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`no_sep`, `kode_icd9`, `urut`) USING BTREE,
  INDEX `idrg_pc_smc_icd9cm_im`(`kode_icd9`) USING BTREE,
  CONSTRAINT `idrg_pc_smc_no_sep` FOREIGN KEY (`no_sep`) REFERENCES `bridging_sep` (`no_sep`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `idrg_referensi_icd9cm_smc`  (
  `code1` varchar(7) NOT NULL,
  `code2` varchar(7) NOT NULL DEFAULT '',
  `deskripsi` varchar(300) NOT NULL DEFAULT '',
  `validcode` enum('0','1') NOT NULL DEFAULT '0',
  `im` enum('0','1') NOT NULL DEFAULT '0',
  PRIMARY KEY (`code1`) USING BTREE,
  INDEX `eklaim_icd9cm_smc_ibfk_1`(`code1`, `deskripsi`) USING BTREE,
  INDEX `eklaim_icd9cm_smc_ibfk_2`(`validcode`, `im`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `idrg_referensi_icd10_smc`  (
  `code1` varchar(7) NOT NULL,
  `code2` varchar(7) NOT NULL DEFAULT '',
  `deskripsi` varchar(300) NOT NULL DEFAULT '',
  `validcode` enum('0','1') NOT NULL DEFAULT '0',
  `accpdx` enum('Y','N') NOT NULL DEFAULT 'N',
  `asterisk` enum('0','1') NOT NULL DEFAULT '0',
  `im` enum('0','1') NOT NULL DEFAULT '0',
  PRIMARY KEY (`code1`) USING BTREE,
  INDEX `eklaim_icd10_smc_ibfk_1`(`code1`, `deskripsi`) USING BTREE,
  INDEX `eklaim_icd10_smc_ibfk_2`(`validcode`, `accpdx`, `asterisk`, `im`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `inacbg_cetak_klaim`  (
  `no_sep` varchar(40) NOT NULL,
  `path` varchar(100) NULL DEFAULT NULL,
  `kirim_ke_dc` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`no_sep`) USING BTREE,
  CONSTRAINT `inacbg_cetak_klaim_bridging_sep_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `inacbg_data_terkirim2` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `inacbg_data_klaim_smc`  (
  `no_sep` varchar(40) NOT NULL,
  `nomor_kartu` varchar(20) NOT NULL,
  `tgl_masuk` datetime NOT NULL,
  `tgl_pulang` datetime NOT NULL,
  `cara_masuk` enum('gp','hosp-trans','mp','outp','inp','emd','born','nursing','psych','rehab','other') NOT NULL,
  `jenis_rawat` enum('1','2','3') NOT NULL,
  `kelas_rawat` enum('1','2','3') NOT NULL,
  `adl_sub_acute` varchar(2) NOT NULL DEFAULT '',
  `adl_chronic` varchar(2) NOT NULL DEFAULT '',
  `icu_indicator` enum('','0','1') NOT NULL DEFAULT '',
  `icu_los` varchar(2) NOT NULL DEFAULT '',
  `ventilator_hour` varchar(2) NOT NULL DEFAULT '',
  `upgrade_class_ind` enum('','0','1') NOT NULL DEFAULT '',
  `upgrade_class_class` enum('','kelas_2','kelas_1','vip','vvip') NOT NULL DEFAULT '',
  `upgrade_class_los` varchar(2) NOT NULL DEFAULT '',
  `upgrade_class_payor` enum('','peserta','pemberi_kerja','asuransi_tambahan') NOT NULL DEFAULT '',
  `add_payment_pct` int(10) unsigned DEFAULT NULL,
  `birth_weight` varchar(10) NOT NULL DEFAULT '',
  `sistole` varchar(4) NOT NULL,
  `diastole` varchar(4) NOT NULL,
  `discharge_status` enum('1','2','3','4','5') NOT NULL,
  `dializer_single_use` enum('','0','1') NOT NULL DEFAULT '',
  `kantong_darah` varchar(5) NOT NULL DEFAULT '',
  `alteplase_ind` enum('','0','1') NOT NULL DEFAULT '',
  `menit_1_appearance` enum('','0','1','2') NOT NULL DEFAULT '',
  `menit_1_pulse` enum('','0','1','2') NOT NULL DEFAULT '',
  `menit_1_grimace` enum('','0','1','2') NOT NULL DEFAULT '',
  `menit_1_activity` enum('','0','1','2') NOT NULL DEFAULT '',
  `menit_1_respiration` enum('','0','1','2') NOT NULL DEFAULT '',
  `menit_5_appearance` enum('','0','1','2') NOT NULL DEFAULT '',
  `menit_5_pulse` enum('','0','1','2') NOT NULL DEFAULT '',
  `menit_5_grimace` enum('','0','1','2') NOT NULL DEFAULT '',
  `menit_5_activity` enum('','0','1','2') NOT NULL DEFAULT '',
  `menit_5_respiration` enum('','0','1','2') NOT NULL DEFAULT '',
  `usia_kehamilan` varchar(3) NOT NULL DEFAULT '',
  `gravida` varchar(3) NOT NULL DEFAULT '',
  `partus` varchar(3) NOT NULL DEFAULT '',
  `abortus` varchar(3) NOT NULL DEFAULT '',
  `onset_kontraksi` enum('','spontan','induksi','non_spontan_non_induksi') NOT NULL DEFAULT '',
  `tarif_poli_eks` varchar(10) NOT NULL DEFAULT '',
  `nama_dokter` varchar(150) NOT NULL,
  `kode_tarif` varchar(3) NOT NULL,
  `payor_id` varchar(3) NOT NULL DEFAULT '',
  `payor_cd` varchar(10) NOT NULL DEFAULT '',
  `cob_cd` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`no_sep`) USING BTREE,
  CONSTRAINT `inacbg_data_klaim_smc_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `inacbg_klaim_baru2` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX `tgl_masuk`(`tgl_masuk`) USING BTREE,
  INDEX `tgl_pulang`(`tgl_pulang`) USING BTREE,
  INDEX `nama_dokter`(`nama_dokter`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `inacbg_data_klaim_persalinan_smc`  (
  `no_sep` varchar(40) NOT NULL,
  `delivery_sequence` tinyint(3) UNSIGNED NOT NULL,
  `delivery_method` enum('Vaginal','SC') NULL DEFAULT NULL,
  `delivery_date` date NULL DEFAULT NULL,
  `delivery_time` time NULL DEFAULT NULL,
  `letak_janin` enum('Kepala','Sungsang','Lintang') NULL DEFAULT NULL,
  `kondisi` enum('Hidup','Meninggal') NULL DEFAULT NULL,
  `use_manual` enum('0. Tidak','1. Ya') NULL DEFAULT NULL,
  `use_forcep` enum('0. Tidak','1. Ya') NULL DEFAULT NULL,
  `use_vacuum` enum('0. Tidak','1. Ya') NULL DEFAULT NULL,
  `shk_spesimen_ambil` enum('Tidak','Ya') NULL DEFAULT NULL,
  `shk_lokasi` enum('','Tumit','Vena') NULL DEFAULT NULL,
  `shk_spesimen_date` date NULL DEFAULT NULL,
  `shk_spesimen_time` time NULL DEFAULT NULL,
  `shk_alasan` enum('','Tidak dapat dilakukan','Akses sulit') NULL DEFAULT NULL,
  PRIMARY KEY (`no_sep`, `delivery_sequence`) USING BTREE,
  CONSTRAINT `inacbg_data_klaim_persalinan_smc_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `bridging_sep` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `inacbg_data_klaim_tarif_smc`  (
  `no_sep` varchar(40) NOT NULL,
  `tarif_rs` varchar(30) NOT NULL,
  `nilai` double NOT NULL DEFAULT 0,
  PRIMARY KEY (`no_sep`, `tarif_rs`) USING BTREE,
  CONSTRAINT `inacbg_data_klaim_tarif_smc_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `inacbg_data_klaim_smc` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `inacbg_diagnosa_pasien_smc`  (
  `no_sep` varchar(40) NOT NULL,
  `kode_icd10` varchar(7) NOT NULL,
  `deskripsi` varchar(250) NULL DEFAULT NULL,
  `urut` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `keterangan` varchar(100) NULL DEFAULT NULL,
  `locked` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`no_sep`, `kode_icd10`) USING BTREE,
  INDEX `idrg_dx_smc_icd10_im`(`kode_icd10`) USING BTREE,
  CONSTRAINT `inacbg_dx_smc_no_sep` FOREIGN KEY (`no_sep`) REFERENCES `bridging_sep` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `inacbg_grouping_stage2_smc`  (
  `no_sep` varchar(40) NOT NULL,
  `cmg_code` varchar(10) NOT NULL,
  `cmg_description` varchar(100) NULL DEFAULT NULL,
  `cmg_type` varchar(50) NULL DEFAULT NULL,
  `tariff` double NOT NULL DEFAULT 0,
  PRIMARY KEY (`no_sep`, `cmg_code`) USING BTREE,
  CONSTRAINT `inacbg_grouping_stage2_smc_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `inacbg_grouping_stage12` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `inacbg_grouping_stage12` ADD COLUMN IF NOT EXISTS `top_up` enum('Tidak Ada','Belum','Sudah') NOT NULL DEFAULT 'Tidak Ada' AFTER `tarif`;

CREATE TABLE IF NOT EXISTS `inacbg_klaim_final_smc`  (
  `no_sep` varchar(40) NOT NULL,
  `nik` varchar(30) NOT NULL,
  PRIMARY KEY (`no_sep`) USING BTREE,
  CONSTRAINT `inacbg_klaim_final_smc_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `inacbg_grouping_stage12` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `inacbg_pasien_tb_smc`  (
  `no_sep` varchar(40) NOT NULL,
  `no_rkm_medis` varchar(15) NOT NULL,
  `no_sitb` varchar(30) NOT NULL,
  `status_validasi` varchar(80) NULL DEFAULT NULL,
  PRIMARY KEY (`no_sep`) USING BTREE,
  INDEX `inacbg_pasien_tb_smc_ibfk_2`(`no_rkm_medis`) USING BTREE,
  CONSTRAINT `inacbg_pasien_tb_smc_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `bridging_sep` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `inacbg_pasien_tb_smc_ibfk_2` FOREIGN KEY (`no_rkm_medis`) REFERENCES `pasien` (`no_rkm_medis`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `inacbg_prosedur_pasien_smc`  (
  `no_sep` varchar(40) NOT NULL,
  `kode_icd9` varchar(7) NOT NULL,
  `deskripsi` varchar(250) NULL DEFAULT NULL,
  `urut` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `keterangan` varchar(100) NULL DEFAULT NULL,
  `locked` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`no_sep`, `kode_icd9`) USING BTREE,
  INDEX `idrg_pc_smc_icd9cm_im`(`kode_icd9`) USING BTREE,
  CONSTRAINT `inacbg_pc_smc_no_sep` FOREIGN KEY (`no_sep`) REFERENCES `bridging_sep` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `inacbg_referensi_icd9cm_smc`  (
  `code1` varchar(7) NOT NULL,
  `code2` varchar(7) NOT NULL DEFAULT '',
  `deskripsi` varchar(300) NOT NULL DEFAULT '',
  `validcode` enum('0','1') NOT NULL DEFAULT '0',
  PRIMARY KEY (`code1`) USING BTREE,
  INDEX `eklaim_icd9cm_smc_ibfk_1`(`code1`, `deskripsi`) USING BTREE,
  INDEX `eklaim_icd9cm_smc_ibfk_2`(`validcode`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `inacbg_referensi_icd10_smc`  (
  `code1` varchar(7) NOT NULL,
  `code2` varchar(7) NOT NULL DEFAULT '',
  `deskripsi` varchar(300) NOT NULL DEFAULT '',
  `validcode` enum('0','1') NOT NULL DEFAULT '0',
  PRIMARY KEY (`code1`) USING BTREE,
  INDEX `eklaim_icd10_smc_ibfk_1`(`code1`, `deskripsi`) USING BTREE,
  INDEX `eklaim_icd10_smc_ibfk_2`(`validcode`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `industrifarmasi` MODIFY COLUMN IF EXISTS `alamat` varchar(200) NULL DEFAULT NULL AFTER `nama_industri`;

ALTER TABLE `industrifarmasi` MODIFY COLUMN IF EXISTS `kota` varchar(30) NULL DEFAULT NULL AFTER `alamat`;

ALTER TABLE `ipsrsdetailpengeluaran` ADD PRIMARY KEY IF NOT EXISTS (`no_keluar`, `kode_brng`) USING BTREE;

ALTER TABLE `ipsrsdetailpengeluaran` DROP FOREIGN KEY IF EXISTS `ipsrsdetailpengeluaran_ibfk_4`;

ALTER TABLE `ipsrsdetailpengeluaran` ADD CONSTRAINT `ipsrsdetailpengeluaran_ibfk_4` FOREIGN KEY IF NOT EXISTS (`kode_brng`) REFERENCES `ipsrsbarang` (`kode_brng`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `ipsrsopname` MODIFY COLUMN IF EXISTS `stok` double NOT NULL AFTER `tanggal`;

ALTER TABLE `ipsrsopname` MODIFY COLUMN IF EXISTS `real` double NOT NULL AFTER `stok`;

ALTER TABLE `ipsrsopname` MODIFY COLUMN IF EXISTS `selisih` double NOT NULL AFTER `real`;

ALTER TABLE `ipsrsopname` MODIFY COLUMN IF EXISTS `lebih` double NOT NULL AFTER `nomihilang`;

ALTER TABLE `ipsrssuplier` MODIFY COLUMN IF EXISTS `alamat` varchar(100) NULL DEFAULT NULL AFTER `nama_suplier`;

ALTER TABLE `ipsrssuplier` MODIFY COLUMN IF EXISTS `kota` varchar(50) NULL DEFAULT NULL AFTER `alamat`;

ALTER TABLE `ipsrssuplier` MODIFY COLUMN IF EXISTS `no_telp` varchar(20) NULL DEFAULT NULL AFTER `kota`;

ALTER TABLE `ipsrssuplier` MODIFY COLUMN IF EXISTS `nama_bank` varchar(50) NULL DEFAULT NULL AFTER `no_telp`;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h1` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h2` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h3` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h4` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h5` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h6` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h7` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h8` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h9` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h10` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h11` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h12` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h13` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h14` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h15` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h16` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h17` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h18` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h19` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h20` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h21` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h22` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h23` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h24` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h25` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h26` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h27` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h28` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h29` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h30` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_pegawai` MODIFY COLUMN IF EXISTS `h31` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

CREATE TABLE IF NOT EXISTS `jadwal_pegawai_smc`  (
  `id` int(11) NOT NULL,
  `tanggal` date NOT NULL,
  `kode_shift` varchar(5) NOT NULL,
  PRIMARY KEY (`id`, `tanggal`) USING BTREE,
  INDEX `kode_shift`(`kode_shift`) USING BTREE,
  INDEX `tanggal`(`tanggal`) USING BTREE,
  CONSTRAINT `jadwal_pegawai_smc_ibfk_1` FOREIGN KEY (`id`) REFERENCES `pegawai` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h1` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h2` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h3` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h4` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h5` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h6` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h7` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h8` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h9` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h10` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h11` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h12` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h13` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h14` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h15` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h16` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h17` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h18` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h19` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h20` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h21` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h22` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h23` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h24` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h25` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h26` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h27` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h28` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h29` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h30` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jadwal_tambahan` MODIFY COLUMN IF EXISTS `h31` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', '', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

CREATE TABLE IF NOT EXISTS `jadwal_tambahan_smc`  (
  `id` int(11) NOT NULL,
  `tanggal` date NOT NULL,
  `kode_shift` varchar(5) NOT NULL,
  PRIMARY KEY (`id`, `tanggal`) USING BTREE,
  INDEX `kode_shift`(`kode_shift`) USING BTREE,
  INDEX `tanggal`(`tanggal`) USING BTREE,
  CONSTRAINT `jadwal_tambahan_smc_ibfk_1` FOREIGN KEY (`id`) REFERENCES `pegawai` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `jam_jaga` MODIFY COLUMN IF EXISTS `shift` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `jam_masuk` MODIFY COLUMN IF EXISTS `shift` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

CREATE TABLE IF NOT EXISTS `jam_masuk_smc`  (
  `kode_shift` varchar(5) NOT NULL,
  `nama_shift` varchar(50) NOT NULL,
  `jam_masuk` time NOT NULL DEFAULT '00:00:00',
  `jam_pulang` time NOT NULL DEFAULT '00:00:00',
  PRIMARY KEY (`kode_shift`) USING BTREE,
  INDEX `nama_shift`(`nama_shift`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `jadwal_pegawai_smc` ADD CONSTRAINT `jadwal_pegawai_smc_ibfk_2` FOREIGN KEY IF NOT EXISTS (`kode_shift`) REFERENCES `jam_masuk_smc` (`kode_shift`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `jadwal_tambahan_smc` ADD CONSTRAINT `jadwal_tambahan_smc_ibfk_2` FOREIGN KEY IF NOT EXISTS (`kode_shift`) REFERENCES `jam_masuk_smc` (`kode_shift`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `jns_perawatan_inap` MODIFY COLUMN IF EXISTS `nm_perawatan` varchar(200) NULL DEFAULT NULL AFTER `kd_jenis_prw`;

CREATE TABLE IF NOT EXISTS `jns_perawatan_radiologi_modality_smc`  (
  `kd_jenis_prw` varchar(15) NOT NULL,
  `modality` varchar(16) NOT NULL,
  PRIMARY KEY (`kd_jenis_prw`) USING BTREE,
  INDEX `jns_perawatan_radiologi_modality_smc_ibfk_1`(`modality`) USING BTREE,
  CONSTRAINT `jns_perawatan_radiologi_modality_smc_ibfk_2` FOREIGN KEY (`kd_jenis_prw`) REFERENCES `jns_perawatan_radiologi` (`kd_jenis_prw`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `jurnal` DROP INDEX IF EXISTS `no_jurnal`;

CREATE TABLE IF NOT EXISTS `lis_orderlab`  (
  `vendor` varchar(20) NOT NULL,
  `noorder` varchar(20) NOT NULL,
  `nolab` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`vendor`, `noorder`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `lis_request_response`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `vendor` varchar(20) NOT NULL DEFAULT '',
  `noorder` varchar(20) NULL DEFAULT NULL,
  `url` varchar(255) NULL DEFAULT NULL,
  `method` varchar(15) NULL DEFAULT NULL,
  `request` text NULL DEFAULT NULL,
  `code` varchar(5) NULL DEFAULT NULL,
  `response` text NULL DEFAULT NULL,
  `pengirim` varchar(20) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `vendor_noorder`(`vendor`, `noorder`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `maping_dokter_dpjpvclaim` MODIFY COLUMN IF EXISTS `nm_dokter_bpjs` varchar(100) NULL DEFAULT NULL AFTER `kd_dokter_bpjs`;

ALTER TABLE `maping_dokter_dpjpvclaim` ADD UNIQUE INDEX IF NOT EXISTS `maping_dokter_dpjpvclaim_unique`(`kd_dokter_bpjs`) USING BTREE;

ALTER TABLE `maping_obat_apotek_bpjs` ADD COLUMN IF NOT EXISTS `harga` double NOT NULL DEFAULT 0 AFTER `nama_brng_apotek_bpjs`;

ALTER TABLE `maping_obat_apotek_bpjs` ADD COLUMN IF NOT EXISTS `restriksi` varchar(255) NULL DEFAULT NULL AFTER `harga`;

ALTER TABLE `maping_obat_apotek_bpjs` MODIFY COLUMN IF EXISTS `nama_brng_apotek_bpjs` varchar(200) NULL DEFAULT NULL AFTER `kode_brng_apotek_bpjs`;

ALTER TABLE `maping_poli_bpjs` DROP INDEX IF EXISTS `kd_poli_bpjs`;

CREATE TABLE IF NOT EXISTS `mapping_pemeriksaan_labpk`  (
  `id_pemeriksaan` int(10) UNSIGNED NOT NULL,
  `id_template` int(11) NOT NULL,
  PRIMARY KEY (`id_pemeriksaan`, `id_template`) USING BTREE,
  INDEX `id_template`(`id_template`) USING BTREE,
  CONSTRAINT `mapping_pemeriksaan_labpk_ibfk_1` FOREIGN KEY (`id_pemeriksaan`) REFERENCES `pemeriksaan_labpk` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `mapping_pemeriksaan_labpk_ibfk_2` FOREIGN KEY (`id_template`) REFERENCES `template_laboratorium` (`id_template`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `mapping_pin_pegawai_smc`  (
  `pin` varchar(10) NOT NULL,
  `id` int(11) NOT NULL,
  PRIMARY KEY (`pin`) USING BTREE,
  INDEX `id`(`id`) USING BTREE,
  CONSTRAINT `mapping_pin_pegawai_smc_ibfk_1` FOREIGN KEY (`id`) REFERENCES `pegawai` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `mapping_user_bridginglab`  (
  `nip` varchar(20) NOT NULL,
  `username` varchar(100) NOT NULL,
  `vendor` varchar(100) NOT NULL,
  PRIMARY KEY (`nip`, `username`, `vendor`) USING BTREE,
  CONSTRAINT `mapping_user_bridginglab_petugas_fk` FOREIGN KEY (`nip`) REFERENCES `petugas` (`nip`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `master_berkas_digital` ADD COLUMN IF NOT EXISTS `include_kompilasi_berkas` tinyint(1) NOT NULL DEFAULT 1 AFTER `nama`;

ALTER TABLE `obat_racikan` ADD COLUMN IF NOT EXISTS `tgl_kadaluarsa` date NULL DEFAULT NULL after `keterangan`;

ALTER TABLE `pasien` MODIFY COLUMN IF EXISTS `nm_pasien` varchar(60) NULL DEFAULT NULL AFTER `no_rkm_medis`;

ALTER TABLE `pasien` MODIFY COLUMN IF EXISTS `tmp_lahir` varchar(30) NULL DEFAULT NULL AFTER `jk`;

ALTER TABLE `pasien` MODIFY COLUMN IF EXISTS `nm_ibu` varchar(60) NOT NULL AFTER `tgl_lahir`;

ALTER TABLE `pasien` ADD INDEX IF NOT EXISTS `tgl_daftar`(`tgl_daftar`) USING BTREE;

ALTER TABLE `pasien` ADD INDEX IF NOT EXISTS `tgl_lahir`(`tgl_lahir`) USING BTREE;

CREATE TABLE IF NOT EXISTS `pasien_bayi_gambar_smc`  (
  `no_rkm_medis` varchar(15) NOT NULL,
  `photo` varchar(500) NOT NULL,
  PRIMARY KEY (`no_rkm_medis`) USING BTREE,
  CONSTRAINT `pasien_bayi_gambar_smc_ibfk_1` FOREIGN KEY (`no_rkm_medis`) REFERENCES `pasien_bayi` (`no_rkm_medis`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `pegawai` MODIFY COLUMN IF EXISTS `nama` varchar(100) NOT NULL AFTER `nik`;

ALTER TABLE `pegawai` MODIFY COLUMN IF EXISTS `alamat` varchar(150) NOT NULL AFTER `tgl_lahir`;

CREATE TABLE IF NOT EXISTS `pemeriksaan_labpk`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `kode_pemeriksaan` varchar(20) NOT NULL,
  `nama_pemeriksaan` varchar(200) NOT NULL,
  `satuan` varchar(15) NOT NULL,
  `metode` varchar(50) NULL DEFAULT NULL,
  `kategori` varchar(50) NOT NULL,
  `urut` int(10) UNSIGNED NULL DEFAULT NULL,
  `vendor` varchar(15) NOT NULL DEFAULT '',
  `kode_compound` varchar(255) GENERATED ALWAYS AS (concat_ws('-',`kode_pemeriksaan`,`kategori`,`vendor`)) VIRTUAL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `kode_pemeriksaan`(`kode_pemeriksaan`) USING BTREE,
  INDEX `nama_pemeriksaan`(`nama_pemeriksaan`) USING BTREE,
  INDEX `urut`(`urut`) USING BTREE,
  INDEX `vendor`(`vendor`) USING BTREE,
  INDEX `pemeriksaan_labpk_pemeriksaan_labpk_kategori_FK`(`kategori`) USING BTREE,
  INDEX `kode_compund`(`kode_compound`) USING BTREE,
  CONSTRAINT `pemeriksaan_labpk_pemeriksaan_labpk_kategori_FK` FOREIGN KEY (`kategori`) REFERENCES `pemeriksaan_labpk_kategori` (`nama`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `pemeriksaan_labpk_kategori`  (
  `nama` varchar(50) NOT NULL,
  `urut` int(10) UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`nama`) USING BTREE,
  INDEX `urut_idx`(`urut`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `pengajuan_cuti` ADD COLUMN IF NOT EXISTS `tmt_kerja` date NOT NULL AFTER `tanggal_akhir`;

ALTER TABLE `pengajuan_cuti` ADD COLUMN IF NOT EXISTS `tat_kerja` date NOT NULL AFTER `tmt_kerja`;

ALTER TABLE `pengajuan_cuti` MODIFY COLUMN IF EXISTS `urgensi` enum('Tahunan','Besar','Sakit','Bersalin','Alasan Penting','Keterangan Lainnya','Lainnya','Panjang (10 Tahun)') NOT NULL AFTER `nik`;

CREATE TABLE IF NOT EXISTS `pengajuan_izin_smc`  (
  `no_pengajuan` varchar(17) NOT NULL,
  `tanggal` date NOT NULL,
  `nik` varchar(20) NOT NULL,
  `tmt` date NOT NULL DEFAULT '0000-00-00',
  `tat` date NOT NULL DEFAULT '0000-00-00',
  `izin` enum('','Tidak Ada','1 Bulan TMT','3 Bulan TMT','6 Bulan TMT','12 Bulan TMT','1 Bulan per Tahun','3 Bulan per Tahun','6 Bulan per Tahun','12 Bulan per Tahun') NOT NULL DEFAULT '',
  `urgensi` enum('Terlambat','Meninggalkan Kerja','Tidak Masuk Kerja','Lainnya') NOT NULL,
  `tanggal_izin` date NOT NULL,
  `jam_mulai` time NOT NULL DEFAULT '00:00:00',
  `jam_akhir` time NOT NULL DEFAULT '00:00:00',
  `kepentingan` varchar(70) NOT NULL,
  `nik_pj` varchar(20) NOT NULL,
  `status` enum('Proses Pengajuan','Disetujui','Ditolak') NOT NULL,
  `normatif` enum('Tidak','Ya') NOT NULL DEFAULT 'Tidak',
  PRIMARY KEY (`no_pengajuan`) USING BTREE,
  INDEX `nik` (`nik`) USING BTREE,
  INDEX `nik_pj` (`nik_pj`) USING BTREE,
  INDEX `nik_3` (`nik`,`tanggal_izin`) USING BTREE,
  INDEX `nik_4` (`nik`,`tmt`,`tat`,`urgensi`) USING BTREE,
  CONSTRAINT `pengajuan_izin_smc_ibfk_1` FOREIGN KEY (`nik`) REFERENCES `pegawai` (`nik`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `pengajuan_izin_smc_ibfk_2` FOREIGN KEY (`nik_pj`) REFERENCES `pegawai` (`nik`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `pengajuan_izin_smc` ADD COLUMN IF NOT EXISTS `normatif` enum('Tidak','Ya') NOT NULL DEFAULT 'Tidak' AFTER `status`;

UPDATE `pengajuan_izin_smc` SET `urgensi` = 'Meninggalkan Kerja' WHERE `urgensi` = 'Pulang Cepat';

ALTER TABLE `pengajuan_izin_smc` MODIFY COLUMN IF EXISTS `urgensi` enum('Terlambat','Meninggalkan Kerja','Tidak Masuk Kerja','Lainnya') NOT NULL AFTER `izin`;

ALTER TABLE `pengajuan_izin_smc` DROP INDEX IF EXISTS `nik_2`;

ALTER TABLE `pengajuan_izin_smc` ADD INDEX IF NOT EXISTS `nik_4`(`nik`, `tmt`, `tat`, `urgensi`) USING BTREE;

ALTER TABLE `pengeluaran_harian` MODIFY COLUMN IF EXISTS `keterangan` varchar(250) NOT NULL DEFAULT '' AFTER `nip`;

ALTER TABLE `pengkajian_restrain` MODIFY COLUMN IF EXISTS `restrain_farmakologi` text NULL DEFAULT NULL AFTER `restrain_non_farmakologi_keterangan`;

ALTER TABLE `penilaian_awal_keperawatan_gigi` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `bmi`;

ALTER TABLE `penilaian_awal_keperawatan_gigi` MODIFY COLUMN IF EXISTS `nyeri_hilang` enum('-','Istirahat','Medengar Musik','Minum Obat','Tidak ada nyeri','Lain-lain') NOT NULL AFTER `frekuensi`;

ALTER TABLE `penilaian_awal_keperawatan_gigi` MODIFY COLUMN IF EXISTS `rencana` text NOT NULL AFTER `palatum`;

ALTER TABLE `penilaian_awal_keperawatan_igd` MODIFY COLUMN IF EXISTS `provokes` enum('-','Proses Penyakit','Benturan','Lain-lain') NOT NULL AFTER `nyeri`;

ALTER TABLE `penilaian_awal_keperawatan_igd` MODIFY COLUMN IF EXISTS `quality` enum('-','Seperti Tertusuk','Berdenyut','Teriris','Tertindih','Tertiban','Lain-lain') NOT NULL AFTER `ket_provokes`;

ALTER TABLE `penilaian_awal_keperawatan_igd` MODIFY COLUMN IF EXISTS `nyeri_hilang` enum('-','Istirahat','Medengar Musik','Minum Obat') NOT NULL AFTER `durasi`;

ALTER TABLE `penilaian_awal_keperawatan_kebidanan` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `panggul`;

ALTER TABLE `penilaian_awal_keperawatan_kebidanan` MODIFY COLUMN IF EXISTS `provokes` enum('-','Proses Penyakit','Benturan','Lain-lain') NOT NULL AFTER `nyeri`;

ALTER TABLE `penilaian_awal_keperawatan_kebidanan` MODIFY COLUMN IF EXISTS `quality` enum('-','Seperti Tertusuk','Berdenyut','Teriris','Tertindih','Tertiban','Lain-lain') NOT NULL AFTER `ket_provokes`;

ALTER TABLE `penilaian_awal_keperawatan_kebidanan` MODIFY COLUMN IF EXISTS `nyeri_hilang` enum('-','Istirahat','Medengar Musik','Minum Obat') NOT NULL AFTER `durasi`;

ALTER TABLE `penilaian_awal_keperawatan_kebidanan` MODIFY COLUMN IF EXISTS `masalah` text NOT NULL AFTER `ket_dokter`;

ALTER TABLE `penilaian_awal_keperawatan_kebidanan` MODIFY COLUMN IF EXISTS `tindakan` text NOT NULL AFTER `masalah`;

ALTER TABLE `penilaian_awal_keperawatan_kebidanan_ranap` MODIFY COLUMN IF EXISTS `keluhan` text NOT NULL AFTER `cara_masuk`;

ALTER TABLE `penilaian_awal_keperawatan_kebidanan_ranap` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `keluhan`;

ALTER TABLE `penilaian_awal_keperawatan_kebidanan_ranap` MODIFY COLUMN IF EXISTS `psk` text NOT NULL AFTER `rpk`;

ALTER TABLE `penilaian_awal_keperawatan_kebidanan_ranap` MODIFY COLUMN IF EXISTS `rp` text NOT NULL AFTER `psk`;

ALTER TABLE `penilaian_awal_keperawatan_kebidanan_ranap` MODIFY COLUMN IF EXISTS `penilaian_nyeri_penyebab` enum('-','Proses Penyakit','Benturan','Lain-lain') NOT NULL AFTER `penilaian_nyeri`;

ALTER TABLE `penilaian_awal_keperawatan_kebidanan_ranap` MODIFY COLUMN IF EXISTS `penilaian_nyeri_kualitas` enum('-','Seperti Tertusuk','Berdenyut','Teriris','Tertindih','Tertiban','Lain-lain') NOT NULL AFTER `penilaian_nyeri_ket_penyebab`;

ALTER TABLE `penilaian_awal_keperawatan_kebidanan_ranap` MODIFY COLUMN IF EXISTS `penilaian_nyeri_hilang` enum('-','Istirahat','Medengar Musik','Minum Obat') NOT NULL AFTER `penilaian_nyeri_waktu`;

ALTER TABLE `penilaian_awal_keperawatan_kebidanan_ranap` MODIFY COLUMN IF EXISTS `masalah` text NOT NULL AFTER `skrining_gizi_jam_diketahui_dietisen`;

ALTER TABLE `penilaian_awal_keperawatan_kebidanan_ranap` MODIFY COLUMN IF EXISTS `rencana` text NOT NULL AFTER `masalah`;

ALTER TABLE `penilaian_awal_keperawatan_mata` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `bmi`;

ALTER TABLE `penilaian_awal_keperawatan_mata` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_awal_keperawatan_mata` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_awal_keperawatan_mata` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_awal_keperawatan_mata` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpk`;

ALTER TABLE `penilaian_awal_keperawatan_mata` MODIFY COLUMN IF EXISTS `provokes` enum('-','Proses Penyakit','Benturan','Lain-lain') NOT NULL AFTER `nyeri`;

ALTER TABLE `penilaian_awal_keperawatan_mata` MODIFY COLUMN IF EXISTS `quality` enum('-','Seperti Tertusuk','Berdenyut','Teriris','Tertindih','Tertiban','Lain-lain') NOT NULL AFTER `ket_provokes`;

ALTER TABLE `penilaian_awal_keperawatan_mata` MODIFY COLUMN IF EXISTS `nyeri_hilang` enum('-','Istirahat','Medengar Musik','Minum Obat') NOT NULL AFTER `durasi`;

ALTER TABLE `penilaian_awal_keperawatan_mata` MODIFY COLUMN IF EXISTS `rencana` text NOT NULL AFTER `oftalmoskopikiri`;

ALTER TABLE `penilaian_awal_keperawatan_ralan` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `bmi`;

ALTER TABLE `penilaian_awal_keperawatan_ralan` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_awal_keperawatan_ralan` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_awal_keperawatan_ralan` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpk`;

ALTER TABLE `penilaian_awal_keperawatan_ralan` MODIFY COLUMN IF EXISTS `provokes` enum('-','Proses Penyakit','Benturan','Lain-lain') NOT NULL AFTER `nyeri`;

ALTER TABLE `penilaian_awal_keperawatan_ralan` MODIFY COLUMN IF EXISTS `quality` enum('-','Seperti Tertusuk','Berdenyut','Teriris','Tertindih','Tertiban','Lain-lain') NOT NULL AFTER `ket_provokes`;

ALTER TABLE `penilaian_awal_keperawatan_ralan` MODIFY COLUMN IF EXISTS `nyeri_hilang` enum('-','Istirahat','Medengar Musik','Minum Obat') NOT NULL AFTER `durasi`;

ALTER TABLE `penilaian_awal_keperawatan_ralan` MODIFY COLUMN IF EXISTS `rencana` text NOT NULL AFTER `ket_dokter`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_bayi` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `ld`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_bayi` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_bayi` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_bayi` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpk`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_bayi` MODIFY COLUMN IF EXISTS `rencana` text NOT NULL AFTER `ket_dokter`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_geriatri` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `bmi`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_geriatri` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_geriatri` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_geriatri` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpk`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_geriatri` MODIFY COLUMN IF EXISTS `provokes` enum('-','Proses Penyakit','Benturan','Lain-lain') NOT NULL AFTER `nyeri`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_geriatri` MODIFY COLUMN IF EXISTS `quality` enum('-','Seperti Tertusuk','Berdenyut','Teriris','Tertindih','Tertiban','Lain-lain') NOT NULL AFTER `ket_provokes`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_geriatri` MODIFY COLUMN IF EXISTS `nyeri_hilang` enum('-','Istirahat','Medengar Musik','Minum Obat') NOT NULL AFTER `durasi`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_geriatri` MODIFY COLUMN IF EXISTS `rencana` text NOT NULL AFTER `fraily_phenotype_status`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_psikiatri` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `informasi`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_psikiatri` MODIFY COLUMN IF EXISTS `rkd_keluhan` text NOT NULL AFTER `rkd_sakit_sejak`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_psikiatri` MODIFY COLUMN IF EXISTS `provokes` enum('-','Proses Penyakit','Benturan','Lain-lain') NOT NULL AFTER `nyeri`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_psikiatri` MODIFY COLUMN IF EXISTS `quality` enum('-','Seperti Tertusuk','Berdenyut','Teriris','Tertindih','Tertiban','Lain-lain') NOT NULL AFTER `ket_provokes`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_psikiatri` MODIFY COLUMN IF EXISTS `nyeri_hilang` enum('-','Istirahat','Medengar Musik','Minum Obat') NOT NULL AFTER `ket_dokter`;

ALTER TABLE `penilaian_awal_keperawatan_ralan_psikiatri` MODIFY COLUMN IF EXISTS `rencana` text NOT NULL AFTER `ket_kk_kebutuhan_edukasi`;

ALTER TABLE `penilaian_awal_keperawatan_ranap` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `cara_masuk`;

ALTER TABLE `penilaian_awal_keperawatan_ranap` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_awal_keperawatan_ranap` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_awal_keperawatan_ranap` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpk`;

ALTER TABLE `penilaian_awal_keperawatan_ranap` MODIFY COLUMN IF EXISTS `alat_bantu_dipakai` enum('Tidak Ada','Kacamata','Prothesa','Alat Bantu Dengar','Lain-lain') NOT NULL AFTER `riwayat_dirawat_dirs`;

ALTER TABLE `penilaian_awal_keperawatan_ranap` MODIFY COLUMN IF EXISTS `penilaian_nyeri_penyebab` enum('-','Proses Penyakit','Benturan','Lain-lain') NOT NULL AFTER `penilaian_nyeri`;

ALTER TABLE `penilaian_awal_keperawatan_ranap` MODIFY COLUMN IF EXISTS `penilaian_nyeri_kualitas` enum('-','Seperti Tertusuk','Berdenyut','Teriris','Tertindih','Tertiban','Lain-lain') NOT NULL AFTER `penilaian_nyeri_ket_penyebab`;

ALTER TABLE `penilaian_awal_keperawatan_ranap` MODIFY COLUMN IF EXISTS `penilaian_nyeri_hilang` enum('-','Istirahat','Medengar Musik','Minum Obat') NOT NULL AFTER `penilaian_nyeri_waktu`;

ALTER TABLE `penilaian_awal_keperawatan_ranap` MODIFY COLUMN IF EXISTS `rencana` text NULL DEFAULT NULL AFTER `skrining_gizi_jam_diketahui_dietisen`;

ALTER TABLE `penilaian_awal_keperawatan_ranap_bayi` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `tiba_diruang_rawat`;

ALTER TABLE `penilaian_awal_keperawatan_ranap_bayi` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_awal_keperawatan_ranap_bayi` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_awal_keperawatan_ranap_bayi` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpk`;

ALTER TABLE `penilaian_awal_keperawatan_ranap_bayi` MODIFY COLUMN IF EXISTS `perawatan_lanjutan_dirumah` text NOT NULL AFTER `kondisi_klinis_pulang`;

ALTER TABLE `penilaian_awal_keperawatan_ranap_bayi` MODIFY COLUMN IF EXISTS `rencana` text NULL DEFAULT NULL AFTER `transportasi_digunakan`;

ALTER TABLE `penilaian_awal_keperawatan_ranap_neonatus` MODIFY COLUMN IF EXISTS `keluhan_utama` text NULL DEFAULT NULL AFTER `hubungan_dengan_pasien`;

ALTER TABLE `penilaian_awal_keperawatan_ranap_neonatus` MODIFY COLUMN IF EXISTS `perawatan_lanjutan_dirumah` text NOT NULL AFTER `kondisi_klinis_pulang`;

ALTER TABLE `penilaian_awal_keperawatan_ranap_neonatus` MODIFY COLUMN IF EXISTS `rencana` text NULL DEFAULT NULL AFTER `transportasi_digunakan`;

ALTER TABLE `penilaian_bayi_baru_lahir` MODIFY COLUMN IF EXISTS `pemeriksaan_fisik_lainnya` text NULL DEFAULT NULL AFTER `keterangan_denyut_femoral`;

ALTER TABLE `penilaian_bayi_baru_lahir` MODIFY COLUMN IF EXISTS `pemeriksaan_penunjang` text NULL DEFAULT NULL AFTER `pemeriksaan_fisik_lainnya`;

ALTER TABLE `penilaian_bayi_baru_lahir` MODIFY COLUMN IF EXISTS `diagnosa` text NULL DEFAULT NULL AFTER `pemeriksaan_penunjang`;

ALTER TABLE `penilaian_bayi_baru_lahir` MODIFY COLUMN IF EXISTS `tatalaksana` text NULL DEFAULT NULL AFTER `diagnosa`;

ALTER TABLE `penilaian_dehidrasi` MODIFY COLUMN IF EXISTS `hasil_penilaian` text NULL DEFAULT NULL AFTER `penilaian_totalnilai`;

ALTER TABLE `penilaian_fisioterapi` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `informasi`;

ALTER TABLE `penilaian_fisioterapi` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_fisioterapi` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_fisioterapi` MODIFY COLUMN IF EXISTS `pemeriksaan_musculoskeletal` text NOT NULL AFTER `ket_fisik`;

ALTER TABLE `penilaian_fisioterapi` MODIFY COLUMN IF EXISTS `pemeriksaan_neuromuscular` text NOT NULL AFTER `pemeriksaan_musculoskeletal`;

ALTER TABLE `penilaian_fisioterapi` MODIFY COLUMN IF EXISTS `pemeriksaan_cardiopulmonal` text NOT NULL AFTER `pemeriksaan_neuromuscular`;

ALTER TABLE `penilaian_fisioterapi` MODIFY COLUMN IF EXISTS `pemeriksaan_integument` text NOT NULL AFTER `pemeriksaan_cardiopulmonal`;

ALTER TABLE `penilaian_fisioterapi` MODIFY COLUMN IF EXISTS `pengukuran_musculoskeletal` text NOT NULL AFTER `pemeriksaan_integument`;

ALTER TABLE `penilaian_fisioterapi` MODIFY COLUMN IF EXISTS `pengukuran_neuromuscular` text NOT NULL AFTER `pengukuran_musculoskeletal`;

ALTER TABLE `penilaian_fisioterapi` MODIFY COLUMN IF EXISTS `pengukuran_cardiopulmonal` text NOT NULL AFTER `pengukuran_neuromuscular`;

ALTER TABLE `penilaian_fisioterapi` MODIFY COLUMN IF EXISTS `pengukuran_integument` text NOT NULL AFTER `pengukuran_cardiopulmonal`;

ALTER TABLE `penilaian_fisioterapi` MODIFY COLUMN IF EXISTS `penunjang` text NOT NULL AFTER `pengukuran_integument`;

ALTER TABLE `penilaian_fisioterapi` MODIFY COLUMN IF EXISTS `diagnosis_fisio` text NOT NULL AFTER `penunjang`;

ALTER TABLE `penilaian_fisioterapi` MODIFY COLUMN IF EXISTS `rencana_terapi` text NOT NULL AFTER `diagnosis_fisio`;

ALTER TABLE `penilaian_korban_kekerasan` MODIFY COLUMN IF EXISTS `kekerasan_yang_dialami` text NULL DEFAULT NULL AFTER `hubungan_orang_terdekat`;

ALTER TABLE `penilaian_korban_kekerasan` MODIFY COLUMN IF EXISTS `dampak_kekerasan` text NULL DEFAULT NULL AFTER `yang_melakukan_kekerasan`;

ALTER TABLE `penilaian_korban_kekerasan` MODIFY COLUMN IF EXISTS `tanda_tanda_didapatkan` text NULL DEFAULT NULL AFTER `dampak_kekerasan`;

ALTER TABLE `penilaian_lanjutan_resiko_jatuh_anak` MODIFY COLUMN IF EXISTS `hasil_skrining` text NULL DEFAULT NULL AFTER `penilaian_humptydumpty_totalnilai`;

ALTER TABLE `penilaian_lanjutan_resiko_jatuh_anak` MODIFY COLUMN IF EXISTS `saran` text NULL DEFAULT NULL AFTER `hasil_skrining`;

ALTER TABLE `penilaian_lanjutan_resiko_jatuh_dewasa` MODIFY COLUMN IF EXISTS `hasil_skrining` text NULL DEFAULT NULL AFTER `penilaian_jatuhmorse_totalnilai`;

ALTER TABLE `penilaian_lanjutan_resiko_jatuh_dewasa` MODIFY COLUMN IF EXISTS `saran` text NULL DEFAULT NULL AFTER `hasil_skrining`;

ALTER TABLE `penilaian_lanjutan_resiko_jatuh_geriatri` MODIFY COLUMN IF EXISTS `hasil_skrining` text NULL DEFAULT NULL AFTER `penilaian_jatuh_totalnilai`;

ALTER TABLE `penilaian_lanjutan_resiko_jatuh_geriatri` MODIFY COLUMN IF EXISTS `saran` text NULL DEFAULT NULL AFTER `hasil_skrining`;

ALTER TABLE `penilaian_lanjutan_resiko_jatuh_lansia` MODIFY COLUMN IF EXISTS `hasil_skrining` text NULL DEFAULT NULL AFTER `penilaian_jatuhmorse_totalnilai`;

ALTER TABLE `penilaian_lanjutan_resiko_jatuh_lansia` MODIFY COLUMN IF EXISTS `saran` text NULL DEFAULT NULL AFTER `hasil_skrining`;

ALTER TABLE `penilaian_lanjutan_resiko_jatuh_psikiatri` MODIFY COLUMN IF EXISTS `hasil_skrining` text NULL DEFAULT NULL AFTER `penilaian_jatuhedmonson_totalnilai`;

ALTER TABLE `penilaian_lanjutan_resiko_jatuh_psikiatri` MODIFY COLUMN IF EXISTS `saran` text NULL DEFAULT NULL AFTER `hasil_skrining`;

ALTER TABLE `penilaian_mcu` MODIFY COLUMN IF EXISTS `proc_mastoideus` enum('Tidak Ada','Ada','Normal','Tidak Normal','-') NOT NULL AFTER `selaput_pendengaran`;

ALTER TABLE `penilaian_mcu` MODIFY COLUMN IF EXISTS `bunyi_tambahan` enum('Tidak Ada','Wheezing','Tronkhi','Ronchi','-') NOT NULL AFTER `bunyi_napas`;

ALTER TABLE `penilaian_mcu` MODIFY COLUMN IF EXISTS `bunyi_jantung` enum('Reguler','Irreguler','Korotkoff I, II','Gallop','Lain-lain','-') NOT NULL AFTER `ictus_cordis`;

ALTER TABLE `penilaian_mcu` MODIFY COLUMN IF EXISTS `auskultasi` enum('Normal','Meningkat (>4x/menit)','Bising Usus Meningkat','Bising Usus Menurun','-') NOT NULL AFTER `perkusi_abdomen`;

ALTER TABLE `penilaian_mcu` MODIFY COLUMN IF EXISTS `costovertebral` enum('Tidak Ada','Ada','Ada Di Kiri','Ada Di Kanan','-') NOT NULL AFTER `limpa`;

ALTER TABLE `penilaian_medis_hemodialisa` MODIFY COLUMN IF EXISTS `edukasi` text NOT NULL AFTER `anti_hcv`;

ALTER TABLE `penilaian_medis_igd` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_igd` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_igd` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_igd` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_igd` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpk`;

ALTER TABLE `penilaian_medis_igd` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `lab`;

ALTER TABLE `penilaian_medis_ralan` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ralan` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ralan` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_ralan` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpk`;

ALTER TABLE `penilaian_medis_ralan` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `penunjang`;

ALTER TABLE `penilaian_medis_ralan` MODIFY COLUMN IF EXISTS `konsulrujuk` text NOT NULL AFTER `tata`;

ALTER TABLE `penilaian_medis_ralan_anak` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ralan_anak` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan_anak` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ralan_anak` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_ralan_anak` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpk`;

ALTER TABLE `penilaian_medis_ralan_anak` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `penunjang`;

ALTER TABLE `penilaian_medis_ralan_anak` MODIFY COLUMN IF EXISTS `konsul` text NOT NULL AFTER `tata`;

ALTER TABLE `penilaian_medis_ralan_bedah` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ralan_bedah` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan_bedah` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ralan_bedah` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_ralan_bedah` MODIFY COLUMN IF EXISTS `lainnya` text NOT NULL AFTER `muskulos`;

ALTER TABLE `penilaian_medis_ralan_bedah` MODIFY COLUMN IF EXISTS `lab` text NOT NULL AFTER `ket_lokalis`;

ALTER TABLE `penilaian_medis_ralan_bedah` MODIFY COLUMN IF EXISTS `rad` text NOT NULL AFTER `lab`;

ALTER TABLE `penilaian_medis_ralan_bedah` MODIFY COLUMN IF EXISTS `pemeriksaan` text NOT NULL AFTER `rad`;

ALTER TABLE `penilaian_medis_ralan_bedah` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `pemeriksaan`;

ALTER TABLE `penilaian_medis_ralan_bedah` MODIFY COLUMN IF EXISTS `diagnosis2` text NOT NULL AFTER `diagnosis`;

ALTER TABLE `penilaian_medis_ralan_bedah` MODIFY COLUMN IF EXISTS `permasalahan` text NOT NULL AFTER `diagnosis2`;

ALTER TABLE `penilaian_medis_ralan_bedah` MODIFY COLUMN IF EXISTS `terapi` text NOT NULL AFTER `permasalahan`;

ALTER TABLE `penilaian_medis_ralan_bedah` MODIFY COLUMN IF EXISTS `tindakan` text NOT NULL AFTER `terapi`;

ALTER TABLE `penilaian_medis_ralan_bedah` MODIFY COLUMN IF EXISTS `edukasi` text NOT NULL AFTER `tindakan`;

ALTER TABLE `penilaian_medis_ralan_bedah_mulut` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ralan_bedah_mulut` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan_bedah_mulut` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ralan_bedah_mulut` MODIFY COLUMN IF EXISTS `wajah` text NOT NULL AFTER `keterangan_ekstremitas`;

ALTER TABLE `penilaian_medis_ralan_bedah_mulut` MODIFY COLUMN IF EXISTS `intra` text NOT NULL AFTER `wajah`;

ALTER TABLE `penilaian_medis_ralan_bedah_mulut` MODIFY COLUMN IF EXISTS `gigigeligi` text NOT NULL AFTER `intra`;

ALTER TABLE `penilaian_medis_ralan_bedah_mulut` MODIFY COLUMN IF EXISTS `lab` text NOT NULL AFTER `gigigeligi`;

ALTER TABLE `penilaian_medis_ralan_bedah_mulut` MODIFY COLUMN IF EXISTS `rad` text NOT NULL AFTER `lab`;

ALTER TABLE `penilaian_medis_ralan_bedah_mulut` MODIFY COLUMN IF EXISTS `penunjang` text NOT NULL AFTER `rad`;

ALTER TABLE `penilaian_medis_ralan_bedah_mulut` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `penunjang`;

ALTER TABLE `penilaian_medis_ralan_bedah_mulut` MODIFY COLUMN IF EXISTS `diagnosis2` text NOT NULL AFTER `diagnosis`;

ALTER TABLE `penilaian_medis_ralan_bedah_mulut` MODIFY COLUMN IF EXISTS `permasalahan` text NOT NULL AFTER `diagnosis2`;

ALTER TABLE `penilaian_medis_ralan_bedah_mulut` MODIFY COLUMN IF EXISTS `terapi` text NOT NULL AFTER `permasalahan`;

ALTER TABLE `penilaian_medis_ralan_bedah_mulut` MODIFY COLUMN IF EXISTS `tindakan` text NOT NULL AFTER `terapi`;

ALTER TABLE `penilaian_medis_ralan_bedah_mulut` MODIFY COLUMN IF EXISTS `edukasi` text NOT NULL AFTER `tindakan`;

ALTER TABLE `penilaian_medis_ralan_gawat_darurat_psikiatri` MODIFY COLUMN IF EXISTS `keluhan_utama` text NULL DEFAULT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ralan_gawat_darurat_psikiatri` MODIFY COLUMN IF EXISTS `gejala_menyertai` text NULL DEFAULT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan_gawat_darurat_psikiatri` MODIFY COLUMN IF EXISTS `faktor_pencetus` text NULL DEFAULT NULL AFTER `gejala_menyertai`;

ALTER TABLE `penilaian_medis_ralan_gawat_darurat_psikiatri` MODIFY COLUMN IF EXISTS `keterangan_riwayat_penyakit_dahulu` text NULL DEFAULT NULL AFTER `riwayat_penyakit_dahulu`;

ALTER TABLE `penilaian_medis_ralan_gawat_darurat_psikiatri` MODIFY COLUMN IF EXISTS `riwayat_kehamilan` text NULL DEFAULT NULL AFTER `keterangan_riwayat_penyakit_dahulu`;

ALTER TABLE `penilaian_medis_ralan_gawat_darurat_psikiatri` MODIFY COLUMN IF EXISTS `riwayat_obat_diminum` text NULL DEFAULT NULL AFTER `keterangan_riwayat_pekerjaan`;

ALTER TABLE `penilaian_medis_ralan_gawat_darurat_psikiatri` MODIFY COLUMN IF EXISTS `status_lokalisata` text NULL DEFAULT NULL AFTER `keterangan_status_kelainan_anggota_gerak`;

ALTER TABLE `penilaian_medis_ralan_gawat_darurat_psikiatri` MODIFY COLUMN IF EXISTS `laborat` text NULL DEFAULT NULL AFTER `psikiatrik_insight`;

ALTER TABLE `penilaian_medis_ralan_gawat_darurat_psikiatri` MODIFY COLUMN IF EXISTS `radiologi` text NULL DEFAULT NULL AFTER `laborat`;

ALTER TABLE `penilaian_medis_ralan_gawat_darurat_psikiatri` MODIFY COLUMN IF EXISTS `ekg` text NULL DEFAULT NULL AFTER `radiologi`;

ALTER TABLE `penilaian_medis_ralan_gawat_darurat_psikiatri` MODIFY COLUMN IF EXISTS `diagnosis` text NULL DEFAULT NULL AFTER `ekg`;

ALTER TABLE `penilaian_medis_ralan_gawat_darurat_psikiatri` MODIFY COLUMN IF EXISTS `permasalahan` text NULL DEFAULT NULL AFTER `diagnosis`;

ALTER TABLE `penilaian_medis_ralan_gawat_darurat_psikiatri` MODIFY COLUMN IF EXISTS `instruksi_medis` text NULL DEFAULT NULL AFTER `permasalahan`;

ALTER TABLE `penilaian_medis_ralan_gawat_darurat_psikiatri` MODIFY COLUMN IF EXISTS `rencana_target` text NULL DEFAULT NULL AFTER `instruksi_medis`;

ALTER TABLE `penilaian_medis_ralan_gawat_darurat_psikiatri` MODIFY COLUMN IF EXISTS `edukasi` text NULL DEFAULT NULL AFTER `fisik_pulang_rr`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `kondisi_umum` text NOT NULL AFTER `rr`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `kondisi_sosial` text NOT NULL AFTER `status_psikologis_gds`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `lainnya` text NOT NULL AFTER `status_nutrisi`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `lab` text NOT NULL AFTER `lainnya`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `rad` text NOT NULL AFTER `lab`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `pemeriksaan` text NOT NULL AFTER `rad`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `pemeriksaan`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `diagnosis2` text NOT NULL AFTER `diagnosis`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `permasalahan` text NOT NULL AFTER `diagnosis2`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `terapi` text NOT NULL AFTER `permasalahan`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `tindakan` text NOT NULL AFTER `terapi`;

ALTER TABLE `penilaian_medis_ralan_geriatri` MODIFY COLUMN IF EXISTS `edukasi` text NOT NULL AFTER `tindakan`;

ALTER TABLE `penilaian_medis_ralan_kandungan` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ralan_kandungan` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan_kandungan` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ralan_kandungan` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_ralan_kandungan` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpk`;

ALTER TABLE `penilaian_medis_ralan_kandungan` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `lab`;

ALTER TABLE `penilaian_medis_ralan_kandungan` MODIFY COLUMN IF EXISTS `konsul` text NOT NULL AFTER `tata`;

ALTER TABLE `penilaian_medis_ralan_kulitdankelamin` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ralan_kulitdankelamin` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan_kulitdankelamin` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ralan_kulitdankelamin` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_ralan_kulitdankelamin` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `rpo`;

ALTER TABLE `penilaian_medis_ralan_kulitdankelamin` MODIFY COLUMN IF EXISTS `statusderma` text NOT NULL AFTER `gcs`;

ALTER TABLE `penilaian_medis_ralan_kulitdankelamin` MODIFY COLUMN IF EXISTS `pemeriksaan` text NOT NULL AFTER `statusderma`;

ALTER TABLE `penilaian_medis_ralan_kulitdankelamin` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `pemeriksaan`;

ALTER TABLE `penilaian_medis_ralan_kulitdankelamin` MODIFY COLUMN IF EXISTS `diagnosis2` text NOT NULL AFTER `diagnosis`;

ALTER TABLE `penilaian_medis_ralan_kulitdankelamin` MODIFY COLUMN IF EXISTS `permasalahan` text NOT NULL AFTER `diagnosis2`;

ALTER TABLE `penilaian_medis_ralan_kulitdankelamin` MODIFY COLUMN IF EXISTS `terapi` text NOT NULL AFTER `permasalahan`;

ALTER TABLE `penilaian_medis_ralan_kulitdankelamin` MODIFY COLUMN IF EXISTS `tindakan` text NOT NULL AFTER `terapi`;

ALTER TABLE `penilaian_medis_ralan_kulitdankelamin` MODIFY COLUMN IF EXISTS `edukasi` text NOT NULL AFTER `tindakan`;

ALTER TABLE `penilaian_medis_ralan_mata` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ralan_mata` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan_mata` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ralan_mata` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_ralan_mata` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `pemeriksaan`;

ALTER TABLE `penilaian_medis_ralan_mata` MODIFY COLUMN IF EXISTS `diagnosisbdg` text NOT NULL AFTER `diagnosis`;

ALTER TABLE `penilaian_medis_ralan_mata` MODIFY COLUMN IF EXISTS `edukasi` text NOT NULL AFTER `tindakan`;

ALTER TABLE `penilaian_medis_ralan_neurologi` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ralan_neurologi` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan_neurologi` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ralan_neurologi` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_ralan_neurologi` MODIFY COLUMN IF EXISTS `lainnya` text NOT NULL AFTER `keterangan_muskulos`;

ALTER TABLE `penilaian_medis_ralan_neurologi` MODIFY COLUMN IF EXISTS `lab` text NOT NULL AFTER `lainnya`;

ALTER TABLE `penilaian_medis_ralan_neurologi` MODIFY COLUMN IF EXISTS `rad` text NOT NULL AFTER `lab`;

ALTER TABLE `penilaian_medis_ralan_neurologi` MODIFY COLUMN IF EXISTS `penunjanglain` text NOT NULL AFTER `rad`;

ALTER TABLE `penilaian_medis_ralan_neurologi` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `penunjanglain`;

ALTER TABLE `penilaian_medis_ralan_neurologi` MODIFY COLUMN IF EXISTS `diagnosis2` text NOT NULL AFTER `diagnosis`;

ALTER TABLE `penilaian_medis_ralan_neurologi` MODIFY COLUMN IF EXISTS `permasalahan` text NOT NULL AFTER `diagnosis2`;

ALTER TABLE `penilaian_medis_ralan_neurologi` MODIFY COLUMN IF EXISTS `terapi` text NOT NULL AFTER `permasalahan`;

ALTER TABLE `penilaian_medis_ralan_neurologi` MODIFY COLUMN IF EXISTS `tindakan` text NOT NULL AFTER `terapi`;

ALTER TABLE `penilaian_medis_ralan_neurologi` MODIFY COLUMN IF EXISTS `edukasi` text NOT NULL AFTER `tindakan`;

ALTER TABLE `penilaian_medis_ralan_orthopedi` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ralan_orthopedi` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan_orthopedi` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ralan_orthopedi` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_ralan_orthopedi` MODIFY COLUMN IF EXISTS `lainnya` text NOT NULL AFTER `muskulos`;

ALTER TABLE `penilaian_medis_ralan_orthopedi` MODIFY COLUMN IF EXISTS `lab` text NOT NULL AFTER `ket_lokalis`;

ALTER TABLE `penilaian_medis_ralan_orthopedi` MODIFY COLUMN IF EXISTS `rad` text NOT NULL AFTER `lab`;

ALTER TABLE `penilaian_medis_ralan_orthopedi` MODIFY COLUMN IF EXISTS `pemeriksaan` text NOT NULL AFTER `rad`;

ALTER TABLE `penilaian_medis_ralan_orthopedi` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `pemeriksaan`;

ALTER TABLE `penilaian_medis_ralan_orthopedi` MODIFY COLUMN IF EXISTS `diagnosis2` text NOT NULL AFTER `diagnosis`;

ALTER TABLE `penilaian_medis_ralan_orthopedi` MODIFY COLUMN IF EXISTS `permasalahan` text NOT NULL AFTER `diagnosis2`;

ALTER TABLE `penilaian_medis_ralan_orthopedi` MODIFY COLUMN IF EXISTS `terapi` text NOT NULL AFTER `permasalahan`;

ALTER TABLE `penilaian_medis_ralan_orthopedi` MODIFY COLUMN IF EXISTS `tindakan` text NOT NULL AFTER `terapi`;

ALTER TABLE `penilaian_medis_ralan_orthopedi` MODIFY COLUMN IF EXISTS `edukasi` text NOT NULL AFTER `tindakan`;

ALTER TABLE `penilaian_medis_ralan_paru` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ralan_paru` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan_paru` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ralan_paru` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_ralan_paru` MODIFY COLUMN IF EXISTS `lainnya` text NOT NULL AFTER `muskulos`;

ALTER TABLE `penilaian_medis_ralan_paru` MODIFY COLUMN IF EXISTS `lab` text NOT NULL AFTER `ket_lokalis`;

ALTER TABLE `penilaian_medis_ralan_paru` MODIFY COLUMN IF EXISTS `rad` text NOT NULL AFTER `lab`;

ALTER TABLE `penilaian_medis_ralan_paru` MODIFY COLUMN IF EXISTS `pemeriksaan` text NOT NULL AFTER `rad`;

ALTER TABLE `penilaian_medis_ralan_paru` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `pemeriksaan`;

ALTER TABLE `penilaian_medis_ralan_paru` MODIFY COLUMN IF EXISTS `diagnosis2` text NOT NULL AFTER `diagnosis`;

ALTER TABLE `penilaian_medis_ralan_paru` MODIFY COLUMN IF EXISTS `permasalahan` text NOT NULL AFTER `diagnosis2`;

ALTER TABLE `penilaian_medis_ralan_paru` MODIFY COLUMN IF EXISTS `terapi` text NOT NULL AFTER `permasalahan`;

ALTER TABLE `penilaian_medis_ralan_paru` MODIFY COLUMN IF EXISTS `tindakan` text NOT NULL AFTER `terapi`;

ALTER TABLE `penilaian_medis_ralan_paru` MODIFY COLUMN IF EXISTS `edukasi` text NOT NULL AFTER `tindakan`;

ALTER TABLE `penilaian_medis_ralan_penyakit_dalam` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ralan_penyakit_dalam` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan_penyakit_dalam` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ralan_penyakit_dalam` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_ralan_penyakit_dalam` MODIFY COLUMN IF EXISTS `kondisi` text NOT NULL AFTER `alergi`;

ALTER TABLE `penilaian_medis_ralan_penyakit_dalam` MODIFY COLUMN IF EXISTS `lainnya` text NOT NULL AFTER `keterangan_ekstremitas`;

ALTER TABLE `penilaian_medis_ralan_penyakit_dalam` MODIFY COLUMN IF EXISTS `lab` text NOT NULL AFTER `lainnya`;

ALTER TABLE `penilaian_medis_ralan_penyakit_dalam` MODIFY COLUMN IF EXISTS `rad` text NOT NULL AFTER `lab`;

ALTER TABLE `penilaian_medis_ralan_penyakit_dalam` MODIFY COLUMN IF EXISTS `penunjanglain` text NOT NULL AFTER `rad`;

ALTER TABLE `penilaian_medis_ralan_penyakit_dalam` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `penunjanglain`;

ALTER TABLE `penilaian_medis_ralan_penyakit_dalam` MODIFY COLUMN IF EXISTS `diagnosis2` text NOT NULL AFTER `diagnosis`;

ALTER TABLE `penilaian_medis_ralan_penyakit_dalam` MODIFY COLUMN IF EXISTS `permasalahan` text NOT NULL AFTER `diagnosis2`;

ALTER TABLE `penilaian_medis_ralan_penyakit_dalam` MODIFY COLUMN IF EXISTS `terapi` text NOT NULL AFTER `permasalahan`;

ALTER TABLE `penilaian_medis_ralan_penyakit_dalam` MODIFY COLUMN IF EXISTS `tindakan` text NOT NULL AFTER `terapi`;

ALTER TABLE `penilaian_medis_ralan_penyakit_dalam` MODIFY COLUMN IF EXISTS `edukasi` text NOT NULL AFTER `tindakan`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpk`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `penampilan` text NOT NULL AFTER `alergi`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `pembicaraan` text NOT NULL AFTER `penampilan`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `psikomotor` text NOT NULL AFTER `pembicaraan`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `sikap` text NOT NULL AFTER `psikomotor`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `mood` text NOT NULL AFTER `sikap`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `fungsi_kognitif` text NOT NULL AFTER `mood`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `gangguan_persepsi` text NOT NULL AFTER `fungsi_kognitif`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `proses_pikir` text NOT NULL AFTER `gangguan_persepsi`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `pengendalian_impuls` text NOT NULL AFTER `proses_pikir`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `tilikan` text NOT NULL AFTER `pengendalian_impuls`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `rta` text NOT NULL AFTER `tilikan`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `ket_fisik` text NOT NULL AFTER `kulit`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `penunjang` text NOT NULL AFTER `ket_fisik`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `penunjang`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `tata` text NOT NULL AFTER `diagnosis`;

ALTER TABLE `penilaian_medis_ralan_psikiatrik` MODIFY COLUMN IF EXISTS `konsulrujuk` text NOT NULL AFTER `tata`;

ALTER TABLE `penilaian_medis_ralan_rehab_medik` MODIFY COLUMN IF EXISTS `keluhan_utama` text NULL DEFAULT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ralan_rehab_medik` MODIFY COLUMN IF EXISTS `rps` text NULL DEFAULT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan_rehab_medik` MODIFY COLUMN IF EXISTS `rpd` text NULL DEFAULT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ralan_rehab_medik` MODIFY COLUMN IF EXISTS `lainnya` text NULL DEFAULT NULL AFTER `keterangan_muskulos`;

ALTER TABLE `penilaian_medis_ralan_rehab_medik` MODIFY COLUMN IF EXISTS `diagnosa_medis` text NULL DEFAULT NULL AFTER `kebutuhan_fungsional`;

ALTER TABLE `penilaian_medis_ralan_rehab_medik` MODIFY COLUMN IF EXISTS `diagnosa_fungsi` text NULL DEFAULT NULL AFTER `diagnosa_medis`;

ALTER TABLE `penilaian_medis_ralan_rehab_medik` MODIFY COLUMN IF EXISTS `penunjang_lain` text NULL DEFAULT NULL AFTER `diagnosa_fungsi`;

ALTER TABLE `penilaian_medis_ralan_rehab_medik` MODIFY COLUMN IF EXISTS `edukasi` text NULL DEFAULT NULL AFTER `terapi_lainnya`;

ALTER TABLE `penilaian_medis_ralan_tht` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ralan_tht` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ralan_tht` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_ralan_tht` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `penunjang`;

ALTER TABLE `penilaian_medis_ralan_tht` MODIFY COLUMN IF EXISTS `diagnosisbanding` text NOT NULL AFTER `diagnosis`;

ALTER TABLE `penilaian_medis_ralan_tht` MODIFY COLUMN IF EXISTS `edukasi` text NOT NULL AFTER `tatalaksana`;

ALTER TABLE `penilaian_medis_ranap` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ranap` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ranap` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ranap` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_ranap` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpk`;

ALTER TABLE `penilaian_medis_ranap` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `penunjang`;

ALTER TABLE `penilaian_medis_ranap` MODIFY COLUMN IF EXISTS `edukasi` text NOT NULL AFTER `tata`;

ALTER TABLE `penilaian_medis_ranap_kandungan` MODIFY COLUMN IF EXISTS `keluhan_utama` text NOT NULL AFTER `hubungan`;

ALTER TABLE `penilaian_medis_ranap_kandungan` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_medis_ranap_kandungan` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_medis_ranap_kandungan` MODIFY COLUMN IF EXISTS `rpk` text NOT NULL AFTER `rpd`;

ALTER TABLE `penilaian_medis_ranap_kandungan` MODIFY COLUMN IF EXISTS `rpo` text NOT NULL AFTER `rpk`;

ALTER TABLE `penilaian_medis_ranap_kandungan` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `lab`;

ALTER TABLE `penilaian_medis_ranap_kandungan` MODIFY COLUMN IF EXISTS `edukasi` text NOT NULL AFTER `tata`;

ALTER TABLE `penilaian_medis_ranap_neonatus` MODIFY COLUMN IF EXISTS `pemeriksaan_regional` text NOT NULL AFTER `kelainan_lainnya`;

ALTER TABLE `penilaian_medis_ranap_neonatus` MODIFY COLUMN IF EXISTS `lab` text NOT NULL AFTER `pemeriksaan_regional`;

ALTER TABLE `penilaian_medis_ranap_neonatus` MODIFY COLUMN IF EXISTS `radiologi` text NOT NULL AFTER `lab`;

ALTER TABLE `penilaian_medis_ranap_neonatus` MODIFY COLUMN IF EXISTS `penunjanglainnya` text NOT NULL AFTER `radiologi`;

ALTER TABLE `penilaian_medis_ranap_neonatus` MODIFY COLUMN IF EXISTS `diagnosis` text NOT NULL AFTER `penunjanglainnya`;

ALTER TABLE `penilaian_medis_ranap_neonatus` MODIFY COLUMN IF EXISTS `tata` text NOT NULL AFTER `diagnosis`;

ALTER TABLE `penilaian_medis_ranap_neonatus` MODIFY COLUMN IF EXISTS `edukasi` text NOT NULL AFTER `tata`;

ALTER TABLE `penilaian_pasien_imunitas_rendah` MODIFY COLUMN IF EXISTS `riwayat_penyakit_keluhan` text NULL DEFAULT NULL AFTER `kebutuhan_ruang_perawatan`;

ALTER TABLE `penilaian_pasien_imunitas_rendah` MODIFY COLUMN IF EXISTS `riwayat_penyakit_keluarga` text NULL DEFAULT NULL AFTER `riwayat_penyakit_keluhan`;

ALTER TABLE `penilaian_pasien_imunitas_rendah` MODIFY COLUMN IF EXISTS `riwayat_pengobatan` text NULL DEFAULT NULL AFTER `riwayat_vaksinasi`;

ALTER TABLE `penilaian_pasien_imunitas_rendah` MODIFY COLUMN IF EXISTS `diagnosa_utama` text NULL DEFAULT NULL AFTER `riwayat_pengobatan`;

ALTER TABLE `penilaian_pasien_imunitas_rendah` MODIFY COLUMN IF EXISTS `diagnosa_tambahan` text NULL DEFAULT NULL AFTER `diagnosa_utama`;

ALTER TABLE `penilaian_pasien_keracunan` MODIFY COLUMN IF EXISTS `keluhan` text NULL DEFAULT NULL AFTER `keterangan_tempat_kejadian`;

ALTER TABLE `penilaian_pasien_keracunan` MODIFY COLUMN IF EXISTS `riwayat_penyakit_sekarang` text NULL DEFAULT NULL AFTER `keluhan`;

ALTER TABLE `penilaian_pasien_keracunan` MODIFY COLUMN IF EXISTS `pengobatan_sebelum_igd` text NULL DEFAULT NULL AFTER `urine`;

ALTER TABLE `penilaian_pasien_keracunan` MODIFY COLUMN IF EXISTS `diagnosis` text NULL DEFAULT NULL AFTER `pengobatan_sebelum_igd`;

ALTER TABLE `penilaian_pasien_keracunan` MODIFY COLUMN IF EXISTS `pemeriksaan_penunjang` text NULL DEFAULT NULL AFTER `diagnosis`;

ALTER TABLE `penilaian_pasien_keracunan` MODIFY COLUMN IF EXISTS `penatalaksanaan_diberikan` text NULL DEFAULT NULL AFTER `pemeriksaan_penunjang`;

ALTER TABLE `penilaian_pasien_penyakit_menular` MODIFY COLUMN IF EXISTS `keluhan_yang_dirasakan_saat_ini` text NULL DEFAULT NULL AFTER `kebutuhan_ruang_rawat`;

ALTER TABLE `penilaian_pasien_penyakit_menular` MODIFY COLUMN IF EXISTS `riwayat_penyakit_keluarga` text NULL DEFAULT NULL AFTER `keluhan_yang_dirasakan_saat_ini`;

ALTER TABLE `penilaian_pasien_penyakit_menular` MODIFY COLUMN IF EXISTS `riwayat_pengobatan` text NULL DEFAULT NULL AFTER `riwayat_vaksinasi`;

ALTER TABLE `penilaian_pasien_penyakit_menular` MODIFY COLUMN IF EXISTS `diagnosa_utama` text NULL DEFAULT NULL AFTER `riwayat_pengobatan`;

ALTER TABLE `penilaian_pasien_penyakit_menular` MODIFY COLUMN IF EXISTS `diagnosa_tambahan` text NULL DEFAULT NULL AFTER `diagnosa_utama`;

ALTER TABLE `penilaian_pasien_terminal` MODIFY COLUMN IF EXISTS `diagnosa` text NOT NULL AFTER `tanggal`;

ALTER TABLE `penilaian_pasien_terminal` MODIFY COLUMN IF EXISTS `rps` text NOT NULL AFTER `diagnosa`;

ALTER TABLE `penilaian_pasien_terminal` MODIFY COLUMN IF EXISTS `rpd` text NOT NULL AFTER `rps`;

ALTER TABLE `penilaian_pasien_terminal` MODIFY COLUMN IF EXISTS `kebutuhan_spiritual_pasien` text NULL DEFAULT NULL AFTER `tanda_klinis_menjelang_kematian`;

ALTER TABLE `penilaian_pre_induksi` MODIFY COLUMN IF EXISTS `perencanaan` text NULL DEFAULT NULL AFTER `asesmen`;

ALTER TABLE `penilaian_pre_induksi` MODIFY COLUMN IF EXISTS `infus_perifier` text NULL DEFAULT NULL AFTER `perencanaan`;

ALTER TABLE `penilaian_pre_induksi` MODIFY COLUMN IF EXISTS `intubasi_keterangan` text NULL DEFAULT NULL AFTER `intubasi_tracheostomi`;

ALTER TABLE `penilaian_pre_induksi` MODIFY COLUMN IF EXISTS `teknik_regional_obat_obatan` text NULL DEFAULT NULL AFTER `teknik_regional_kateter_viksasi`;

ALTER TABLE `penilaian_pre_induksi` MODIFY COLUMN IF EXISTS `teknik_regional_komplikasi` text NULL DEFAULT NULL AFTER `teknik_regional_obat_obatan`;

ALTER TABLE `penilaian_pre_operasi` MODIFY COLUMN IF EXISTS `ringkasan_klinik` text NULL DEFAULT NULL AFTER `kd_dokter`;

ALTER TABLE `penilaian_pre_operasi` MODIFY COLUMN IF EXISTS `pemeriksaan_fisik` text NULL DEFAULT NULL AFTER `ringkasan_klinik`;

ALTER TABLE `penilaian_pre_operasi` MODIFY COLUMN IF EXISTS `pemeriksaan_diagnostik` text NULL DEFAULT NULL AFTER `pemeriksaan_fisik`;

ALTER TABLE `penilaian_pre_operasi` MODIFY COLUMN IF EXISTS `diagnosa_pre_operasi` text NULL DEFAULT NULL AFTER `pemeriksaan_diagnostik`;

ALTER TABLE `penilaian_pre_operasi` MODIFY COLUMN IF EXISTS `rencana_tindakan_bedah` text NULL DEFAULT NULL AFTER `diagnosa_pre_operasi`;

ALTER TABLE `penilaian_pre_operasi` MODIFY COLUMN IF EXISTS `hal_hal_yang_perludi_persiapkan` text NULL DEFAULT NULL AFTER `rencana_tindakan_bedah`;

ALTER TABLE `penilaian_pre_operasi` MODIFY COLUMN IF EXISTS `terapi_pre_operasi` text NULL DEFAULT NULL AFTER `hal_hal_yang_perludi_persiapkan`;

ALTER TABLE `penilaian_psikologi` MODIFY COLUMN IF EXISTS `ciri_menyolok` text NOT NULL AFTER `penggunaan_kata`;

ALTER TABLE `penilaian_psikologi_klinis` MODIFY COLUMN IF EXISTS `ket_anamnesis` text NULL DEFAULT NULL AFTER `tujuan_pemeriksaan`;

ALTER TABLE `penilaian_psikologi_klinis` MODIFY COLUMN IF EXISTS `keluhan_utama` text NULL DEFAULT NULL AFTER `ket_anamnesis`;

ALTER TABLE `penilaian_psikologi_klinis` MODIFY COLUMN IF EXISTS `riwayat_penyakit` text NULL DEFAULT NULL AFTER `keluhan_utama`;

ALTER TABLE `penilaian_psikologi_klinis` MODIFY COLUMN IF EXISTS `riwayat_keluhan` text NULL DEFAULT NULL AFTER `riwayat_penyakit`;

ALTER TABLE `penilaian_psikologi_klinis` MODIFY COLUMN IF EXISTS `riwayat_hidup_singkat` text NULL DEFAULT NULL AFTER `permasalahan_ekspektasi`;

ALTER TABLE `penilaian_psikologi_klinis` MODIFY COLUMN IF EXISTS `dinamika_psikologis` text NULL DEFAULT NULL AFTER `psikotes_hasil`;

ALTER TABLE `penilaian_psikologi_klinis` MODIFY COLUMN IF EXISTS `diagnosa_psikologis` text NULL DEFAULT NULL AFTER `dinamika_psikologis`;

ALTER TABLE `penilaian_psikologi_klinis` MODIFY COLUMN IF EXISTS `manifestasi_fungsi_psikologis` text NULL DEFAULT NULL AFTER `diagnosa_psikologis`;

ALTER TABLE `penilaian_psikologi_klinis` MODIFY COLUMN IF EXISTS `rencana_intervensi` text NULL DEFAULT NULL AFTER `manifestasi_fungsi_psikologis`;

ALTER TABLE `penilaian_psikologi_klinis` MODIFY COLUMN IF EXISTS `evaluasi` text NULL DEFAULT NULL AFTER `target_terapi7`;

ALTER TABLE `penilaian_tambahan_beresiko_melarikan_diri` MODIFY COLUMN IF EXISTS `faktor_faktor_pencegahan` text NULL DEFAULT NULL AFTER `dinamis_skortotal`;

ALTER TABLE `penilaian_tambahan_bunuh_diri` MODIFY COLUMN IF EXISTS `faktor_faktor_pencegahan` text NULL DEFAULT NULL AFTER `dinamis_skortotal`;

ALTER TABLE `penilaian_tambahan_perilaku_kekerasan` MODIFY COLUMN IF EXISTS `faktor_faktor_pencegahan` text NULL DEFAULT NULL AFTER `dinamis_skortotal`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `diagnosa_terapi_wicara` text NULL DEFAULT NULL AFTER `tanggal`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `diagnosa_medis` text NULL DEFAULT NULL AFTER `diagnosa_terapi_wicara`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `anamnesa` text NOT NULL AFTER `diagnosa_medis`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `aktifitas_oral_menghisap` text NOT NULL AFTER `organ_wicara_fisiologis_faring`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `aktifitas_oral_mengunyah` text NOT NULL AFTER `aktifitas_oral_menghisap`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `aktifitas_oral_meniup` text NOT NULL AFTER `aktifitas_oral_mengunyah`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `kemampuan_artikulasi_subtitusi` text NOT NULL AFTER `aktifitas_oral_meniup`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `kemampuan_artikulasi_omisi` text NOT NULL AFTER `kemampuan_artikulasi_subtitusi`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `kemampuan_artikulasi_distorsi` text NOT NULL AFTER `kemampuan_artikulasi_omisi`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `kemampuan_artikulasi_adisi` text NOT NULL AFTER `kemampuan_artikulasi_distorsi`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `kemampuan_menelan` text NOT NULL AFTER `kemampuan_irama_kelancaran`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `pernafasan` text NOT NULL AFTER `kemampuan_menelan`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `penunjang_medis` text NOT NULL AFTER `tingkat_komunikasi_enkoding_gesture`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `perencanaan_terapi_tujuan` text NOT NULL AFTER `penunjang_medis`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `perencanaan_terapi_program` text NOT NULL AFTER `perencanaan_terapi_tujuan`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `edukasi` text NOT NULL AFTER `perencanaan_terapi_program`;

ALTER TABLE `penilaian_terapi_wicara` MODIFY COLUMN IF EXISTS `tindak_lanjut` text NOT NULL AFTER `edukasi`;

ALTER TABLE `penilaian_ulang_nyeri` MODIFY COLUMN IF EXISTS `provokes` enum('-','Proses Penyakit','Benturan','Lain-lain') NOT NULL AFTER `nyeri`;

ALTER TABLE `penilaian_ulang_nyeri` MODIFY COLUMN IF EXISTS `quality` enum('-','Seperti Tertusuk','Berdenyut','Teriris','Tertindih','Tertiban','Lain-lain') NOT NULL AFTER `ket_provokes`;

ALTER TABLE `penilaian_ulang_nyeri` MODIFY COLUMN IF EXISTS `nyeri_hilang` enum('-','Istirahat','Medengar Musik','Minum Obat') NOT NULL AFTER `durasi`;

ALTER TABLE `penjab` ADD COLUMN IF NOT EXISTS `email` varchar(50) NOT NULL DEFAULT '' AFTER `no_telp`;

ALTER TABLE `penjab` ADD COLUMN IF NOT EXISTS `no_npwp` varchar(30) NOT NULL DEFAULT '' AFTER `attn`;

ALTER TABLE `penjab` MODIFY COLUMN IF EXISTS `png_jawab` varchar(50) NOT NULL AFTER `kd_pj`;

ALTER TABLE `penjab` MODIFY COLUMN IF EXISTS `nama_perusahaan` varchar(100) NOT NULL AFTER `png_jawab`;

ALTER TABLE `penyakit` MODIFY COLUMN IF EXISTS `deskripsi_panjang` varchar(300) NULL DEFAULT NULL AFTER `kd_penyakit`;

ALTER TABLE `perusahaan_pasien` ADD COLUMN IF NOT EXISTS `email` varchar(50) NULL DEFAULT NULL AFTER `no_telp`;

ALTER TABLE `perusahaan_pasien` ADD COLUMN IF NOT EXISTS `no_npwp` varchar(30) NULL DEFAULT NULL AFTER `email`;

ALTER TABLE `perusahaan_pasien` MODIFY COLUMN IF EXISTS `nama_perusahaan` varchar(120) NULL DEFAULT NULL AFTER `kode_perusahaan`;

ALTER TABLE `piutang` MODIFY COLUMN IF EXISTS `nota_piutang` varchar(40) NOT NULL FIRST;

ALTER TABLE `detailpiutang` ADD CONSTRAINT `detailpiutang_ibfk_1` FOREIGN KEY IF NOT EXISTS (`nota_piutang`) REFERENCES `piutang` ON DELETE CASCADE ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS `pengajuan_fingerprint_bpjs_smc`  (
  `no_rkm_medis` varchar(15) NOT NULL,
  `no_kartu` varchar(25) NOT NULL,
  `tglsep` date NOT NULL,
  `status_pengajuan` varchar(1000) NULL DEFAULT NULL,
  `status_approval` varchar(1000) NULL DEFAULT NULL,
  `nip` varchar(20) NOT NULL,
  PRIMARY KEY (`no_rkm_medis`,`tglsep`) USING BTREE,
  INDEX `no_kartu`(`no_kartu`) USING BTREE,
  INDEX `tglsep`(`tglsep`) USING BTREE,
  INDEX `nip`(`nip`) USING BTREE,
  CONSTRAINT `pengajuan_fingerprint_bpjs_smc_ibfk_1` FOREIGN KEY (`no_rkm_medis`) REFERENCES `pasien` (`no_rkm_medis`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `pintu_smc`  (
  `kd_pintu` varchar(20) NOT NULL DEFAULT '',
  `nm_pintu` varchar(50) NULL DEFAULT NULL,
  `status` enum('0','1') NOT NULL DEFAULT '1',
  PRIMARY KEY (`kd_pintu`) USING BTREE,
  INDEX `nm_pintu` (`nm_pintu`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `prosedur_pasien` DROP INDEX IF EXISTS `PRIMARY`;

ALTER TABLE `prosedur_pasien` ADD PRIMARY KEY IF NOT EXISTS (`no_rawat`, `kode`, `status`, `prioritas`) USING BTREE;

ALTER TABLE `referensi_mobilejkn_bpjs` DROP INDEX IF EXISTS `no_rawat`;

CREATE TABLE IF NOT EXISTS `referensi_mobilejkn_bpjs_taskid_response2`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `no_rawat` varchar(17) NOT NULL,
  `kodebooking` varchar(17) NULL DEFAULT NULL,
  `jenispasien` enum('MobileJKN','Onsite') NULL DEFAULT NULL,
  `taskid` enum('addantrean','batalantrean','addantreanfarmasi','1','2','3','4','5','6','7','99') NULL DEFAULT NULL,
  `request` varchar(5000) NULL DEFAULT NULL,
  `code` varchar(5) NULL DEFAULT NULL,
  `message` varchar(200) NULL DEFAULT NULL,
  `response` varchar(5000) NULL DEFAULT NULL,
  `waktu` datetime NULL DEFAULT NULL,
  `waktu_rs` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `referensi_mobilejkn_bpjs_taskid_response_no_rawat_IDX`(`no_rawat`) USING BTREE,
  INDEX `referensi_mobilejkn_bpjs_taskid_response_waktu_IDX`(`waktu`) USING BTREE,
  INDEX `referensi_mobilejkn_bpjs_taskid_response_kodebooking_IDX`(`kodebooking`) USING BTREE,
  INDEX `referensi_mobilejkn_bpjs_taskid_response_jenispasien_IDX`(`jenispasien`) USING BTREE,
  INDEX `referensi_mobilejkn_bpjs_taskid_response_taskid_IDX`(`taskid`) USING BTREE,
  INDEX `referensi_mobilejkn_bpjs_taskid_response_code_IDX`(`code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `reg_periksa` MODIFY COLUMN IF EXISTS `stts` enum('Belum','Sudah','Batal','Berkas Diterima','Dirujuk','Meninggal','Dirawat','Pulang Paksa','TTV','Rujuk Internal') NULL DEFAULT NULL AFTER `biaya_reg`;

ALTER TABLE `reg_periksa` ADD INDEX IF NOT EXISTS `tgl_registrasi`(`tgl_registrasi`) USING BTREE;

ALTER TABLE `rekap_presensi` MODIFY COLUMN IF EXISTS `shift` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `resep_dokter` ADD INDEX IF NOT EXISTS resep_dokter_ibfk_3 (`no_resep`, `kode_brng`) USING BTREE;

ALTER TABLE `resep_obat` ADD COLUMN IF NOT EXISTS `nama_template` varchar(100) NULL DEFAULT NULL AFTER `jam_penyerahan`;

ALTER TABLE `resep_obat` ADD INDEX IF NOT EXISTS `idx_resep_obat_peresepan_status_dokter_perawatan`(`tgl_peresepan`, `status`, `kd_dokter`, `tgl_perawatan`) USING BTREE;

ALTER TABLE `resep_obat` ADD INDEX IF NOT EXISTS `idx_peresepan_desc`(`tgl_peresepan`, `jam_peresepan`) USING BTREE;

ALTER TABLE `resep_obat` ADD INDEX IF NOT EXISTS `idx_nama_template`(`nama_template`) USING BTREE;

ALTER TABLE `resiko_kerja` MODIFY COLUMN IF EXISTS `nama_resiko` varchar(200) NULL DEFAULT NULL AFTER `kode_resiko`;

ALTER TABLE `resume_pasien` MODIFY COLUMN IF EXISTS `diagnosa_utama` varchar(200) NOT NULL AFTER `hasil_laborat`;

ALTER TABLE `resume_pasien` MODIFY COLUMN IF EXISTS `diagnosa_sekunder` varchar(200) NOT NULL AFTER `kd_diagnosa_utama`;

ALTER TABLE `resume_pasien` MODIFY COLUMN IF EXISTS `diagnosa_sekunder2` varchar(200) NOT NULL AFTER `kd_diagnosa_sekunder`;

ALTER TABLE `resume_pasien` MODIFY COLUMN IF EXISTS `diagnosa_sekunder3` varchar(200) NOT NULL AFTER `kd_diagnosa_sekunder2`;

ALTER TABLE `resume_pasien` MODIFY COLUMN IF EXISTS `diagnosa_sekunder4` varchar(200) NOT NULL AFTER `kd_diagnosa_sekunder3`;

ALTER TABLE `resume_pasien` MODIFY COLUMN IF EXISTS `prosedur_utama` varchar(200) NOT NULL AFTER `kd_diagnosa_sekunder4`;

ALTER TABLE `resume_pasien` MODIFY COLUMN IF EXISTS `prosedur_sekunder` varchar(200) NOT NULL AFTER `kd_prosedur_utama`;

ALTER TABLE `resume_pasien` MODIFY COLUMN IF EXISTS `prosedur_sekunder2` varchar(200) NOT NULL AFTER `kd_prosedur_sekunder`;

ALTER TABLE `resume_pasien` MODIFY COLUMN IF EXISTS `prosedur_sekunder3` varchar(200) NOT NULL AFTER `kd_prosedur_sekunder2`;

ALTER TABLE `resume_pasien_ranap` MODIFY COLUMN IF EXISTS `diagnosa_utama` varchar(200) NOT NULL AFTER `obat_di_rs`;

ALTER TABLE `resume_pasien_ranap` MODIFY COLUMN IF EXISTS `diagnosa_sekunder` varchar(200) NOT NULL AFTER `kd_diagnosa_utama`;

ALTER TABLE `resume_pasien_ranap` MODIFY COLUMN IF EXISTS `diagnosa_sekunder2` varchar(200) NOT NULL AFTER `kd_diagnosa_sekunder`;

ALTER TABLE `resume_pasien_ranap` MODIFY COLUMN IF EXISTS `diagnosa_sekunder3` varchar(200) NOT NULL AFTER `kd_diagnosa_sekunder2`;

ALTER TABLE `resume_pasien_ranap` MODIFY COLUMN IF EXISTS `diagnosa_sekunder4` varchar(200) NOT NULL AFTER `kd_diagnosa_sekunder3`;

ALTER TABLE `resume_pasien_ranap` MODIFY COLUMN IF EXISTS `prosedur_utama` varchar(200) NOT NULL AFTER `kd_diagnosa_sekunder4`;

ALTER TABLE `resume_pasien_ranap` MODIFY COLUMN IF EXISTS `prosedur_sekunder` varchar(200) NOT NULL AFTER `kd_prosedur_utama`;

ALTER TABLE `resume_pasien_ranap` MODIFY COLUMN IF EXISTS `prosedur_sekunder2` varchar(200) NOT NULL AFTER `kd_prosedur_sekunder`;

ALTER TABLE `resume_pasien_ranap` MODIFY COLUMN IF EXISTS `prosedur_sekunder3` varchar(200) NOT NULL AFTER `kd_prosedur_sekunder2`;

ALTER TABLE `riwayat_barang_medis` MODIFY COLUMN IF EXISTS `keterangan` varchar(500) NOT NULL AFTER `no_faktur`;

ALTER TABLE `riwayat_barang_medis` ADD INDEX IF NOT EXISTS `riwayat_barang_medis_ibfk_2`(`tanggal`) USING BTREE;

ALTER TABLE `riwayat_barang_medis` ADD INDEX IF NOT EXISTS `riwayat_barang_medis_ibfk_3`(`kode_brng`, `kd_bangsal`, `tanggal` DESC, `jam` DESC) USING BTREE;

ALTER TABLE `saran_kesan_lab` MODIFY COLUMN IF EXISTS `saran` varchar(1000) NULL DEFAULT NULL AFTER `jam`;

ALTER TABLE `saran_kesan_lab` MODIFY COLUMN IF EXISTS `kesan` varchar(1000) NULL DEFAULT NULL AFTER `saran`;

CREATE TABLE IF NOT EXISTS `satu_sehat_accession_radiologi_smc`  (
  `noorder` varchar(15) NOT NULL,
  `kd_jenis_prw` varchar(15) NOT NULL,
  `no_acsn` varchar(16) NOT NULL,
  `study_iuid` varchar(64) NULL DEFAULT NULL,
  `worklist_id` varchar(64) NULL DEFAULT NULL,
  `aet_tujuan` varchar(16) NULL DEFAULT NULL,
  `tgl_kirim_worklist` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`noorder`,`kd_jenis_prw`) USING BTREE,
  UNIQUE KEY `satu_sehat_accession_radiologi_smc_no_acsn` (`no_acsn`) USING BTREE,
  INDEX `satu_sehat_accession_radiologi_smc_ibfk_1`(`kd_jenis_prw`) USING BTREE,
  INDEX `satu_sehat_accession_radiologi_smc_ibfk_2`(`noorder`) USING BTREE,
  CONSTRAINT `satu_sehat_accession_radiologi_smc_ibfk_3` FOREIGN KEY (`noorder`, `kd_jenis_prw`) REFERENCES `permintaan_pemeriksaan_radiologi` (`noorder`, `kd_jenis_prw`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `satu_sehat_mapping_radiologi` MODIFY COLUMN IF EXISTS `code` varchar(20) NOT NULL AFTER `kd_jenis_prw`;

ALTER TABLE `satu_sehat_mapping_radiologi` MODIFY COLUMN IF EXISTS `display` varchar(200) NOT NULL AFTER `system`;

ALTER TABLE `satu_sehat_mapping_radiologi` MODIFY COLUMN IF EXISTS `sampel_code` varchar(20) NOT NULL AFTER `display`;

ALTER TABLE `satu_sehat_mapping_radiologi` MODIFY COLUMN IF EXISTS `sampel_display` varchar(200) NOT NULL AFTER `sampel_system`;

ALTER TABLE `satu_sehat_mapping_obat` MODIFY COLUMN IF EXISTS `obat_display` varchar(500) NULL DEFAULT NULL AFTER `obat_system`;

CREATE TABLE IF NOT EXISTS `satu_sehat_referensi_denominator`  (
  `code` varchar(30) NOT NULL,
  `display` varchar(100) NULL DEFAULT NULL,
  `definition` varchar(400) NULL DEFAULT NULL,
  `status` varchar(10) NULL DEFAULT NULL,
  `system` varchar(100) NOT NULL,
  PRIMARY KEY (`code`, `system`) USING BTREE,
  INDEX `satu_sehat_referensi_denominator_obat_display_ibfk_1`(`display`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `satu_sehat_referensi_lab_loinc`  (
  `code` varchar(30) NOT NULL,
  `system` varchar(100) NOT NULL,
  `display` varchar(300) NULL DEFAULT NULL,
  PRIMARY KEY (`code`, `system`) USING BTREE,
  INDEX `display`(`display`) USING BTREE
) ENGINE = MyISAM CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `satu_sehat_referensi_lab_snomed`  (
  `code` varchar(40) NOT NULL,
  `system` varchar(100) NOT NULL,
  `display` varchar(600) NULL DEFAULT NULL,
  PRIMARY KEY (`code`, `system`) USING BTREE,
  INDEX `display`(`display`) USING BTREE
) ENGINE = MyISAM CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `satu_sehat_referensi_numerator`  (
  `code` varchar(30) NOT NULL,
  `display` varchar(200) NULL DEFAULT NULL,
  `system` varchar(100) NOT NULL,
  PRIMARY KEY (`code`, `display`) USING BTREE,
  INDEX `satu_sehat_referensi_numerator_obat_display_ibfk_1`(`display`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `satu_sehat_referensi_patient`  (
  `no_ktp` varchar(20) NOT NULL,
  `patient_ihs_number` varchar(20) NOT NULL,
  PRIMARY KEY (`no_ktp`, `patient_ihs_number`) USING BTREE
) ENGINE = MyISAM CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `satu_sehat_referensi_practitioneer`  (
  `no_ktp` varchar(20) NOT NULL,
  `practition_his_number` varchar(20) NOT NULL,
  PRIMARY KEY (`no_ktp`, `practition_his_number`) USING BTREE
) ENGINE = MyISAM CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `satu_sehat_referensi_radiologi_loinc`  (
  `code` varchar(30) NOT NULL,
  `system` varchar(100) NOT NULL,
  `display` varchar(300) NULL DEFAULT NULL,
  PRIMARY KEY (`code`, `system`) USING BTREE,
  INDEX `display`(`display`) USING BTREE
) ENGINE = MyISAM CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `satu_sehat_referensi_radiologi_snomed`  (
  `code` varchar(30) NOT NULL,
  `system` varchar(100) NOT NULL,
  `display` varchar(300) NULL DEFAULT NULL,
  PRIMARY KEY (`code`, `system`) USING BTREE,
  INDEX `display`(`display`) USING BTREE
) ENGINE = MyISAM CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `satu_sehat_referensi_route`  (
  `code` varchar(30) NOT NULL,
  `display` varchar(100) NULL DEFAULT NULL,
  `keterangan` text NULL DEFAULT NULL,
  `system` varchar(100) NOT NULL,
  PRIMARY KEY (`code`, `system`) USING BTREE,
  INDEX `satu_sehat_referensi_route_display_ibfk_1`(`display`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `set_akses_edit_sementara`  (
  `id_user` varchar(700) NOT NULL,
  `tgl_selesai` datetime NOT NULL,
  PRIMARY KEY (`id_user`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE satu_sehat_episode_of_care ( no_rawat VARCHAR(17) NOT NULL COLLATE 'latin1_swedish_ci',
 kd_penyakit VARCHAR(15) NOT NULL COLLATE 'latin1_swedish_ci', status ENUM('Ralan','Ranap') NOT NULL COLLATE 'latin1_swedish_ci',
 id_episode_of_care VARCHAR(40) NULL DEFAULT NULL COLLATE 'latin1_swedish_ci', PRIMARY KEY (`no_rawat`, kd_penyakit, `status`) USING BTREE,
 INDEX kd_penyakit (`kd_penyakit`) USING BTREE, INDEX status (`status`) USING BTREE,
 INDEX no_rawat (`no_rawat`) USING BTREE, CONSTRAINT satu_sehat_episode_of_care_ibfk_1 FOREIGN KEY (`no_rawat`) REFERENCES reg_periksa (`no_rawat`) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT satu_sehat_episode_of_care_ibfk_2 FOREIGN KEY (`kd_penyakit`) REFERENCES penyakit (`kd_penyakit`) ON UPDATE CASCADE ON DELETE RESTRICT)
COLLATE='latin1_swedish_ci'ENGINE=InnoDB
ROW_FORMAT=DYNAMIC;

CREATE TABLE `satu_sehat_imagingstudy_radiologi`  (
  `noorder` varchar(15) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `kd_jenis_prw` varchar(15) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `id_servicerequest` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `id_imaging` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  PRIMARY KEY (`noorder`, `kd_jenis_prw`) USING BTREE,
  INDEX `kd_jenis_prw`(`kd_jenis_prw` ASC) USING BTREE,
  CONSTRAINT `satu_sehat_imagingstudy_radiologi_ibfk_1` FOREIGN KEY (`noorder`) REFERENCES `permintaan_radiologi` (`noorder`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `satu_sehat_imagingstudy_radiologi_ibfk_2` FOREIGN KEY (`kd_jenis_prw`) REFERENCES `jns_perawatan_radiologi` (`kd_jenis_prw`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = DYNAMIC;

ALTER TABLE `set_akun2` MODIFY COLUMN IF EXISTS `Piutang_Jasa_Perusahaan` varchar(15) NULL DEFAULT NULL AFTER `Kontra_Hibah_Dapur`;

ALTER TABLE `set_akun2` MODIFY COLUMN IF EXISTS `Pendapatan_Piutang_Jasa_Perusahaan` varchar(15) NULL DEFAULT NULL AFTER `Piutang_Jasa_Perusahaan`;

CREATE TABLE IF NOT EXISTS `set_filter_jenis_resep_obat_ralan`  (
  `kd_poli` char(5) NOT NULL,
  `kd_pj` char(3) NOT NULL,
  `kdjns` char(4) NOT NULL,
  PRIMARY KEY (`kd_poli`, `kd_pj`, `kdjns`) USING BTREE,
  INDEX `set_filter_jenis_resep_obat_ralan_kd_pj_ibfk1`(`kd_pj`) USING BTREE,
  INDEX `set_filter_jenis_resep_obat_ralan_kdjns_ibfk1`(`kdjns`) USING BTREE,
  CONSTRAINT `set_filter_jenis_resep_obat_ralan_kd_pj_ibfk1` FOREIGN KEY (`kd_pj`) REFERENCES `penjab` (`kd_pj`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `set_filter_jenis_resep_obat_ralan_kd_poli_ibfk1` FOREIGN KEY (`kd_poli`) REFERENCES `poliklinik` (`kd_poli`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `set_filter_jenis_resep_obat_ralan_kdjns_ibfk1` FOREIGN KEY (`kdjns`) REFERENCES `jenis` (`kdjns`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `set_filter_jenis_resep_obat_ranap`  (
  `kd_bangsal` char(5) NOT NULL,
  `kd_pj` char(3) NOT NULL,
  `kdjns` char(4) NOT NULL,
  PRIMARY KEY (`kd_bangsal`, `kd_pj`, `kdjns`) USING BTREE,
  INDEX `set_filter_jenis_resep_obat_ranap_kd_pj_ibfk1`(`kd_pj`) USING BTREE,
  INDEX `set_filter_jenis_resep_obat_ranap_kdjns_ibfk1`(`kdjns`) USING BTREE,
  CONSTRAINT `set_filter_jenis_resep_obat_ranap_kd_bangsal_ibfk1` FOREIGN KEY (`kd_bangsal`) REFERENCES `bangsal` (`kd_bangsal`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `set_filter_jenis_resep_obat_ranap_kd_pj_ibfk1` FOREIGN KEY (`kd_pj`) REFERENCES `penjab` (`kd_pj`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `set_filter_jenis_resep_obat_ranap_kdjns_ibfk1` FOREIGN KEY (`kdjns`) REFERENCES `jenis` (`kdjns`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `set_kode_shift_smc`  (
  `shift` varchar(15) NOT NULL,
  `kode_shift` varchar(5) NOT NULL,
  PRIMARY KEY (`kode_shift`) USING BTREE,
  UNIQUE INDEX `shift`(`shift`) USING BTREE,
  CONSTRAINT `set_kode_shift_smc_ibfk_1` FOREIGN KEY (`kode_shift`) REFERENCES `jam_masuk_smc` (`kode_shift`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `set_pintu_smc`  (
  `kd_pintu` varchar(20) NOT NULL DEFAULT '',
  `kd_dokter` varchar(20) NOT NULL,
  `kd_poli` char(5) NOT NULL,
  PRIMARY KEY (`kd_pintu`, `kd_dokter`, `kd_poli`) USING BTREE,
  CONSTRAINT `set_pintu_smc_ibfk_1` FOREIGN KEY (`kd_pintu`) REFERENCES `pintu_smc` (`kd_pintu`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `set_pintu_smc_ibfk_2` FOREIGN KEY (`kd_dokter`) REFERENCES `dokter` (`kd_dokter`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `set_pintu_smc_ibfk_3` FOREIGN KEY (`kd_poli`) REFERENCES `poliklinik` (`kd_poli`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `set_validasi_registrasi` MODIFY COLUMN IF EXISTS `wajib_closing_kasir` enum('Yes','Peringatan di hari yang sama','No') NULL DEFAULT NULL FIRST;

ALTER TABLE `setting` ADD COLUMN IF NOT EXISTS `pemberlakuan_2x24_jam` enum('Yes','No') NULL DEFAULT NULL AFTER `logo`;

ALTER TABLE `setting` ADD COLUMN IF NOT EXISTS `sistem_import_koding` enum('','IDRG','INA-CBG') NULL DEFAULT NULL AFTER `pemberlakuan_2x24_jam`;

ALTER TABLE `setting` ADD COLUMN IF NOT EXISTS `kode_ppkapotek` varchar(15) NULL DEFAULT NULL AFTER `sistem_import_koding`;

CREATE TABLE IF NOT EXISTS `smc_master_masalah_keperawatan`  (
  `menu` varchar(50) NOT NULL,
  `kode_masalah` varchar(3) NOT NULL,
  `nama_masalah` varchar(100) NULL DEFAULT NULL,
  PRIMARY KEY (`menu`,`kode_masalah`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `smc_master_rencana_keperawatan`  (
  `menu` varchar(50) NOT NULL,
  `kode_masalah` varchar(3) NOT NULL,
  `kode_rencana` varchar(3) NOT NULL,
  `rencana_keperawatan` varchar(1000) NOT NULL,
  PRIMARY KEY (`menu`,`kode_masalah`,`kode_rencana`) USING BTREE,
  CONSTRAINT `smc_master_rencana_keperawatan_ibfk_1` FOREIGN KEY (`menu`,`kode_masalah`) REFERENCES `smc_master_masalah_keperawatan` (`menu`,`kode_masalah`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `smc_pengkajian_tindakan_invasif_non_bedah`  (
  `no_rawat` varchar(17) NOT NULL,
  `tanggal` datetime NOT NULL,
  `nip` varchar(20) DEFAULT NULL,
  `diagnosa` varchar(200) DEFAULT NULL,
  `rencana_tindakan` varchar(200) DEFAULT NULL,
  `status_fungsional` varchar(200) DEFAULT NULL,
  `keluhan_utama` text DEFAULT NULL,
  `status_psiko` varchar(50) DEFAULT NULL,
  `ket_psiko` varchar(200) DEFAULT NULL,
  `rpd` text DEFAULT NULL,
  `sistem_pernapasan` varchar(50) DEFAULT NULL,
  `ket_sistem_pernapasan` varchar(200) DEFAULT NULL,
  `muntah_darah` varchar(50) DEFAULT NULL,
  `bab` varchar(50) DEFAULT NULL,
  `urine` varchar(10) DEFAULT NULL,
  `antiplatelet` enum('Tidak','Ya') NOT NULL,
  `lama_antiplatelet` varchar(50) DEFAULT NULL,
  `beta_blocker` enum('Tidak','Ya') NOT NULL,
  `lama_beta_blocker` varchar(50) DEFAULT NULL,
  `simarc` enum('Tidak','Ya') NOT NULL,
  `lama_simarc` varchar(50) DEFAULT NULL,
  `riwayat_alergi` varchar(40) DEFAULT NULL,
  `tb` varchar(10) DEFAULT NULL,
  `bb` varchar(10) DEFAULT NULL,
  `td` varchar(15) DEFAULT NULL,
  `io2` varchar(10) DEFAULT NULL,
  `nadi` varchar(10) DEFAULT NULL,
  `suhu` varchar(10) DEFAULT NULL,
  `pernapasan` varchar(10) DEFAULT NULL,
  `radialis_kanan` enum('Adekuat','Tidak Adekuat') NOT NULL,
  `radialis_kiri` enum('Adekuat','Tidak Adekuat') DEFAULT NULL,
  `pedis_kanan` enum('Adekuat','Tidak Adekuat') DEFAULT NULL,
  `pedis_kiri` enum('Adekuat','Tidak Adekuat') DEFAULT NULL,
  `penilaian_nyeri` enum('Tidak Ada Nyeri','Nyeri Akut','Nyeri Kronis') NOT NULL,
  `penilaian_nyeri_pencetus` varchar(50) NOT NULL,
  `penilaian_nyeri_kualitas` varchar(50) NOT NULL,
  `penilaian_nyeri_lokasi` varchar(50) NOT NULL,
  `penilaian_nyeri_penjalaran` varchar(50) NOT NULL,
  `penilaian_nyeri_skala` enum('0','1','2','3','4','5','6','7','8','9','10') NOT NULL,
  `penilaian_nyeri_durasi` varchar(50) NOT NULL,
  `kebutuhan_edukasi` varchar(200) DEFAULT NULL,
  `pemeriksaan_lab` varchar(1000) NOT NULL DEFAULT '',
  `skrining_fungsi_skala1` enum('Tak Terkendali/Tak Teratur (Perlu Pencahar)','Kadang-kadang Tak Terkendali (1x Seminggu)','Terkendali Teratur') DEFAULT NULL,
  `skrining_fungsi_nilai1` tinyint(4) DEFAULT NULL,
  `skrining_fungsi_skala2` enum('Tak Terkendali/Pakai Kateter','Kadang-kadang Tak Terkendali (Hanya 1x/24 Jam )','Mandiri') DEFAULT NULL,
  `skrining_fungsi_nilai2` tinyint(4) DEFAULT NULL,
  `skrining_fungsi_skala3` enum('Butuh Pertolongan Orang Lain','Mandiri') DEFAULT NULL,
  `skrining_fungsi_nilai3` tinyint(4) DEFAULT NULL,
  `skrining_fungsi_skala4` enum('Tergantung Pertolongan Orang Lain','Perlu Pertolongan Pada Beberapa Kegiatan Tetapi Dapat Mengerjakan Sendiri Beberapa Kegiatan Yang Lain','Mandiri') DEFAULT NULL,
  `skrining_fungsi_nilai4` tinyint(4) DEFAULT NULL,
  `skrining_fungsi_skala5` enum('Tidak Mampu','Perlu Ditolong Memotong Makanan','Mandiri') DEFAULT NULL,
  `skrining_fungsi_nilai5` tinyint(4) DEFAULT NULL,
  `skrining_fungsi_skala6` enum('Tidak Mampu','Perlu Banyak Bantuan Untuk Bisa Duduk (2 Orang)','Bantuan Minimal 1 Orang','Mandiri') DEFAULT NULL,
  `skrining_fungsi_nilai6` tinyint(4) DEFAULT NULL,
  `skrining_fungsi_skala7` enum('Tidak Mampu','Bisa (Pindah) Dengan Kursi Roda','Berjalan Dengan Bantuan 1 Orang','Mandiri') DEFAULT NULL,
  `skrining_fungsi_nilai7` tinyint(4) DEFAULT NULL,
  `skrining_fungsi_skala8` enum('Tergantung Orang Lain','Sebagian Dibantu (Misal Mengancing Baju)','Mandiri') DEFAULT NULL,
  `skrining_fungsi_nilai8` tinyint(4) DEFAULT NULL,
  `skrining_fungsi_skala9` enum('Tidak Mampu','Butuh Pertolongan','Mandiri') DEFAULT NULL,
  `skrining_fungsi_nilai9` tinyint(4) DEFAULT NULL,
  `skrining_fungsi_skala10` enum('Tergantung Orang Lain','Mandiri') DEFAULT NULL,
  `skrining_fungsi_nilai10` tinyint(4) DEFAULT NULL,
  `skrining_fungsi_totalnilai` tinyint(4) DEFAULT NULL,
  `hasil_echo` text DEFAULT NULL,
  `rencana` text DEFAULT NULL,
  PRIMARY KEY (`no_rawat`) USING BTREE,
  INDEX `nip`(`nip`) USING BTREE,
  CONSTRAINT `smc_pengkajian_tindakan_invasif_non_bedah_ibfk_1` FOREIGN KEY (`no_rawat`) REFERENCES `reg_periksa` (`no_rawat`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `smc_pengkajian_tindakan_invasif_non_bedah_ibfk_2` FOREIGN KEY (`nip`) REFERENCES `petugas` (`nip`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `smc_pengkajian_tindakan_invasif_non_bedah_masalah` (
  `no_rawat` varchar(17) NOT NULL,
  `menu` varchar(50) not null,
  `kode_masalah` varchar(3) NOT NULL,
  PRIMARY KEY (`no_rawat`,`menu`,`kode_masalah`) USING BTREE,
  INDEX `menu`(`menu`,`kode_masalah`) USING BTREE,
  CONSTRAINT `smc_pengkajian_tindakan_invasif_non_bedah_masalah_ibfk_1` FOREIGN KEY (`no_rawat`) REFERENCES `smc_pengkajian_tindakan_invasif_non_bedah` (`no_rawat`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `smc_pengkajian_tindakan_invasif_non_bedah_masalah_ibfk_2` FOREIGN KEY (`menu`,`kode_masalah`) REFERENCES `smc_master_masalah_keperawatan` (`menu`,`kode_masalah`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE IF NOT EXISTS `smc_pengkajian_tindakan_invasif_non_bedah_rencana` (
  `no_rawat` varchar(17) NOT NULL,
  `menu` varchar(50) not null,
  `kode_masalah` varchar(3) NOT NULL,
  `kode_rencana` varchar(3) NOT NULL,
  PRIMARY KEY (`no_rawat`,`menu`,`kode_masalah`,`kode_rencana`) USING BTREE,
  index `menu`(`menu`,`kode_masalah`,`kode_rencana`) USING BTREE,
  CONSTRAINT `smc_pengkajian_tindakan_invasif_non_bedah_rencana_ibfk_1` FOREIGN KEY (`no_rawat`) REFERENCES `smc_pengkajian_tindakan_invasif_non_bedah` (`no_rawat`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `smc_pengkajian_tindakan_invasif_non_bedah_rencana_ibfk_2` FOREIGN KEY (`menu`, `kode_masalah`, `kode_rencana`) REFERENCES `smc_master_rencana_keperawatan` (`menu`, `kode_masalah`, `kode_rencana`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `spesialis` MODIFY COLUMN IF EXISTS `nm_sps` varchar(60) NULL DEFAULT NULL AFTER `kd_sps`;

ALTER TABLE `stts_kerja` ADD COLUMN IF NOT EXISTS `cuti_besar` enum('','Tidak Ada','10 Tahun Dari TMT') NOT NULL DEFAULT '' AFTER `hakcuti`;

ALTER TABLE `stts_kerja` ADD COLUMN IF NOT EXISTS `hakcuti_besar` int NOT NULL DEFAULT 0 AFTER `cuti_besar`;

ALTER TABLE `stts_kerja` ADD COLUMN IF NOT EXISTS `izin` enum('','1 Bulan TMT','3 Bulan TMT','6 Bulan TMT','12 Bulan TMT','1 Bulan per Tahun','3 Bulan per Tahun','6 Bulan per Tahun','12 Bulan per Tahun') NOT NULL DEFAULT '' AFTER `hakcuti_besar`;

ALTER TABLE `stts_kerja` ADD COLUMN IF NOT EXISTS `hakizin` int NOT NULL DEFAULT 0 AFTER `izin`;

ALTER TABLE `stts_kerja` ADD COLUMN IF NOT EXISTS `max_menit` int NOT NULL DEFAULT 0 AFTER `hakizin`;

ALTER TABLE `surat_keterangan_rawat_inap` ADD COLUMN IF NOT EXISTS `kd_dokter` varchar(20) NOT NULL AFTER `tanggalakhir`;

ALTER TABLE `surat_keterangan_rawat_inap` ADD COLUMN IF NOT EXISTS `lamasakit` varchar(20) NULL DEFAULT NULL AFTER `kd_dokter`;

ALTER TABLE `surat_keterangan_rawat_inap` ADD CONSTRAINT `surat_keterangan_rawat_inap_dokter_FK` FOREIGN KEY IF NOT EXISTS (`kd_dokter`) REFERENCES `dokter` (`kd_dokter`) ON DELETE NO ACTION ON UPDATE CASCADE;

ALTER TABLE `surat_keterangan_rawat_inap` ADD INDEX IF NOT EXISTS `surat_keterangan_rawat_inap_dokter_FK`(`kd_dokter`) USING BTREE;

ALTER TABLE `surat_keterangan_sehat` MODIFY COLUMN IF EXISTS `butawarna` enum('Ya','Tidak','-') NOT NULL AFTER `suhu`;

ALTER TABLE `suratsakitpihak2` MODIFY COLUMN IF EXISTS `hubungan` enum('Suami','Istri','Anak','Ayah','Ibu','Saudara','Keponakan') NOT NULL AFTER `alamat`;

ALTER TABLE `suratsakitpihak2` ADD PRIMARY KEY IF NOT EXISTS (`no_surat`) USING BTREE;

ALTER TABLE `tamppiutang` DROP INDEX IF EXISTS `PRIMARY`;

ALTER TABLE `tamppiutang` ADD PRIMARY KEY IF NOT EXISTS (`petugas`, `kode_brng`, `no_batch`, `no_faktur`);

ALTER TABLE `tamppiutang` ADD COLUMN IF NOT EXISTS `no_racik` varchar(2) NULL DEFAULT NULL AFTER `aturan_pakai`;

CREATE TABLE IF NOT EXISTS `tampjurnal_rvpbpjs`  (
  `kd_rek` char(15) NOT NULL,
  `nm_rek` varchar(100) NULL DEFAULT NULL,
  `debet` double NOT NULL,
  `kredit` double NOT NULL,
  PRIMARY KEY (`kd_rek`) USING HASH,
  INDEX `nm_rek`(`nm_rek`) USING HASH,
  INDEX `debet`(`debet`) USING HASH,
  INDEX `kredit`(`kredit`) USING HASH
) ENGINE = MEMORY CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Fixed;

CREATE TABLE IF NOT EXISTS `tampjurnal_smc`  (
  `kd_rek` char(15) NOT NULL,
  `nm_rek` varchar(100) NULL DEFAULT NULL,
  `debet` double NOT NULL,
  `kredit` double NOT NULL,
  `user_id` varchar(20) NOT NULL,
  `ip` varchar(25) NOT NULL,
  PRIMARY KEY (`kd_rek`, `user_id`, `ip`) USING HASH
) ENGINE = MEMORY CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Fixed;

CREATE TABLE IF NOT EXISTS `tempinacbg`  (
  `coder_nik` varchar(20) NOT NULL,
  `cmg_code` varchar(10) NOT NULL,
  `cmg_description` varchar(100) NULL DEFAULT NULL,
  `cmg_type` varchar(50) NULL DEFAULT NULL,
  PRIMARY KEY (`coder_nik`, `cmg_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `template_laboratorium` MODIFY COLUMN IF EXISTS `method` varchar(30) NOT NULL DEFAULT '' AFTER `nilai_rujukan_pa`;

ALTER TABLE `temporary` DROP INDEX IF EXISTS `no`;

ALTER TABLE `temporary_bayar_ralan` DROP INDEX IF EXISTS `no`;

ALTER TABLE `temporary_bayar_ranap` DROP INDEX IF EXISTS `no`;

CREATE TABLE IF NOT EXISTS `temporary_besar`  (
  `userid` varchar(30) NOT NULL,
  `ipaddress` varchar(30) NOT NULL,
  `no` int(10) UNSIGNED NULL DEFAULT 1,
  `temp1` varchar(500) NULL DEFAULT NULL,
  `temp2` varchar(500) NULL DEFAULT NULL,
  `temp3` varchar(500) NULL DEFAULT NULL,
  `temp4` varchar(500) NULL DEFAULT NULL,
  `temp5` varchar(500) NULL DEFAULT NULL,
  `temp6` varchar(500) NULL DEFAULT NULL,
  `temp7` varchar(500) NULL DEFAULT NULL,
  `temp8` varchar(500) NULL DEFAULT NULL,
  `temp9` varchar(500) NULL DEFAULT NULL,
  `temp10` varchar(500) NULL DEFAULT NULL,
  `temp11` varchar(500) NULL DEFAULT NULL,
  `temp12` varchar(500) NULL DEFAULT NULL,
  `temp13` varchar(500) NULL DEFAULT NULL,
  `temp14` varchar(500) NULL DEFAULT NULL,
  `temp15` varchar(500) NULL DEFAULT NULL,
  `temp16` varchar(500) NULL DEFAULT NULL,
  `temp17` varchar(500) NULL DEFAULT NULL,
  `temp18` varchar(500) NULL DEFAULT NULL,
  `temp19` varchar(500) NULL DEFAULT NULL,
  `temp20` varchar(500) NULL DEFAULT NULL,
  `temp21` varchar(500) NULL DEFAULT NULL,
  `temp22` varchar(500) NULL DEFAULT NULL,
  `temp23` varchar(500) NULL DEFAULT NULL,
  `temp24` varchar(500) NULL DEFAULT NULL,
  `temp25` varchar(500) NULL DEFAULT NULL,
  `temp26` varchar(500) NULL DEFAULT NULL,
  `temp27` varchar(500) NULL DEFAULT NULL,
  `temp28` varchar(500) NULL DEFAULT NULL,
  `temp29` varchar(500) NULL DEFAULT NULL,
  `temp30` varchar(500) NULL DEFAULT NULL,
  `temp31` varchar(500) NULL DEFAULT NULL,
  `temp32` varchar(500) NULL DEFAULT NULL,
  `temp33` varchar(500) NULL DEFAULT NULL,
  `temp34` varchar(500) NULL DEFAULT NULL,
  `temp35` varchar(500) NULL DEFAULT NULL,
  `temp36` varchar(500) NULL DEFAULT NULL,
  `temp37` varchar(500) NULL DEFAULT NULL,
  `temp38` varchar(500) NULL DEFAULT NULL,
  `temp39` varchar(500) NULL DEFAULT NULL,
  `temp40` varchar(500) NULL DEFAULT NULL,
  `temp41` varchar(500) NULL DEFAULT NULL,
  `temp42` varchar(500) NULL DEFAULT NULL,
  `temp43` varchar(500) NULL DEFAULT NULL,
  `temp44` varchar(500) NULL DEFAULT NULL,
  `temp45` varchar(500) NULL DEFAULT NULL,
  `temp46` varchar(500) NULL DEFAULT NULL,
  `temp47` varchar(500) NULL DEFAULT NULL,
  `temp48` varchar(500) NULL DEFAULT NULL,
  `temp49` varchar(500) NULL DEFAULT NULL,
  `temp50` varchar(500) NULL DEFAULT NULL,
  `temp51` varchar(500) NULL DEFAULT NULL,
  `temp52` varchar(500) NULL DEFAULT NULL,
  `temp53` varchar(500) NULL DEFAULT NULL,
  `temp54` varchar(500) NULL DEFAULT NULL,
  `temp55` varchar(500) NULL DEFAULT NULL,
  `temp56` varchar(500) NULL DEFAULT NULL,
  `temp57` varchar(500) NULL DEFAULT NULL,
  `temp58` varchar(500) NULL DEFAULT NULL,
  `temp59` varchar(500) NULL DEFAULT NULL,
  `temp60` varchar(500) NULL DEFAULT NULL,
  `temp61` varchar(500) NULL DEFAULT NULL,
  `temp62` varchar(500) NULL DEFAULT NULL,
  `temp63` varchar(500) NULL DEFAULT NULL,
  `temp64` varchar(500) NULL DEFAULT NULL,
  `temp65` varchar(500) NULL DEFAULT NULL,
  `temp66` varchar(500) NULL DEFAULT NULL,
  `temp67` varchar(500) NULL DEFAULT NULL,
  `temp68` varchar(500) NULL DEFAULT NULL,
  `temp69` varchar(500) NULL DEFAULT NULL,
  `temp70` varchar(500) NULL DEFAULT NULL,
  `temp71` varchar(500) NULL DEFAULT NULL,
  `temp72` varchar(500) NULL DEFAULT NULL,
  `temp73` varchar(500) NULL DEFAULT NULL,
  `temp74` varchar(500) NULL DEFAULT NULL,
  `temp75` varchar(500) NULL DEFAULT NULL,
  `temp76` varchar(500) NULL DEFAULT NULL,
  `temp77` varchar(500) NULL DEFAULT NULL,
  `temp78` varchar(500) NULL DEFAULT NULL,
  `temp79` varchar(500) NULL DEFAULT NULL,
  INDEX `userid`(`userid`) USING BTREE,
  INDEX `ipaddress`(`ipaddress`) USING BTREE
) ENGINE = MyISAM CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

ALTER TABLE `temporary_lab` DROP INDEX IF EXISTS `no`;

ALTER TABLE `temporary_permintaan_lab` DROP INDEX IF EXISTS `no`;

ALTER TABLE `temporary_permintaan_labmb` DROP INDEX IF EXISTS `no`;

ALTER TABLE `temporary_presensi` MODIFY COLUMN IF EXISTS `shift` enum('Pagi', 'Pagi2', 'Pagi3', 'Pagi4', 'Pagi5', 'Pagi6', 'Pagi7', 'Pagi8', 'Pagi9', 'Pagi10', 'Siang', 'Siang2', 'Siang3', 'Siang4', 'Siang5', 'Siang6', 'Siang7', 'Siang8', 'Siang9', 'Siang10', 'Malam', 'Malam2', 'Malam3', 'Malam4', 'Malam5', 'Malam6', 'Malam7', 'Malam8', 'Malam9', 'Malam10', 'Midle Pagi1', 'Midle Pagi2', 'Midle Pagi3', 'Midle Pagi4', 'Midle Pagi5', 'Midle Pagi6', 'Midle Pagi7', 'Midle Pagi8', 'Midle Pagi9', 'Midle Pagi10', 'Midle Siang1', 'Midle Siang2', 'Midle Siang3', 'Midle Siang4', 'Midle Siang5', 'Midle Siang6', 'Midle Siang7', 'Midle Siang8', 'Midle Siang9', 'Midle Siang10', 'Midle Malam1', 'Midle Malam2', 'Midle Malam3', 'Midle Malam4', 'Midle Malam5', 'Midle Malam6', 'Midle Malam7', 'Midle Malam8', 'Midle Malam9', 'Midle Malam10', 'Pagi11', 'Pagi12', 'Pagi13', 'Pagi14', 'Pagi15', 'Pagi16', 'Pagi17', 'Pagi18', 'Pagi19', 'Pagi20', 'Pagi21', 'Pagi22', 'Pagi23', 'Pagi24', 'Pagi25', 'Pagi26', 'Pagi27', 'Pagi28', 'Pagi29', 'Pagi30', 'Pagi31', 'Pagi32', 'Pagi33', 'Pagi34', 'Pagi35', 'Pagi36', 'Pagi37', 'Pagi38', 'Pagi39', 'Pagi40', 'Siang11', 'Siang12', 'Siang13', 'Siang14', 'Siang15', 'Siang16', 'Siang17', 'Siang18', 'Siang19', 'Siang20', 'Siang21', 'Siang22', 'Siang23', 'Siang24', 'Siang25', 'Siang26', 'Siang27', 'Siang28', 'Siang29', 'Siang30', 'Siang31', 'Siang32', 'Siang33', 'Siang34', 'Siang35', 'Siang36', 'Siang37', 'Siang38', 'Siang39', 'Siang40', 'Malam11', 'Malam12', 'Malam13', 'Malam14', 'Malam15', 'Malam16', 'Malam17', 'Malam18', 'Malam19', 'Malam20', 'Malam21', 'Malam22', 'Malam23', 'Malam24', 'Malam25', 'Malam26', 'Malam27', 'Malam28', 'Malam29', 'Malam30', 'Malam31', 'Malam32', 'Malam33', 'Malam34', 'Malam35', 'Malam36', 'Malam37', 'Malam38', 'Malam39', 'Malam40', 'Midle Pagi11', 'Midle Pagi12', 'Midle Pagi13', 'Midle Pagi14', 'Midle Pagi15', 'Midle Pagi16', 'Midle Pagi17', 'Midle Pagi18', 'Midle Pagi19', 'Midle Pagi20', 'Midle Pagi21', 'Midle Pagi22', 'Midle Pagi23', 'Midle Pagi24', 'Midle Pagi25', 'Midle Pagi26', 'Midle Pagi27', 'Midle Pagi28', 'Midle Pagi29', 'Midle Pagi30', 'Midle Pagi31', 'Midle Pagi32', 'Midle Pagi33', 'Midle Pagi34', 'Midle Pagi35', 'Midle Pagi36', 'Midle Pagi37', 'Midle Pagi38', 'Midle Pagi39', 'Midle Pagi40', 'Midle Siang11', 'Midle Siang12', 'Midle Siang13', 'Midle Siang14', 'Midle Siang15', 'Midle Siang16', 'Midle Siang17', 'Midle Siang18', 'Midle Siang19', 'Midle Siang20', 'Midle Siang21', 'Midle Siang22', 'Midle Siang23', 'Midle Siang24', 'Midle Siang25', 'Midle Siang26', 'Midle Siang27', 'Midle Siang28', 'Midle Siang29', 'Midle Siang30', 'Midle Siang31', 'Midle Siang32', 'Midle Siang33', 'Midle Siang34', 'Midle Siang35', 'Midle Siang36', 'Midle Siang37', 'Midle Siang38', 'Midle Siang39', 'Midle Siang40', 'Midle Malam11', 'Midle Malam12', 'Midle Malam13', 'Midle Malam14', 'Midle Malam15', 'Midle Malam16', 'Midle Malam17', 'Midle Malam18', 'Midle Malam19', 'Midle Malam20', 'Midle Malam21', 'Midle Malam22', 'Midle Malam23', 'Midle Malam24', 'Midle Malam25', 'Midle Malam26', 'Midle Malam27', 'Midle Malam28', 'Midle Malam29', 'Midle Malam30', 'Midle Malam31', 'Midle Malam32', 'Midle Malam33', 'Midle Malam34', 'Midle Malam35', 'Midle Malam36', 'Midle Malam37', 'Midle Malam38', 'Midle Malam39', 'Midle Malam40') NOT NULL;

ALTER TABLE `temporary_radiologi` DROP INDEX IF EXISTS `no`;

ALTER TABLE `temporary_resep` DROP INDEX IF EXISTS `no`;

ALTER TABLE `temporary2` DROP INDEX IF EXISTS `no`;

ALTER TABLE `trackersql` ADD INDEX IF NOT EXISTS `trackersql_tanggal_IDX`(`tanggal`) USING BTREE;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `edit_hapus_spo_medis` enum('true','false') NULL DEFAULT NULL AFTER `penatalaksanaan_terapi_okupasi`;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `edit_hapus_spo_nonmedis` enum('true','false') NULL DEFAULT NULL AFTER `edit_hapus_spo_medis`;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `bpjs_kompilasi_berkas_klaim` enum('true','false') NULL DEFAULT NULL AFTER `satu_sehat_kirim_specimen_radiologi`;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `pindah_kamar_pilihan_2` enum('true','false') NULL DEFAULT NULL AFTER `ringkasan_hutang_vendor_dapur`;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `set_pintu_poli` enum('true','false') NULL DEFAULT NULL AFTER `validasi_pengujian_sampel_lab_kesehatan_lingkungan`;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `bpjs_kirim_obat_smc` enum('true','false') NULL DEFAULT NULL AFTER `parameter_pengujian_lab_kesehatan_lingkungan`;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `bpjs_edit_kirim_obat_smc` enum('true','false') NULL DEFAULT NULL AFTER `bpjs_kirim_obat_smc`;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `bpjs_riwayat_obat_smc` enum('true','false') NULL DEFAULT NULL AFTER `bpjs_edit_kirim_obat_smc`;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `bpjs_riwayat_pelayanan_resep_smc` enum('true','false') NULL DEFAULT NULL AFTER `bpjs_riwayat_obat_smc`;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `pintu_poli` enum('true','false') NULL DEFAULT NULL AFTER `bpjs_potensi_prb`;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `bpjs_riwayat_surat_smc` enum('true','false') NULL DEFAULT NULL AFTER `bpjs_rekap_peserta_prb_apotek`;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `pengkajian_tindakan_invasif_non_bedah_smc` enum('true','false') DEFAULT NULL AFTER `catatan_observasi_ruang_ok`;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `pengajuan_izin_smc` enum('true','false') DEFAULT NULL AFTER `pengkajian_tindakan_invasif_non_bedah_smc`;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `jam_masuk_smc` enum('true','false') NULL DEFAULT NULL AFTER `pengajuan_izin_smc`;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `jadwal_pegawai_smc` enum('true','false') NULL DEFAULT NULL AFTER `jam_masuk_smc`;

ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `template_laboratorium_smc` enum('true','false') NULL DEFAULT NULL AFTER `ringkasan_beban_hutang_lain`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `penyakit` enum('true','false') NULL DEFAULT NULL AFTER `password`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `obat_penyakit` enum('true','false') NULL DEFAULT NULL AFTER `penyakit`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `dokter` enum('true','false') NULL DEFAULT NULL AFTER `obat_penyakit`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `jadwal_praktek` enum('true','false') NULL DEFAULT NULL AFTER `dokter`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `petugas` enum('true','false') NULL DEFAULT NULL AFTER `jadwal_praktek`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `pasien` enum('true','false') NULL DEFAULT NULL AFTER `petugas`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `registrasi` enum('true','false') NULL DEFAULT NULL AFTER `pasien`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `tindakan_ralan` enum('true','false') NULL DEFAULT NULL AFTER `registrasi`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `kamar_inap` enum('true','false') NULL DEFAULT NULL AFTER `tindakan_ralan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `tindakan_ranap` enum('true','false') NULL DEFAULT NULL AFTER `kamar_inap`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `operasi` enum('true','false') NULL DEFAULT NULL AFTER `tindakan_ranap`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `rujukan_keluar` enum('true','false') NULL DEFAULT NULL AFTER `operasi`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `rujukan_masuk` enum('true','false') NULL DEFAULT NULL AFTER `rujukan_keluar`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `beri_obat` enum('true','false') NULL DEFAULT NULL AFTER `rujukan_masuk`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `resep_pulang` enum('true','false') NULL DEFAULT NULL AFTER `beri_obat`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `pasien_meninggal` enum('true','false') NULL DEFAULT NULL AFTER `resep_pulang`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `diet_pasien` enum('true','false') NULL DEFAULT NULL AFTER `pasien_meninggal`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `kelahiran_bayi` enum('true','false') NULL DEFAULT NULL AFTER `diet_pasien`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `periksa_lab` enum('true','false') NULL DEFAULT NULL AFTER `kelahiran_bayi`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `periksa_radiologi` enum('true','false') NULL DEFAULT NULL AFTER `periksa_lab`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `kasir_ralan` enum('true','false') NULL DEFAULT NULL AFTER `periksa_radiologi`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `deposit_pasien` enum('true','false') NULL DEFAULT NULL AFTER `kasir_ralan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `piutang_pasien` enum('true','false') NULL DEFAULT NULL AFTER `deposit_pasien`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `peminjaman_berkas` enum('true','false') NULL DEFAULT NULL AFTER `piutang_pasien`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `barcode` enum('true','false') NULL DEFAULT NULL AFTER `peminjaman_berkas`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `presensi_harian` enum('true','false') NULL DEFAULT NULL AFTER `barcode`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `presensi_bulanan` enum('true','false') NULL DEFAULT NULL AFTER `presensi_harian`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `pegawai_admin` enum('true','false') NULL DEFAULT NULL AFTER `presensi_bulanan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `pegawai_user` enum('true','false') NULL DEFAULT NULL AFTER `pegawai_admin`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `suplier` enum('true','false') NULL DEFAULT NULL AFTER `pegawai_user`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `satuan_barang` enum('true','false') NULL DEFAULT NULL AFTER `suplier`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `konversi_satuan` enum('true','false') NULL DEFAULT NULL AFTER `satuan_barang`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `jenis_barang` enum('true','false') NULL DEFAULT NULL AFTER `konversi_satuan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `obat` enum('true','false') NULL DEFAULT NULL AFTER `jenis_barang`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `stok_opname_obat` enum('true','false') NULL DEFAULT NULL AFTER `obat`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `stok_obat_pasien` enum('true','false') NULL DEFAULT NULL AFTER `stok_opname_obat`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `pengadaan_obat` enum('true','false') NULL DEFAULT NULL AFTER `stok_obat_pasien`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `pemesanan_obat` enum('true','false') NULL DEFAULT NULL AFTER `pengadaan_obat`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `penjualan_obat` enum('true','false') NULL DEFAULT NULL AFTER `pemesanan_obat`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `piutang_obat` enum('true','false') NULL DEFAULT NULL AFTER `penjualan_obat`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `retur_ke_suplier` enum('true','false') NULL DEFAULT NULL AFTER `piutang_obat`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `retur_dari_pembeli` enum('true','false') NULL DEFAULT NULL AFTER `retur_ke_suplier`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `retur_obat_ranap` enum('true','false') NULL DEFAULT NULL AFTER `retur_dari_pembeli`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `retur_piutang_pasien` enum('true','false') NULL DEFAULT NULL AFTER `retur_obat_ranap`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `keuntungan_penjualan` enum('true','false') NULL DEFAULT NULL AFTER `retur_piutang_pasien`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `keuntungan_beri_obat` enum('true','false') NULL DEFAULT NULL AFTER `keuntungan_penjualan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `sirkulasi_obat` enum('true','false') NULL DEFAULT NULL AFTER `keuntungan_beri_obat`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `ipsrs_barang` enum('true','false') NULL DEFAULT NULL AFTER `sirkulasi_obat`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `ipsrs_pengadaan_barang` enum('true','false') NULL DEFAULT NULL AFTER `ipsrs_barang`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `ipsrs_stok_keluar` enum('true','false') NULL DEFAULT NULL AFTER `ipsrs_pengadaan_barang`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `ipsrs_rekap_pengadaan` enum('true','false') NULL DEFAULT NULL AFTER `ipsrs_stok_keluar`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `ipsrs_rekap_stok_keluar` enum('true','false') NULL DEFAULT NULL AFTER `ipsrs_rekap_pengadaan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `ipsrs_pengeluaran_harian` enum('true','false') NULL DEFAULT NULL AFTER `ipsrs_rekap_stok_keluar`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `inventaris_jenis` enum('true','false') NULL DEFAULT NULL AFTER `ipsrs_pengeluaran_harian`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `inventaris_kategori` enum('true','false') NULL DEFAULT NULL AFTER `inventaris_jenis`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `inventaris_merk` enum('true','false') NULL DEFAULT NULL AFTER `inventaris_kategori`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `inventaris_ruang` enum('true','false') NULL DEFAULT NULL AFTER `inventaris_merk`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `inventaris_produsen` enum('true','false') NULL DEFAULT NULL AFTER `inventaris_ruang`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `inventaris_koleksi` enum('true','false') NULL DEFAULT NULL AFTER `inventaris_produsen`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `inventaris_inventaris` enum('true','false') NULL DEFAULT NULL AFTER `inventaris_koleksi`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `inventaris_sirkulasi` enum('true','false') NULL DEFAULT NULL AFTER `inventaris_inventaris`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `parkir_jenis` enum('true','false') NULL DEFAULT NULL AFTER `inventaris_sirkulasi`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `parkir_in` enum('true','false') NULL DEFAULT NULL AFTER `parkir_jenis`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `parkir_out` enum('true','false') NULL DEFAULT NULL AFTER `parkir_in`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `parkir_rekap_harian` enum('true','false') NULL DEFAULT NULL AFTER `parkir_out`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `parkir_rekap_bulanan` enum('true','false') NULL DEFAULT NULL AFTER `parkir_rekap_harian`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `informasi_kamar` enum('true','false') NULL DEFAULT NULL AFTER `parkir_rekap_bulanan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `harian_tindakan_poli` enum('true','false') NULL DEFAULT NULL AFTER `informasi_kamar`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `obat_per_poli` enum('true','false') NULL DEFAULT NULL AFTER `harian_tindakan_poli`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `obat_per_kamar` enum('true','false') NULL DEFAULT NULL AFTER `obat_per_poli`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `obat_per_dokter_ralan` enum('true','false') NULL DEFAULT NULL AFTER `obat_per_kamar`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `obat_per_dokter_ranap` enum('true','false') NULL DEFAULT NULL AFTER `obat_per_dokter_ralan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `harian_dokter` enum('true','false') NULL DEFAULT NULL AFTER `obat_per_dokter_ranap`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `bulanan_dokter` enum('true','false') NULL DEFAULT NULL AFTER `harian_dokter`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `harian_paramedis` enum('true','false') NULL DEFAULT NULL AFTER `bulanan_dokter`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `bulanan_paramedis` enum('true','false') NULL DEFAULT NULL AFTER `harian_paramedis`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `pembayaran_ralan` enum('true','false') NULL DEFAULT NULL AFTER `bulanan_paramedis`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `pembayaran_ranap` enum('true','false') NULL DEFAULT NULL AFTER `pembayaran_ralan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `rekap_pembayaran_ralan` enum('true','false') NULL DEFAULT NULL AFTER `pembayaran_ranap`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `rekap_pembayaran_ranap` enum('true','false') NULL DEFAULT NULL AFTER `rekap_pembayaran_ralan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `tagihan_masuk` enum('true','false') NULL DEFAULT NULL AFTER `rekap_pembayaran_ranap`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `tambahan_biaya` enum('true','false') NULL DEFAULT NULL AFTER `tagihan_masuk`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `potongan_biaya` enum('true','false') NULL DEFAULT NULL AFTER `tambahan_biaya`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `resep_obat` enum('true','false') NULL DEFAULT NULL AFTER `potongan_biaya`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `resume_pasien` enum('true','false') NULL DEFAULT NULL AFTER `resep_obat`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `penyakit_ralan` enum('true','false') NULL DEFAULT NULL AFTER `resume_pasien`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `penyakit_ranap` enum('true','false') NULL DEFAULT NULL AFTER `penyakit_ralan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `kamar` enum('true','false') NULL DEFAULT NULL AFTER `penyakit_ranap`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `tarif_ralan` enum('true','false') NULL DEFAULT NULL AFTER `kamar`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `tarif_ranap` enum('true','false') NULL DEFAULT NULL AFTER `tarif_ralan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `tarif_lab` enum('true','false') NULL DEFAULT NULL AFTER `tarif_ranap`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `tarif_radiologi` enum('true','false') NULL DEFAULT NULL AFTER `tarif_lab`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `tarif_operasi` enum('true','false') NULL DEFAULT NULL AFTER `tarif_radiologi`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `akun_rekening` enum('true','false') NULL DEFAULT NULL AFTER `tarif_operasi`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `rekening_tahun` enum('true','false') NULL DEFAULT NULL AFTER `akun_rekening`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `posting_jurnal` enum('true','false') NULL DEFAULT NULL AFTER `rekening_tahun`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `buku_besar` enum('true','false') NULL DEFAULT NULL AFTER `posting_jurnal`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `cashflow` enum('true','false') NULL DEFAULT NULL AFTER `buku_besar`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `keuangan` enum('true','false') NULL DEFAULT NULL AFTER `cashflow`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `pengeluaran` enum('true','false') NULL DEFAULT NULL AFTER `keuangan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `setup_pjlab` enum('true','false') NULL DEFAULT NULL AFTER `pengeluaran`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `setup_otolokasi` enum('true','false') NULL DEFAULT NULL AFTER `setup_pjlab`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `setup_jam_kamin` enum('true','false') NULL DEFAULT NULL AFTER `setup_otolokasi`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `setup_embalase` enum('true','false') NULL DEFAULT NULL AFTER `setup_jam_kamin`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `tracer_login` enum('true','false') NULL DEFAULT NULL AFTER `setup_embalase`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `display` enum('true','false') NULL DEFAULT NULL AFTER `tracer_login`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `set_harga_obat` enum('true','false') NULL DEFAULT NULL AFTER `display`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `set_penggunaan_tarif` enum('true','false') NULL DEFAULT NULL AFTER `set_harga_obat`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `set_oto_ralan` enum('true','false') NULL DEFAULT NULL AFTER `set_penggunaan_tarif`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `biaya_harian` enum('true','false') NULL DEFAULT NULL AFTER `set_oto_ralan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `biaya_masuk_sekali` enum('true','false') NULL DEFAULT NULL AFTER `biaya_harian`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `set_no_rm` enum('true','false') NULL DEFAULT NULL AFTER `biaya_masuk_sekali`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `billing_ralan` enum('true','false') NULL DEFAULT NULL AFTER `set_no_rm`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `billing_ranap` enum('true','false') NULL DEFAULT NULL AFTER `billing_ralan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `jm_ranap_dokter` enum('true','false') NULL DEFAULT NULL AFTER `billing_ranap`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `igd` enum('true','false') NULL DEFAULT NULL AFTER `jm_ranap_dokter`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `barcoderalan` enum('true','false') NULL DEFAULT NULL AFTER `igd`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `barcoderanap` enum('true','false') NULL DEFAULT NULL AFTER `barcoderalan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `set_harga_obat_ralan` enum('true','false') NULL DEFAULT NULL AFTER `barcoderanap`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `set_harga_obat_ranap` enum('true','false') NULL DEFAULT NULL AFTER `set_harga_obat_ralan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `penyakit_pd3i` enum('true','false') NULL DEFAULT NULL AFTER `set_harga_obat_ranap`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `surveilans_pd3i` enum('true','false') NULL DEFAULT NULL AFTER `penyakit_pd3i`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `surveilans_ralan` enum('true','false') NULL DEFAULT NULL AFTER `surveilans_pd3i`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `diagnosa_pasien` enum('true','false') NULL DEFAULT NULL AFTER `surveilans_ralan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `surveilans_ranap` enum('true','false') NULL DEFAULT NULL AFTER `diagnosa_pasien`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `pny_takmenular_ranap` enum('true','false') NULL DEFAULT NULL AFTER `surveilans_ranap`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `pny_takmenular_ralan` enum('true','false') NULL DEFAULT NULL AFTER `pny_takmenular_ranap`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `kunjungan_ralan` enum('true','false') NULL DEFAULT NULL AFTER `pny_takmenular_ralan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `rl32` enum('true','false') NULL DEFAULT NULL AFTER `kunjungan_ralan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `rl33` enum('true','false') NULL DEFAULT NULL AFTER `rl32`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `rl37` enum('true','false') NULL DEFAULT NULL AFTER `rl33`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `rl38` enum('true','false') NULL DEFAULT NULL AFTER `rl37`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `harian_tindakan_dokter` enum('true','false') NULL DEFAULT NULL AFTER `rl38`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `sms` enum('true','false') NULL DEFAULT NULL AFTER `harian_tindakan_dokter`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `sidikjari` enum('true','false') NULL DEFAULT NULL AFTER `sms`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `jam_masuk` enum('true','false') NULL DEFAULT NULL AFTER `sidikjari`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `jadwal_pegawai` enum('true','false') NULL DEFAULT NULL AFTER `jam_masuk`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `parkir_barcode` enum('true','false') NULL DEFAULT NULL AFTER `jadwal_pegawai`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `set_nota` enum('true','false') NULL DEFAULT NULL AFTER `parkir_barcode`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `dpjp_ranap` enum('true','false') NULL DEFAULT NULL AFTER `set_nota`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `mutasi_barang` enum('true','false') NULL DEFAULT NULL AFTER `dpjp_ranap`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `rl36` enum('true','false') NULL DEFAULT NULL AFTER `rl34`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `grafik_per_perujuk` enum('true','false') NULL DEFAULT NULL AFTER `surat_pemesanan_non_medis`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `surat_balas` enum('true','false') NULL DEFAULT NULL AFTER `surat_sifat`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `pcare_pemberian_tindakan` enum('true','false') NULL DEFAULT NULL AFTER `pcare_pemberian_obat`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `kemenkes_sitt` enum('true','false') NULL DEFAULT NULL AFTER `password_asuransi`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `grafik_tb_hasilteshiv` enum('true','false') NULL DEFAULT NULL AFTER `grafik_tb_hasilakhirpengobatan`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `kadaluarsa_batch` enum('true','false') NULL DEFAULT NULL AFTER `grafik_tb_hasilteshiv`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `peminjam_piutang` enum('true','false') NULL DEFAULT NULL AFTER `penilaian_mcu`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `satu_sehat_kirim_clinicalimpression` enum('true','false') NULL DEFAULT NULL AFTER `konfirmasi_rekonsiliasi_obat`;

ALTER TABLE `user` MODIFY COLUMN IF EXISTS `template_persetujuan_penolakan_tindakan` enum('true','false') NULL DEFAULT NULL AFTER `laporan_anestesi`;

ALTER TABLE `user` ADD COLUMN `bpjs_riwayat_pelayanan_obat_smc` enum('true','false') CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL AFTER `bpjs_riwayat_obat_smc`;

ALTER TABLE `user` ADD COLUMN `apt_restore` enum('true','false') CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL AFTER `bpjs_riwayat_surat_smc`;

ALTER TABLE `user` ADD COLUMN `p2km_kompilasi_berkas_klaim` enum('true','false') CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL AFTER `surat_keterangan_berobat`;

CREATE TABLE `hasil_pemeriksaan_gdt` (
  `no_rawat` varchar(17) NOT NULL,
  `TglSampel` date NOT NULL,
  `TglHasil` date NOT NULL,
  `kd_dokter` varchar(20) NOT NULL,
  `nip` varchar(20) NOT NULL,
  `kesan_eritorsit` text NOT NULL,
  `kesan_leukosit` text NOT NULL,
  `kesan_trombosit` text NOT NULL,
  `kesan` text NOT NULL,
  `kesimpulan` text NOT NULL,
  `saran` text NOT NULL,
  `diff_manual` text NOT NULL,
  `HB` varchar(8) NOT NULL,
  `WBC` varchar(8) NOT NULL,
  `PLT` varchar(8) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


ALTER TABLE `hasil_pemeriksaan_gdt`
  ADD PRIMARY KEY (`no_rawat`) USING BTREE,
  ADD UNIQUE KEY `nip` (`nip`),
  ADD KEY `kd_dokter` (`kd_dokter`) USING BTREE;


ALTER TABLE `hasil_pemeriksaan_gdt`
  ADD CONSTRAINT `hasil_pemeriksaan_gdt_ibfk_1` FOREIGN KEY (`no_rawat`) REFERENCES `reg_periksa` (`no_rawat`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `hasil_pemeriksaan_gdt_ibfk_2` FOREIGN KEY (`kd_dokter`) REFERENCES `dokter` (`kd_dokter`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `hasil_pemeriksaan_gdt_ibfk_3` FOREIGN KEY (`nip`) REFERENCES `petugas` (`nip`) ON DELETE CASCADE ON UPDATE CASCADE;

DROP TABLE IF EXISTS `satu_sehat_mapping_vaksin`;
CREATE TABLE `satu_sehat_mapping_vaksin` (
  `kode_brng` varchar(15) NOT NULL,
  `vaksin_code` varchar(15) DEFAULT NULL,
  `vaksin_system` varchar(100) NOT NULL,
  `vaksin_display` varchar(80) DEFAULT NULL,
  `route_code` varchar(30) DEFAULT NULL,
  `route_system` varchar(100) DEFAULT NULL,
  `route_display` varchar(80) DEFAULT NULL,
  `dose_quantity_code` varchar(15) DEFAULT NULL,
  `dose_quantity_system` varchar(80) DEFAULT NULL,
  `dose_quantity_unit` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`kode_brng`),
  CONSTRAINT `satu_sehat_mapping_vaksin_ibfk_1` FOREIGN KEY (`kode_brng`) REFERENCES `databarang` (`kode_brng`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE catatan_berkas_klaim (
    no_sep       VARCHAR(19)  NOT NULL PRIMARY KEY,
    catatan      TEXT         NOT NULL,
    dibuat_oleh  VARCHAR(50)  NOT NULL,
    tgl_dibuat   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diubah_oleh  VARCHAR(50)  NOT NULL,
    tgl_diubah   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE catatan_berkas_klaim_log (
    id          BIGINT        NOT NULL AUTO_INCREMENT PRIMARY KEY,
    no_sep      VARCHAR(19)   NOT NULL,
    aksi        ENUM('BUAT','UBAH','HAPUS') NOT NULL,
    catatan_lama TEXT,
    catatan_baru TEXT,
    oleh        VARCHAR(50)   NOT NULL,
    tgl_aksi    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_no_sep (no_sep),
    INDEX idx_tgl   (tgl_aksi)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE `antrian_cs`  (
  `kd` int(50) NOT NULL AUTO_INCREMENT,
  `noantrian` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `postdate` date NOT NULL,
  PRIMARY KEY (`kd`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE `antrian_loket`  (
  `kd` int(50) NOT NULL AUTO_INCREMENT,
  `noantrian` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `postdate` date NOT NULL,
  PRIMARY KEY (`kd`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE `eklaim_icd10`  (
  `code` varchar(7) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `name` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `status` tinyint(3) UNSIGNED NULL DEFAULT 1,
  PRIMARY KEY (`code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE `idrg_diagnosa_pasien_p2km`  (
  `no_sep` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `kode_icd10` varchar(7) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `urut` int(10) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`no_sep`, `kode_icd10`) USING BTREE,
  INDEX `idrg_dx_smc_icd10_im`(`kode_icd10`) USING BTREE,
  CONSTRAINT `idrg_diagnosa_pasien_p2km_ibfk_1` FOREIGN KEY (`kode_icd10`) REFERENCES `idrg_referensi_icd10_smc` (`code1`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE `idrg_grouping_p2km`  (
  `no_sep` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `mdc_number` varchar(4) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `mdc_description` varchar(150) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `drg_code` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `drg_description` varchar(250) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `kelas_rs` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `cost_weight` double NULL DEFAULT NULL,
  `sub_acute_weight` double NULL DEFAULT NULL,
  `chronic_weight` double NULL DEFAULT NULL,
  `total_cost_weight` double NULL DEFAULT NULL,
  `nbr` double NULL DEFAULT NULL,
  PRIMARY KEY (`no_sep`) USING BTREE,
  CONSTRAINT `idrg_grouping_p2km_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `inacbg_klaim_baru2` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE `idrg_klaim_final_p2km`  (
  `no_sep` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `nik` varchar(30) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  PRIMARY KEY (`no_sep`) USING BTREE,
  CONSTRAINT `idrg_klaim_final_p2km_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `idrg_grouping_p2km` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE `idrg_prosedur_pasien_p2km`  (
  `no_sep` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `kode_icd9` varchar(7) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `multiplicity` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `urut` int(10) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`no_sep`, `kode_icd9`, `urut`) USING BTREE,
  INDEX `idrg_pc_smc_icd9cm_im`(`kode_icd9`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE `inacbg_data_klaim_p2km`  (
  `no_sep` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `nomor_kartu` varchar(20) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `tgl_masuk` datetime(0) NOT NULL,
  `tgl_pulang` datetime(0) NOT NULL,
  `cara_masuk` enum('gp','hosp-trans','mp','outp','inp','emd','born','nursing','psych','rehab','other') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `jenis_rawat` enum('1','2','3') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `kelas_rawat` enum('1','2','3') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `adl_sub_acute` varchar(2) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `adl_chronic` varchar(2) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `icu_indicator` enum('','0','1') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `icu_los` varchar(2) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `ventilator_hour` varchar(2) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `upgrade_class_ind` enum('','0','1') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `upgrade_class_class` enum('','kelas_2','kelas_1','vip','vvip') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `upgrade_class_los` varchar(2) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `upgrade_class_payor` enum('','peserta','pemberi_kerja','asuransi_tambahan') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `add_payment_pct` int(10) UNSIGNED NULL DEFAULT NULL,
  `birth_weight` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `sistole` varchar(4) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `diastole` varchar(4) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `discharge_status` enum('1','2','3','4','5') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `dializer_single_use` enum('','0','1') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `kantong_darah` varchar(5) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `alteplase_ind` enum('','0','1') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `menit_1_appearance` enum('','0','1','2') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `menit_1_pulse` enum('','0','1','2') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `menit_1_grimace` enum('','0','1','2') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `menit_1_activity` enum('','0','1','2') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `menit_1_respiration` enum('','0','1','2') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `menit_5_appearance` enum('','0','1','2') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `menit_5_pulse` enum('','0','1','2') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `menit_5_grimace` enum('','0','1','2') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `menit_5_activity` enum('','0','1','2') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `menit_5_respiration` enum('','0','1','2') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `usia_kehamilan` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `gravida` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `partus` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `abortus` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `onset_kontraksi` enum('','spontan','induksi','non_spontan_non_induksi') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `tarif_poli_eks` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `nama_dokter` varchar(150) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `kode_tarif` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `payor_id` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `payor_cd` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `cob_cd` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`no_sep`) USING BTREE,
  INDEX `tgl_masuk`(`tgl_masuk`) USING BTREE,
  INDEX `tgl_pulang`(`tgl_pulang`) USING BTREE,
  INDEX `nama_dokter`(`nama_dokter`) USING BTREE,
  CONSTRAINT `inacbg_data_klaim_p2km_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `inacbg_klaim_baru2` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE `inacbg_data_klaim_persalinan_p2km`  (
  `no_sep` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `delivery_sequence` tinyint(3) UNSIGNED NOT NULL,
  `delivery_method` enum('Vaginal','SC') CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `delivery_date` date NULL DEFAULT NULL,
  `delivery_time` time(0) NULL DEFAULT NULL,
  `letak_janin` enum('Kepala','Sungsang','Lintang') CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `kondisi` enum('Hidup','Meninggal') CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `use_manual` enum('0. Tidak','1. Ya') CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `use_forcep` enum('0. Tidak','1. Ya') CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `use_vacuum` enum('0. Tidak','1. Ya') CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `shk_spesimen_ambil` enum('Tidak','Ya') CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `shk_lokasi` enum('','Tumit','Vena') CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `shk_spesimen_date` date NULL DEFAULT NULL,
  `shk_spesimen_time` time(0) NULL DEFAULT NULL,
  `shk_alasan` enum('','Tidak dapat dilakukan','Akses sulit') CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  PRIMARY KEY (`no_sep`, `delivery_sequence`) USING BTREE,
  CONSTRAINT `inacbg_data_klaim_persalinan_p2km_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `pasien` (`no_ktp`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE `inacbg_data_klaim_tarif_p2km`  (
  `no_sep` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `tarif_rs` varchar(30) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `nilai` double NOT NULL DEFAULT 0,
  PRIMARY KEY (`no_sep`, `tarif_rs`) USING BTREE,
  CONSTRAINT `inacbg_data_klaim_tarif_p2km_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `inacbg_data_klaim_p2km` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE `inacbg_diagnosa_pasien_p2km`  (
  `no_sep` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `kode_icd10` varchar(7) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `deskripsi` varchar(250) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `urut` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `keterangan` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `locked` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`no_sep`, `kode_icd10`) USING BTREE,
  INDEX `idrg_dx_smc_icd10_im`(`kode_icd10`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE `inacbg_grouping_stage2_p2km`  (
  `no_sep` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `cmg_code` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `cmg_description` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `cmg_type` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `tariff` double NOT NULL DEFAULT 0,
  PRIMARY KEY (`no_sep`, `cmg_code`) USING BTREE,
  CONSTRAINT `inacbg_grouping_stage2_p2km_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `inacbg_grouping_stage12` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE `inacbg_klaim_final_p2km`  (
  `no_sep` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `nik` varchar(30) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  PRIMARY KEY (`no_sep`) USING BTREE,
  CONSTRAINT `inacbg_klaim_final_p2km_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `inacbg_grouping_stage12` (`no_sep`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE `inacbg_pasien_tb_p2km`  (
  `no_sep` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `no_rkm_medis` varchar(15) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `no_sitb` varchar(30) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `status_validasi` varchar(80) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  PRIMARY KEY (`no_sep`) USING BTREE,
  INDEX `inacbg_pasien_tb_smc_ibfk_2`(`no_rkm_medis`) USING BTREE,
  CONSTRAINT `inacbg_pasien_tb_p2km_ibfk_1` FOREIGN KEY (`no_sep`) REFERENCES `pasien` (`no_ktp`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `inacbg_pasien_tb_p2km_ibfk_2` FOREIGN KEY (`no_rkm_medis`) REFERENCES `pasien` (`no_rkm_medis`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE `inacbg_prosedur_pasien_p2km`  (
  `no_sep` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `kode_icd9` varchar(7) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `deskripsi` varchar(250) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `urut` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `keterangan` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `locked` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`no_sep`, `kode_icd9`) USING BTREE,
  INDEX `idrg_pc_smc_icd9cm_im`(`kode_icd9`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

CREATE TABLE `laborat_kesling_pelanggan`  (
  `kode_pelanggan` varchar(5) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `nama_pelanggan` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `alamat` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `kota` varchar(20) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `no_telp` varchar(13) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `kegiatan_usaha` varchar(30) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `personal_dihubungi` varchar(30) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  PRIMARY KEY (`kode_pelanggan`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;


CREATE TABLE `handover` (
  `no_rawat` varchar(17) NOT NULL,
  `tgl_perawatan` date NOT NULL,
  `jam_rawat` time NOT NULL,
  `situation` varchar(2000) DEFAULT NULL,
  `background` varchar(2000) DEFAULT NULL,
  `assesment` varchar(2000) NOT NULL,
  `recommendation` varchar(2000) NOT NULL,
  `tindakan` text NOT NULL,
  `shift` enum('Pagi','Siang','Malam') NOT NULL,
  `nip` varchar(20) NOT NULL,
  `shift2` enum('Pagi','Siang','Malam') NOT NULL,
  `nip2` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

ALTER TABLE `handover`
  ADD PRIMARY KEY (`no_rawat`,`tgl_perawatan`,`jam_rawat`) USING BTREE,
  ADD KEY `no_rawat` (`no_rawat`) USING BTREE,
  ADD KEY `nip` (`nip`) USING BTREE,
  ADD KEY `handover_ibfk_3` (`nip2`);

ALTER TABLE `handover`
  ADD CONSTRAINT `handover_ibfk_1` FOREIGN KEY (`no_rawat`) REFERENCES `reg_periksa` (`no_rawat`) ON UPDATE CASCADE,
  ADD CONSTRAINT `handover_ibfk_2` FOREIGN KEY (`nip`) REFERENCES `petugas` (`nip`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `handover_ibfk_3` FOREIGN KEY (`nip2`) REFERENCES `petugas` (`nip`) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE TABLE `validasi_handover` (
  `no_rawat` varchar(17) NOT NULL,
  `tgl_perawatan` date NOT NULL,
  `jam_rawat` time NOT NULL,
  `shift` enum('Pagi','Siang','Malam') NOT NULL,
  `situation` text NOT NULL,
  `background` text NOT NULL,
  `assesment` text NOT NULL,
  `recommendation` text NOT NULL,
  `tindakan` text NOT NULL,
  `nik` varchar(20) NOT NULL,
  `nik_validator` varchar(20) NOT NULL,
  `tgl_validasi` date NOT NULL,
  `jam_validasi` time NOT NULL,
  `status_validasi` enum('-','Validasi','Tidak Di Validasi') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci ROW_FORMAT=DYNAMIC;

ALTER TABLE `validasi_handover`
  ADD PRIMARY KEY (`no_rawat`,`tgl_perawatan`,`jam_rawat`) USING BTREE,
  ADD KEY `no_rawat` (`no_rawat`) USING BTREE,
  ADD KEY `validasi_pemeriksaan_sbar_2` (`nik`) USING BTREE;

CREATE TABLE
IF
	NOT EXISTS kep_otek (
		id INT AUTO_INCREMENT PRIMARY KEY,
		kode VARCHAR ( 20 ) NOT NULL UNIQUE,
		nama VARCHAR ( 100 ) NOT NULL,
		urutan INT NOT NULL DEFAULT 0,
		aktif ENUM ( 'Y', 'N' ) NOT NULL DEFAULT 'Y' 
	) ENGINE = INNODB DEFAULT CHARSET = utf8mb4;
INSERT INTO kep_otek ( kode, nama, urutan )
VALUES
	( 'OBS', 'OBSERVASI', 1 ),
	( 'TER', 'TERAPEUTIK', 2 ),
	( 'EDU', 'EDUKASI', 3 ),
	( 'KOL', 'KOLABORASI', 4 ) 
	ON DUPLICATE KEY UPDATE nama =
VALUES
	( nama ),
	urutan =
VALUES
	( urutan );
CREATE TABLE
IF
	NOT EXISTS kep_sdki (
		id INT AUTO_INCREMENT PRIMARY KEY,
		kode VARCHAR ( 20 ) NOT NULL UNIQUE,
		nama_diagnosis VARCHAR ( 255 ) NOT NULL,
		kategori VARCHAR ( 100 ) NOT NULL,
		subkategori VARCHAR ( 150 ) NOT NULL,
		jenis ENUM ( 'AKTUAL', 'RISIKO', 'PROMOSI_KESEHATAN', 'LAINNYA' ) NULL,
		definisi TEXT NULL,
		aktif ENUM ( 'Y', 'N' ) NOT NULL DEFAULT 'Y',
		created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		INDEX idx_sdki_nama ( nama_diagnosis ),
		INDEX idx_sdki_kategori ( kategori, subkategori ),
		INDEX idx_sdki_aktif ( aktif ) 
	) ENGINE = INNODB DEFAULT CHARSET = utf8mb4;
CREATE TABLE
IF
	NOT EXISTS kep_siki (
		id INT AUTO_INCREMENT PRIMARY KEY,
		kode VARCHAR ( 20 ) NOT NULL UNIQUE,
		nama_intervensi VARCHAR ( 255 ) NOT NULL,
		definisi TEXT NULL,
		aktif ENUM ( 'Y', 'N' ) NOT NULL DEFAULT 'Y',
		created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		INDEX idx_siki_nama ( nama_intervensi ),
		INDEX idx_siki_aktif ( aktif ) 
	) ENGINE = INNODB DEFAULT CHARSET = utf8mb4;
CREATE TABLE
IF
	NOT EXISTS kep_siki_detail (
		id BIGINT AUTO_INCREMENT PRIMARY KEY,
		siki_id INT NOT NULL,
		otek_id INT NOT NULL,
		tindakan TEXT NOT NULL,
		urutan INT NOT NULL DEFAULT 0,
		aktif ENUM ( 'Y', 'N' ) NOT NULL DEFAULT 'Y',
		CONSTRAINT fk_siki_detail_siki FOREIGN KEY ( siki_id ) REFERENCES kep_siki ( id ) ON DELETE CASCADE ON UPDATE CASCADE,
		CONSTRAINT fk_siki_detail_otek FOREIGN KEY ( otek_id ) REFERENCES kep_otek ( id ) ON DELETE CASCADE ON UPDATE CASCADE,
		INDEX idx_siki_detail_siki ( siki_id ),
		INDEX idx_siki_detail_otek ( otek_id ) 
	) ENGINE = INNODB DEFAULT CHARSET = utf8mb4;
CREATE TABLE
IF
	NOT EXISTS kep_sdki_siki (
		id BIGINT AUTO_INCREMENT PRIMARY KEY,
		sdki_id INT NOT NULL,
		siki_id INT NOT NULL,
		urutan INT NOT NULL DEFAULT 0,
		CONSTRAINT fk_sdki_siki_sdki FOREIGN KEY ( sdki_id ) REFERENCES kep_sdki ( id ) ON DELETE CASCADE ON UPDATE CASCADE,
		CONSTRAINT fk_sdki_siki_siki FOREIGN KEY ( siki_id ) REFERENCES kep_siki ( id ) ON DELETE CASCADE ON UPDATE CASCADE,
	UNIQUE KEY uk_sdki_siki ( sdki_id, siki_id ) 
	) ENGINE = INNODB DEFAULT CHARSET = utf8mb4;

INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('001', 'Bersihan Jalan Napas Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('002', 'Gangguan Penyapihan Ventilator');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('003', 'Gangguan Pertukaran Gas');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('004', 'Gangguan Ventilasi Spontan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('005', 'Pola Napas Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('006', 'Risiko Aspirasi');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('007', 'Gangguan Sirkulasi Spontan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('008', 'Penurunan Curah Jantung');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('009', 'Perfusi Perifer Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('010', 'Risiko Gangguan Sirkulasi Spontan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('011', 'Risiko Penurunan Curah Jantung');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('012', 'Risiko Perdarahan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('013', 'Risiko Perfusi Gastrointestinal Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('014', 'Risiko Perfusi Miokard Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('015', 'Risiko Perfusi Perifer Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('016', 'Risiko Perfusi Renal Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('017', 'Risiko Perfusi Serebral Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('018', 'Berat Badan Lebih');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('019', 'Defisit Nutrisi');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('020', 'Diare');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('021', 'Disfungsi Motilitas Gastrointestinal');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('022', 'Hipervolemia');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('023', 'Hipovolemia');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('024', 'Ikterik Neonatus');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('025', 'Kesiapan Peningkatan Keseimbangan Cairan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('026', 'Kesiapan Peningkatan Nutrisi');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('027', 'Ketidakstabilan Kadar Glukosa Darah');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('028', 'Menyusui Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('029', 'Menyusui Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('030', 'Obesitas');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('031', 'Risiko Berat Badan Lebih');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('032', 'Risiko Defisit Nutrisi');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('033', 'Risiko Disfungsi Motilitas Gastrointestinal');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('034', 'Risiko Hipovolemia');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('035', 'Risiko Ikterik Neonatus');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('036', 'Risiko Ketidakseimbangan Cairan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('037', 'Risiko Ketidakseimbangan Elektrolit');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('038', 'Risiko Ketidakstabilan Kadar Glukosa Darah');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('039', 'Risiko Syok');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('040', 'Gangguan Eliminasi Urin');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('041', 'Inkontinensia Fekal');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('042', 'Inkontinensia Urin Berlanjut');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('043', 'Inkontinensia Urin Berlebih');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('044', 'Inkontinensia Urin Fungsional');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('045', 'Inkontinensia Urin Refleks');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('046', 'Inkontinensia Urin Stres');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('047', 'Inkontinensia Urin Urgensi');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('048', 'Kesiapan Peningkatan Eliminasi Urin');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('049', 'Konstipasi');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('050', 'Retensi Urin');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('051', 'Risiko Inkontinensia Urin Urgensi');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('052', 'Risiko Konstipasi');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('053', 'Disorganisasi Perilaku Bayi');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('054', 'Gangguan Mobilitas Fisik');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('055', 'Gangguan Pola Tidur');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('056', 'Intoleransi Aktivitas');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('057', 'Keletihan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('058', 'Kesiapan Peningkatan Tidur');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('059', 'Risiko Disorganisasi Perilaku Bayi');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('060', 'Risiko Intoleransi Aktivitas');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('061', 'Disrefleksia Otonom');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('062', 'Gangguan Memori');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('063', 'Gangguan Menelan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('064', 'Konfusi Akut');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('065', 'Konfusi Kronis');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('066', 'Penurunan Kapasitas Adaptif Intrakranial');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('067', 'Risiko Disfungsi Neurovaskuler Perifer');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('068', 'Risiko Konfusi Akut');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('069', 'Disfungsi Seksual');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('070', 'Kesiapan Persalinan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('071', 'Pola Seksual Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('072', 'Risiko Disfungsi Seksual');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('073', 'Risiko Kehamilan Tidak Dikehendaki');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('074', 'Gangguan Rasa Nyaman');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('075', 'Ketidaknyamanan Pasca Partum');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('076', 'Nausea');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('077', 'Nyeri Akut');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('078', 'Nyeri Kronis');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('079', 'Nyeri Melahirkan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('080', 'Ansietas');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('081', 'Berduka');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('082', 'Distres Spiritual');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('083', 'Gangguan Citra Tubuh');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('084', 'Gangguan Identitas Diri');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('085', 'Gangguan Persepsi Sensori');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('086', 'Harga Diri Rendah Kronis');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('087', 'Harga Diri Rendah Situasional');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('088', 'Keputusasaan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('089', 'Kesiapan Peningkatan Konsep Diri');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('090', 'Kesiapan Peningkatan Koping Keluarga');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('091', 'Kesiapan Peningkatan Koping Komunitas');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('092', 'Ketidakberdayaan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('093', 'Ketidakmampuan Koping Keluarga');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('094', 'Koping Defensif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('095', 'Koping Komunitas Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('096', 'Koping Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('097', 'Penurunan Koping Keluarga');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('098', 'Penyangkalan Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('099', 'Perilaku Kesehatan Cenderung Berisiko');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('100', 'Risiko Distres Spiritual');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('101', 'Sindrom Pasca Trauma');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('102', 'Waham');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('103', 'Risiko Harga Diri Rendah Kronis');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('104', 'Risiko Harga Diri Rendah Situasional');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('105', 'Risiko Ketidakberdayaan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('106', 'Gangguan Tumbuh Kembang');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('107', 'Risiko Gangguan Perkembangan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('108', 'Risiko Gangguan Pertumbuhan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('109', 'Defisit Perawatan Diri');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('110', 'Defisit Kesehatan Komunitas');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('111', 'Defisit Pengetahuan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('112', 'Kesiapan Peningkatan Manajemen Kesehatan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('113', 'Kesiapan Peningkatan Pengetahuan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('114', 'Ketidakpatuhan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('115', 'Manajemen Kesehatan Keluarga Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('116', 'Manajemen Kesehatan Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('117', 'Pemeliharaan Kesehatan Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('118', 'Gangguan Interaksi Sosial');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('119', 'Gangguan Komunikasi Verbal');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('120', 'Gangguan Proses Keluarga');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('121', 'Isolasi Sosial');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('122', 'Kesiapan Peningkatan Menjadi Orang Tua');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('123', 'Kesiapan Peningkatan Proses Keluarga');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('124', 'Ketegangan Peran Pemberi Asuhan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('125', 'Penampilan Peran Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('126', 'Pencapaian Peran Menjadi Orang Tua');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('127', 'Risiko Gangguan Perlekatan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('128', 'Risiko Proses Pengasuhan Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('129', 'Gangguan Integritas Kulit/Jaringan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('130', 'Hipertermia');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('131', 'Hipotermia');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('132', 'Perilaku Kekerasan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('133', 'Perlambatan Pemulihan Pascabedah');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('134', 'Risiko Alergi');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('135', 'Risiko Bunuh Diri');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('136', 'Risiko Cedera');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('137', 'Risiko Cedera Pada Ibu');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('138', 'Risiko Cedera Pada Janin');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('139', 'Risiko Gangguan Integritas Kulit/Jaringan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('140', 'Risiko Hipotermia');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('141', 'Risiko Hipotermia Perioperatif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('142', 'Risiko Infeksi');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('143', 'Risiko Jatuh');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('144', 'Risiko Luka Tekan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('145', 'Risiko Mutilasi Diri');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('146', 'Risiko Perilaku Kekerasan');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('147', 'Risiko Perlambatan Pemulihan Pascabedah');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('148', 'Risiko Termoregulasi Tidak Efektif');
INSERT INTO `master_masalah_keperawatan`(`kode_masalah`, `nama_masalah`) VALUES ('149', 'Termoregulasi Tidak Efektif');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('001', '001', 'Latihan Batuk Efektif');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('001', '002', 'Manajemen Jalan Napas');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('001', '003', 'Pemantauan Respirasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('002', '004', 'Pemantauan Respirasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('002', '005', 'Penyapihan Ventilasi Mekanik');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('003', '006', 'Pemantauan Respirasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('003', '007', 'Terapi Oksigen');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('004', '008', 'Pemantauan Respirasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('004', '009', 'Dukungan Ventilasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('005', '010', 'Manajemen Jalan Napas');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('005', '011', 'Pemantauan Respirasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('006', '012', 'Manajemen Muntah');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('006', '013', 'Pencegahan Aspirasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('007', '014', 'Resusitasi Jantung Paru');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('008', '015', 'Perawatan Jantung');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('008', '016', 'Perawatan Jantung Akut');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('009', '017', 'Perawatan Sirkulasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('009', '018', 'Manajemen Sensasi Perifer');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('010', '019', 'Resusitasi Jantung Paru');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('010', '020', 'Pencegahan Syok');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('011', '021', 'Perawatan Jantung');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('011', '022', 'Perawatan Jantung Akut');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('012', '023', 'Pencegahan Perdarahan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('013', '024', 'Pencegahan Syok');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('013', '025', 'Pemantauan Tanda Vital');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('014', '026', 'Perawatan Jantung');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('014', '027', 'Perawatan Jantung Akut');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('014', '028', 'Manajemen Aritmia');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('015', '029', 'Perawatan Sirkulasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('015', '030', 'Pencegahan Syok');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('016', '031', 'Pencegahan Syok');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('016', '032', 'Pemantauan Cairan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('017', '033', 'Manajemen Peningkatan Tekanan Intrakranial');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('017', '034', 'Pemantauan Tekanan Intrakranial');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('018', '035', 'Konseling Nutrisi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('018', '036', 'Manajemen Berat Badan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('019', '037', 'Manajemen Nutrisi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('019', '038', 'Promosi Berat Badan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('020', '039', 'Pemantauan Cairan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('020', '040', 'Manajemen Diare');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('021', '041', 'Manajemen Nutrisi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('021', '042', 'Manajemen Diare');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('022', '043', 'Pemantauan Cairan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('022', '044', 'Manajemen Hipervolemia');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('023', '045', 'Pemantauan Cairan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('023', '046', 'Manajemen Hipovolemia');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('024', '047', 'Fototerapi Neonatus');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('024', '048', 'Perawatan Bayi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('025', '049', 'Pemantauan Cairan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('025', '050', 'Manajemen Cairan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('026', '051', 'Konseling Nutrisi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('026', '052', 'Edukasi Nutrisi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('027', '053', 'Manajemen Hiperglikemia');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('027', '054', 'Manajemen Hipoglikemia');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('028', '055', 'Edukasi Menyusui');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('028', '056', 'Konseling Laktasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('029', '057', 'Edukasi Menyusui');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('029', '058', 'Konseling Laktasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('029', '059', 'Perawatan Payudara');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('030', '060', 'Manajemen Berat Badan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('030', '061', 'Edukasi Nutrisi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('031', '062', 'Konseling Nutrisi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('031', '063', 'Edukasi Diet');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('032', '064', 'Manajemen Nutrisi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('032', '065', 'Pemantauan Nutrisi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('033', '066', 'Manajemen Nutrisi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('033', '067', 'Edukasi Diet');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('034', '068', 'Manajemen Hipovolemia');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('034', '069', 'Manajemen Cairan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('035', '070', 'Fototerapi Neonatus');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('035', '071', 'Perawatan Bayi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('036', '072', 'Pemantauan Cairan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('036', '073', 'Manajemen Cairan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('037', '074', 'Manajemen Cairan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('037', '075', 'Pemantauan Elektrolit');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('038', '076', 'Manajemen Hiperglikemia');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('038', '077', 'Manajemen Hipoglikemia');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('039', '078', 'Pencegahan Syok');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('039', '079', 'Pemantauan Tanda Vital');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('040', '080', 'Manajemen Eliminasi Urin');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('041', '081', 'Latihan Eliminasi Fekal');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('041', '082', 'Perawatan Inkontinensia Fekal');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('042', '083', 'Perawatan Inkontinensia Urin');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('042', '084', 'Latihan Otot Panggul');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('043', '085', 'Perawatan Inkontinensia Urin');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('043', '086', 'Kateterisasi Urin');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('044', '087', 'Perawatan Inkontinensia Urin');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('044', '088', 'Latihan Berkemih');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('045', '089', 'Perawatan Inkontinensia Urin');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('045', '090', 'Kateterisasi Urin');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('046', '091', 'Perawatan Inkontinensia Urin');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('046', '092', 'Latihan Otot Panggul');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('047', '093', 'Perawatan Inkontinensia Urin');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('047', '094', 'Latihan Otot Panggul');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('048', '095', 'Manajemen Eliminasi Urin');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('048', '096', 'Edukasi Eliminasi Urin');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('049', '097', 'Manajemen Konstipasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('049', '098', 'Manajemen Eliminasi Fekal');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('050', '099', 'Manajemen Eliminasi Urin');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('050', '100', 'Kateterisasi Urin');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('051', '101', 'Perawatan Inkontinensia Urin');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('051', '102', 'Latihan Otot Panggul');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('052', '103', 'Manajemen Konstipasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('052', '104', 'Manajemen Eliminasi Fekal');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('053', '105', 'Perawatan Bayi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('053', '106', 'Perawatan Perkembangan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('054', '107', 'Dukungan Mobilisasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('054', '108', 'Dukungan Ambulasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('055', '109', 'Dukungan Tidur');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('055', '110', 'Edukasi Aktivitas/Istirahat');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('056', '111', 'Manajemen Energi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('056', '112', 'Terapi Aktivitas');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('057', '113', 'Edukasi Aktivitas/Istirahat');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('057', '114', 'Manajemen Energi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('058', '115', 'Dukungan Tidur');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('058', '116', 'Edukasi Aktivitas/Istirahat');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('059', '117', 'Perawatan Bayi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('059', '118', 'Perawatan Perkembangan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('060', '119', 'Manajemen Energi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('060', '120', 'Terapi Aktivitas');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('061', '121', 'Manajemen Disrefleksia Otonom');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('062', '122', 'Latihan Memori');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('062', '123', 'Orientasi Realita');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('063', '124', 'Dukungan Perawatan Diri: Makan/Minum');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('063', '125', 'Manajemen Gangguan Menelan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('064', '126', 'Manajemen Delirium');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('065', '127', 'Orientasi Realita');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('065', '128', 'Manajemen Demensia');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('066', '129', 'Manajemen Peningkatan Tekanan Intrakranial');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('066', '130', 'Pemantauan Tekanan Intrakranial');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('067', '131', 'Manajemen Sensasi Perifer');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('068', '132', 'Manajemen Delirium');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('069', '133', 'Konseling Seksualitas');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('069', '134', 'Edukasi Seksualitas');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('070', '135', 'Edukasi Persalinan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('070', '136', 'Persiapan Persalinan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('071', '137', 'Konseling Seksualitas');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('071', '138', 'Edukasi Seksualitas');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('072', '139', 'Konseling Seksualitas');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('072', '140', 'Edukasi Seksualitas');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('073', '141', 'Konseling Keluarga Berencana');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('073', '142', 'Edukasi Keluarga Berencana');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('074', '143', 'Manajemen Nyeri');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('074', '144', 'Terapi Relaksasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('075', '145', 'Manajemen Nyeri');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('075', '146', 'Perawatan Pasca Partum');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('076', '147', 'Manajemen Muntah');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('076', '148', 'Manajemen Mual');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('077', '149', 'Manajemen Nyeri');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('077', '150', 'Pemberian Analgesik');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('078', '151', 'Manajemen Nyeri');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('078', '152', 'Perawatan Kenyamanan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('079', '153', 'Manajemen Nyeri');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('079', '154', 'Latihan Pernapasan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('080', '155', 'Terapi Relaksasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('080', '156', 'Reduksi Ansietas');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('081', '157', 'Dukungan Proses Berduka');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('081', '158', 'Dukungan Emosional');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('082', '159', 'Dukungan Spiritual');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('083', '160', 'Promosi Citra Tubuh');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('084', '161', 'Promosi Kesadaran Diri');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('085', '162', 'Manajemen Halusinasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('086', '163', 'Promosi Harga Diri');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('087', '164', 'Promosi Harga Diri');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('088', '165', 'Dukungan Emosional');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('088', '166', 'Promosi Harapan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('089', '167', 'Promosi Kesadaran Diri');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('090', '168', 'Dukungan Koping Keluarga');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('091', '169', 'Promosi Koping Komunitas');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('092', '170', 'Promosi Koping');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('093', '171', 'Dukungan Koping Keluarga');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('094', '172', 'Promosi Koping');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('095', '173', 'Promosi Koping Komunitas');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('096', '174', 'Promosi Koping');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('097', '175', 'Dukungan Koping Keluarga');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('098', '176', 'Promosi Koping');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('099', '177', 'Edukasi Kesehatan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('100', '178', 'Dukungan Spiritual');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('101', '179', 'Dukungan Pemulihan Trauma');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('102', '180', 'Manajemen Waham');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('103', '181', 'Promosi Harga Diri');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('104', '182', 'Promosi Harga Diri');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('105', '183', 'Promosi Harapan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('105', '184', 'Dukungan Pengambilan Keputusan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('106', '185', 'Perawatan Perkembangan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('106', '186', 'Promosi Perkembangan Anak');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('107', '187', 'Promosi Perkembangan Anak');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('108', '188', 'Promosi Berat Badan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('109', '189', 'Dukungan Perawatan Diri');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('110', '190', 'Pengembangan Kesehatan Masyarakat');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('111', '191', 'Edukasi Kesehatan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('112', '192', 'Edukasi Kesehatan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('113', '193', 'Edukasi Kesehatan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('114', '194', 'Dukungan Kepatuhan Program Pengobatan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('115', '195', 'Dukungan Koping Keluarga');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('116', '196', 'Bimbingan Sistem Kesehatan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('117', '197', 'Edukasi Kesehatan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('118', '198', 'Modifikasi Perilaku Keterampilan Sosial');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('119', '199', 'Promosi Komunikasi: Defisit Bicara');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('120', '200', 'Dukungan Koping Keluarga');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('121', '201', 'Terapi Aktivitas');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('121', '202', 'Promosi Sosialisasi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('122', '203', 'Promosi Pengasuhan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('122', '204', 'Dukungan Proses Keluarga');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('123', '205', 'Dukungan Koping Keluarga');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('123', '206', 'Dukungan Proses Keluarga');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('124', '207', 'Dukungan Pemberi Asuhan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('125', '208', 'Promosi Peran');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('126', '209', 'Promosi Pengasuhan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('127', '210', 'Promosi Perlekatan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('128', '211', 'Promosi Pengasuhan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('129', '212', 'Perawatan Integritas Kulit');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('129', '213', 'Perawatan Luka');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('130', '214', 'Manajemen Hipertermia');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('131', '215', 'Manajemen Hipotermia');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('132', '216', 'Pencegahan Perilaku Kekerasan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('133', '217', 'Perawatan Pasca Anestesi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('134', '218', 'Pencegahan Alergi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('135', '219', 'Pencegahan Bunuh Diri');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('136', '220', 'Pencegahan Cedera');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('137', '221', 'Pencegahan Cedera');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('137', '222', 'Perawatan Kehamilan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('138', '223', 'Pemantauan Denyut Jantung Janin');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('139', '224', 'Perawatan Integritas Kulit');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('139', '225', 'Pencegahan Luka Tekan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('140', '226', 'Manajemen Hipotermia');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('141', '227', 'Manajemen Hipotermia');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('142', '228', 'Pencegahan Infeksi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('143', '229', 'Pencegahan Jatuh');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('144', '230', 'Pencegahan Luka Tekan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('145', '231', 'Pencegahan Mutilasi Diri');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('146', '232', 'Pencegahan Perilaku Kekerasan');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('147', '233', 'Perawatan Pasca Anestesi');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('148', '234', 'Regulasi Temperatur');
INSERT INTO `master_rencana_keperawatan`(`kode_masalah`, `kode_rencana`, `rencana_keperawatan`) VALUES ('149', '235', 'Regulasi Temperatur');
INSERT INTO `kep_otek`(`id`, `kode`, `nama`, `urutan`, `aktif`) VALUES (1, 'OBS', 'OBSERVASI', 1, 'Y');
INSERT INTO `kep_otek`(`id`, `kode`, `nama`, `urutan`, `aktif`) VALUES (2, 'TER', 'TERAPEUTIK', 2, 'Y');
INSERT INTO `kep_otek`(`id`, `kode`, `nama`, `urutan`, `aktif`) VALUES (3, 'EDU', 'EDUKASI', 3, 'Y');
INSERT INTO `kep_otek`(`id`, `kode`, `nama`, `urutan`, `aktif`) VALUES (4, 'KOL', 'KOLABORASI', 4, 'Y');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (5, 'D.0001', 'Bersihan Jalan Napas Tidak Efektif', 'Fisiologis', 'Respirasi', NULL, NULL, 'Y', '2026-09-09 22:19:43', '2026-09-09 22:19:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (6, 'D.0002', 'Gangguan Penyapihan Ventilator', 'Fisiologis', 'Respirasi', NULL, NULL, 'Y', '2026-09-09 22:19:43', '2026-09-09 22:19:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (7, 'D.0003', 'Gangguan Pertukaran Gas', 'Fisiologis', 'Respirasi', NULL, NULL, 'Y', '2026-09-09 22:19:43', '2026-09-09 22:19:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (8, 'D.0004', 'Gangguan Ventilasi Spontan', 'Fisiologis', 'Respirasi', NULL, NULL, 'Y', '2026-09-09 22:19:43', '2026-09-09 22:19:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (9, 'D.0005', 'Pola Napas Tidak Efektif', 'Fisiologis', 'Respirasi', NULL, NULL, 'Y', '2026-09-09 22:19:43', '2026-09-09 22:19:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (10, 'D.0006', 'Risiko Aspirasi', 'Fisiologis', 'Respirasi', NULL, NULL, 'Y', '2026-09-09 22:22:42', '2026-09-09 22:22:42');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (11, 'D.0007', 'Gangguan Sirkulasi Spontan', 'Fisiologis', 'Sirkulasi', NULL, NULL, 'Y', '2026-09-09 22:22:42', '2026-09-09 22:22:42');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (12, 'D.0008', 'Penurunan Curah Jantung', 'Fisiologis', 'Sirkulasi', NULL, NULL, 'Y', '2026-09-09 22:22:42', '2026-09-09 22:22:42');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (13, 'D.0009', 'Perfusi Perifer Tidak Efektif', 'Fisiologis', 'Sirkulasi', NULL, NULL, 'Y', '2026-09-09 22:22:42', '2026-09-09 22:22:42');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (14, 'D.0010', 'Risiko Gangguan Sirkulasi Spontan', 'Fisiologis', 'Sirkulasi', NULL, NULL, 'Y', '2026-09-09 22:22:42', '2026-09-09 22:22:42');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (15, 'D.0011', 'Risiko Penurunan Curah Jantung', 'Fisiologis', 'Sirkulasi', NULL, NULL, 'Y', '2026-09-09 22:32:19', '2026-09-09 22:32:19');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (16, 'D.0012', 'Risiko Perdarahan', 'Fisiologis', 'Sirkulasi', NULL, NULL, 'Y', '2026-09-09 22:32:19', '2026-09-09 22:32:19');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (17, 'D.0013', 'Risiko Perfusi Gastrointestinal Tidak Efektif', 'Fisiologis', 'Sirkulasi', NULL, NULL, 'Y', '2026-09-09 22:32:19', '2026-09-09 22:32:19');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (18, 'D.0014', 'Risiko Perfusi Miokard Tidak Efektif', 'Fisiologis', 'Sirkulasi', NULL, NULL, 'Y', '2026-09-09 22:32:19', '2026-09-09 22:32:19');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (19, 'D.0015', 'Risiko Perfusi Perifer Tidak Efektif', 'Fisiologis', 'Sirkulasi', NULL, NULL, 'Y', '2026-09-09 22:32:19', '2026-09-09 22:32:19');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (20, 'D.0016', 'Risiko Perfusi Renal Tidak Efektif', 'Fisiologis', 'Sirkulasi', NULL, NULL, 'Y', '2026-09-09 22:38:22', '2026-09-09 22:38:22');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (21, 'D.0017', 'Risiko Perfusi Serebral Tidak Efektif', 'Fisiologis', 'Sirkulasi', NULL, NULL, 'Y', '2026-09-09 22:38:22', '2026-09-09 22:38:22');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (22, 'D.0018', 'Berat Badan Lebih', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:38:22', '2026-09-09 22:38:22');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (23, 'D.0019', 'Defisit Nutrisi', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:38:22', '2026-09-09 22:38:22');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (24, 'D.0020', 'Diare', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:38:22', '2026-09-09 22:38:22');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (25, 'D.0021', 'Disfungsi Motilitas Gastrointestinal', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:44:46', '2026-09-09 22:44:46');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (26, 'D.0022', 'Hipervolemia', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:44:46', '2026-09-09 22:44:46');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (27, 'D.0023', 'Hipovolemia', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:44:46', '2026-09-09 22:44:46');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (28, 'D.0024', 'Ikterik Neonatus', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:44:46', '2026-09-09 22:44:46');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (29, 'D.0025', 'Kesiapan Peningkatan Keseimbangan Cairan', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:44:46', '2026-09-09 22:44:46');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (30, 'D.0026', 'Kesiapan Peningkatan Nutrisi', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:46:43', '2026-09-09 22:46:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (31, 'D.0027', 'Ketidakstabilan Kadar Glukosa Darah', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:46:43', '2026-09-09 22:46:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (32, 'D.0028', 'Menyusui Efektif', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:46:43', '2026-09-09 22:46:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (33, 'D.0029', 'Menyusui Tidak Efektif', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:46:43', '2026-09-09 22:46:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (34, 'D.0030', 'Obesitas', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:46:43', '2026-09-09 22:46:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (35, 'D.0031', 'Risiko Berat Badan Lebih', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:48:04', '2026-09-09 22:48:04');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (36, 'D.0032', 'Risiko Defisit Nutrisi', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:48:04', '2026-09-09 22:48:04');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (37, 'D.0033', 'Risiko Disfungsi Motilitas Gastrointestinal', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:48:04', '2026-09-09 22:48:04');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (38, 'D.0034', 'Risiko Hipovolemia', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:48:04', '2026-09-09 22:48:04');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (39, 'D.0035', 'Risiko Ikterik Neonatus', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:48:04', '2026-09-09 22:48:04');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (40, 'D.0036', 'Risiko Ketidakseimbangan Cairan', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:50:41', '2026-09-09 22:50:41');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (41, 'D.0037', 'Risiko Ketidakseimbangan Elektrolit', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:50:41', '2026-09-09 22:50:41');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (42, 'D.0038', 'Risiko Ketidakstabilan Kadar Glukosa Darah', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:50:41', '2026-09-09 22:50:41');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (43, 'D.0039', 'Risiko Syok', 'Fisiologis', 'Nutrisi dan Cairan', NULL, NULL, 'Y', '2026-09-09 22:50:41', '2026-09-09 22:50:41');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (44, 'D.0040', 'Gangguan Eliminasi Urin', 'Fisiologis', 'Eliminasi', NULL, NULL, 'Y', '2026-09-09 22:50:41', '2026-09-09 22:50:41');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (45, 'D.0041', 'Inkontinensia Fekal', 'Fisiologis', 'Eliminasi', NULL, NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (46, 'D.0042', 'Inkontinensia Urin Berlanjut', 'Fisiologis', 'Eliminasi', NULL, NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (47, 'D.0043', 'Inkontinensia Urin Berlebih', 'Fisiologis', 'Eliminasi', NULL, NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (48, 'D.0044', 'Inkontinensia Urin Fungsional', 'Fisiologis', 'Eliminasi', NULL, NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (49, 'D.0045', 'Inkontinensia Urin Refleks', 'Fisiologis', 'Eliminasi', NULL, NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (50, 'D.0046', 'Inkontinensia Urin Stres', 'Fisiologis', 'Eliminasi', NULL, NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (51, 'D.0047', 'Inkontinensia Urin Urgensi', 'Fisiologis', 'Eliminasi', NULL, NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (52, 'D.0048', 'Kesiapan Peningkatan Eliminasi Urin', 'Fisiologis', 'Eliminasi', NULL, NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (53, 'D.0049', 'Konstipasi', 'Fisiologis', 'Eliminasi', NULL, NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (54, 'D.0050', 'Retensi Urin', 'Fisiologis', 'Eliminasi', NULL, NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (55, 'D.0051', 'Risiko Inkontinensia Urin Urgensi', 'Fisiologis', 'Eliminasi', NULL, NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (56, 'D.0052', 'Risiko Konstipasi', 'Fisiologis', 'Eliminasi', NULL, NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (57, 'D.0053', 'Disorganisasi Perilaku Bayi', 'Fisiologis', 'Aktivitas dan Istirahat', NULL, NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (58, 'D.0054', 'Gangguan Mobilitas Fisik', 'Fisiologis', 'Aktivitas dan Istirahat', NULL, NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (59, 'D.0055', 'Gangguan Pola Tidur', 'Fisiologis', 'Aktivitas dan Istirahat', NULL, NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (60, 'D.0056', 'Intoleransi Aktivitas', 'Fisiologis', 'Aktivitas dan Istirahat', NULL, NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (61, 'D.0057', 'Keletihan', 'Fisiologis', 'Aktivitas dan Istirahat', NULL, NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (62, 'D.0058', 'Kesiapan Peningkatan Tidur', 'Fisiologis', 'Aktivitas dan Istirahat', NULL, NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (63, 'D.0059', 'Risiko Disorganisasi Perilaku Bayi', 'Fisiologis', 'Aktivitas dan Istirahat', NULL, NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (64, 'D.0060', 'Risiko Intoleransi Aktivitas', 'Fisiologis', 'Aktivitas dan Istirahat', NULL, NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (65, 'D.0061', 'Disrefleksia Otonom', 'Fisiologis', 'Neurosensori', NULL, NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (66, 'D.0062', 'Gangguan Memori', 'Fisiologis', 'Neurosensori', NULL, NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (67, 'D.0063', 'Gangguan Menelan', 'Fisiologis', 'Neurosensori', NULL, NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (68, 'D.0064', 'Konfusi Akut', 'Fisiologis', 'Neurosensori', NULL, NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (69, 'D.0065', 'Konfusi Kronis', 'Fisiologis', 'Neurosensori', NULL, NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (70, 'D.0066', 'Penurunan Kapasitas Adaptif Intrakranial', 'Fisiologis', 'Neurosensori', NULL, NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (71, 'D.0067', 'Risiko Disfungsi Neurovaskuler Perifer', 'Fisiologis', 'Neurosensori', NULL, NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (72, 'D.0068', 'Risiko Konfusi Akut', 'Fisiologis', 'Neurosensori', NULL, NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (73, 'D.0069', 'Disfungsi Seksual', 'Fisiologis', 'Reproduksi dan Seksualitas', NULL, NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (74, 'D.0070', 'Kesiapan Persalinan', 'Fisiologis', 'Reproduksi dan Seksualitas', NULL, NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (75, 'D.0071', 'Pola Seksual Tidak Efektif', 'Fisiologis', 'Reproduksi dan Seksualitas', NULL, NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (76, 'D.0072', 'Risiko Disfungsi Seksual', 'Fisiologis', 'Reproduksi dan Seksualitas', NULL, NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (77, 'D.0073', 'Risiko Kehamilan Tidak Dikehendaki', 'Fisiologis', 'Reproduksi dan Seksualitas', NULL, NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (78, 'D.0074', 'Gangguan Rasa Nyaman', 'Psikologis', 'Nyeri dan Kenyamanan', NULL, NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (79, 'D.0075', 'Ketidaknyamanan Pasca Partum', 'Psikologis', 'Nyeri dan Kenyamanan', NULL, NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (80, 'D.0076', 'Nausea', 'Psikologis', 'Nyeri dan Kenyamanan', NULL, NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (81, 'D.0077', 'Nyeri Akut', 'Psikologis', 'Nyeri dan Kenyamanan', NULL, NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (82, 'D.0078', 'Nyeri Kronis', 'Psikologis', 'Nyeri dan Kenyamanan', NULL, NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (83, 'D.0079', 'Nyeri Melahirkan', 'Psikologis', 'Nyeri dan Kenyamanan', NULL, NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (84, 'D.0080', 'Ansietas', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (85, 'D.0081', 'Berduka', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (86, 'D.0082', 'Distres Spiritual', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (87, 'D.0083', 'Gangguan Citra Tubuh', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (88, 'D.0084', 'Gangguan Identitas Diri', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (89, 'D.0085', 'Gangguan Persepsi Sensori', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (90, 'D.0086', 'Harga Diri Rendah Kronis', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (91, 'D.0087', 'Harga Diri Rendah Situasional', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (92, 'D.0088', 'Keputusasaan', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (93, 'D.0089', 'Kesiapan Peningkatan Konsep Diri', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (94, 'D.0090', 'Kesiapan Peningkatan Koping Keluarga', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (95, 'D.0091', 'Kesiapan Peningkatan Koping Komunitas', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (96, 'D.0092', 'Ketidakberdayaan', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (97, 'D.0093', 'Ketidakmampuan Koping Keluarga', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (98, 'D.0094', 'Koping Defensif', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (99, 'D.0095', 'Koping Komunitas Tidak Efektif', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (100, 'D.0096', 'Koping Tidak Efektif', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (101, 'D.0097', 'Penurunan Koping Keluarga', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (102, 'D.0098', 'Penyangkalan Tidak Efektif', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (103, 'D.0099', 'Perilaku Kesehatan Cenderung Berisiko', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (104, 'D.0100', 'Risiko Distres Spiritual', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (105, 'D.0101', 'Sindrom Pasca Trauma', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (106, 'D.0102', 'Waham', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (107, 'D.0103', 'Risiko Harga Diri Rendah Kronis', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (108, 'D.0104', 'Risiko Harga Diri Rendah Situasional', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (109, 'D.0105', 'Risiko Ketidakberdayaan', 'Psikologis', 'Integritas Ego', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (110, 'D.0106', 'Gangguan Tumbuh Kembang', 'Psikologis', 'Pertumbuhan dan Perkembangan', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (111, 'D.0107', 'Risiko Gangguan Perkembangan', 'Psikologis', 'Pertumbuhan dan Perkembangan', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (112, 'D.0108', 'Risiko Gangguan Pertumbuhan', 'Psikologis', 'Pertumbuhan dan Perkembangan', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (113, 'D.0109', 'Defisit Perawatan Diri', 'Perilaku', 'Kebersihan Diri', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (114, 'D.0110', 'Defisit Kesehatan Komunitas', 'Perilaku', 'Penyuluhan dan Pembelajaran', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (115, 'D.0111', 'Defisit Pengetahuan', 'Perilaku', 'Penyuluhan dan Pembelajaran', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (116, 'D.0112', 'Kesiapan Peningkatan Manajemen Kesehatan', 'Perilaku', 'Penyuluhan dan Pembelajaran', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (117, 'D.0113', 'Kesiapan Peningkatan Pengetahuan', 'Perilaku', 'Penyuluhan dan Pembelajaran', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (118, 'D.0114', 'Ketidakpatuhan', 'Perilaku', 'Penyuluhan dan Pembelajaran', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (119, 'D.0115', 'Manajemen Kesehatan Keluarga Tidak Efektif', 'Perilaku', 'Penyuluhan dan Pembelajaran', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (120, 'D.0116', 'Manajemen Kesehatan Tidak Efektif', 'Perilaku', 'Penyuluhan dan Pembelajaran', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (121, 'D.0117', 'Pemeliharaan Kesehatan Tidak Efektif', 'Perilaku', 'Penyuluhan dan Pembelajaran', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (122, 'D.0118', 'Gangguan Interaksi Sosial', 'Relasional', 'Interaksi Sosial', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (123, 'D.0119', 'Gangguan Komunikasi Verbal', 'Relasional', 'Interaksi Sosial', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (124, 'D.0120', 'Gangguan Proses Keluarga', 'Relasional', 'Interaksi Sosial', NULL, NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (125, 'D.0121', 'Isolasi Sosial', 'Relasional', 'Interaksi Sosial', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (126, 'D.0122', 'Kesiapan Peningkatan Menjadi Orang Tua', 'Relasional', 'Interaksi Sosial', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (127, 'D.0123', 'Kesiapan Peningkatan Proses Keluarga', 'Relasional', 'Interaksi Sosial', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (128, 'D.0124', 'Ketegangan Peran Pemberi Asuhan', 'Relasional', 'Interaksi Sosial', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (129, 'D.0125', 'Penampilan Peran Tidak Efektif', 'Relasional', 'Interaksi Sosial', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (130, 'D.0126', 'Pencapaian Peran Menjadi Orang Tua', 'Relasional', 'Interaksi Sosial', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (131, 'D.0127', 'Risiko Gangguan Perlekatan', 'Relasional', 'Interaksi Sosial', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (132, 'D.0128', 'Risiko Proses Pengasuhan Tidak Efektif', 'Relasional', 'Interaksi Sosial', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (133, 'D.0129', 'Gangguan Integritas Kulit/Jaringan', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (134, 'D.0130', 'Hipertermia', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (135, 'D.0131', 'Hipotermia', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (136, 'D.0132', 'Perilaku Kekerasan', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (137, 'D.0133', 'Perlambatan Pemulihan Pascabedah', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (138, 'D.0134', 'Risiko Alergi', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (139, 'D.0135', 'Risiko Bunuh Diri', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (140, 'D.0136', 'Risiko Cedera', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (141, 'D.0137', 'Risiko Cedera Pada Ibu', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (142, 'D.0138', 'Risiko Cedera Pada Janin', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (143, 'D.0139', 'Risiko Gangguan Integritas Kulit/Jaringan', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (144, 'D.0140', 'Risiko Hipotermia', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (145, 'D.0141', 'Risiko Hipotermia Perioperatif', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (146, 'D.0142', 'Risiko Infeksi', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (147, 'D.0143', 'Risiko Jatuh', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (148, 'D.0144', 'Risiko Luka Tekan', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (149, 'D.0145', 'Risiko Mutilasi Diri', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (150, 'D.0146', 'Risiko Perilaku Kekerasan', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (151, 'D.0147', 'Risiko Perlambatan Pemulihan Pascabedah', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (152, 'D.0148', 'Risiko Termoregulasi Tidak Efektif', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki`(`id`, `kode`, `nama_diagnosis`, `kategori`, `subkategori`, `jenis`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (153, 'D.0149', 'Termoregulasi Tidak Efektif', 'Lingkungan', 'Keamanan dan Proteksi', NULL, NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (5, 5, 6, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (6, 5, 7, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (7, 5, 8, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (8, 6, 9, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (9, 6, 8, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (10, 7, 8, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (11, 7, 10, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (12, 8, 11, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (13, 8, 8, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (14, 9, 7, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (15, 9, 8, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (16, 10, 12, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (17, 10, 13, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (18, 11, 14, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (19, 12, 15, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (20, 12, 16, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (21, 13, 17, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (22, 13, 18, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (23, 14, 19, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (24, 14, 14, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (25, 15, 15, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (26, 15, 16, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (27, 16, 20, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (28, 17, 19, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (29, 17, 21, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (30, 18, 22, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (31, 18, 15, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (32, 18, 16, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (33, 19, 19, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (34, 19, 17, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (35, 20, 19, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (36, 20, 23, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (37, 21, 24, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (38, 21, 25, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (39, 22, 26, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (40, 22, 27, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (41, 23, 28, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (42, 23, 29, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (43, 24, 30, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (44, 24, 23, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (45, 25, 28, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (46, 25, 30, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (47, 26, 31, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (48, 26, 23, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (49, 27, 32, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (50, 27, 23, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (51, 28, 33, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (52, 28, 34, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (53, 29, 35, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (54, 29, 23, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (55, 30, 36, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (56, 30, 26, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (57, 31, 37, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (58, 31, 38, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (59, 32, 39, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (60, 32, 40, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (61, 33, 39, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (62, 33, 40, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (63, 33, 41, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (64, 34, 27, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (65, 34, 36, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (66, 35, 26, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (67, 35, 42, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (68, 36, 28, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (69, 36, 43, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (70, 37, 28, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (71, 37, 42, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (72, 38, 35, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (73, 38, 32, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (74, 39, 34, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (75, 39, 33, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (76, 40, 35, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (77, 40, 23, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (78, 41, 35, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (79, 41, 44, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (80, 42, 37, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (81, 42, 38, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (82, 43, 19, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (83, 43, 21, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (84, 44, 45, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (85, 45, 46, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (86, 45, 47, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (87, 46, 48, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (88, 46, 49, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (89, 47, 48, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (90, 47, 50, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (91, 48, 48, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (92, 48, 51, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (93, 49, 48, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (94, 49, 50, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (95, 50, 49, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (96, 50, 48, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (97, 51, 48, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (98, 51, 49, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (99, 52, 52, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (100, 52, 45, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (101, 53, 53, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (102, 53, 54, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (103, 54, 45, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (104, 54, 50, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (105, 55, 48, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (106, 55, 49, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (107, 56, 53, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (108, 56, 54, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (109, 57, 55, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (110, 57, 34, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (111, 58, 56, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (112, 58, 57, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (113, 59, 58, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (114, 59, 59, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (115, 60, 60, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (116, 60, 61, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (117, 61, 59, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (118, 61, 60, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (119, 62, 58, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (120, 62, 59, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (121, 63, 55, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (122, 63, 34, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (123, 64, 60, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (124, 64, 61, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (125, 65, 62, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (126, 66, 63, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (127, 66, 64, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (128, 67, 65, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (129, 67, 66, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (130, 68, 67, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (131, 69, 68, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (132, 69, 64, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (133, 70, 24, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (134, 70, 25, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (135, 71, 18, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (136, 72, 67, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (137, 73, 69, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (138, 73, 70, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (139, 74, 71, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (140, 74, 72, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (141, 75, 69, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (142, 75, 70, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (143, 76, 69, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (144, 76, 70, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (145, 77, 73, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (146, 77, 74, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (147, 78, 75, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (148, 78, 76, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (149, 79, 75, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (150, 79, 77, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (151, 80, 78, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (152, 80, 12, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (153, 81, 75, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (154, 81, 79, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (155, 82, 75, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (156, 82, 80, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (157, 83, 75, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (158, 83, 81, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (159, 84, 82, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (160, 84, 76, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (161, 85, 83, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (162, 85, 89, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (163, 86, 84, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (164, 87, 85, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (165, 88, 86, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (166, 89, 87, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (167, 90, 88, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (168, 91, 88, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (169, 92, 89, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (170, 92, 90, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (171, 93, 86, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (172, 94, 91, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (173, 95, 92, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (174, 96, 93, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (175, 97, 91, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (176, 98, 93, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (177, 99, 92, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (178, 100, 93, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (179, 101, 91, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (180, 102, 93, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (181, 103, 94, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (182, 104, 84, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (183, 105, 95, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (184, 106, 96, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (185, 107, 88, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (186, 108, 88, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (187, 109, 90, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (188, 109, 97, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (189, 110, 55, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (190, 110, 98, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (191, 111, 98, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (192, 112, 29, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (193, 113, 99, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (194, 114, 100, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (195, 115, 94, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (196, 116, 94, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (197, 117, 94, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (198, 118, 101, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (199, 119, 91, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (200, 120, 102, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (201, 121, 94, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (202, 122, 103, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (203, 123, 104, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (204, 124, 91, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (205, 125, 105, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (206, 125, 61, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (207, 126, 106, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (208, 126, 107, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (209, 127, 107, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (210, 127, 91, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (211, 128, 108, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (212, 129, 109, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (213, 130, 106, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (214, 131, 110, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (215, 132, 106, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (216, 133, 111, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (217, 133, 112, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (218, 134, 113, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (219, 135, 114, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (220, 136, 115, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (221, 137, 116, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (222, 138, 117, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (223, 139, 118, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (224, 140, 119, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (225, 141, 119, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (226, 141, 120, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (227, 142, 121, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (228, 143, 122, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (229, 143, 111, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (230, 144, 114, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (231, 145, 114, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (232, 146, 123, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (233, 147, 124, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (234, 148, 122, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (235, 149, 125, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (236, 150, 115, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (237, 151, 116, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (238, 152, 126, 0);
INSERT INTO `kep_sdki_siki`(`id`, `sdki_id`, `siki_id`, `urutan`) VALUES (239, 153, 126, 0);
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (6, 'I.01006', 'Latihan Batuk Efektif', NULL, 'Y', '2026-09-09 22:19:43', '2026-09-09 22:19:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (7, 'I.01011', 'Manajemen Jalan Napas', NULL, 'Y', '2026-09-09 22:19:43', '2026-09-09 22:19:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (8, 'I.01014', 'Pemantauan Respirasi', NULL, 'Y', '2026-09-09 22:19:43', '2026-09-09 22:19:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (9, 'I.01021', 'Penyapihan Ventilasi Mekanik', NULL, 'Y', '2026-09-09 22:19:43', '2026-09-09 22:19:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (10, 'I.01026', 'Terapi Oksigen', NULL, 'Y', '2026-09-09 22:19:43', '2026-09-09 22:19:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (11, 'I.01002', 'Dukungan Ventilasi', NULL, 'Y', '2026-09-09 22:19:43', '2026-09-09 22:19:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (12, 'I.03118', 'Manajemen Muntah', NULL, 'Y', '2026-09-09 22:22:42', '2026-09-09 22:22:42');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (13, 'I.01018', 'Pencegahan Aspirasi', NULL, 'Y', '2026-09-09 22:22:42', '2026-09-09 22:22:42');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (14, 'I.02083', 'Resusitasi Jantung Paru', NULL, 'Y', '2026-09-09 22:22:42', '2026-09-09 22:22:42');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (15, 'I.02075', 'Perawatan Jantung', NULL, 'Y', '2026-09-09 22:22:42', '2026-09-09 22:22:42');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (16, 'I.02076', 'Perawatan Jantung Akut', NULL, 'Y', '2026-09-09 22:22:42', '2026-09-09 22:22:42');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (17, 'I.02079', 'Perawatan Sirkulasi', NULL, 'Y', '2026-09-09 22:22:42', '2026-09-09 22:22:42');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (18, 'I.06195', 'Manajemen Sensasi Perifer', NULL, 'Y', '2026-09-09 22:22:42', '2026-09-09 22:22:42');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (19, 'I.02068', 'Pencegahan Syok', NULL, 'Y', '2026-09-09 22:22:42', '2026-09-09 22:22:42');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (20, 'I.02067', 'Pencegahan Perdarahan', NULL, 'Y', '2026-09-09 22:32:19', '2026-09-09 22:32:19');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (21, 'I.02060', 'Pemantauan Tanda Vital', NULL, 'Y', '2026-09-09 22:32:19', '2026-09-09 22:32:19');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (22, 'I.02035', 'Manajemen Aritmia', NULL, 'Y', '2026-09-09 22:32:19', '2026-09-09 22:32:19');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (23, 'I.03121', 'Pemantauan Cairan', NULL, 'Y', '2026-09-09 22:38:22', '2026-09-09 22:38:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (24, 'I.06194', 'Manajemen Peningkatan Tekanan Intrakranial', NULL, 'Y', '2026-09-09 22:38:22', '2026-09-09 22:38:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (25, 'I.06198', 'Pemantauan Tekanan Intrakranial', NULL, 'Y', '2026-09-09 22:38:22', '2026-09-09 22:38:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (26, 'I.03094', 'Konseling Nutrisi', NULL, 'Y', '2026-09-09 22:38:22', '2026-09-09 22:38:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (27, 'I.03097', 'Manajemen Berat Badan', NULL, 'Y', '2026-09-09 22:38:22', '2026-09-09 22:38:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (28, 'I.03119', 'Manajemen Nutrisi', NULL, 'Y', '2026-09-09 22:38:22', '2026-09-09 22:38:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (29, 'I.03136', 'Promosi Berat Badan', NULL, 'Y', '2026-09-09 22:38:22', '2026-09-09 22:38:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (30, 'I.03101', 'Manajemen Diare', NULL, 'Y', '2026-09-09 22:38:22', '2026-09-09 22:38:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (31, 'I.03114', 'Manajemen Hipervolemia', NULL, 'Y', '2026-09-09 22:44:46', '2026-09-09 22:44:46');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (32, 'I.03116', 'Manajemen Hipovolemia', NULL, 'Y', '2026-09-09 22:44:46', '2026-09-09 22:44:46');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (33, 'I.03091', 'Fototerapi Neonatus', NULL, 'Y', '2026-09-09 22:44:46', '2026-09-09 22:44:46');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (34, 'I.10324', 'Perawatan Bayi', NULL, 'Y', '2026-09-09 22:44:46', '2026-09-09 22:44:46');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (35, 'I.03098', 'Manajemen Cairan', NULL, 'Y', '2026-09-09 22:44:46', '2026-09-09 22:44:46');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (36, 'I.12395', 'Edukasi Nutrisi', NULL, 'Y', '2026-09-09 22:46:43', '2026-09-09 22:46:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (37, 'I.03115', 'Manajemen Hiperglikemia', NULL, 'Y', '2026-09-09 22:46:43', '2026-09-09 22:46:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (38, 'I.03111', 'Manajemen Hipoglikemia', NULL, 'Y', '2026-09-09 22:46:43', '2026-09-09 22:46:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (39, 'I.12393', 'Edukasi Menyusui', NULL, 'Y', '2026-09-09 22:46:43', '2026-09-09 22:46:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (40, 'I.03093', 'Konseling Laktasi', NULL, 'Y', '2026-09-09 22:46:43', '2026-09-09 22:46:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (41, 'I.07214', 'Perawatan Payudara', NULL, 'Y', '2026-09-09 22:46:43', '2026-09-09 22:46:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (42, 'I.12369', 'Edukasi Diet', NULL, 'Y', '2026-09-09 22:48:04', '2026-09-09 22:48:04');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (43, 'I.03123', 'Pemantauan Nutrisi', NULL, 'Y', '2026-09-09 22:48:04', '2026-09-09 22:48:04');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (44, 'I.03122', 'Pemantauan Elektrolit', NULL, 'Y', '2026-09-09 22:50:41', '2026-09-09 22:50:41');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (45, 'I.04152', 'Manajemen Eliminasi Urin', NULL, 'Y', '2026-09-09 22:50:41', '2026-09-09 22:50:41');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (46, 'I.04150', 'Latihan Eliminasi Fekal', NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (47, 'I.04162', 'Perawatan Inkontinensia Fekal', NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (48, 'I.04163', 'Perawatan Inkontinensia Urin', NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (49, 'I.07215', 'Latihan Otot Panggul', NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (50, 'I.04148', 'Kateterisasi Urin', NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (51, 'I.04149', 'Latihan Berkemih', NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (52, 'I.12368', 'Edukasi Eliminasi Urin', NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (53, 'I.04155', 'Manajemen Konstipasi', NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (54, 'I.04151', 'Manajemen Eliminasi Fekal', NULL, 'Y', '2026-09-09 22:51:22', '2026-09-09 22:51:22');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (55, 'I.10336', 'Perawatan Perkembangan', NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (56, 'I.05173', 'Dukungan Mobilisasi', NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (57, 'I.05171', 'Dukungan Ambulasi', NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (58, 'I.05174', 'Dukungan Tidur', NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (59, 'I.12362', 'Edukasi Aktivitas/Istirahat', NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (60, 'I.05178', 'Manajemen Energi', NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (61, 'I.05186', 'Terapi Aktivitas', NULL, 'Y', '2026-09-09 22:53:45', '2026-09-09 22:53:45');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (62, 'I.06191', 'Manajemen Disrefleksia Otonom', NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (63, 'I.06188', 'Latihan Memori', NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (64, 'I.09297', 'Orientasi Realita', NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (65, 'I.11351', 'Dukungan Perawatan Diri: Makan/Minum', NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (66, 'I.03112', 'Manajemen Gangguan Menelan', NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (67, 'I.09283', 'Manajemen Delirium', NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (68, 'I.09284', 'Manajemen Demensia', NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (69, 'I.07213', 'Konseling Seksualitas', NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (70, 'I.12422', 'Edukasi Seksualitas', NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (71, 'I.12437', 'Edukasi Persalinan', NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (72, 'I.07225', 'Persiapan Persalinan', NULL, 'Y', '2026-09-09 22:55:43', '2026-09-09 22:55:43');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (73, 'I.07212', 'Konseling Keluarga Berencana', NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (74, 'I.12381', 'Edukasi Keluarga Berencana', NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (75, 'I.08238', 'Manajemen Nyeri', NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (76, 'I.09326', 'Terapi Relaksasi', NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (77, 'I.07226', 'Perawatan Pasca Partum', NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (78, 'I.03117', 'Manajemen Mual', NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (79, 'I.08243', 'Pemberian Analgesik', NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (80, 'I.08245', 'Perawatan Kenyamanan', NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (81, 'I.01007', 'Latihan Pernapasan', NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (82, 'I.09314', 'Reduksi Ansietas', NULL, 'Y', '2026-09-09 22:56:37', '2026-09-09 22:56:37');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (83, 'I.09277', 'Dukungan Proses Berduka', NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (84, 'I.09276', 'Dukungan Spiritual', NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (85, 'I.09305', 'Promosi Citra Tubuh', NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (86, 'I.09312', 'Promosi Kesadaran Diri', NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (87, 'I.09293', 'Manajemen Halusinasi', NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (88, 'I.09308', 'Promosi Harga Diri', NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (89, 'I.09274', 'Dukungan Emosional', NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (90, 'I.09307', 'Promosi Harapan', NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (91, 'I.09260', 'Dukungan Koping Keluarga', NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (92, 'I.09309', 'Promosi Koping Komunitas', NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (93, 'I.09313', 'Promosi Koping', NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (94, 'I.12383', 'Edukasi Kesehatan', NULL, 'Y', '2026-09-09 22:58:24', '2026-09-09 22:58:24');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (95, 'I.09275', 'Dukungan Pemulihan Trauma', NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (96, 'I.09295', 'Manajemen Waham', NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (97, 'I.09265', 'Dukungan Pengambilan Keputusan', NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (98, 'I.10340', 'Promosi Perkembangan Anak', NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (99, 'I.11348', 'Dukungan Perawatan Diri', NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (100, 'I.14548', 'Pengembangan Kesehatan Masyarakat', NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (101, 'I.12361', 'Dukungan Kepatuhan Program Pengobatan', NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (102, 'I.12360', 'Bimbingan Sistem Kesehatan', NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (103, 'I.09299', 'Modifikasi Perilaku Keterampilan Sosial', NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (104, 'I.13492', 'Promosi Komunikasi: Defisit Bicara', NULL, 'Y', '2026-09-09 23:00:54', '2026-09-09 23:00:54');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (105, 'I.09315', 'Promosi Sosialisasi', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (106, 'I.13495', 'Promosi Pengasuhan', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (107, 'I.13483', 'Dukungan Proses Keluarga', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (108, 'I.13491', 'Dukungan Pemberi Asuhan', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (109, 'I.13497', 'Promosi Peran', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (110, 'I.10341', 'Promosi Perlekatan', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (111, 'I.11353', 'Perawatan Integritas Kulit', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (112, 'I.14564', 'Perawatan Luka', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (113, 'I.15506', 'Manajemen Hipertermia', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (114, 'I.14507', 'Manajemen Hipotermia', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (115, 'I.09303', 'Pencegahan Perilaku Kekerasan', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (116, 'I.14526', 'Perawatan Pasca Anestesi', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (117, 'I.14524', 'Pencegahan Alergi', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (118, 'I.09301', 'Pencegahan Bunuh Diri', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (119, 'I.14537', 'Pencegahan Cedera', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (120, 'I.14525', 'Perawatan Kehamilan', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (121, 'I.02056', 'Pemantauan Denyut Jantung Janin', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (122, 'I.14543', 'Pencegahan Luka Tekan', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (123, 'I.14539', 'Pencegahan Infeksi', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (124, 'I.14540', 'Pencegahan Jatuh', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (125, 'I.09302', 'Pencegahan Mutilasi Diri', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
INSERT INTO `kep_siki`(`id`, `kode`, `nama_intervensi`, `definisi`, `aktif`, `created_at`, `updated_at`) VALUES (126, 'I.14578', 'Regulasi Temperatur', NULL, 'Y', '2026-09-09 23:03:05', '2026-09-09 23:03:05');
	
SET FOREIGN_KEY_CHECKS=1;