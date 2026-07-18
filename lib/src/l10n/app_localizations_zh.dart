// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'SewaBukti';

  @override
  String get appTagline => '整理证据，追讨押金。';

  @override
  String get landingIntro =>
      'SewaBukti 帮助马来西亚租户在房东、代理或管理公司拖延、扣减或拒绝退还租赁押金时整理证据。它是一个证据整理与文书准备工具，并非律师事务所。';

  @override
  String get howItWorksTitle => '使用流程';

  @override
  String get stepCompileTitle => '整理';

  @override
  String get stepCompileBody => '将租约、收据、照片和聊天记录集中到一个私密、有条理的案件中。';

  @override
  String get stepDemandTitle => '追讨';

  @override
  String get stepDemandBody => '计算尚欠金额，并生成一封中立、专业且完全由你掌控的催讨函。';

  @override
  String get stepPrepareTitle => '准备';

  @override
  String get stepPrepareBody => '建立事实时间线，并导出带索引的证据册，以支持民事或小额索偿申请。';

  @override
  String get privacySummaryTitle => '你的证据保持私密';

  @override
  String get privacySummaryBody => '上传的文件存储在只有你才能访问的私密存储中。SewaBukti 绝不会公开你的文件。';

  @override
  String get disclaimerSummaryTitle => '请注意';

  @override
  String get disclaimerSummaryBody =>
      'SewaBukti 不提供法律意见或代理，也不保证获得退款或被法院采纳。你需确认每一项事实、日期、金额和当事方名称的准确性。法院规则、表格、费用和限额可能会变动。';

  @override
  String get continueWithGoogle => '通过 Google 继续';

  @override
  String get googleSignInHint =>
      '使用你现有的 Google 账号登录 SewaBukti。你不会创建新的 Google 账号。';

  @override
  String get previewBuildNotice => '预览版本——登录为演示模拟。';

  @override
  String get previewSignIn => '继续（预览）';

  @override
  String get signInFailed => '登录失败，请重试。';

  @override
  String get inactiveSignedOut => '由于长时间未操作，你已被登出。请重新登录。';

  @override
  String get notLegalServiceNotice => 'SewaBukti 并非律师事务所、法院或政府服务。';

  @override
  String get languageLabel => '语言';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageMalay => 'Bahasa Melayu';

  @override
  String get languageChinese => '简体中文';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfUse => '使用条款';

  @override
  String get help => '帮助';

  @override
  String get signOut => '退出登录';

  @override
  String get navDashboard => '仪表板';

  @override
  String get navSettings => '设置';

  @override
  String dashboardWelcome(String name) {
    return '欢迎，$name';
  }

  @override
  String get dashboardNoCaseTitle => '你还没有进行中的案件';

  @override
  String get dashboardNoCaseBody => '开始一个押金追讨案件，整理证据、计算应得金额并准备催讨函。';

  @override
  String get dashboardStartCase => '开始你的案件';

  @override
  String get dashboardContinueCase => '继续你的案件';

  @override
  String get dashboardActiveCaseTitle => '你的押金追讨案件';

  @override
  String dashboardCompletion(int percent) {
    return '已完成 $percent%';
  }

  @override
  String get dashboardOutstandingTasks => '待办事项';

  @override
  String get dashboardDemandLetter => '催讨函';

  @override
  String get dashboardEvidenceBundle => '证据册';

  @override
  String get dashboardStorageUsed => '已用存储';

  @override
  String dashboardStorageValue(String usedMb, String totalMb) {
    return '$usedMb MB / $totalMb MB';
  }

  @override
  String get statusNotStarted => '未开始';

  @override
  String get statusInProgress => '进行中';

  @override
  String get statusReady => '就绪';

  @override
  String get statusSent => '已发送';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsAccountSection => '账户';

  @override
  String get settingsNameLabel => '姓名';

  @override
  String get settingsEmailLabel => 'Google 电子邮箱';

  @override
  String get settingsPreferencesSection => '偏好设置';

  @override
  String get settingsLanguageLabel => '语言';

  @override
  String get settingsDisplayModeLabel => '显示模式';

  @override
  String get displayLight => '浅色';

  @override
  String get displayDark => '深色';

  @override
  String get settingsStorageSection => '存储';

  @override
  String get settingsDataSection => '你的数据';

  @override
  String get settingsExportData => '下载你的案件数据副本';

  @override
  String get settingsDeleteCase => '删除案件';

  @override
  String get settingsDeleteAccount => '删除账户及应用数据';

  @override
  String get settingsLegalSection => '法律与隐私';

  @override
  String get comingSoon => '即将推出';

  @override
  String get caseWizardTitle => '你的案件';

  @override
  String wizardStepOf(int current, int total) {
    return '第 $current 步，共 $total 步';
  }

  @override
  String get wizardNext => '下一步';

  @override
  String get wizardBack => '上一步';

  @override
  String get wizardSaveExit => '保存并退出';

  @override
  String get wizardFinish => '完成';

  @override
  String get wizardSavedToast => '进度已保存';

  @override
  String get fieldRequired => '必填';

  @override
  String get invalidEmail => '请输入有效的电子邮箱';

  @override
  String get invalidAmount => '请输入有效的金额';

  @override
  String get optionalLabel => '可选';

  @override
  String get selectDate => '选择日期';

  @override
  String get notSet => '未设置';

  @override
  String get showLabel => '显示';

  @override
  String get hideLabel => '隐藏';

  @override
  String get stepTenancyTitle => '租赁详情';

  @override
  String get stepClaimantTitle => '你的资料';

  @override
  String get stepOtherPartyTitle => '对方';

  @override
  String get stepDepositTitle => '押金详情';

  @override
  String get stepReviewTitle => '核对';

  @override
  String get fieldAddressLine1 => '地址第一行';

  @override
  String get fieldAddressLine2 => '地址第二行';

  @override
  String get fieldCity => '城市 / 城镇';

  @override
  String get fieldPostcode => '邮编';

  @override
  String get fieldState => '州属';

  @override
  String get fieldTenancyStart => '租赁开始日期';

  @override
  String get fieldTenancyEnd => '租赁结束日期';

  @override
  String get fieldVacatedDate => '你搬离的日期';

  @override
  String get fieldKeysReturned => '归还钥匙 / 门禁卡的日期';

  @override
  String get fieldMonthlyRent => '每月租金';

  @override
  String get fieldRefundDeadline => '合同中注明的退款期限';

  @override
  String get fieldFullName => '全名';

  @override
  String get fieldIdNumber => '身份证 / 护照号码';

  @override
  String get fieldIdNumberHint => '可选。默认遮蔽并安全存储；仅用于你的文件。';

  @override
  String get fieldEmail => '电子邮箱';

  @override
  String get fieldEmailFromGoogleHint => '来自你的 Google 账号';

  @override
  String get fieldPhone => '电话号码';

  @override
  String get fieldCorrespondenceAddress => '通讯地址';

  @override
  String get otherPartyDisclaimer =>
      '这些问题有助于整理信息，并不确定法律上正确的被告——如不确定，请向法院注册处或律师核实。';

  @override
  String get fieldPartyType => '你要向谁追讨？';

  @override
  String get partyTypeLandlord => '房东';

  @override
  String get partyTypeAgent => '代理';

  @override
  String get partyTypeManagement => '管理公司';

  @override
  String get partyTypeUncertain => '不确定';

  @override
  String get fieldPartyIsCompany => '该方为公司';

  @override
  String get fieldPartyName => '名称（与租约上一致）';

  @override
  String get fieldPartyCompanyNo => '公司注册号';

  @override
  String get fieldPartyEmail => '电子邮箱';

  @override
  String get fieldPartyPhone => '电话号码';

  @override
  String get fieldPartyAddress => '送达 / 通讯地址';

  @override
  String get fieldDepositReceivedBy => '谁收取了押金？';

  @override
  String get fieldDepositPromisedBy => '谁承诺退还押金？';

  @override
  String get fieldSecurityDeposit => '已付的租赁押金';

  @override
  String get fieldUtilityDeposit => '已付的水电押金';

  @override
  String get fieldAccessDeposit => '已付的门禁卡 / 钥匙押金';

  @override
  String get fieldOtherDeposit => '已付的其他押金';

  @override
  String get labelTotalDeposit => '已付押金总额';

  @override
  String get fieldAmountRefunded => '已退还的金额';

  @override
  String get fieldDeductionsAccepted => '你接受的扣款';

  @override
  String get fieldDeductionsDisputed => '你有异议的扣款';

  @override
  String get labelTotalClaimed => '当前追讨金额';

  @override
  String get reviewConfirmHint => '请核对每一项事实、日期、金额和当事方名称。你需对其准确性负责。';

  @override
  String get reviewNoData => '尚未填写。';

  @override
  String get dashboardAmountClaimed => '追讨金额';

  @override
  String get dashboardManageEvidence => '证据';

  @override
  String get evidenceTitle => '证据';

  @override
  String get evidenceSupportedHint => 'PDF、JPG、PNG、WebP 或 TXT。';

  @override
  String evidenceFileCount(int count, int max) {
    return '$count / $max 个文件';
  }

  @override
  String get evidenceAdd => '添加文件';

  @override
  String get evidenceEmptyCategory => '暂无';

  @override
  String get evidencePreview => '预览';

  @override
  String get evidenceDownload => '下载';

  @override
  String get evidenceDelete => '删除';

  @override
  String evidenceDeleteConfirm(String name) {
    return '移除“$name”？此操作无法撤销。';
  }

  @override
  String get commonCancel => '取消';

  @override
  String get commonRemove => '移除';

  @override
  String get evidenceAddDialogTitle => '添加证据';

  @override
  String get evidenceItemTitle => '标题';

  @override
  String get evidenceItemDescription => '描述';

  @override
  String get evidenceItemDate => '文件 / 事件日期';

  @override
  String get evidenceUploaded => '已添加文件';

  @override
  String get evidencePreviewUnavailable =>
      '此处暂不可预览——配置后端后文件才会存储；在本次会话中重新添加即可预览。';

  @override
  String get evidenceHashNote => '文件哈希可检测文件之后的更改，但无法证明原始文件的创建时间。';

  @override
  String get evidenceNoCaseTitle => '请先开始案件';

  @override
  String get evidenceNoCaseBody => '在添加证据之前，请先创建你的押金追讨案件。';

  @override
  String get errUnsupportedType => '不支持此文件类型。';

  @override
  String get errFileTooLarge => '此文件超过大小限制。';

  @override
  String get errFileCountExceeded => '此案件的文件数量已达上限。';

  @override
  String get errStorageQuota => '此案件的存储空间已满。';

  @override
  String get errPickFailed => '无法读取所选文件。';

  @override
  String get evCatTenancyAgreement => '租约';

  @override
  String get evCatStampedAgreement => '已盖印花税的租约';

  @override
  String get evCatDepositReceipt => '押金付款 / 银行转账凭证';

  @override
  String get evCatMoveInPhotos => '入住时的状况照片';

  @override
  String get evCatMoveOutPhotos => '退租时的状况照片';

  @override
  String get evCatHandoverKeys => '钥匙 / 门禁卡交接';

  @override
  String get evCatInspectionReport => '最终验收 / 交接报告';

  @override
  String get evCatUtilityBills => '最终水电账单及读数';

  @override
  String get evCatMessages => 'WhatsApp / 消息截图';

  @override
  String get evCatEmails => '电子邮件';

  @override
  String get evCatDeductionStatement => '扣款清单';

  @override
  String get evCatRepairQuote => '维修 / 清洁报价';

  @override
  String get evCatRepairReceipt => '维修 / 清洁收据';

  @override
  String get evCatPriorRequests => '以往的退款请求';

  @override
  String get evCatDemandDelivery => '催讨函送达凭证';

  @override
  String get evCatOther => '其他佐证材料';

  @override
  String get dashboardChronology => '时间线';

  @override
  String get chronologyTitle => '时间线';

  @override
  String get chronologyIntro => '按顺序添加关键事件。只填写你能支持的事实——SewaBukti 绝不会臆造或推断。';

  @override
  String get chronologyEmpty => '暂无事件。添加第一个吧。';

  @override
  String get chronologyAdd => '添加事件';

  @override
  String get chronologyEditEvent => '编辑事件';

  @override
  String get chronologySortByDate => '按日期排序';

  @override
  String get chronologyDeleteConfirm => '移除此事件？';

  @override
  String get chronologyNoCaseBody => '在建立时间线之前，请先创建你的案件。';

  @override
  String get eventDateLabel => '日期';

  @override
  String get eventTimeLabel => '时间（可选）';

  @override
  String get eventTitleLabel => '事件';

  @override
  String get eventDescriptionLabel => '发生了什么';

  @override
  String get eventLinkedEvidence => '关联证据';

  @override
  String get eventSuggestionsLabel => '常见事件';

  @override
  String eventLinkedCount(int count) {
    return '已关联 $count 项';
  }

  @override
  String get evtTenancyCommenced => '租期开始';

  @override
  String get evtDepositPaid => '支付押金';

  @override
  String get evtNoticeGiven => '发出终止通知';

  @override
  String get evtVacated => '搬离房产';

  @override
  String get evtKeysReturned => '归还钥匙';

  @override
  String get evtInspection => '完成验收';

  @override
  String get evtRefundRequested => '请求退款';

  @override
  String get evtRefundPromised => '承诺退款';

  @override
  String get evtPartialRefund => '收到部分退款';

  @override
  String get evtDeductionDisputed => '对扣款提出异议';

  @override
  String get evtDemandSent => '已寄出催讨函';

  @override
  String get evtDeadlineExpired => '付款期限已过';

  @override
  String get demandLetterTitle => '催讨函';

  @override
  String get demandLetterIntro => '根据你的案件详情生成一封中立的催讨函。在下载或发送前，请核对全部内容并确认无误。';

  @override
  String get demandLanguageLabel => '信函语言';

  @override
  String get demandRecipientEmailLabel => '收件人电子邮箱';

  @override
  String get demandSignatureLabel => '你的姓名（作为签名）';

  @override
  String get demandDeadlineLabel => '付款期限';

  @override
  String get demandPaymentInstructionsLabel => '付款说明（可选）';

  @override
  String get demandNotesLabel => '补充说明（可选）';

  @override
  String get demandFactsHeading => '信中使用的详情';

  @override
  String get demandConfirmCheckbox => '我确认以上事实、金额、日期和名称均准确无误。';

  @override
  String get demandConfirmRequired => '请先确认详情准确无误。';

  @override
  String get demandMissingFields => '请填写收件人电子邮箱、你的姓名和付款期限。';

  @override
  String get demandDownloadPdf => '下载 / 打印 PDF';

  @override
  String get demandSend => '把副本发送到我的邮箱';

  @override
  String get demandSent => '副本已发送至你的邮箱。';

  @override
  String get demandCopyToLabel => '将副本发送至（你的邮箱）';

  @override
  String get demandDeliveryNote =>
      'SewaBukti 会将信函及其 PDF 通过电子邮件发送给你。之后由你自行转发或送达给对方 —— SewaBukti 不会代你送达。';

  @override
  String get demandPaymentInstructionsHint => '可选。仅在你愿意分享银行信息时才填写。';

  @override
  String get demandSendFailed => '发送失败，请重试。';

  @override
  String get demandBackendRequired => '发送电子邮件需要配置后端。你仍可下载 PDF。';

  @override
  String get demandNoCaseBody => '在生成催讨函之前，请先创建你的案件。';

  @override
  String get letterSubject => '关于退还租赁押金的催讨';

  @override
  String letterGreeting(String recipient) {
    return '尊敬的 $recipient：';
  }

  @override
  String get letterGreetingFallback => '敬启者：';

  @override
  String letterOpening(String property) {
    return '本人就位于 $property 之房产的租赁押金事宜致函。';
  }

  @override
  String letterTenancyPeriod(String start, String end) {
    return '租期自 $start 至 $end。';
  }

  @override
  String get letterDepositHeading => '押金摘要';

  @override
  String letterOutstandingSentence(String amount) {
    return '尚欠本人的押金金额为 $amount。';
  }

  @override
  String get letterFactsHeading => '事件摘要';

  @override
  String letterDeadlineSentence(String deadline) {
    return '本人要求于 $deadline 前全额支付该款项。';
  }

  @override
  String get letterPaymentHeading => '付款说明';

  @override
  String get letterDocsHeading => '佐证文件';

  @override
  String get letterFurtherAction => '若未能于上述日期前收到付款，本人可能考虑采取进一步的民事行动以追讨欠款。';

  @override
  String get letterClosing => '此致';

  @override
  String get letterFooterDisclaimer =>
      '本函由发件人使用 SewaBukti（一款证据整理与文书准备工具）编写。其内容属一般性质，并非法律意见，亦非由律师出具。';

  @override
  String get bundleTitle => '证据册';

  @override
  String get bundleIntro => '将你的案件详情、时间线和所选证据整合为一份可下载的带索引 PDF。不会上传任何内容。';

  @override
  String get bundleNoCaseBody => '在生成证据册之前，请先创建你的案件。';

  @override
  String get bundleIncludedHeading => '证据册包含的内容';

  @override
  String get bundleIncludeCaseSummary => '案件摘要、当事人、房产及押金计算';

  @override
  String get bundleIncludeChronology => '事件时间线';

  @override
  String get bundleEvidenceHeading => '要包含的证据';

  @override
  String get bundleEvidenceHint => '默认选中所有文件。取消勾选任何你不想放入证据册的敏感内容。';

  @override
  String get bundleNoEvidence => '尚未上传证据。证据册将仅包含你的案件详情。';

  @override
  String get bundleSelectAll => '全选';

  @override
  String get bundleSelectNone => '全部清除';

  @override
  String get bundleEmbeddedHint => '图片 — 已嵌入';

  @override
  String get bundleAttachmentHint => '单独附件';

  @override
  String get bundlePreparedByLabel => '编制人（姓名）';

  @override
  String get bundleChecklistHeading => '生成前的最终检查';

  @override
  String bundleChecklistEvidence(int included, int total) {
    return '已包含 $total 项证据中的 $included 项';
  }

  @override
  String bundleChecklistEmbedded(int embedded, int attachments) {
    return '$embedded 项作为图片嵌入，$attachments 项作为单独附件';
  }

  @override
  String bundleChecklistEvents(int count) {
    return '$count 个时间线事件';
  }

  @override
  String get bundleConfirmCheckbox => '我确认此信息准确无误，并且我已选择要包含的证据。';

  @override
  String get bundleConfirmRequired => '请先确认，然后再生成证据册。';

  @override
  String get bundleGenerate => '生成证据册 PDF';

  @override
  String get bundleGenerating => '正在准备你的证据册…';

  @override
  String get bundleGenerateFailed => '无法生成证据册，请重试。';

  @override
  String get bundleCoverPreparedBy => '编制人';

  @override
  String get bundleGeneratedOn => '生成日期';

  @override
  String get bundleDisclaimerHeading => '免责声明与确认';

  @override
  String get bundleDisclaimerP1 =>
      'SewaBukti 是一款证据整理与文书准备工具。它并非律师事务所，不提供法律意见或代理，也不保证退款或获法院受理。';

  @override
  String get bundleDisclaimerP2 =>
      '封面所载人士编制了本证据册，并确认其中所含的事实、日期、金额及当事人姓名在其所知范围内均属准确。';

  @override
  String get bundleDisclaimerP3 => '法院规则、表格、费用及限额可能会有变动。请向相关法院登记处确认当前要求。';

  @override
  String get bundleProvenanceNote =>
      '标题、合计及附录编号（SB-A##）由 SewaBukti 生成。所有其他数值均由用户输入。';

  @override
  String get bundleCaseSummaryHeading => '案件摘要';

  @override
  String get bundleTenancyPeriodLabel => '租期';

  @override
  String get bundleEvidenceCountLabel => '包含的证据项目';

  @override
  String get bundleEventCountLabel => '时间线事件';

  @override
  String get bundlePartiesHeading => '当事人与房产';

  @override
  String get bundlePropertyLabel => '地址';

  @override
  String get bundlePropertyHeading => '房产';

  @override
  String get bundleClaimantHeading => '索偿人';

  @override
  String get bundleOtherPartyHeading => '对方当事人';

  @override
  String get bundleDepositHeading => '押金计算';

  @override
  String get bundleChronologyHeading => '事件时间线';

  @override
  String get bundleChronologyEmpty => '未添加任何时间线事件。';

  @override
  String get bundleChronologyRefsLabel => '关联证据';

  @override
  String get bundleIndexHeading => '证据索引';

  @override
  String bundleIndexIntro(int count) {
    return '本证据册共包含 $count 项。';
  }

  @override
  String get bundleColAppendix => '附录';

  @override
  String get bundleColItem => '项目';

  @override
  String get bundleColCategory => '类别';

  @override
  String get bundleColDocDate => '文件日期';

  @override
  String get bundleColUploaded => '上传日期';

  @override
  String get bundleColType => '类型';

  @override
  String get bundleEmbeddedType => '嵌入图片';

  @override
  String get bundleAttachmentType => '单独文件';

  @override
  String get bundleSecTenancy => '租赁协议';

  @override
  String get bundleSecDeposit => '押金支付凭证';

  @override
  String get bundleSecHandover => '交接与房产状况证据';

  @override
  String get bundleSecUtility => '公用事业证据';

  @override
  String get bundleSecComms => '通信记录';

  @override
  String get bundleSecDeduction => '扣除与支出证据';

  @override
  String get bundleSecDemand => '催讨函与送达证据';

  @override
  String get bundleSecOther => '其他证据';

  @override
  String get bundleEvidenceMainHeading => '证据';

  @override
  String get bundleAttachmentNotice => '此文件作为单独附件提供，未嵌入本证据册。';

  @override
  String get bundleImageUnavailable => '此图片无法嵌入，将作为单独附件提供。';

  @override
  String get bundleFileLabel => '文件名';

  @override
  String get bundleSha256Label => 'SHA-256';

  @override
  String get bundleFooterDisclaimer =>
      '本证据册由发件人使用 SewaBukti（一款证据整理与文书准备工具）编制。其内容属一般性质，并非法律意见，亦非由律师出具。';

  @override
  String get legalReviewBanner => '测试版草稿 —— 尚待专业法律审核。以英文版本为准。';

  @override
  String get claimRouteTitle => '索偿途径';

  @override
  String get claimRouteOpenGuidance => '打开官方司法指引';

  @override
  String get claimRouteGuidanceNote => '适用的法院和官方门户取决于你提交申请的地点。请打开你所在区域的指引：';

  @override
  String get regionPeninsular => '马来西亚半岛';

  @override
  String get regionSabahSarawak => '沙巴与砂拉越';

  @override
  String claimRouteAboveCeiling(String amount, String ceiling) {
    return '此 $amount 的索偿超过了 $ceiling 的小额索偿上限。它可能需要普通民事诉讼，而非小额索偿法庭 —— 建议咨询法院登记处或律师。';
  }

  @override
  String get dashboardClaimRoute => '索偿途径';

  @override
  String get commonDelete => '删除';

  @override
  String get deleteCaseConfirmTitle => '删除此案件？';

  @override
  String get deleteCaseConfirmBody => '此操作将永久删除你的案件、证据和时间线。此操作无法撤销。';

  @override
  String get caseDeleted => '案件已删除。';

  @override
  String get deleteCaseFailed => '无法删除案件，请重试。';

  @override
  String get deleteAccountConfirmTitle => '删除你的账户？';

  @override
  String get deleteAccountConfirmBody =>
      '此操作将永久删除你的账户和所有应用数据，包括你的案件和证据。此操作无法撤销。';

  @override
  String get deleteAccountAck => '我明白此操作将永久删除我的账户和数据。';

  @override
  String get deleteAccountAction => '删除账户';

  @override
  String get accountDeleteFailed => '无法删除你的账户，请重试。';

  @override
  String get exportReady => '你的案件数据导出已下载。';

  @override
  String get exportFailed => '无法导出你的数据，请重试。';

  @override
  String get betaFull => 'SewaBukti 测试版当前已满，请稍后再试。';
}
