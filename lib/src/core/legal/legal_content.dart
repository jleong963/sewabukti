import 'package:intl/intl.dart';

import 'package:sewabukti/src/core/constants/legal_config.dart';
import 'package:sewabukti/src/core/preferences/app_language.dart';

/// Configurable, localised legal / procedural content (§6.2, §6.3, §10.7,
/// NFR-SEC-13). Per §6.3 and §147 these limits, links, and notices are stored
/// as configurable content — here, colocated and localised — rather than
/// hard-coded across the UI, so they can be reviewed before each release.
///
/// NOTE (§18/§21): demand-letter templates, disclaimers, evidence-bundle
/// headings, and help content require separately, professionally reviewed
/// versions in all three languages before public beta. The text below is a
/// clear, honest beta draft pending that review; the English version prevails
/// (see [InfoDocument.reviewPending]).

/// A block within an info document: an optional [heading] followed by
/// [paragraphs] and/or [bullets].
class InfoSection {
  const InfoSection({
    this.heading,
    this.paragraphs = const <String>[],
    this.bullets = const <String>[],
  });

  final String? heading;
  final List<String> paragraphs;
  final List<String> bullets;
}

/// A rendered legal / informational document.
class InfoDocument {
  const InfoDocument({
    required this.title,
    required this.sections,
    this.intro,
    this.footer,
    this.reviewPending = true,
  });

  final String title;
  final String? intro;
  final List<InfoSection> sections;
  final String? footer;

  /// When true, the screen shows a "beta draft pending legal review" banner.
  final bool reviewPending;
}

/// Formatted small-claims ceiling label, e.g. `RM5,000` (§6.3, §10.7).
String smallClaimsCeilingLabel() =>
    'RM${NumberFormat('#,##0').format(LegalConfig.smallClaimsCeilingRm)}';

/// Privacy notice explaining the data categories stored and the service
/// providers used (NFR-SEC-13/14).
InfoDocument privacyPolicyDoc(AppLanguage lang) => switch (lang) {
  AppLanguage.ms => InfoDocument(
    title: 'Dasar Privasi',
    intro:
        'Dasar ini menerangkan data yang SewaBukti simpan, tempat ia disimpan, '
        'dan kawalan yang anda ada. SewaBukti hanya mengumpul maklumat yang '
        'perlu untuk menyediakan kes anda.',
    sections: const <InfoSection>[
      InfoSection(
        heading: 'Maklumat yang kami simpan',
        bullets: <String>[
          'Butiran akaun: nama dan e-mel daripada Akaun Google anda.',
          'Butiran kes yang anda masukkan: hartanah, pihak, jumlah, dan tarikh.',
          'Fail bukti yang anda muat naik dan kronologi yang anda bina.',
          'Rekod surat tuntutan yang anda jana atau hantar.',
          'Nombor kad pengenalan/pasport adalah pilihan, ditutup dalam antara '
              'muka, dan disulitkan apabila disimpan.',
        ],
      ),
      InfoSection(
        heading: 'Tempat data anda disimpan',
        paragraphs: <String>[
          'SewaBukti menggunakan penyedia pihak ketiga yang bereputasi:',
        ],
        bullets: <String>[
          'Google — hanya untuk log masuk (pengesahan identiti).',
          'Supabase Storage — simpanan peribadi untuk fail bukti anda.',
          'Turso — pangkalan data untuk butiran kes anda.',
          'Gmail (Google) — hanya untuk menghantar e-mel surat tuntutan.',
          'Hos statik (contohnya Vercel) — untuk menyajikan aplikasi.',
        ],
      ),
      InfoSection(
        heading: 'Cara kami melindunginya',
        bullets: <String>[
          'Fail bukti disimpan secara peribadi; hanya anda boleh mengaksesnya.',
          'Pelayan mengesahkan pemilikan bagi setiap operasi data.',
          'Semua trafik menggunakan HTTPS.',
          'Nombor pengenalan disulitkan semasa disimpan.',
          'Fail yang dimuat naik tidak sekali-kali dipaparkan sebagai halaman web boleh laku.',
        ],
      ),
      InfoSection(
        heading: 'Perkara yang kami tidak lakukan',
        bullets: <String>[
          'Kami tidak menjual atau mengiklankan data anda.',
          'Kami tidak berkongsi dokumen anda dengan tuan rumah atau ejen.',
          'Kami tidak memberikan nasihat guaman.',
        ],
      ),
      InfoSection(
        heading: 'Kawalan dan penyimpanan anda',
        bullets: <String>[
          'Anda boleh memadam fail bukti, kes, atau akaun anda pada bila-bila masa.',
          'Pemadaman akaun mengeluarkan objek simpanan dan rekod anda dalam '
              'tempoh ${LegalConfig.deletionPurgeDays} hari.',
          'Anda boleh memuat turun salinan data kes anda dari Tetapan.',
        ],
      ),
    ],
    footer: 'Soalan tentang privasi? Hubungi ${LegalConfig.supportEmail}.',
  ),
  AppLanguage.zhHans => InfoDocument(
    title: '隐私政策',
    intro:
        '本政策说明 SewaBukti 存储哪些数据、存储在何处，以及你拥有哪些控制权。'
        'SewaBukti 仅收集准备你的案件所必需的信息。',
    sections: const <InfoSection>[
      InfoSection(
        heading: '我们存储的信息',
        bullets: <String>[
          '账户信息：来自你 Google 账户的姓名和电子邮箱。',
          '你输入的案件详情：房产、当事人、金额和日期。',
          '你上传的证据文件以及你建立的时间线。',
          '你生成或发送的催讨函记录。',
          '身份证/护照号码为可选项，在界面中被遮蔽，并在存储时加密。',
        ],
      ),
      InfoSection(
        heading: '你的数据存储在何处',
        paragraphs: <String>['SewaBukti 使用信誉良好的第三方服务提供商：'],
        bullets: <String>[
          'Google —— 仅用于登录（身份验证）。',
          'Supabase Storage —— 用于存放你证据文件的私有存储。',
          'Turso —— 存放你案件详情的数据库。',
          'Gmail（Google）—— 仅用于发送催讨函电子邮件。',
          '静态托管（如 Vercel）—— 用于提供应用。',
        ],
      ),
      InfoSection(
        heading: '我们如何保护数据',
        bullets: <String>[
          '证据文件以私有方式存储，只有你本人可以访问。',
          '服务器对每一次数据操作都会验证归属权。',
          '所有流量均使用 HTTPS。',
          '身份证号码在存储时加密。',
          '上传的文件绝不会作为可执行网页呈现。',
        ],
      ),
      InfoSection(
        heading: '我们不会做的事',
        bullets: <String>[
          '我们不会出售你的数据或用其投放广告。',
          '我们不会与房东或中介分享你的文件。',
          '我们不提供法律意见。',
        ],
      ),
      InfoSection(
        heading: '你的控制权与数据保留',
        bullets: <String>[
          '你可以随时删除证据文件、案件或账户。',
          '删除账户会在 ${LegalConfig.deletionPurgeDays} 天内移除你的存储对象和记录。',
          '你可以在“设置”中下载你的案件数据副本。',
        ],
      ),
    ],
    footer: '有隐私方面的问题？请联系 ${LegalConfig.supportEmail}。',
  ),
  AppLanguage.en => InfoDocument(
    title: 'Privacy Policy',
    intro:
        'This policy explains what data SewaBukti stores, where it is stored, '
        'and the controls you have. SewaBukti collects only the information '
        'needed to prepare your case.',
    sections: const <InfoSection>[
      InfoSection(
        heading: 'Information we store',
        bullets: <String>[
          'Account details: your name and email from your Google Account.',
          'Case details you enter: property, parties, amounts, and dates.',
          'Evidence files you upload and the chronology you build.',
          'Records of demand letters you generate or send.',
          'Identity-card/passport numbers are optional, masked in the '
              'interface, and encrypted when stored.',
        ],
      ),
      InfoSection(
        heading: 'Where your data is stored',
        paragraphs: <String>['SewaBukti uses reputable third-party providers:'],
        bullets: <String>[
          'Google — for sign-in only (identity verification).',
          'Supabase Storage — private storage for your evidence files.',
          'Turso — the database for your case details.',
          'Gmail (Google) — only to send demand-letter emails.',
          'Static hosting (for example Vercel) — to serve the application.',
        ],
      ),
      InfoSection(
        heading: 'How we protect it',
        bullets: <String>[
          'Evidence files are stored privately; only you can access them.',
          'The server verifies ownership for every data operation.',
          'All traffic uses HTTPS.',
          'Identity numbers are encrypted at rest.',
          'Uploaded files are never rendered as executable web pages.',
        ],
      ),
      InfoSection(
        heading: 'What we do not do',
        bullets: <String>[
          'We do not sell your data or use it for advertising.',
          'We do not share your documents with landlords or agents.',
          'We do not provide legal advice.',
        ],
      ),
      InfoSection(
        heading: 'Your controls and retention',
        bullets: <String>[
          'You can delete evidence files, your case, or your account at any time.',
          'Account deletion removes your storage objects and records within '
              '${LegalConfig.deletionPurgeDays} days.',
          'You can download a copy of your case data from Settings.',
        ],
      ),
    ],
    footer: 'Questions about privacy? Contact ${LegalConfig.supportEmail}.',
  ),
};

/// Terms of use, including the required disclaimers (§6.2) and product
/// positioning (§6.1).
InfoDocument termsOfUseDoc(AppLanguage lang) => switch (lang) {
  AppLanguage.ms => InfoDocument(
    title: 'Syarat Penggunaan',
    intro:
        'Dengan menggunakan SewaBukti, anda bersetuju dengan syarat ini. Sila '
        'baca dengan teliti.',
    sections: const <InfoSection>[
      InfoSection(
        heading: 'Apakah SewaBukti',
        paragraphs: <String>[
          'SewaBukti ialah alat penyusunan bukti dan penyediaan dokumen serta '
              'sumber maklumat prosedur umum. Ia bukan pengganti nasihat '
              'daripada peguam Malaysia atau pendaftaran mahkamah.',
        ],
      ),
      InfoSection(
        heading: 'Bukan nasihat guaman',
        paragraphs: <String>[
          'SewaBukti bukan firma guaman dan tidak memberikan nasihat atau '
              'perwakilan guaman. Maklumat yang anda masukkan tidak disahkan '
              'secara bebas oleh kami.',
        ],
      ),
      InfoSection(
        heading: 'Disclaimer penting',
        bullets: <String>[
          'SewaBukti tidak memberikan nasihat atau perwakilan guaman.',
          'Maklumat yang dimasukkan pengguna tidak disahkan secara bebas.',
          'Anda mesti mengesahkan ketepatan setiap fakta, tarikh, jumlah, dan nama pihak.',
          'Surat dan himpunan bukti yang dijana tidak menjamin pembayaran balik atau penerimaan mahkamah.',
          'Peraturan mahkamah, borang, yuran, had, dan prosedur mungkin berubah.',
          'Sahkan defendan yang betul dan tempat pemfailan dengan pendaftaran '
              'mahkamah atau peguam jika anda tidak pasti.',
        ],
      ),
      InfoSection(
        heading: 'Tanggungjawab anda',
        bullets: <String>[
          'Anda bertanggungjawab atas ketepatan semua maklumat kes anda.',
          'Anda memfailkan dan menyampaikan dokumen mahkamah sendiri.',
          'Gunakan aplikasi hanya untuk pertikaian deposit anda yang sebenar dan sah.',
        ],
      ),
      InfoSection(
        heading: 'Beta dan ketersediaan',
        paragraphs: <String>[
          'SewaBukti disediakan sebagai beta percuma bukan komersial "seadanya", '
              'tanpa jaminan. Perkhidmatan, had, dan ketersediaan mungkin '
              'berubah atau dijeda. Setakat yang dibenarkan undang-undang, '
              'SewaBukti tidak bertanggungan atas kerugian akibat penggunaan alat ini.',
        ],
      ),
    ],
    footer: 'Soalan? Hubungi ${LegalConfig.supportEmail}.',
  ),
  AppLanguage.zhHans => InfoDocument(
    title: '使用条款',
    intro: '使用 SewaBukti 即表示你同意本条款。请仔细阅读。',
    sections: const <InfoSection>[
      InfoSection(
        heading: 'SewaBukti 是什么',
        paragraphs: <String>[
          'SewaBukti 是一款证据整理与文书准备工具，也是一般程序信息的来源。'
              '它不能替代马来西亚律师或法院登记处的意见。',
        ],
      ),
      InfoSection(
        heading: '并非法律意见',
        paragraphs: <String>[
          'SewaBukti 并非律师事务所，不提供法律意见或代理。'
              '你输入的信息不会由我们独立核实。',
        ],
      ),
      InfoSection(
        heading: '重要免责声明',
        bullets: <String>[
          'SewaBukti 不提供法律意见或代理。',
          '用户输入的信息不会经过独立核实。',
          '你必须确认每一项事实、日期、金额和当事人姓名的准确性。',
          '生成的信函和证据册不保证退款或获法院受理。',
          '法院规则、表格、费用、限额及程序可能会变动。',
          '如有不确定，请向法院登记处或律师确认正确的被告与提交法院。',
        ],
      ),
      InfoSection(
        heading: '你的责任',
        bullets: <String>[
          '你对案件所有信息的准确性负责。',
          '你需自行提交并送达法院文件。',
          '仅将本应用用于你真实、合法的押金纠纷。',
        ],
      ),
      InfoSection(
        heading: '测试版与可用性',
        paragraphs: <String>[
          'SewaBukti 以“按现状”方式作为免费、非商业测试版提供，不作任何保证。'
              '服务、限额和可用性可能变动或暂停。在法律允许的范围内，'
              'SewaBukti 不对因使用本工具而产生的损失承担责任。',
        ],
      ),
    ],
    footer: '有疑问？请联系 ${LegalConfig.supportEmail}。',
  ),
  AppLanguage.en => InfoDocument(
    title: 'Terms of Use',
    intro:
        'By using SewaBukti you agree to these terms. Please read them '
        'carefully.',
    sections: const <InfoSection>[
      InfoSection(
        heading: 'What SewaBukti is',
        paragraphs: <String>[
          'SewaBukti is an evidence-organisation and document-preparation tool '
              'and a source of general procedural information. It is not a '
              'substitute for advice from a Malaysian lawyer or court registry.',
        ],
      ),
      InfoSection(
        heading: 'Not legal advice',
        paragraphs: <String>[
          'SewaBukti is not a law firm and does not provide legal advice or '
              'representation. Information you enter is not independently '
              'verified by us.',
        ],
      ),
      InfoSection(
        heading: 'Important disclaimers',
        bullets: <String>[
          'SewaBukti does not provide legal advice or representation.',
          'Information entered by the user is not independently verified.',
          'You must confirm the accuracy of every fact, date, amount, and party name.',
          'Generated letters and evidence bundles do not guarantee repayment or court acceptance.',
          'Court rules, forms, fees, limits, and procedures may change.',
          'Confirm the correct defendant and filing venue with the court '
              'registry or a lawyer if you are uncertain.',
        ],
      ),
      InfoSection(
        heading: 'Your responsibility',
        bullets: <String>[
          'You are responsible for the accuracy of all your case information.',
          'You file and serve the court documents yourself.',
          'Use the app only for your own genuine and lawful deposit dispute.',
        ],
      ),
      InfoSection(
        heading: 'Beta and availability',
        paragraphs: <String>[
          'SewaBukti is provided as a free, non-commercial beta "as is", '
              'without warranty. The service, its limits, and availability may '
              'change or pause. To the extent permitted by law, SewaBukti is '
              'not liable for losses arising from use of this tool.',
        ],
      ),
    ],
    footer: 'Questions? Contact ${LegalConfig.supportEmail}.',
  ),
};

/// In-app help / how-it-works content, including the evidence-hash caveat
/// (FR-EVD-09).
InfoDocument helpDoc(AppLanguage lang) => switch (lang) {
  AppLanguage.ms => InfoDocument(
    reviewPending: false,
    title: 'Bantuan',
    intro:
        'SewaBukti membantu penyewa Malaysia menyusun bukti untuk menuntut '
        'semula deposit sewa.',
    sections: const <InfoSection>[
      InfoSection(
        heading: 'Cara ia berfungsi',
        bullets: <String>[
          'Susun butiran kes anda: hartanah, pihak, dan tarikh.',
          'Kira jumlah deposit yang terhutang kepada anda.',
          'Muat naik bukti dan bina kronologi peristiwa.',
          'Jana surat tuntutan yang neutral dan profesional.',
          'Muat turun himpunan bukti berindeks untuk menyokong pemfailan.',
        ],
      ),
      InfoSection(
        heading: 'Tentang bukti anda',
        bullets: <String>[
          'Fail disimpan secara peribadi; format yang disokong ialah PDF, JPG, PNG, WebP, dan TXT.',
          'Had saiz setiap fail dan setiap kes dikuatkuasakan untuk kekal dalam had percuma.',
          'Cincangan (hash) fail mengesan perubahan kemudian pada fail tetapi '
              'tidak membuktikan bila fail asal dicipta.',
        ],
      ),
      InfoSection(
        heading: 'Bahasa dan paparan',
        paragraphs: <String>[
          'Tukar bahasa (Inggeris, Bahasa Melayu, 简体中文) dan mod paparan '
              '(terang/gelap) dalam Tetapan. Pilihan anda disimpan.',
        ],
      ),
      InfoSection(
        heading: 'Memadam data anda',
        paragraphs: <String>[
          'Anda boleh memadam fail bukti individu, keseluruhan kes, atau akaun '
              'anda dari Tetapan.',
        ],
      ),
    ],
    footer:
        'Perlukan bantuan? Hubungi ${LegalConfig.supportEmail}. Ambil perhatian '
        'bahawa kami tidak boleh memberikan nasihat guaman.',
  ),
  AppLanguage.zhHans => InfoDocument(
    reviewPending: false,
    title: '帮助',
    intro: 'SewaBukti 帮助马来西亚租户整理证据，以追讨租赁押金。',
    sections: const <InfoSection>[
      InfoSection(
        heading: '使用方法',
        bullets: <String>[
          '整理你的案件详情：房产、当事人和日期。',
          '计算应退还给你的押金金额。',
          '上传证据并建立事件时间线。',
          '生成中立、专业的催讨函。',
          '下载带索引的证据册以支持提交申请。',
        ],
      ),
      InfoSection(
        heading: '关于你的证据',
        bullets: <String>[
          '文件以私有方式存储；支持的格式为 PDF、JPG、PNG、WebP 和 TXT。',
          '为保持在免费额度内，系统会限制每个文件及每个案件的大小。',
          '文件哈希值可检测文件之后是否被更改，但不能证明原始文件的创建时间。',
        ],
      ),
      InfoSection(
        heading: '语言与显示',
        paragraphs: <String>[
          '在“设置”中切换语言（English、Bahasa Melayu、简体中文）和显示模式'
              '（浅色/深色）。你的选择会被保存。',
        ],
      ),
      InfoSection(
        heading: '删除你的数据',
        paragraphs: <String>['你可以在“设置”中删除单个证据文件、整个案件或你的账户。'],
      ),
    ],
    footer: '需要帮助？请联系 ${LegalConfig.supportEmail}。请注意，我们无法提供法律意见。',
  ),
  AppLanguage.en => InfoDocument(
    reviewPending: false,
    title: 'Help',
    intro:
        'SewaBukti helps Malaysian tenants organise evidence to reclaim a '
        'rental deposit.',
    sections: const <InfoSection>[
      InfoSection(
        heading: 'How it works',
        bullets: <String>[
          'Organise your case details: property, parties, and dates.',
          'Calculate the deposit amount owed to you.',
          'Upload evidence and build a chronology of events.',
          'Generate a neutral, professional demand letter.',
          'Download an indexed evidence bundle to support a filing.',
        ],
      ),
      InfoSection(
        heading: 'About your evidence',
        bullets: <String>[
          'Files are stored privately; supported formats are PDF, JPG, PNG, WebP, and TXT.',
          'Per-file and per-case size limits are enforced to stay within free-tier limits.',
          'A file hash detects later changes to a file but does not prove when '
              'the original file was created.',
        ],
      ),
      InfoSection(
        heading: 'Language and display',
        paragraphs: <String>[
          'Change the language (English, Bahasa Melayu, 简体中文) and the '
              'display mode (light/dark) in Settings. Your choices are saved.',
        ],
      ),
      InfoSection(
        heading: 'Deleting your data',
        paragraphs: <String>[
          'You can delete individual evidence files, your whole case, or your '
              'account from Settings.',
        ],
      ),
    ],
    footer:
        'Need help? Contact ${LegalConfig.supportEmail}. Please note that we '
        'cannot give legal advice.',
  ),
};

/// Claim-route guidance (§10.7). Uses the configurable limit and form name from
/// [LegalConfig]. The screen shows the claimed amount separately and links to
/// official judiciary guidance; it must not claim to submit or file anything.
InfoDocument claimRouteDoc(AppLanguage lang) => switch (lang) {
  AppLanguage.ms => InfoDocument(
    title: 'Laluan tuntutan',
    intro:
        'Pertikaian deposit antara penyewa dan tuan rumah ialah pertikaian '
        'sivil. Maklumat di bawah adalah panduan am sahaja.',
    sections: <InfoSection>[
      InfoSection(
        bullets: <String>[
          'Tuntutan oleh individu yang tidak melebihi ${smallClaimsCeilingLabel()} mungkin '
              'layak untuk Mahkamah Tuntutan Kecil.',
          'Tuntutan bernilai lebih tinggi mungkin memerlukan prosiding sivil '
              'biasa di mahkamah yang sesuai.',
          'Writ tuntutan kecil semasa ialah ${LegalConfig.smallClaimFormName} '
              '(tertakluk kepada pengesahan rasmi).',
          'Anda mesti memfailkan dan menyampaikan dokumen mahkamah sendiri — '
              'SewaBukti tidak menghantar, memfailkan, atau mendaftarkan apa-apa bagi pihak anda.',
          'Bukti dokumen mungkin diperlukan semasa perbicaraan — bawa himpunan bukti anda.',
          'Jika defendan yang betul, bidang kuasa, alamat penyampaian, atau '
              'nilai tuntutan tidak pasti, rujuk pendaftaran mahkamah atau peguam.',
        ],
      ),
    ],
    footer:
        'Peraturan, borang, yuran, dan had mahkamah mungkin berubah. Sahkan '
        'keperluan semasa dengan pendaftaran mahkamah yang berkaitan.',
  ),
  AppLanguage.zhHans => InfoDocument(
    title: '索偿途径',
    intro: '租户与房东之间的押金纠纷属于民事纠纷。以下信息仅为一般指引。',
    sections: <InfoSection>[
      InfoSection(
        bullets: <String>[
          '个人提出的、不超过 ${smallClaimsCeilingLabel()} 的索偿可能符合小额索偿法庭的受理条件。',
          '金额更高的索偿可能需要在适当的法院进行普通民事诉讼。',
          '当前的小额索偿令状为 ${LegalConfig.smallClaimFormName}（以官方确认为准）。',
          '你必须自行提交并送达法院文件 —— SewaBukti 不会为你呈交、提交或立案。',
          '开庭时可能需要提供书面证据 —— 请带上你的证据册。',
          '如对正确被告、管辖权、送达地址或索偿金额不确定，请咨询法院登记处或律师。',
        ],
      ),
    ],
    footer: '法院规则、表格、费用及限额可能变动。请向相关法院登记处确认当前要求。',
  ),
  AppLanguage.en => InfoDocument(
    title: 'Claim route',
    intro:
        'A deposit dispute between a tenant and a landlord is a civil dispute. '
        'The information below is general guidance only.',
    sections: <InfoSection>[
      InfoSection(
        bullets: <String>[
          'A claim by an individual not exceeding ${smallClaimsCeilingLabel()} may be eligible '
              'for the Small Claims Court.',
          'Higher-value claims may require ordinary civil proceedings in the '
              'appropriate court.',
          'The current small-claim writ is ${LegalConfig.smallClaimFormName} '
              '(subject to official confirmation).',
          'You must file and serve the court documents yourself — SewaBukti '
              'does not submit, lodge, or file anything for you.',
          'Documentary evidence may be required at the hearing — bring your evidence bundle.',
          'If the correct defendant, jurisdiction, service address, or claim '
              'value is uncertain, consult the court registry or a lawyer.',
        ],
      ),
    ],
    footer:
        'Court rules, forms, fees, and limits may change. Confirm the current '
        'requirements with the relevant court registry.',
  ),
};
