import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms'),
    Locale('zh'),
  ];

  /// Product name / wordmark.
  ///
  /// In en, this message translates to:
  /// **'SewaBukti'**
  String get appName;

  /// Landing hero tagline.
  ///
  /// In en, this message translates to:
  /// **'Build your case. Claim your deposit.'**
  String get appTagline;

  /// One-paragraph product explanation on the landing page.
  ///
  /// In en, this message translates to:
  /// **'SewaBukti helps Malaysian tenants organise evidence when a landlord, agent, or management company delays, reduces, or refuses to return a rental deposit. It is an evidence-organisation and document-preparation tool, not a law firm.'**
  String get landingIntro;

  /// No description provided for @howItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorksTitle;

  /// No description provided for @stepCompileTitle.
  ///
  /// In en, this message translates to:
  /// **'Compile'**
  String get stepCompileTitle;

  /// No description provided for @stepCompileBody.
  ///
  /// In en, this message translates to:
  /// **'Gather your tenancy agreement, receipts, photos, and messages into one private, organised case.'**
  String get stepCompileBody;

  /// No description provided for @stepDemandTitle.
  ///
  /// In en, this message translates to:
  /// **'Demand'**
  String get stepDemandTitle;

  /// No description provided for @stepDemandBody.
  ///
  /// In en, this message translates to:
  /// **'Calculate the outstanding amount and generate a neutral, professional demand letter you fully control.'**
  String get stepDemandBody;

  /// No description provided for @stepPrepareTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare'**
  String get stepPrepareTitle;

  /// No description provided for @stepPrepareBody.
  ///
  /// In en, this message translates to:
  /// **'Build a factual chronology and export an indexed evidence bundle to support a civil or small-claims filing.'**
  String get stepPrepareBody;

  /// No description provided for @privacySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your evidence stays private'**
  String get privacySummaryTitle;

  /// No description provided for @privacySummaryBody.
  ///
  /// In en, this message translates to:
  /// **'Uploaded files are stored in private storage that only you can access. SewaBukti never makes your documents public.'**
  String get privacySummaryBody;

  /// No description provided for @disclaimerSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Please note'**
  String get disclaimerSummaryTitle;

  /// No description provided for @disclaimerSummaryBody.
  ///
  /// In en, this message translates to:
  /// **'SewaBukti does not provide legal advice or representation and does not guarantee repayment or court acceptance. You confirm the accuracy of every fact, date, amount, and party name. Court rules, forms, fees, and limits may change.'**
  String get disclaimerSummaryBody;

  /// Google Sign-In button label. Must match Google's approved localisation for the selected language (FR-AUTH-14).
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @googleSignInHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to SewaBukti with your existing Google Account. You are not creating a new Google Account.'**
  String get googleSignInHint;

  /// No description provided for @previewBuildNotice.
  ///
  /// In en, this message translates to:
  /// **'Preview build — sign-in is simulated for demonstration.'**
  String get previewBuildNotice;

  /// No description provided for @previewSignIn.
  ///
  /// In en, this message translates to:
  /// **'Continue (preview)'**
  String get previewSignIn;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get signInFailed;

  /// No description provided for @inactiveSignedOut.
  ///
  /// In en, this message translates to:
  /// **'You were signed out after a period of inactivity. Please sign in again.'**
  String get inactiveSignedOut;

  /// No description provided for @notLegalServiceNotice.
  ///
  /// In en, this message translates to:
  /// **'SewaBukti is not a law firm, court, or government service.'**
  String get notLegalServiceNotice;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageMalay.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Melayu'**
  String get languageMalay;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageChinese;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @dashboardWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String dashboardWelcome(String name);

  /// No description provided for @dashboardNoCaseTitle.
  ///
  /// In en, this message translates to:
  /// **'You have no active case yet'**
  String get dashboardNoCaseTitle;

  /// No description provided for @dashboardNoCaseBody.
  ///
  /// In en, this message translates to:
  /// **'Start a deposit-recovery case to compile your evidence, calculate what you are owed, and prepare a demand letter.'**
  String get dashboardNoCaseBody;

  /// No description provided for @dashboardStartCase.
  ///
  /// In en, this message translates to:
  /// **'Start your case'**
  String get dashboardStartCase;

  /// No description provided for @dashboardContinueCase.
  ///
  /// In en, this message translates to:
  /// **'Continue your case'**
  String get dashboardContinueCase;

  /// No description provided for @dashboardActiveCaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Your deposit-recovery case'**
  String get dashboardActiveCaseTitle;

  /// No description provided for @dashboardCompletion.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String dashboardCompletion(int percent);

  /// No description provided for @dashboardOutstandingTasks.
  ///
  /// In en, this message translates to:
  /// **'Outstanding tasks'**
  String get dashboardOutstandingTasks;

  /// No description provided for @dashboardDemandLetter.
  ///
  /// In en, this message translates to:
  /// **'Demand letter'**
  String get dashboardDemandLetter;

  /// No description provided for @dashboardEvidenceBundle.
  ///
  /// In en, this message translates to:
  /// **'Evidence bundle'**
  String get dashboardEvidenceBundle;

  /// No description provided for @dashboardStorageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage used'**
  String get dashboardStorageUsed;

  /// No description provided for @dashboardStorageValue.
  ///
  /// In en, this message translates to:
  /// **'{usedMb} MB of {totalMb} MB'**
  String dashboardStorageValue(String usedMb, String totalMb);

  /// No description provided for @statusNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get statusNotStarted;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// No description provided for @statusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get statusSent;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// No description provided for @settingsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsNameLabel;

  /// No description provided for @settingsEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Google email'**
  String get settingsEmailLabel;

  /// No description provided for @settingsPreferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferencesSection;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsDisplayModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Display mode'**
  String get settingsDisplayModeLabel;

  /// No description provided for @displayLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get displayLight;

  /// No description provided for @displayDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get displayDark;

  /// No description provided for @settingsStorageSection.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settingsStorageSection;

  /// No description provided for @settingsDataSection.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsDataSection;

  /// No description provided for @settingsExportData.
  ///
  /// In en, this message translates to:
  /// **'Download a copy of your case data'**
  String get settingsExportData;

  /// No description provided for @settingsDeleteCase.
  ///
  /// In en, this message translates to:
  /// **'Delete case'**
  String get settingsDeleteCase;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account and application data'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsLegalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal & privacy'**
  String get settingsLegalSection;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @caseWizardTitle.
  ///
  /// In en, this message translates to:
  /// **'Your case'**
  String get caseWizardTitle;

  /// No description provided for @wizardStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String wizardStepOf(int current, int total);

  /// No description provided for @wizardNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get wizardNext;

  /// No description provided for @wizardBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get wizardBack;

  /// No description provided for @wizardSaveExit.
  ///
  /// In en, this message translates to:
  /// **'Save & exit'**
  String get wizardSaveExit;

  /// No description provided for @wizardFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get wizardFinish;

  /// No description provided for @wizardSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Progress saved'**
  String get wizardSavedToast;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get invalidAmount;

  /// No description provided for @optionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalLabel;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @showLabel.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get showLabel;

  /// No description provided for @hideLabel.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hideLabel;

  /// No description provided for @stepTenancyTitle.
  ///
  /// In en, this message translates to:
  /// **'Tenancy details'**
  String get stepTenancyTitle;

  /// No description provided for @stepClaimantTitle.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get stepClaimantTitle;

  /// No description provided for @stepOtherPartyTitle.
  ///
  /// In en, this message translates to:
  /// **'Other party'**
  String get stepOtherPartyTitle;

  /// No description provided for @stepDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit details'**
  String get stepDepositTitle;

  /// No description provided for @stepReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepReviewTitle;

  /// No description provided for @fieldAddressLine1.
  ///
  /// In en, this message translates to:
  /// **'Address line 1'**
  String get fieldAddressLine1;

  /// No description provided for @fieldAddressLine2.
  ///
  /// In en, this message translates to:
  /// **'Address line 2'**
  String get fieldAddressLine2;

  /// No description provided for @fieldCity.
  ///
  /// In en, this message translates to:
  /// **'City / town'**
  String get fieldCity;

  /// No description provided for @fieldPostcode.
  ///
  /// In en, this message translates to:
  /// **'Postcode'**
  String get fieldPostcode;

  /// No description provided for @fieldState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get fieldState;

  /// No description provided for @fieldTenancyStart.
  ///
  /// In en, this message translates to:
  /// **'Tenancy start date'**
  String get fieldTenancyStart;

  /// No description provided for @fieldTenancyEnd.
  ///
  /// In en, this message translates to:
  /// **'Tenancy end date'**
  String get fieldTenancyEnd;

  /// No description provided for @fieldVacatedDate.
  ///
  /// In en, this message translates to:
  /// **'Date you vacated'**
  String get fieldVacatedDate;

  /// No description provided for @fieldKeysReturned.
  ///
  /// In en, this message translates to:
  /// **'Date keys / access cards returned'**
  String get fieldKeysReturned;

  /// No description provided for @fieldMonthlyRent.
  ///
  /// In en, this message translates to:
  /// **'Monthly rent'**
  String get fieldMonthlyRent;

  /// No description provided for @fieldRefundDeadline.
  ///
  /// In en, this message translates to:
  /// **'Refund deadline stated in the agreement'**
  String get fieldRefundDeadline;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fieldFullName;

  /// No description provided for @fieldIdNumber.
  ///
  /// In en, this message translates to:
  /// **'Identity card / passport number'**
  String get fieldIdNumber;

  /// No description provided for @fieldIdNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. Masked by default and stored securely; used only on your documents.'**
  String get fieldIdNumberHint;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldEmailFromGoogleHint.
  ///
  /// In en, this message translates to:
  /// **'From your Google account'**
  String get fieldEmailFromGoogleHint;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Telephone number'**
  String get fieldPhone;

  /// No description provided for @fieldCorrespondenceAddress.
  ///
  /// In en, this message translates to:
  /// **'Correspondence address'**
  String get fieldCorrespondenceAddress;

  /// No description provided for @otherPartyDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'These questions help organise information. They do not determine the legally correct defendant — confirm that with the court registry or a lawyer if you are unsure.'**
  String get otherPartyDisclaimer;

  /// No description provided for @fieldPartyType.
  ///
  /// In en, this message translates to:
  /// **'Who are you claiming from?'**
  String get fieldPartyType;

  /// No description provided for @partyTypeLandlord.
  ///
  /// In en, this message translates to:
  /// **'Landlord'**
  String get partyTypeLandlord;

  /// No description provided for @partyTypeAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get partyTypeAgent;

  /// No description provided for @partyTypeManagement.
  ///
  /// In en, this message translates to:
  /// **'Management company'**
  String get partyTypeManagement;

  /// No description provided for @partyTypeUncertain.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get partyTypeUncertain;

  /// No description provided for @fieldPartyIsCompany.
  ///
  /// In en, this message translates to:
  /// **'This party is a company'**
  String get fieldPartyIsCompany;

  /// No description provided for @fieldPartyName.
  ///
  /// In en, this message translates to:
  /// **'Name (as written in the tenancy agreement)'**
  String get fieldPartyName;

  /// No description provided for @fieldPartyCompanyNo.
  ///
  /// In en, this message translates to:
  /// **'Company registration number'**
  String get fieldPartyCompanyNo;

  /// No description provided for @fieldPartyEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldPartyEmail;

  /// No description provided for @fieldPartyPhone.
  ///
  /// In en, this message translates to:
  /// **'Telephone number'**
  String get fieldPartyPhone;

  /// No description provided for @fieldPartyAddress.
  ///
  /// In en, this message translates to:
  /// **'Service / correspondence address'**
  String get fieldPartyAddress;

  /// No description provided for @fieldDepositReceivedBy.
  ///
  /// In en, this message translates to:
  /// **'Who received the deposit?'**
  String get fieldDepositReceivedBy;

  /// No description provided for @fieldDepositPromisedBy.
  ///
  /// In en, this message translates to:
  /// **'Who promised to return the deposit?'**
  String get fieldDepositPromisedBy;

  /// No description provided for @fieldSecurityDeposit.
  ///
  /// In en, this message translates to:
  /// **'Security deposit paid'**
  String get fieldSecurityDeposit;

  /// No description provided for @fieldUtilityDeposit.
  ///
  /// In en, this message translates to:
  /// **'Utility deposit paid'**
  String get fieldUtilityDeposit;

  /// No description provided for @fieldAccessDeposit.
  ///
  /// In en, this message translates to:
  /// **'Access-card / key deposit paid'**
  String get fieldAccessDeposit;

  /// No description provided for @fieldOtherDeposit.
  ///
  /// In en, this message translates to:
  /// **'Other deposit paid'**
  String get fieldOtherDeposit;

  /// No description provided for @labelTotalDeposit.
  ///
  /// In en, this message translates to:
  /// **'Total deposit paid'**
  String get labelTotalDeposit;

  /// No description provided for @fieldAmountRefunded.
  ///
  /// In en, this message translates to:
  /// **'Amount already refunded'**
  String get fieldAmountRefunded;

  /// No description provided for @fieldDeductionsAccepted.
  ///
  /// In en, this message translates to:
  /// **'Deductions you accept'**
  String get fieldDeductionsAccepted;

  /// No description provided for @fieldDeductionsDisputed.
  ///
  /// In en, this message translates to:
  /// **'Deductions you dispute'**
  String get fieldDeductionsDisputed;

  /// No description provided for @labelTotalClaimed.
  ///
  /// In en, this message translates to:
  /// **'Amount currently claimed'**
  String get labelTotalClaimed;

  /// No description provided for @reviewConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Please check every fact, date, amount, and party name. You are responsible for their accuracy.'**
  String get reviewConfirmHint;

  /// No description provided for @reviewNoData.
  ///
  /// In en, this message translates to:
  /// **'Not entered yet.'**
  String get reviewNoData;

  /// No description provided for @dashboardAmountClaimed.
  ///
  /// In en, this message translates to:
  /// **'Amount claimed'**
  String get dashboardAmountClaimed;

  /// No description provided for @dashboardManageEvidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get dashboardManageEvidence;

  /// No description provided for @evidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get evidenceTitle;

  /// No description provided for @evidenceSupportedHint.
  ///
  /// In en, this message translates to:
  /// **'PDF, JPG, PNG, WebP, or TXT.'**
  String get evidenceSupportedHint;

  /// No description provided for @evidenceFileCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of {max} files'**
  String evidenceFileCount(int count, int max);

  /// No description provided for @evidenceAdd.
  ///
  /// In en, this message translates to:
  /// **'Add file'**
  String get evidenceAdd;

  /// No description provided for @evidenceEmptyCategory.
  ///
  /// In en, this message translates to:
  /// **'None yet'**
  String get evidenceEmptyCategory;

  /// No description provided for @evidencePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get evidencePreview;

  /// No description provided for @evidenceDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get evidenceDownload;

  /// No description provided for @evidenceDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get evidenceDelete;

  /// No description provided for @evidenceDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\"? This cannot be undone.'**
  String evidenceDeleteConfirm(String name);

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @evidenceAddDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add evidence'**
  String get evidenceAddDialogTitle;

  /// No description provided for @evidenceItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get evidenceItemTitle;

  /// No description provided for @evidenceItemDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get evidenceItemDescription;

  /// No description provided for @evidenceItemDate.
  ///
  /// In en, this message translates to:
  /// **'Document / event date'**
  String get evidenceItemDate;

  /// No description provided for @evidenceUploaded.
  ///
  /// In en, this message translates to:
  /// **'File added'**
  String get evidenceUploaded;

  /// No description provided for @evidencePreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Preview isn\'t available here — files are stored once the backend is configured; re-add to preview it in this session.'**
  String get evidencePreviewUnavailable;

  /// No description provided for @evidenceHashNote.
  ///
  /// In en, this message translates to:
  /// **'A file hash detects later changes to a file but does not prove when the original was created.'**
  String get evidenceHashNote;

  /// No description provided for @evidenceNoCaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a case first'**
  String get evidenceNoCaseTitle;

  /// No description provided for @evidenceNoCaseBody.
  ///
  /// In en, this message translates to:
  /// **'Create your deposit-recovery case before adding evidence.'**
  String get evidenceNoCaseBody;

  /// No description provided for @errUnsupportedType.
  ///
  /// In en, this message translates to:
  /// **'This file type isn\'t supported.'**
  String get errUnsupportedType;

  /// No description provided for @errFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This file exceeds the size limit.'**
  String get errFileTooLarge;

  /// No description provided for @errFileCountExceeded.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the maximum number of files for this case.'**
  String get errFileCountExceeded;

  /// No description provided for @errStorageQuota.
  ///
  /// In en, this message translates to:
  /// **'This case\'s storage limit is full.'**
  String get errStorageQuota;

  /// No description provided for @errPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected file.'**
  String get errPickFailed;

  /// No description provided for @evCatTenancyAgreement.
  ///
  /// In en, this message translates to:
  /// **'Tenancy agreement'**
  String get evCatTenancyAgreement;

  /// No description provided for @evCatStampedAgreement.
  ///
  /// In en, this message translates to:
  /// **'Stamped tenancy agreement'**
  String get evCatStampedAgreement;

  /// No description provided for @evCatDepositReceipt.
  ///
  /// In en, this message translates to:
  /// **'Deposit payment / bank-transfer proof'**
  String get evCatDepositReceipt;

  /// No description provided for @evCatMoveInPhotos.
  ///
  /// In en, this message translates to:
  /// **'Move-in condition photos'**
  String get evCatMoveInPhotos;

  /// No description provided for @evCatMoveOutPhotos.
  ///
  /// In en, this message translates to:
  /// **'Move-out condition photos'**
  String get evCatMoveOutPhotos;

  /// No description provided for @evCatHandoverKeys.
  ///
  /// In en, this message translates to:
  /// **'Key / access-card handover'**
  String get evCatHandoverKeys;

  /// No description provided for @evCatInspectionReport.
  ///
  /// In en, this message translates to:
  /// **'Final inspection / handover report'**
  String get evCatInspectionReport;

  /// No description provided for @evCatUtilityBills.
  ///
  /// In en, this message translates to:
  /// **'Final utility bills & meter readings'**
  String get evCatUtilityBills;

  /// No description provided for @evCatMessages.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp / message screenshots'**
  String get evCatMessages;

  /// No description provided for @evCatEmails.
  ///
  /// In en, this message translates to:
  /// **'Emails'**
  String get evCatEmails;

  /// No description provided for @evCatDeductionStatement.
  ///
  /// In en, this message translates to:
  /// **'Deduction statement'**
  String get evCatDeductionStatement;

  /// No description provided for @evCatRepairQuote.
  ///
  /// In en, this message translates to:
  /// **'Repair / cleaning quotation'**
  String get evCatRepairQuote;

  /// No description provided for @evCatRepairReceipt.
  ///
  /// In en, this message translates to:
  /// **'Repair / cleaning receipt'**
  String get evCatRepairReceipt;

  /// No description provided for @evCatPriorRequests.
  ///
  /// In en, this message translates to:
  /// **'Previous refund requests'**
  String get evCatPriorRequests;

  /// No description provided for @evCatDemandDelivery.
  ///
  /// In en, this message translates to:
  /// **'Demand-letter delivery evidence'**
  String get evCatDemandDelivery;

  /// No description provided for @evCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other supporting evidence'**
  String get evCatOther;

  /// No description provided for @dashboardChronology.
  ///
  /// In en, this message translates to:
  /// **'Chronology'**
  String get dashboardChronology;

  /// No description provided for @chronologyTitle.
  ///
  /// In en, this message translates to:
  /// **'Chronology'**
  String get chronologyTitle;

  /// No description provided for @chronologyIntro.
  ///
  /// In en, this message translates to:
  /// **'Add the key events in order. Enter only facts you can support — SewaBukti never invents or infers anything.'**
  String get chronologyIntro;

  /// No description provided for @chronologyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No events yet. Add the first one.'**
  String get chronologyEmpty;

  /// No description provided for @chronologyAdd.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get chronologyAdd;

  /// No description provided for @chronologyEditEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get chronologyEditEvent;

  /// No description provided for @chronologySortByDate.
  ///
  /// In en, this message translates to:
  /// **'Sort by date'**
  String get chronologySortByDate;

  /// No description provided for @chronologyDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this event?'**
  String get chronologyDeleteConfirm;

  /// No description provided for @chronologyNoCaseBody.
  ///
  /// In en, this message translates to:
  /// **'Create your case before building the chronology.'**
  String get chronologyNoCaseBody;

  /// No description provided for @eventDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get eventDateLabel;

  /// No description provided for @eventTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time (optional)'**
  String get eventTimeLabel;

  /// No description provided for @eventTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventTitleLabel;

  /// No description provided for @eventDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'What happened'**
  String get eventDescriptionLabel;

  /// No description provided for @eventLinkedEvidence.
  ///
  /// In en, this message translates to:
  /// **'Linked evidence'**
  String get eventLinkedEvidence;

  /// No description provided for @eventSuggestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Common events'**
  String get eventSuggestionsLabel;

  /// No description provided for @eventLinkedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} linked'**
  String eventLinkedCount(int count);

  /// No description provided for @evtTenancyCommenced.
  ///
  /// In en, this message translates to:
  /// **'Tenancy commenced'**
  String get evtTenancyCommenced;

  /// No description provided for @evtDepositPaid.
  ///
  /// In en, this message translates to:
  /// **'Deposit paid'**
  String get evtDepositPaid;

  /// No description provided for @evtNoticeGiven.
  ///
  /// In en, this message translates to:
  /// **'Notice to terminate given'**
  String get evtNoticeGiven;

  /// No description provided for @evtVacated.
  ///
  /// In en, this message translates to:
  /// **'Property vacated'**
  String get evtVacated;

  /// No description provided for @evtKeysReturned.
  ///
  /// In en, this message translates to:
  /// **'Keys returned'**
  String get evtKeysReturned;

  /// No description provided for @evtInspection.
  ///
  /// In en, this message translates to:
  /// **'Inspection completed'**
  String get evtInspection;

  /// No description provided for @evtRefundRequested.
  ///
  /// In en, this message translates to:
  /// **'Refund requested'**
  String get evtRefundRequested;

  /// No description provided for @evtRefundPromised.
  ///
  /// In en, this message translates to:
  /// **'Refund promised'**
  String get evtRefundPromised;

  /// No description provided for @evtPartialRefund.
  ///
  /// In en, this message translates to:
  /// **'Partial refund received'**
  String get evtPartialRefund;

  /// No description provided for @evtDeductionDisputed.
  ///
  /// In en, this message translates to:
  /// **'Deduction disputed'**
  String get evtDeductionDisputed;

  /// No description provided for @evtDemandSent.
  ///
  /// In en, this message translates to:
  /// **'Demand letter sent'**
  String get evtDemandSent;

  /// No description provided for @evtDeadlineExpired.
  ///
  /// In en, this message translates to:
  /// **'Payment deadline expired'**
  String get evtDeadlineExpired;

  /// No description provided for @demandLetterTitle.
  ///
  /// In en, this message translates to:
  /// **'Demand letter'**
  String get demandLetterTitle;

  /// No description provided for @demandLetterIntro.
  ///
  /// In en, this message translates to:
  /// **'Generate a neutral demand letter from your case details. Review everything and confirm it is accurate before you download or send it.'**
  String get demandLetterIntro;

  /// No description provided for @demandLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Letter language'**
  String get demandLanguageLabel;

  /// No description provided for @demandRecipientEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient email'**
  String get demandRecipientEmailLabel;

  /// No description provided for @demandSignatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name (as signature)'**
  String get demandSignatureLabel;

  /// No description provided for @demandDeadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment deadline'**
  String get demandDeadlineLabel;

  /// No description provided for @demandPaymentInstructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment instructions (optional)'**
  String get demandPaymentInstructionsLabel;

  /// No description provided for @demandNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional notes (optional)'**
  String get demandNotesLabel;

  /// No description provided for @demandFactsHeading.
  ///
  /// In en, this message translates to:
  /// **'Details used in the letter'**
  String get demandFactsHeading;

  /// No description provided for @demandConfirmCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I confirm these facts, amounts, dates, and names are accurate.'**
  String get demandConfirmCheckbox;

  /// No description provided for @demandConfirmRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm the details are accurate first.'**
  String get demandConfirmRequired;

  /// No description provided for @demandMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete the recipient email, your name, and the payment deadline.'**
  String get demandMissingFields;

  /// No description provided for @demandDownloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download / print PDF'**
  String get demandDownloadPdf;

  /// No description provided for @demandSend.
  ///
  /// In en, this message translates to:
  /// **'Email me a copy'**
  String get demandSend;

  /// No description provided for @demandSent.
  ///
  /// In en, this message translates to:
  /// **'A copy has been emailed to you.'**
  String get demandSent;

  /// No description provided for @demandCopyToLabel.
  ///
  /// In en, this message translates to:
  /// **'Email a copy to (your address)'**
  String get demandCopyToLabel;

  /// No description provided for @demandDeliveryNote.
  ///
  /// In en, this message translates to:
  /// **'SewaBukti emails the letter and its PDF to you. You then forward or serve it to the other party yourself — SewaBukti does not deliver it for you.'**
  String get demandDeliveryNote;

  /// No description provided for @demandPaymentInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. Only add bank details if you are comfortable sharing them.'**
  String get demandPaymentInstructionsHint;

  /// No description provided for @demandSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Delivery failed. Please try again.'**
  String get demandSendFailed;

  /// No description provided for @demandBackendRequired.
  ///
  /// In en, this message translates to:
  /// **'Sending email needs the backend configured. You can still download the PDF.'**
  String get demandBackendRequired;

  /// No description provided for @demandNoCaseBody.
  ///
  /// In en, this message translates to:
  /// **'Create your case before generating a demand letter.'**
  String get demandNoCaseBody;

  /// No description provided for @letterSubject.
  ///
  /// In en, this message translates to:
  /// **'Demand for return of rental deposit'**
  String get letterSubject;

  /// No description provided for @letterGreeting.
  ///
  /// In en, this message translates to:
  /// **'Dear {recipient},'**
  String letterGreeting(String recipient);

  /// No description provided for @letterGreetingFallback.
  ///
  /// In en, this message translates to:
  /// **'To whom it may concern,'**
  String get letterGreetingFallback;

  /// No description provided for @letterOpening.
  ///
  /// In en, this message translates to:
  /// **'I am writing regarding the rental deposit for the property at {property}.'**
  String letterOpening(String property);

  /// No description provided for @letterTenancyPeriod.
  ///
  /// In en, this message translates to:
  /// **'The tenancy ran from {start} to {end}.'**
  String letterTenancyPeriod(String start, String end);

  /// No description provided for @letterDepositHeading.
  ///
  /// In en, this message translates to:
  /// **'Deposit summary'**
  String get letterDepositHeading;

  /// No description provided for @letterOutstandingSentence.
  ///
  /// In en, this message translates to:
  /// **'The outstanding deposit amount owed to me is {amount}.'**
  String letterOutstandingSentence(String amount);

  /// No description provided for @letterFactsHeading.
  ///
  /// In en, this message translates to:
  /// **'Summary of events'**
  String get letterFactsHeading;

  /// No description provided for @letterDeadlineSentence.
  ///
  /// In en, this message translates to:
  /// **'I request that this amount be paid in full by {deadline}.'**
  String letterDeadlineSentence(String deadline);

  /// No description provided for @letterPaymentHeading.
  ///
  /// In en, this message translates to:
  /// **'Payment instructions'**
  String get letterPaymentHeading;

  /// No description provided for @letterDocsHeading.
  ///
  /// In en, this message translates to:
  /// **'Supporting documents'**
  String get letterDocsHeading;

  /// No description provided for @letterFurtherAction.
  ///
  /// In en, this message translates to:
  /// **'If payment is not received by that date, I may consider further civil action to recover the amount owed.'**
  String get letterFurtherAction;

  /// No description provided for @letterClosing.
  ///
  /// In en, this message translates to:
  /// **'Yours faithfully,'**
  String get letterClosing;

  /// No description provided for @letterFooterDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This letter was prepared by the sender using SewaBukti, an evidence-organisation and document-preparation tool. It is general in nature, is not legal advice, and was not issued by a lawyer.'**
  String get letterFooterDisclaimer;

  /// No description provided for @bundleTitle.
  ///
  /// In en, this message translates to:
  /// **'Evidence bundle'**
  String get bundleTitle;

  /// No description provided for @bundleIntro.
  ///
  /// In en, this message translates to:
  /// **'Assemble your case details, chronology, and selected evidence into a single indexed PDF you can download. Nothing is uploaded.'**
  String get bundleIntro;

  /// No description provided for @bundleNoCaseBody.
  ///
  /// In en, this message translates to:
  /// **'Create your case before generating an evidence bundle.'**
  String get bundleNoCaseBody;

  /// No description provided for @bundleIncludedHeading.
  ///
  /// In en, this message translates to:
  /// **'Included in the bundle'**
  String get bundleIncludedHeading;

  /// No description provided for @bundleIncludeCaseSummary.
  ///
  /// In en, this message translates to:
  /// **'Case summary, parties, property, and deposit calculation'**
  String get bundleIncludeCaseSummary;

  /// No description provided for @bundleIncludeChronology.
  ///
  /// In en, this message translates to:
  /// **'Chronology of events'**
  String get bundleIncludeChronology;

  /// No description provided for @bundleEvidenceHeading.
  ///
  /// In en, this message translates to:
  /// **'Evidence to include'**
  String get bundleEvidenceHeading;

  /// No description provided for @bundleEvidenceHint.
  ///
  /// In en, this message translates to:
  /// **'All files are selected by default. Untick anything sensitive you do not want in the bundle.'**
  String get bundleEvidenceHint;

  /// No description provided for @bundleNoEvidence.
  ///
  /// In en, this message translates to:
  /// **'No evidence uploaded. The bundle will contain your case details only.'**
  String get bundleNoEvidence;

  /// No description provided for @bundleSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get bundleSelectAll;

  /// No description provided for @bundleSelectNone.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get bundleSelectNone;

  /// No description provided for @bundleEmbeddedHint.
  ///
  /// In en, this message translates to:
  /// **'Image — embedded'**
  String get bundleEmbeddedHint;

  /// No description provided for @bundleAttachmentHint.
  ///
  /// In en, this message translates to:
  /// **'Separate attachment'**
  String get bundleAttachmentHint;

  /// No description provided for @bundlePreparedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Prepared by (name)'**
  String get bundlePreparedByLabel;

  /// No description provided for @bundleChecklistHeading.
  ///
  /// In en, this message translates to:
  /// **'Final check before generating'**
  String get bundleChecklistHeading;

  /// No description provided for @bundleChecklistEvidence.
  ///
  /// In en, this message translates to:
  /// **'{included} of {total} evidence items included'**
  String bundleChecklistEvidence(int included, int total);

  /// No description provided for @bundleChecklistEmbedded.
  ///
  /// In en, this message translates to:
  /// **'{embedded} embedded as images, {attachments} as separate attachments'**
  String bundleChecklistEmbedded(int embedded, int attachments);

  /// No description provided for @bundleChecklistEvents.
  ///
  /// In en, this message translates to:
  /// **'{count} chronology events'**
  String bundleChecklistEvents(int count);

  /// No description provided for @bundleConfirmCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I confirm this information is accurate and I have chosen which evidence to include.'**
  String get bundleConfirmCheckbox;

  /// No description provided for @bundleConfirmRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm before generating the bundle.'**
  String get bundleConfirmRequired;

  /// No description provided for @bundleGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate bundle PDF'**
  String get bundleGenerate;

  /// No description provided for @bundleGenerating.
  ///
  /// In en, this message translates to:
  /// **'Preparing your bundle…'**
  String get bundleGenerating;

  /// No description provided for @bundleGenerateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not generate the bundle. Please try again.'**
  String get bundleGenerateFailed;

  /// No description provided for @bundleCoverPreparedBy.
  ///
  /// In en, this message translates to:
  /// **'Prepared by'**
  String get bundleCoverPreparedBy;

  /// No description provided for @bundleGeneratedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated on'**
  String get bundleGeneratedOn;

  /// No description provided for @bundleDisclaimerHeading.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer and confirmation'**
  String get bundleDisclaimerHeading;

  /// No description provided for @bundleDisclaimerP1.
  ///
  /// In en, this message translates to:
  /// **'SewaBukti is an evidence-organisation and document-preparation tool. It is not a law firm, does not provide legal advice or representation, and does not guarantee repayment or court acceptance.'**
  String get bundleDisclaimerP1;

  /// No description provided for @bundleDisclaimerP2.
  ///
  /// In en, this message translates to:
  /// **'The person named on the cover prepared this bundle and confirms that the facts, dates, amounts, and party names it contains are accurate to the best of their knowledge.'**
  String get bundleDisclaimerP2;

  /// No description provided for @bundleDisclaimerP3.
  ///
  /// In en, this message translates to:
  /// **'Court rules, forms, fees, and limits may change. Confirm the current requirements with the relevant court registry.'**
  String get bundleDisclaimerP3;

  /// No description provided for @bundleProvenanceNote.
  ///
  /// In en, this message translates to:
  /// **'Headings, totals, and appendix numbers (SB-A##) are generated by SewaBukti. All other values were entered by the user.'**
  String get bundleProvenanceNote;

  /// No description provided for @bundleCaseSummaryHeading.
  ///
  /// In en, this message translates to:
  /// **'Case summary'**
  String get bundleCaseSummaryHeading;

  /// No description provided for @bundleTenancyPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Tenancy period'**
  String get bundleTenancyPeriodLabel;

  /// No description provided for @bundleEvidenceCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Evidence items included'**
  String get bundleEvidenceCountLabel;

  /// No description provided for @bundleEventCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Chronology events'**
  String get bundleEventCountLabel;

  /// No description provided for @bundlePartiesHeading.
  ///
  /// In en, this message translates to:
  /// **'Parties and property'**
  String get bundlePartiesHeading;

  /// No description provided for @bundlePropertyLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get bundlePropertyLabel;

  /// No description provided for @bundlePropertyHeading.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get bundlePropertyHeading;

  /// No description provided for @bundleClaimantHeading.
  ///
  /// In en, this message translates to:
  /// **'Claimant'**
  String get bundleClaimantHeading;

  /// No description provided for @bundleOtherPartyHeading.
  ///
  /// In en, this message translates to:
  /// **'Other party'**
  String get bundleOtherPartyHeading;

  /// No description provided for @bundleDepositHeading.
  ///
  /// In en, this message translates to:
  /// **'Deposit calculation'**
  String get bundleDepositHeading;

  /// No description provided for @bundleChronologyHeading.
  ///
  /// In en, this message translates to:
  /// **'Chronology of events'**
  String get bundleChronologyHeading;

  /// No description provided for @bundleChronologyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No chronology events were added.'**
  String get bundleChronologyEmpty;

  /// No description provided for @bundleChronologyRefsLabel.
  ///
  /// In en, this message translates to:
  /// **'Linked evidence'**
  String get bundleChronologyRefsLabel;

  /// No description provided for @bundleIndexHeading.
  ///
  /// In en, this message translates to:
  /// **'Evidence index'**
  String get bundleIndexHeading;

  /// No description provided for @bundleIndexIntro.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s) included in this bundle.'**
  String bundleIndexIntro(int count);

  /// No description provided for @bundleColAppendix.
  ///
  /// In en, this message translates to:
  /// **'Appendix'**
  String get bundleColAppendix;

  /// No description provided for @bundleColItem.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get bundleColItem;

  /// No description provided for @bundleColCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get bundleColCategory;

  /// No description provided for @bundleColDocDate.
  ///
  /// In en, this message translates to:
  /// **'Document date'**
  String get bundleColDocDate;

  /// No description provided for @bundleColUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get bundleColUploaded;

  /// No description provided for @bundleColType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get bundleColType;

  /// No description provided for @bundleEmbeddedType.
  ///
  /// In en, this message translates to:
  /// **'Embedded image'**
  String get bundleEmbeddedType;

  /// No description provided for @bundleAttachmentType.
  ///
  /// In en, this message translates to:
  /// **'Separate file'**
  String get bundleAttachmentType;

  /// No description provided for @bundleSecTenancy.
  ///
  /// In en, this message translates to:
  /// **'Tenancy agreement'**
  String get bundleSecTenancy;

  /// No description provided for @bundleSecDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit payment evidence'**
  String get bundleSecDeposit;

  /// No description provided for @bundleSecHandover.
  ///
  /// In en, this message translates to:
  /// **'Handover and property-condition evidence'**
  String get bundleSecHandover;

  /// No description provided for @bundleSecUtility.
  ///
  /// In en, this message translates to:
  /// **'Utility evidence'**
  String get bundleSecUtility;

  /// No description provided for @bundleSecComms.
  ///
  /// In en, this message translates to:
  /// **'Communications'**
  String get bundleSecComms;

  /// No description provided for @bundleSecDeduction.
  ///
  /// In en, this message translates to:
  /// **'Deduction and expense evidence'**
  String get bundleSecDeduction;

  /// No description provided for @bundleSecDemand.
  ///
  /// In en, this message translates to:
  /// **'Demand letter and delivery evidence'**
  String get bundleSecDemand;

  /// No description provided for @bundleSecOther.
  ///
  /// In en, this message translates to:
  /// **'Other evidence'**
  String get bundleSecOther;

  /// No description provided for @bundleEvidenceMainHeading.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get bundleEvidenceMainHeading;

  /// No description provided for @bundleAttachmentNotice.
  ///
  /// In en, this message translates to:
  /// **'This file is provided as a separate attachment and is not embedded in this bundle.'**
  String get bundleAttachmentNotice;

  /// No description provided for @bundleImageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This image could not be embedded and is provided as a separate attachment.'**
  String get bundleImageUnavailable;

  /// No description provided for @bundleFileLabel.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get bundleFileLabel;

  /// No description provided for @bundleSha256Label.
  ///
  /// In en, this message translates to:
  /// **'SHA-256'**
  String get bundleSha256Label;

  /// No description provided for @bundleFooterDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This bundle was prepared by the sender using SewaBukti, an evidence-organisation and document-preparation tool. It is general in nature, is not legal advice, and was not issued by a lawyer.'**
  String get bundleFooterDisclaimer;

  /// No description provided for @legalReviewBanner.
  ///
  /// In en, this message translates to:
  /// **'Draft for beta — pending professional legal review. The English version prevails.'**
  String get legalReviewBanner;

  /// No description provided for @claimRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Claim route'**
  String get claimRouteTitle;

  /// No description provided for @claimRouteOpenGuidance.
  ///
  /// In en, this message translates to:
  /// **'Open official judiciary guidance'**
  String get claimRouteOpenGuidance;

  /// No description provided for @claimRouteGuidanceNote.
  ///
  /// In en, this message translates to:
  /// **'The court and official portal depend on where you would file. Open the guidance for your region:'**
  String get claimRouteGuidanceNote;

  /// No description provided for @regionPeninsular.
  ///
  /// In en, this message translates to:
  /// **'Peninsular Malaysia'**
  String get regionPeninsular;

  /// No description provided for @regionSabahSarawak.
  ///
  /// In en, this message translates to:
  /// **'Sabah & Sarawak'**
  String get regionSabahSarawak;

  /// No description provided for @claimRouteAboveCeiling.
  ///
  /// In en, this message translates to:
  /// **'This claim of {amount} is above the {ceiling} small-claims ceiling. It likely needs ordinary civil proceedings rather than the Small Claims Court — consider consulting the court registry or a lawyer.'**
  String claimRouteAboveCeiling(String amount, String ceiling);

  /// No description provided for @dashboardClaimRoute.
  ///
  /// In en, this message translates to:
  /// **'Claim route'**
  String get dashboardClaimRoute;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @deleteCaseConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this case?'**
  String get deleteCaseConfirmTitle;

  /// No description provided for @deleteCaseConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your case, its evidence, and chronology. This cannot be undone.'**
  String get deleteCaseConfirmBody;

  /// No description provided for @caseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Case deleted.'**
  String get caseDeleted;

  /// No description provided for @deleteCaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the case. Please try again.'**
  String get deleteCaseFailed;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and all application data, including your case and evidence. This cannot be undone.'**
  String get deleteAccountConfirmBody;

  /// No description provided for @deleteAccountAck.
  ///
  /// In en, this message translates to:
  /// **'I understand this permanently deletes my account and data.'**
  String get deleteAccountAck;

  /// No description provided for @deleteAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountAction;

  /// No description provided for @accountDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your account. Please try again.'**
  String get accountDeleteFailed;

  /// No description provided for @exportReady.
  ///
  /// In en, this message translates to:
  /// **'Your case data export has been downloaded.'**
  String get exportReady;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export your data. Please try again.'**
  String get exportFailed;

  /// No description provided for @betaFull.
  ///
  /// In en, this message translates to:
  /// **'The SewaBukti beta is currently full. Please try again later.'**
  String get betaFull;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ms', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ms':
      return AppLocalizationsMs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
