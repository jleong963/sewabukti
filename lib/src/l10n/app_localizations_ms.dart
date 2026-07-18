// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appName => 'SewaBukti';

  @override
  String get appTagline => 'Susun bukti. Tuntut deposit anda.';

  @override
  String get landingIntro =>
      'SewaBukti membantu penyewa di Malaysia menyusun bukti apabila tuan rumah, ejen, atau syarikat pengurusan melewatkan, mengurangkan, atau enggan memulangkan deposit sewa. Ia ialah alat penyusunan bukti dan penyediaan dokumen, bukan firma guaman.';

  @override
  String get howItWorksTitle => 'Cara ia berfungsi';

  @override
  String get stepCompileTitle => 'Kumpul';

  @override
  String get stepCompileBody =>
      'Kumpulkan perjanjian sewa, resit, gambar, dan mesej anda ke dalam satu kes yang tersusun dan peribadi.';

  @override
  String get stepDemandTitle => 'Tuntut';

  @override
  String get stepDemandBody =>
      'Kira baki yang tertunggak dan hasilkan surat tuntutan yang neutral dan profesional yang anda kawal sepenuhnya.';

  @override
  String get stepPrepareTitle => 'Sedia';

  @override
  String get stepPrepareBody =>
      'Bina kronologi berdasarkan fakta dan eksport himpunan bukti berindeks untuk menyokong tuntutan sivil atau tuntutan kecil.';

  @override
  String get privacySummaryTitle => 'Bukti anda kekal peribadi';

  @override
  String get privacySummaryBody =>
      'Fail yang dimuat naik disimpan dalam storan peribadi yang hanya boleh diakses oleh anda. SewaBukti tidak sekali-kali menjadikan dokumen anda umum.';

  @override
  String get disclaimerSummaryTitle => 'Perhatian';

  @override
  String get disclaimerSummaryBody =>
      'SewaBukti tidak memberikan nasihat atau perwakilan guaman dan tidak menjamin pembayaran balik atau penerimaan mahkamah. Anda mengesahkan ketepatan setiap fakta, tarikh, jumlah, dan nama pihak. Peraturan mahkamah, borang, yuran, dan had boleh berubah.';

  @override
  String get continueWithGoogle => 'Teruskan dengan Google';

  @override
  String get googleSignInHint =>
      'Log masuk ke SewaBukti dengan Akaun Google sedia ada anda. Anda tidak mencipta Akaun Google baharu.';

  @override
  String get previewBuildNotice =>
      'Binaan pratonton — log masuk disimulasikan untuk tujuan demonstrasi.';

  @override
  String get previewSignIn => 'Teruskan (pratonton)';

  @override
  String get signInFailed => 'Log masuk gagal. Sila cuba lagi.';

  @override
  String get inactiveSignedOut =>
      'Anda telah dilog keluar selepas satu tempoh tidak aktif. Sila log masuk semula.';

  @override
  String get notLegalServiceNotice =>
      'SewaBukti bukan firma guaman, mahkamah, atau perkhidmatan kerajaan.';

  @override
  String get languageLabel => 'Bahasa';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageMalay => 'Bahasa Melayu';

  @override
  String get languageChinese => '简体中文';

  @override
  String get privacyPolicy => 'Dasar Privasi';

  @override
  String get termsOfUse => 'Terma Penggunaan';

  @override
  String get help => 'Bantuan';

  @override
  String get signOut => 'Log keluar';

  @override
  String get navDashboard => 'Papan Pemuka';

  @override
  String get navSettings => 'Tetapan';

  @override
  String dashboardWelcome(String name) {
    return 'Selamat datang, $name';
  }

  @override
  String get dashboardNoCaseTitle => 'Anda belum mempunyai kes aktif';

  @override
  String get dashboardNoCaseBody =>
      'Mulakan kes tuntutan deposit untuk menyusun bukti anda, mengira jumlah yang anda berhak terima, dan menyediakan surat tuntutan.';

  @override
  String get dashboardStartCase => 'Mulakan kes anda';

  @override
  String get dashboardContinueCase => 'Sambung kes anda';

  @override
  String get dashboardActiveCaseTitle => 'Kes tuntutan deposit anda';

  @override
  String dashboardCompletion(int percent) {
    return '$percent% selesai';
  }

  @override
  String get dashboardOutstandingTasks => 'Tugasan tertunggak';

  @override
  String get dashboardDemandLetter => 'Surat tuntutan';

  @override
  String get dashboardEvidenceBundle => 'Himpunan bukti';

  @override
  String get dashboardStorageUsed => 'Storan digunakan';

  @override
  String dashboardStorageValue(String usedMb, String totalMb) {
    return '$usedMb MB daripada $totalMb MB';
  }

  @override
  String get statusNotStarted => 'Belum bermula';

  @override
  String get statusInProgress => 'Sedang berjalan';

  @override
  String get statusReady => 'Sedia';

  @override
  String get statusSent => 'Dihantar';

  @override
  String get settingsTitle => 'Tetapan';

  @override
  String get settingsAccountSection => 'Akaun';

  @override
  String get settingsNameLabel => 'Nama';

  @override
  String get settingsEmailLabel => 'E-mel Google';

  @override
  String get settingsPreferencesSection => 'Keutamaan';

  @override
  String get settingsLanguageLabel => 'Bahasa';

  @override
  String get settingsDisplayModeLabel => 'Mod paparan';

  @override
  String get displayLight => 'Cerah';

  @override
  String get displayDark => 'Gelap';

  @override
  String get settingsStorageSection => 'Storan';

  @override
  String get settingsDataSection => 'Data anda';

  @override
  String get settingsExportData => 'Muat turun salinan data kes anda';

  @override
  String get settingsDeleteCase => 'Padam kes';

  @override
  String get settingsDeleteAccount => 'Padam akaun dan data aplikasi';

  @override
  String get settingsLegalSection => 'Undang-undang & privasi';

  @override
  String get comingSoon => 'Akan datang';

  @override
  String get caseWizardTitle => 'Kes anda';

  @override
  String wizardStepOf(int current, int total) {
    return 'Langkah $current daripada $total';
  }

  @override
  String get wizardNext => 'Seterusnya';

  @override
  String get wizardBack => 'Kembali';

  @override
  String get wizardSaveExit => 'Simpan & keluar';

  @override
  String get wizardFinish => 'Selesai';

  @override
  String get wizardSavedToast => 'Kemajuan disimpan';

  @override
  String get fieldRequired => 'Diperlukan';

  @override
  String get invalidEmail => 'Masukkan e-mel yang sah';

  @override
  String get invalidAmount => 'Masukkan jumlah yang sah';

  @override
  String get optionalLabel => 'Pilihan';

  @override
  String get selectDate => 'Pilih tarikh';

  @override
  String get notSet => 'Belum ditetapkan';

  @override
  String get showLabel => 'Papar';

  @override
  String get hideLabel => 'Sembunyi';

  @override
  String get stepTenancyTitle => 'Butiran penyewaan';

  @override
  String get stepClaimantTitle => 'Butiran anda';

  @override
  String get stepOtherPartyTitle => 'Pihak satu lagi';

  @override
  String get stepDepositTitle => 'Butiran deposit';

  @override
  String get stepReviewTitle => 'Semak';

  @override
  String get fieldAddressLine1 => 'Alamat baris 1';

  @override
  String get fieldAddressLine2 => 'Alamat baris 2';

  @override
  String get fieldCity => 'Bandar / pekan';

  @override
  String get fieldPostcode => 'Poskod';

  @override
  String get fieldState => 'Negeri';

  @override
  String get fieldTenancyStart => 'Tarikh mula penyewaan';

  @override
  String get fieldTenancyEnd => 'Tarikh tamat penyewaan';

  @override
  String get fieldVacatedDate => 'Tarikh anda mengosongkan';

  @override
  String get fieldKeysReturned => 'Tarikh kunci / kad akses dipulangkan';

  @override
  String get fieldMonthlyRent => 'Sewa bulanan';

  @override
  String get fieldRefundDeadline => 'Tarikh akhir pemulangan dalam perjanjian';

  @override
  String get fieldFullName => 'Nama penuh';

  @override
  String get fieldIdNumber => 'Nombor kad pengenalan / pasport';

  @override
  String get fieldIdNumberHint =>
      'Pilihan. Dilindung secara lalai dan disimpan dengan selamat; digunakan hanya pada dokumen anda.';

  @override
  String get fieldEmail => 'E-mel';

  @override
  String get fieldEmailFromGoogleHint => 'Daripada akaun Google anda';

  @override
  String get fieldPhone => 'Nombor telefon';

  @override
  String get fieldCorrespondenceAddress => 'Alamat surat-menyurat';

  @override
  String get otherPartyDisclaimer =>
      'Soalan ini membantu menyusun maklumat. Ia tidak menentukan pihak defendan yang sah di sisi undang-undang — sahkan dengan pendaftaran mahkamah atau peguam jika anda tidak pasti.';

  @override
  String get fieldPartyType => 'Anda menuntut daripada siapa?';

  @override
  String get partyTypeLandlord => 'Tuan rumah';

  @override
  String get partyTypeAgent => 'Ejen';

  @override
  String get partyTypeManagement => 'Syarikat pengurusan';

  @override
  String get partyTypeUncertain => 'Tidak pasti';

  @override
  String get fieldPartyIsCompany => 'Pihak ini ialah syarikat';

  @override
  String get fieldPartyName => 'Nama (seperti dalam perjanjian sewa)';

  @override
  String get fieldPartyCompanyNo => 'Nombor pendaftaran syarikat';

  @override
  String get fieldPartyEmail => 'E-mel';

  @override
  String get fieldPartyPhone => 'Nombor telefon';

  @override
  String get fieldPartyAddress => 'Alamat penyampaian / surat-menyurat';

  @override
  String get fieldDepositReceivedBy => 'Siapa menerima deposit?';

  @override
  String get fieldDepositPromisedBy => 'Siapa berjanji memulangkan deposit?';

  @override
  String get fieldSecurityDeposit => 'Deposit sewa dibayar';

  @override
  String get fieldUtilityDeposit => 'Deposit utiliti dibayar';

  @override
  String get fieldAccessDeposit => 'Deposit kad akses / kunci dibayar';

  @override
  String get fieldOtherDeposit => 'Deposit lain dibayar';

  @override
  String get labelTotalDeposit => 'Jumlah deposit dibayar';

  @override
  String get fieldAmountRefunded => 'Jumlah yang telah dipulangkan';

  @override
  String get fieldDeductionsAccepted => 'Potongan yang anda terima';

  @override
  String get fieldDeductionsDisputed => 'Potongan yang anda pertikaikan';

  @override
  String get labelTotalClaimed => 'Jumlah dituntut sekarang';

  @override
  String get reviewConfirmHint =>
      'Sila semak setiap fakta, tarikh, jumlah, dan nama pihak. Anda bertanggungjawab atas ketepatannya.';

  @override
  String get reviewNoData => 'Belum dimasukkan.';

  @override
  String get dashboardAmountClaimed => 'Jumlah dituntut';

  @override
  String get dashboardManageEvidence => 'Bukti';

  @override
  String get evidenceTitle => 'Bukti';

  @override
  String get evidenceSupportedHint => 'PDF, JPG, PNG, WebP, atau TXT.';

  @override
  String evidenceFileCount(int count, int max) {
    return '$count daripada $max fail';
  }

  @override
  String get evidenceAdd => 'Tambah fail';

  @override
  String get evidenceEmptyCategory => 'Belum ada';

  @override
  String get evidencePreview => 'Pratonton';

  @override
  String get evidenceDownload => 'Muat turun';

  @override
  String get evidenceDelete => 'Padam';

  @override
  String evidenceDeleteConfirm(String name) {
    return 'Buang \"$name\"? Ini tidak boleh dibatalkan.';
  }

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonRemove => 'Buang';

  @override
  String get evidenceAddDialogTitle => 'Tambah bukti';

  @override
  String get evidenceItemTitle => 'Tajuk';

  @override
  String get evidenceItemDescription => 'Penerangan';

  @override
  String get evidenceItemDate => 'Tarikh dokumen / peristiwa';

  @override
  String get evidenceUploaded => 'Fail ditambah';

  @override
  String get evidencePreviewUnavailable =>
      'Pratonton tidak tersedia di sini — fail disimpan setelah backend disediakan; tambah semula untuk pratonton dalam sesi ini.';

  @override
  String get evidenceHashNote =>
      'Cincangan fail mengesan perubahan kemudian pada fail tetapi tidak membuktikan bila fail asal dicipta.';

  @override
  String get evidenceNoCaseTitle => 'Mulakan kes dahulu';

  @override
  String get evidenceNoCaseBody =>
      'Cipta kes tuntutan deposit anda sebelum menambah bukti.';

  @override
  String get errUnsupportedType => 'Jenis fail ini tidak disokong.';

  @override
  String get errFileTooLarge => 'Fail ini melebihi had saiz.';

  @override
  String get errFileCountExceeded =>
      'Anda telah mencapai bilangan fail maksimum untuk kes ini.';

  @override
  String get errStorageQuota => 'Had storan kes ini telah penuh.';

  @override
  String get errPickFailed => 'Tidak dapat membaca fail yang dipilih.';

  @override
  String get evCatTenancyAgreement => 'Perjanjian sewa';

  @override
  String get evCatStampedAgreement => 'Perjanjian sewa bersetem';

  @override
  String get evCatDepositReceipt =>
      'Resit bayaran deposit / bukti pindahan bank';

  @override
  String get evCatMoveInPhotos => 'Gambar keadaan masuk';

  @override
  String get evCatMoveOutPhotos => 'Gambar keadaan keluar';

  @override
  String get evCatHandoverKeys => 'Penyerahan kunci / kad akses';

  @override
  String get evCatInspectionReport => 'Laporan pemeriksaan / penyerahan akhir';

  @override
  String get evCatUtilityBills => 'Bil utiliti akhir & bacaan meter';

  @override
  String get evCatMessages => 'Tangkap layar WhatsApp / mesej';

  @override
  String get evCatEmails => 'E-mel';

  @override
  String get evCatDeductionStatement => 'Penyata potongan';

  @override
  String get evCatRepairQuote => 'Sebut harga pembaikan / pembersihan';

  @override
  String get evCatRepairReceipt => 'Resit pembaikan / pembersihan';

  @override
  String get evCatPriorRequests => 'Permintaan pemulangan terdahulu';

  @override
  String get evCatDemandDelivery => 'Bukti penghantaran surat tuntutan';

  @override
  String get evCatOther => 'Bukti sokongan lain';

  @override
  String get dashboardChronology => 'Kronologi';

  @override
  String get chronologyTitle => 'Kronologi';

  @override
  String get chronologyIntro =>
      'Tambah peristiwa penting mengikut urutan. Masukkan hanya fakta yang boleh anda sokong — SewaBukti tidak pernah mencipta atau membuat andaian.';

  @override
  String get chronologyEmpty => 'Belum ada peristiwa. Tambah yang pertama.';

  @override
  String get chronologyAdd => 'Tambah peristiwa';

  @override
  String get chronologyEditEvent => 'Sunting peristiwa';

  @override
  String get chronologySortByDate => 'Susun ikut tarikh';

  @override
  String get chronologyDeleteConfirm => 'Buang peristiwa ini?';

  @override
  String get chronologyNoCaseBody =>
      'Cipta kes anda sebelum membina kronologi.';

  @override
  String get eventDateLabel => 'Tarikh';

  @override
  String get eventTimeLabel => 'Masa (pilihan)';

  @override
  String get eventTitleLabel => 'Peristiwa';

  @override
  String get eventDescriptionLabel => 'Apa yang berlaku';

  @override
  String get eventLinkedEvidence => 'Bukti berkaitan';

  @override
  String get eventSuggestionsLabel => 'Peristiwa biasa';

  @override
  String eventLinkedCount(int count) {
    return '$count dipautkan';
  }

  @override
  String get evtTenancyCommenced => 'Penyewaan bermula';

  @override
  String get evtDepositPaid => 'Deposit dibayar';

  @override
  String get evtNoticeGiven => 'Notis penamatan diberi';

  @override
  String get evtVacated => 'Hartanah dikosongkan';

  @override
  String get evtKeysReturned => 'Kunci dipulangkan';

  @override
  String get evtInspection => 'Pemeriksaan selesai';

  @override
  String get evtRefundRequested => 'Pemulangan diminta';

  @override
  String get evtRefundPromised => 'Pemulangan dijanjikan';

  @override
  String get evtPartialRefund => 'Pemulangan separa diterima';

  @override
  String get evtDeductionDisputed => 'Potongan dipertikaikan';

  @override
  String get evtDemandSent => 'Surat tuntutan dihantar';

  @override
  String get evtDeadlineExpired => 'Tarikh akhir bayaran tamat';

  @override
  String get demandLetterTitle => 'Surat tuntutan';

  @override
  String get demandLetterIntro =>
      'Hasilkan surat tuntutan yang neutral daripada butiran kes anda. Semak semuanya dan sahkan ia tepat sebelum anda memuat turun atau menghantarnya.';

  @override
  String get demandLanguageLabel => 'Bahasa surat';

  @override
  String get demandRecipientEmailLabel => 'E-mel penerima';

  @override
  String get demandSignatureLabel => 'Nama anda (sebagai tandatangan)';

  @override
  String get demandDeadlineLabel => 'Tarikh akhir bayaran';

  @override
  String get demandPaymentInstructionsLabel => 'Arahan pembayaran (pilihan)';

  @override
  String get demandNotesLabel => 'Nota tambahan (pilihan)';

  @override
  String get demandFactsHeading => 'Butiran yang digunakan dalam surat';

  @override
  String get demandConfirmCheckbox =>
      'Saya mengesahkan fakta, jumlah, tarikh, dan nama ini adalah tepat.';

  @override
  String get demandConfirmRequired =>
      'Sila sahkan butiran adalah tepat dahulu.';

  @override
  String get demandMissingFields =>
      'Sila lengkapkan e-mel penerima, nama anda, dan tarikh akhir bayaran.';

  @override
  String get demandDownloadPdf => 'Muat turun / cetak PDF';

  @override
  String get demandSend => 'E-mel salinan kepada saya';

  @override
  String get demandSent => 'Satu salinan telah dihantar ke e-mel anda.';

  @override
  String get demandCopyToLabel => 'E-mel salinan kepada (alamat anda)';

  @override
  String get demandDeliveryNote =>
      'SewaBukti menghantar surat dan PDF-nya kepada anda melalui e-mel. Anda kemudian memajukan atau menyampaikannya kepada pihak lain sendiri — SewaBukti tidak menghantarnya bagi pihak anda.';

  @override
  String get demandPaymentInstructionsHint =>
      'Pilihan. Hanya tambah butiran bank jika anda selesa berkongsinya.';

  @override
  String get demandSendFailed => 'Penghantaran gagal. Sila cuba lagi.';

  @override
  String get demandBackendRequired =>
      'Penghantaran e-mel memerlukan backend disediakan. Anda masih boleh memuat turun PDF.';

  @override
  String get demandNoCaseBody =>
      'Cipta kes anda sebelum menghasilkan surat tuntutan.';

  @override
  String get letterSubject => 'Tuntutan pemulangan deposit sewa';

  @override
  String letterGreeting(String recipient) {
    return 'Kepada $recipient,';
  }

  @override
  String get letterGreetingFallback => 'Kepada sesiapa yang berkenaan,';

  @override
  String letterOpening(String property) {
    return 'Saya menulis berkenaan deposit sewa bagi hartanah di $property.';
  }

  @override
  String letterTenancyPeriod(String start, String end) {
    return 'Penyewaan berlangsung dari $start hingga $end.';
  }

  @override
  String get letterDepositHeading => 'Ringkasan deposit';

  @override
  String letterOutstandingSentence(String amount) {
    return 'Baki deposit yang terhutang kepada saya ialah $amount.';
  }

  @override
  String get letterFactsHeading => 'Ringkasan peristiwa';

  @override
  String letterDeadlineSentence(String deadline) {
    return 'Saya memohon agar jumlah ini dibayar sepenuhnya selewat-lewatnya $deadline.';
  }

  @override
  String get letterPaymentHeading => 'Arahan pembayaran';

  @override
  String get letterDocsHeading => 'Dokumen sokongan';

  @override
  String get letterFurtherAction =>
      'Jika bayaran tidak diterima menjelang tarikh tersebut, saya mungkin mempertimbangkan tindakan sivil selanjutnya untuk menuntut jumlah yang terhutang.';

  @override
  String get letterClosing => 'Yang benar,';

  @override
  String get letterFooterDisclaimer =>
      'Surat ini disediakan oleh penghantar menggunakan SewaBukti, alat penyusunan bukti dan penyediaan dokumen. Ia bersifat umum, bukan nasihat guaman, dan tidak dikeluarkan oleh peguam.';

  @override
  String get bundleTitle => 'Himpunan bukti';

  @override
  String get bundleIntro =>
      'Himpunkan butiran kes, kronologi, dan bukti pilihan anda ke dalam satu PDF berindeks yang boleh dimuat turun. Tiada apa-apa dimuat naik.';

  @override
  String get bundleNoCaseBody =>
      'Cipta kes anda sebelum menjana himpunan bukti.';

  @override
  String get bundleIncludedHeading => 'Disertakan dalam himpunan';

  @override
  String get bundleIncludeCaseSummary =>
      'Ringkasan kes, pihak, hartanah, dan pengiraan deposit';

  @override
  String get bundleIncludeChronology => 'Kronologi peristiwa';

  @override
  String get bundleEvidenceHeading => 'Bukti untuk disertakan';

  @override
  String get bundleEvidenceHint =>
      'Semua fail dipilih secara lalai. Nyahtanda apa-apa yang sensitif yang anda tidak mahu dalam himpunan.';

  @override
  String get bundleNoEvidence =>
      'Tiada bukti dimuat naik. Himpunan hanya akan mengandungi butiran kes anda.';

  @override
  String get bundleSelectAll => 'Pilih semua';

  @override
  String get bundleSelectNone => 'Kosongkan semua';

  @override
  String get bundleEmbeddedHint => 'Imej — dibenamkan';

  @override
  String get bundleAttachmentHint => 'Lampiran berasingan';

  @override
  String get bundlePreparedByLabel => 'Disediakan oleh (nama)';

  @override
  String get bundleChecklistHeading => 'Semakan akhir sebelum menjana';

  @override
  String bundleChecklistEvidence(int included, int total) {
    return '$included daripada $total item bukti disertakan';
  }

  @override
  String bundleChecklistEmbedded(int embedded, int attachments) {
    return '$embedded dibenamkan sebagai imej, $attachments sebagai lampiran berasingan';
  }

  @override
  String bundleChecklistEvents(int count) {
    return '$count peristiwa kronologi';
  }

  @override
  String get bundleConfirmCheckbox =>
      'Saya mengesahkan maklumat ini tepat dan saya telah memilih bukti yang hendak disertakan.';

  @override
  String get bundleConfirmRequired => 'Sila sahkan sebelum menjana himpunan.';

  @override
  String get bundleGenerate => 'Jana PDF himpunan';

  @override
  String get bundleGenerating => 'Menyediakan himpunan anda…';

  @override
  String get bundleGenerateFailed =>
      'Tidak dapat menjana himpunan. Sila cuba lagi.';

  @override
  String get bundleCoverPreparedBy => 'Disediakan oleh';

  @override
  String get bundleGeneratedOn => 'Dijana pada';

  @override
  String get bundleDisclaimerHeading => 'Penafian dan pengesahan';

  @override
  String get bundleDisclaimerP1 =>
      'SewaBukti ialah alat penyusunan bukti dan penyediaan dokumen. Ia bukan firma guaman, tidak memberikan nasihat atau perwakilan guaman, dan tidak menjamin pembayaran balik atau penerimaan mahkamah.';

  @override
  String get bundleDisclaimerP2 =>
      'Individu yang dinamakan pada muka hadapan telah menyediakan himpunan ini dan mengesahkan bahawa fakta, tarikh, jumlah, dan nama pihak yang terkandung di dalamnya adalah tepat setakat pengetahuannya.';

  @override
  String get bundleDisclaimerP3 =>
      'Peraturan mahkamah, borang, yuran, dan had mungkin berubah. Sahkan keperluan semasa dengan pendaftaran mahkamah yang berkaitan.';

  @override
  String get bundleProvenanceNote =>
      'Tajuk, jumlah, dan nombor apendiks (SB-A##) dijana oleh SewaBukti. Semua nilai lain dimasukkan oleh pengguna.';

  @override
  String get bundleCaseSummaryHeading => 'Ringkasan kes';

  @override
  String get bundleTenancyPeriodLabel => 'Tempoh penyewaan';

  @override
  String get bundleEvidenceCountLabel => 'Item bukti disertakan';

  @override
  String get bundleEventCountLabel => 'Peristiwa kronologi';

  @override
  String get bundlePartiesHeading => 'Pihak dan hartanah';

  @override
  String get bundlePropertyLabel => 'Alamat';

  @override
  String get bundlePropertyHeading => 'Hartanah';

  @override
  String get bundleClaimantHeading => 'Penuntut';

  @override
  String get bundleOtherPartyHeading => 'Pihak lain';

  @override
  String get bundleDepositHeading => 'Pengiraan deposit';

  @override
  String get bundleChronologyHeading => 'Kronologi peristiwa';

  @override
  String get bundleChronologyEmpty => 'Tiada peristiwa kronologi ditambah.';

  @override
  String get bundleChronologyRefsLabel => 'Bukti berkaitan';

  @override
  String get bundleIndexHeading => 'Indeks bukti';

  @override
  String bundleIndexIntro(int count) {
    return '$count item disertakan dalam himpunan ini.';
  }

  @override
  String get bundleColAppendix => 'Apendiks';

  @override
  String get bundleColItem => 'Item';

  @override
  String get bundleColCategory => 'Kategori';

  @override
  String get bundleColDocDate => 'Tarikh dokumen';

  @override
  String get bundleColUploaded => 'Dimuat naik';

  @override
  String get bundleColType => 'Jenis';

  @override
  String get bundleEmbeddedType => 'Imej dibenamkan';

  @override
  String get bundleAttachmentType => 'Fail berasingan';

  @override
  String get bundleSecTenancy => 'Perjanjian penyewaan';

  @override
  String get bundleSecDeposit => 'Bukti pembayaran deposit';

  @override
  String get bundleSecHandover => 'Bukti penyerahan dan keadaan hartanah';

  @override
  String get bundleSecUtility => 'Bukti utiliti';

  @override
  String get bundleSecComms => 'Komunikasi';

  @override
  String get bundleSecDeduction => 'Bukti potongan dan perbelanjaan';

  @override
  String get bundleSecDemand => 'Surat tuntutan dan bukti penghantaran';

  @override
  String get bundleSecOther => 'Bukti lain';

  @override
  String get bundleEvidenceMainHeading => 'Bukti';

  @override
  String get bundleAttachmentNotice =>
      'Fail ini disediakan sebagai lampiran berasingan dan tidak dibenamkan dalam himpunan ini.';

  @override
  String get bundleImageUnavailable =>
      'Imej ini tidak dapat dibenamkan dan disediakan sebagai lampiran berasingan.';

  @override
  String get bundleFileLabel => 'Nama fail';

  @override
  String get bundleSha256Label => 'SHA-256';

  @override
  String get bundleFooterDisclaimer =>
      'Himpunan ini disediakan oleh penghantar menggunakan SewaBukti, alat penyusunan bukti dan penyediaan dokumen. Ia bersifat umum, bukan nasihat guaman, dan tidak dikeluarkan oleh peguam.';

  @override
  String get legalReviewBanner =>
      'Draf untuk beta — menunggu semakan guaman profesional. Versi Inggeris diguna pakai.';

  @override
  String get claimRouteTitle => 'Laluan tuntutan';

  @override
  String get claimRouteOpenGuidance => 'Buka panduan kehakiman rasmi';

  @override
  String get claimRouteGuidanceNote =>
      'Mahkamah dan portal rasmi bergantung pada tempat anda memfailkan. Buka panduan untuk wilayah anda:';

  @override
  String get regionPeninsular => 'Semenanjung Malaysia';

  @override
  String get regionSabahSarawak => 'Sabah & Sarawak';

  @override
  String claimRouteAboveCeiling(String amount, String ceiling) {
    return 'Tuntutan $amount ini melebihi had tuntutan kecil $ceiling. Ia berkemungkinan memerlukan prosiding sivil biasa dan bukannya Mahkamah Tuntutan Kecil — pertimbangkan untuk merujuk pendaftaran mahkamah atau peguam.';
  }

  @override
  String get dashboardClaimRoute => 'Laluan tuntutan';

  @override
  String get commonDelete => 'Padam';

  @override
  String get deleteCaseConfirmTitle => 'Padam kes ini?';

  @override
  String get deleteCaseConfirmBody =>
      'Ini memadam kes anda, buktinya, dan kronologi secara kekal. Tindakan ini tidak boleh dibatalkan.';

  @override
  String get caseDeleted => 'Kes dipadam.';

  @override
  String get deleteCaseFailed => 'Tidak dapat memadam kes. Sila cuba lagi.';

  @override
  String get deleteAccountConfirmTitle => 'Padam akaun anda?';

  @override
  String get deleteAccountConfirmBody =>
      'Ini memadam akaun anda dan semua data aplikasi secara kekal, termasuk kes dan bukti anda. Tindakan ini tidak boleh dibatalkan.';

  @override
  String get deleteAccountAck =>
      'Saya faham ini memadam akaun dan data saya secara kekal.';

  @override
  String get deleteAccountAction => 'Padam akaun';

  @override
  String get accountDeleteFailed =>
      'Tidak dapat memadam akaun anda. Sila cuba lagi.';

  @override
  String get exportReady => 'Eksport data kes anda telah dimuat turun.';

  @override
  String get exportFailed =>
      'Tidak dapat mengeksport data anda. Sila cuba lagi.';

  @override
  String get betaFull => 'Beta SewaBukti kini penuh. Sila cuba lagi kemudian.';
}
