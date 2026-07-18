// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SewaBukti';

  @override
  String get appTagline => 'Build your case. Claim your deposit.';

  @override
  String get landingIntro =>
      'SewaBukti helps Malaysian tenants organise evidence when a landlord, agent, or management company delays, reduces, or refuses to return a rental deposit. It is an evidence-organisation and document-preparation tool, not a law firm.';

  @override
  String get howItWorksTitle => 'How it works';

  @override
  String get stepCompileTitle => 'Compile';

  @override
  String get stepCompileBody =>
      'Gather your tenancy agreement, receipts, photos, and messages into one private, organised case.';

  @override
  String get stepDemandTitle => 'Demand';

  @override
  String get stepDemandBody =>
      'Calculate the outstanding amount and generate a neutral, professional demand letter you fully control.';

  @override
  String get stepPrepareTitle => 'Prepare';

  @override
  String get stepPrepareBody =>
      'Build a factual chronology and export an indexed evidence bundle to support a civil or small-claims filing.';

  @override
  String get privacySummaryTitle => 'Your evidence stays private';

  @override
  String get privacySummaryBody =>
      'Uploaded files are stored in private storage that only you can access. SewaBukti never makes your documents public.';

  @override
  String get disclaimerSummaryTitle => 'Please note';

  @override
  String get disclaimerSummaryBody =>
      'SewaBukti does not provide legal advice or representation and does not guarantee repayment or court acceptance. You confirm the accuracy of every fact, date, amount, and party name. Court rules, forms, fees, and limits may change.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get googleSignInHint =>
      'Sign in to SewaBukti with your existing Google Account. You are not creating a new Google Account.';

  @override
  String get previewBuildNotice =>
      'Preview build — sign-in is simulated for demonstration.';

  @override
  String get previewSignIn => 'Continue (preview)';

  @override
  String get signInFailed => 'Sign-in failed. Please try again.';

  @override
  String get inactiveSignedOut =>
      'You were signed out after a period of inactivity. Please sign in again.';

  @override
  String get notLegalServiceNotice =>
      'SewaBukti is not a law firm, court, or government service.';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageMalay => 'Bahasa Melayu';

  @override
  String get languageChinese => '简体中文';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get help => 'Help';

  @override
  String get signOut => 'Sign out';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navSettings => 'Settings';

  @override
  String dashboardWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get dashboardNoCaseTitle => 'You have no active case yet';

  @override
  String get dashboardNoCaseBody =>
      'Start a deposit-recovery case to compile your evidence, calculate what you are owed, and prepare a demand letter.';

  @override
  String get dashboardStartCase => 'Start your case';

  @override
  String get dashboardContinueCase => 'Continue your case';

  @override
  String get dashboardActiveCaseTitle => 'Your deposit-recovery case';

  @override
  String dashboardCompletion(int percent) {
    return '$percent% complete';
  }

  @override
  String get dashboardOutstandingTasks => 'Outstanding tasks';

  @override
  String get dashboardDemandLetter => 'Demand letter';

  @override
  String get dashboardEvidenceBundle => 'Evidence bundle';

  @override
  String get dashboardStorageUsed => 'Storage used';

  @override
  String dashboardStorageValue(String usedMb, String totalMb) {
    return '$usedMb MB of $totalMb MB';
  }

  @override
  String get statusNotStarted => 'Not started';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusSent => 'Sent';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsNameLabel => 'Name';

  @override
  String get settingsEmailLabel => 'Google email';

  @override
  String get settingsPreferencesSection => 'Preferences';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsDisplayModeLabel => 'Display mode';

  @override
  String get displayLight => 'Light';

  @override
  String get displayDark => 'Dark';

  @override
  String get settingsStorageSection => 'Storage';

  @override
  String get settingsDataSection => 'Your data';

  @override
  String get settingsExportData => 'Download a copy of your case data';

  @override
  String get settingsDeleteCase => 'Delete case';

  @override
  String get settingsDeleteAccount => 'Delete account and application data';

  @override
  String get settingsLegalSection => 'Legal & privacy';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get caseWizardTitle => 'Your case';

  @override
  String wizardStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get wizardNext => 'Next';

  @override
  String get wizardBack => 'Back';

  @override
  String get wizardSaveExit => 'Save & exit';

  @override
  String get wizardFinish => 'Finish';

  @override
  String get wizardSavedToast => 'Progress saved';

  @override
  String get fieldRequired => 'Required';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get invalidAmount => 'Enter a valid amount';

  @override
  String get optionalLabel => 'Optional';

  @override
  String get selectDate => 'Select date';

  @override
  String get notSet => 'Not set';

  @override
  String get showLabel => 'Show';

  @override
  String get hideLabel => 'Hide';

  @override
  String get stepTenancyTitle => 'Tenancy details';

  @override
  String get stepClaimantTitle => 'Your details';

  @override
  String get stepOtherPartyTitle => 'Other party';

  @override
  String get stepDepositTitle => 'Deposit details';

  @override
  String get stepReviewTitle => 'Review';

  @override
  String get fieldAddressLine1 => 'Address line 1';

  @override
  String get fieldAddressLine2 => 'Address line 2';

  @override
  String get fieldCity => 'City / town';

  @override
  String get fieldPostcode => 'Postcode';

  @override
  String get fieldState => 'State';

  @override
  String get fieldTenancyStart => 'Tenancy start date';

  @override
  String get fieldTenancyEnd => 'Tenancy end date';

  @override
  String get fieldVacatedDate => 'Date you vacated';

  @override
  String get fieldKeysReturned => 'Date keys / access cards returned';

  @override
  String get fieldMonthlyRent => 'Monthly rent';

  @override
  String get fieldRefundDeadline => 'Refund deadline stated in the agreement';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldIdNumber => 'Identity card / passport number';

  @override
  String get fieldIdNumberHint =>
      'Optional. Masked by default and stored securely; used only on your documents.';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldEmailFromGoogleHint => 'From your Google account';

  @override
  String get fieldPhone => 'Telephone number';

  @override
  String get fieldCorrespondenceAddress => 'Correspondence address';

  @override
  String get otherPartyDisclaimer =>
      'These questions help organise information. They do not determine the legally correct defendant — confirm that with the court registry or a lawyer if you are unsure.';

  @override
  String get fieldPartyType => 'Who are you claiming from?';

  @override
  String get partyTypeLandlord => 'Landlord';

  @override
  String get partyTypeAgent => 'Agent';

  @override
  String get partyTypeManagement => 'Management company';

  @override
  String get partyTypeUncertain => 'Not sure';

  @override
  String get fieldPartyIsCompany => 'This party is a company';

  @override
  String get fieldPartyName => 'Name (as written in the tenancy agreement)';

  @override
  String get fieldPartyCompanyNo => 'Company registration number';

  @override
  String get fieldPartyEmail => 'Email';

  @override
  String get fieldPartyPhone => 'Telephone number';

  @override
  String get fieldPartyAddress => 'Service / correspondence address';

  @override
  String get fieldDepositReceivedBy => 'Who received the deposit?';

  @override
  String get fieldDepositPromisedBy => 'Who promised to return the deposit?';

  @override
  String get fieldSecurityDeposit => 'Security deposit paid';

  @override
  String get fieldUtilityDeposit => 'Utility deposit paid';

  @override
  String get fieldAccessDeposit => 'Access-card / key deposit paid';

  @override
  String get fieldOtherDeposit => 'Other deposit paid';

  @override
  String get labelTotalDeposit => 'Total deposit paid';

  @override
  String get fieldAmountRefunded => 'Amount already refunded';

  @override
  String get fieldDeductionsAccepted => 'Deductions you accept';

  @override
  String get fieldDeductionsDisputed => 'Deductions you dispute';

  @override
  String get labelTotalClaimed => 'Amount currently claimed';

  @override
  String get reviewConfirmHint =>
      'Please check every fact, date, amount, and party name. You are responsible for their accuracy.';

  @override
  String get reviewNoData => 'Not entered yet.';

  @override
  String get dashboardAmountClaimed => 'Amount claimed';

  @override
  String get dashboardManageEvidence => 'Evidence';

  @override
  String get evidenceTitle => 'Evidence';

  @override
  String get evidenceSupportedHint => 'PDF, JPG, PNG, WebP, or TXT.';

  @override
  String evidenceFileCount(int count, int max) {
    return '$count of $max files';
  }

  @override
  String get evidenceAdd => 'Add file';

  @override
  String get evidenceEmptyCategory => 'None yet';

  @override
  String get evidencePreview => 'Preview';

  @override
  String get evidenceDownload => 'Download';

  @override
  String get evidenceDelete => 'Delete';

  @override
  String evidenceDeleteConfirm(String name) {
    return 'Remove \"$name\"? This cannot be undone.';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRemove => 'Remove';

  @override
  String get evidenceAddDialogTitle => 'Add evidence';

  @override
  String get evidenceItemTitle => 'Title';

  @override
  String get evidenceItemDescription => 'Description';

  @override
  String get evidenceItemDate => 'Document / event date';

  @override
  String get evidenceUploaded => 'File added';

  @override
  String get evidencePreviewUnavailable =>
      'Preview isn\'t available here — files are stored once the backend is configured; re-add to preview it in this session.';

  @override
  String get evidenceHashNote =>
      'A file hash detects later changes to a file but does not prove when the original was created.';

  @override
  String get evidenceNoCaseTitle => 'Start a case first';

  @override
  String get evidenceNoCaseBody =>
      'Create your deposit-recovery case before adding evidence.';

  @override
  String get errUnsupportedType => 'This file type isn\'t supported.';

  @override
  String get errFileTooLarge => 'This file exceeds the size limit.';

  @override
  String get errFileCountExceeded =>
      'You\'ve reached the maximum number of files for this case.';

  @override
  String get errStorageQuota => 'This case\'s storage limit is full.';

  @override
  String get errPickFailed => 'Could not read the selected file.';

  @override
  String get evCatTenancyAgreement => 'Tenancy agreement';

  @override
  String get evCatStampedAgreement => 'Stamped tenancy agreement';

  @override
  String get evCatDepositReceipt => 'Deposit payment / bank-transfer proof';

  @override
  String get evCatMoveInPhotos => 'Move-in condition photos';

  @override
  String get evCatMoveOutPhotos => 'Move-out condition photos';

  @override
  String get evCatHandoverKeys => 'Key / access-card handover';

  @override
  String get evCatInspectionReport => 'Final inspection / handover report';

  @override
  String get evCatUtilityBills => 'Final utility bills & meter readings';

  @override
  String get evCatMessages => 'WhatsApp / message screenshots';

  @override
  String get evCatEmails => 'Emails';

  @override
  String get evCatDeductionStatement => 'Deduction statement';

  @override
  String get evCatRepairQuote => 'Repair / cleaning quotation';

  @override
  String get evCatRepairReceipt => 'Repair / cleaning receipt';

  @override
  String get evCatPriorRequests => 'Previous refund requests';

  @override
  String get evCatDemandDelivery => 'Demand-letter delivery evidence';

  @override
  String get evCatOther => 'Other supporting evidence';

  @override
  String get dashboardChronology => 'Chronology';

  @override
  String get chronologyTitle => 'Chronology';

  @override
  String get chronologyIntro =>
      'Add the key events in order. Enter only facts you can support — SewaBukti never invents or infers anything.';

  @override
  String get chronologyEmpty => 'No events yet. Add the first one.';

  @override
  String get chronologyAdd => 'Add event';

  @override
  String get chronologyEditEvent => 'Edit event';

  @override
  String get chronologySortByDate => 'Sort by date';

  @override
  String get chronologyDeleteConfirm => 'Remove this event?';

  @override
  String get chronologyNoCaseBody =>
      'Create your case before building the chronology.';

  @override
  String get eventDateLabel => 'Date';

  @override
  String get eventTimeLabel => 'Time (optional)';

  @override
  String get eventTitleLabel => 'Event';

  @override
  String get eventDescriptionLabel => 'What happened';

  @override
  String get eventLinkedEvidence => 'Linked evidence';

  @override
  String get eventSuggestionsLabel => 'Common events';

  @override
  String eventLinkedCount(int count) {
    return '$count linked';
  }

  @override
  String get evtTenancyCommenced => 'Tenancy commenced';

  @override
  String get evtDepositPaid => 'Deposit paid';

  @override
  String get evtNoticeGiven => 'Notice to terminate given';

  @override
  String get evtVacated => 'Property vacated';

  @override
  String get evtKeysReturned => 'Keys returned';

  @override
  String get evtInspection => 'Inspection completed';

  @override
  String get evtRefundRequested => 'Refund requested';

  @override
  String get evtRefundPromised => 'Refund promised';

  @override
  String get evtPartialRefund => 'Partial refund received';

  @override
  String get evtDeductionDisputed => 'Deduction disputed';

  @override
  String get evtDemandSent => 'Demand letter sent';

  @override
  String get evtDeadlineExpired => 'Payment deadline expired';

  @override
  String get demandLetterTitle => 'Demand letter';

  @override
  String get demandLetterIntro =>
      'Generate a neutral demand letter from your case details. Review everything and confirm it is accurate before you download or send it.';

  @override
  String get demandLanguageLabel => 'Letter language';

  @override
  String get demandRecipientEmailLabel => 'Recipient email';

  @override
  String get demandSignatureLabel => 'Your name (as signature)';

  @override
  String get demandDeadlineLabel => 'Payment deadline';

  @override
  String get demandPaymentInstructionsLabel =>
      'Payment instructions (optional)';

  @override
  String get demandNotesLabel => 'Additional notes (optional)';

  @override
  String get demandFactsHeading => 'Details used in the letter';

  @override
  String get demandConfirmCheckbox =>
      'I confirm these facts, amounts, dates, and names are accurate.';

  @override
  String get demandConfirmRequired =>
      'Please confirm the details are accurate first.';

  @override
  String get demandMissingFields =>
      'Please complete the recipient email, your name, and the payment deadline.';

  @override
  String get demandDownloadPdf => 'Download / print PDF';

  @override
  String get demandSend => 'Email me a copy';

  @override
  String get demandSent => 'A copy has been emailed to you.';

  @override
  String get demandCopyToLabel => 'Email a copy to (your address)';

  @override
  String get demandDeliveryNote =>
      'SewaBukti emails the letter and its PDF to you. You then forward or serve it to the other party yourself — SewaBukti does not deliver it for you.';

  @override
  String get demandPaymentInstructionsHint =>
      'Optional. Only add bank details if you are comfortable sharing them.';

  @override
  String get demandSendFailed => 'Delivery failed. Please try again.';

  @override
  String get demandBackendRequired =>
      'Sending email needs the backend configured. You can still download the PDF.';

  @override
  String get demandNoCaseBody =>
      'Create your case before generating a demand letter.';

  @override
  String get letterSubject => 'Demand for return of rental deposit';

  @override
  String letterGreeting(String recipient) {
    return 'Dear $recipient,';
  }

  @override
  String get letterGreetingFallback => 'To whom it may concern,';

  @override
  String letterOpening(String property) {
    return 'I am writing regarding the rental deposit for the property at $property.';
  }

  @override
  String letterTenancyPeriod(String start, String end) {
    return 'The tenancy ran from $start to $end.';
  }

  @override
  String get letterDepositHeading => 'Deposit summary';

  @override
  String letterOutstandingSentence(String amount) {
    return 'The outstanding deposit amount owed to me is $amount.';
  }

  @override
  String get letterFactsHeading => 'Summary of events';

  @override
  String letterDeadlineSentence(String deadline) {
    return 'I request that this amount be paid in full by $deadline.';
  }

  @override
  String get letterPaymentHeading => 'Payment instructions';

  @override
  String get letterDocsHeading => 'Supporting documents';

  @override
  String get letterFurtherAction =>
      'If payment is not received by that date, I may consider further civil action to recover the amount owed.';

  @override
  String get letterClosing => 'Yours faithfully,';

  @override
  String get letterFooterDisclaimer =>
      'This letter was prepared by the sender using SewaBukti, an evidence-organisation and document-preparation tool. It is general in nature, is not legal advice, and was not issued by a lawyer.';

  @override
  String get bundleTitle => 'Evidence bundle';

  @override
  String get bundleIntro =>
      'Assemble your case details, chronology, and selected evidence into a single indexed PDF you can download. Nothing is uploaded.';

  @override
  String get bundleNoCaseBody =>
      'Create your case before generating an evidence bundle.';

  @override
  String get bundleIncludedHeading => 'Included in the bundle';

  @override
  String get bundleIncludeCaseSummary =>
      'Case summary, parties, property, and deposit calculation';

  @override
  String get bundleIncludeChronology => 'Chronology of events';

  @override
  String get bundleEvidenceHeading => 'Evidence to include';

  @override
  String get bundleEvidenceHint =>
      'All files are selected by default. Untick anything sensitive you do not want in the bundle.';

  @override
  String get bundleNoEvidence =>
      'No evidence uploaded. The bundle will contain your case details only.';

  @override
  String get bundleSelectAll => 'Select all';

  @override
  String get bundleSelectNone => 'Clear all';

  @override
  String get bundleEmbeddedHint => 'Image — embedded';

  @override
  String get bundleAttachmentHint => 'Separate attachment';

  @override
  String get bundlePreparedByLabel => 'Prepared by (name)';

  @override
  String get bundleChecklistHeading => 'Final check before generating';

  @override
  String bundleChecklistEvidence(int included, int total) {
    return '$included of $total evidence items included';
  }

  @override
  String bundleChecklistEmbedded(int embedded, int attachments) {
    return '$embedded embedded as images, $attachments as separate attachments';
  }

  @override
  String bundleChecklistEvents(int count) {
    return '$count chronology events';
  }

  @override
  String get bundleConfirmCheckbox =>
      'I confirm this information is accurate and I have chosen which evidence to include.';

  @override
  String get bundleConfirmRequired =>
      'Please confirm before generating the bundle.';

  @override
  String get bundleGenerate => 'Generate bundle PDF';

  @override
  String get bundleGenerating => 'Preparing your bundle…';

  @override
  String get bundleGenerateFailed =>
      'Could not generate the bundle. Please try again.';

  @override
  String get bundleCoverPreparedBy => 'Prepared by';

  @override
  String get bundleGeneratedOn => 'Generated on';

  @override
  String get bundleDisclaimerHeading => 'Disclaimer and confirmation';

  @override
  String get bundleDisclaimerP1 =>
      'SewaBukti is an evidence-organisation and document-preparation tool. It is not a law firm, does not provide legal advice or representation, and does not guarantee repayment or court acceptance.';

  @override
  String get bundleDisclaimerP2 =>
      'The person named on the cover prepared this bundle and confirms that the facts, dates, amounts, and party names it contains are accurate to the best of their knowledge.';

  @override
  String get bundleDisclaimerP3 =>
      'Court rules, forms, fees, and limits may change. Confirm the current requirements with the relevant court registry.';

  @override
  String get bundleProvenanceNote =>
      'Headings, totals, and appendix numbers (SB-A##) are generated by SewaBukti. All other values were entered by the user.';

  @override
  String get bundleCaseSummaryHeading => 'Case summary';

  @override
  String get bundleTenancyPeriodLabel => 'Tenancy period';

  @override
  String get bundleEvidenceCountLabel => 'Evidence items included';

  @override
  String get bundleEventCountLabel => 'Chronology events';

  @override
  String get bundlePartiesHeading => 'Parties and property';

  @override
  String get bundlePropertyLabel => 'Address';

  @override
  String get bundlePropertyHeading => 'Property';

  @override
  String get bundleClaimantHeading => 'Claimant';

  @override
  String get bundleOtherPartyHeading => 'Other party';

  @override
  String get bundleDepositHeading => 'Deposit calculation';

  @override
  String get bundleChronologyHeading => 'Chronology of events';

  @override
  String get bundleChronologyEmpty => 'No chronology events were added.';

  @override
  String get bundleChronologyRefsLabel => 'Linked evidence';

  @override
  String get bundleIndexHeading => 'Evidence index';

  @override
  String bundleIndexIntro(int count) {
    return '$count item(s) included in this bundle.';
  }

  @override
  String get bundleColAppendix => 'Appendix';

  @override
  String get bundleColItem => 'Item';

  @override
  String get bundleColCategory => 'Category';

  @override
  String get bundleColDocDate => 'Document date';

  @override
  String get bundleColUploaded => 'Uploaded';

  @override
  String get bundleColType => 'Type';

  @override
  String get bundleEmbeddedType => 'Embedded image';

  @override
  String get bundleAttachmentType => 'Separate file';

  @override
  String get bundleSecTenancy => 'Tenancy agreement';

  @override
  String get bundleSecDeposit => 'Deposit payment evidence';

  @override
  String get bundleSecHandover => 'Handover and property-condition evidence';

  @override
  String get bundleSecUtility => 'Utility evidence';

  @override
  String get bundleSecComms => 'Communications';

  @override
  String get bundleSecDeduction => 'Deduction and expense evidence';

  @override
  String get bundleSecDemand => 'Demand letter and delivery evidence';

  @override
  String get bundleSecOther => 'Other evidence';

  @override
  String get bundleEvidenceMainHeading => 'Evidence';

  @override
  String get bundleAttachmentNotice =>
      'This file is provided as a separate attachment and is not embedded in this bundle.';

  @override
  String get bundleImageUnavailable =>
      'This image could not be embedded and is provided as a separate attachment.';

  @override
  String get bundleFileLabel => 'File name';

  @override
  String get bundleSha256Label => 'SHA-256';

  @override
  String get bundleFooterDisclaimer =>
      'This bundle was prepared by the sender using SewaBukti, an evidence-organisation and document-preparation tool. It is general in nature, is not legal advice, and was not issued by a lawyer.';

  @override
  String get legalReviewBanner =>
      'Draft for beta — pending professional legal review. The English version prevails.';

  @override
  String get claimRouteTitle => 'Claim route';

  @override
  String get claimRouteOpenGuidance => 'Open official judiciary guidance';

  @override
  String get claimRouteGuidanceNote =>
      'The court and official portal depend on where you would file. Open the guidance for your region:';

  @override
  String get regionPeninsular => 'Peninsular Malaysia';

  @override
  String get regionSabahSarawak => 'Sabah & Sarawak';

  @override
  String claimRouteAboveCeiling(String amount, String ceiling) {
    return 'This claim of $amount is above the $ceiling small-claims ceiling. It likely needs ordinary civil proceedings rather than the Small Claims Court — consider consulting the court registry or a lawyer.';
  }

  @override
  String get dashboardClaimRoute => 'Claim route';

  @override
  String get commonDelete => 'Delete';

  @override
  String get deleteCaseConfirmTitle => 'Delete this case?';

  @override
  String get deleteCaseConfirmBody =>
      'This permanently deletes your case, its evidence, and chronology. This cannot be undone.';

  @override
  String get caseDeleted => 'Case deleted.';

  @override
  String get deleteCaseFailed => 'Could not delete the case. Please try again.';

  @override
  String get deleteAccountConfirmTitle => 'Delete your account?';

  @override
  String get deleteAccountConfirmBody =>
      'This permanently deletes your account and all application data, including your case and evidence. This cannot be undone.';

  @override
  String get deleteAccountAck =>
      'I understand this permanently deletes my account and data.';

  @override
  String get deleteAccountAction => 'Delete account';

  @override
  String get accountDeleteFailed =>
      'Could not delete your account. Please try again.';

  @override
  String get exportReady => 'Your case data export has been downloaded.';

  @override
  String get exportFailed => 'Could not export your data. Please try again.';

  @override
  String get betaFull =>
      'The SewaBukti beta is currently full. Please try again later.';
}
