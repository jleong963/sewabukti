/// Configurable legal / procedural content and official links.
///
/// Per §6.3 and §147, displayed legal limits and links must be stored as
/// configurable content rather than hard-coded throughout the application, so
/// they can be reviewed before each release (values may change).
///
/// NOTE (open decision §23.7): the specific official judiciary pages for
/// Peninsular Malaysia, Sabah, and Sarawak are still to be confirmed. The URLs
/// below are placeholders pending that decision and legal review (§18).
class LegalConfig {
  const LegalConfig._();

  /// Small Claims eligibility ceiling for an individual claimant, in RM (§6.3).
  static const int smallClaimsCeilingRm = 5000;

  /// Current small-claim writ form, subject to official confirmation (§10.7).
  static const String smallClaimFormName = 'Form 198';

  /// Official judiciary links (§10.7, §23.7), confirmed on the official
  /// `kehakiman.gov.my` domain (verified 2026-07-17). Sabah and Sarawak share
  /// one High Court and the e-KSS e-court system, so they use one link.
  ///
  /// National Office of the Chief Registrar of the Federal Court portal.
  static const String judiciaryPortalUrl = 'https://www.kehakiman.gov.my/';

  /// Peninsular Malaysia — civil case procedures, incl. small claims (RM5,000).
  static const String judiciaryPeninsularUrl =
      'https://www.kehakiman.gov.my/en/procedures-civil-cases';

  /// Sabah & Sarawak — e-Kehakiman Sabah dan Sarawak (e-KSS) self-represented
  /// portal, incl. small-claims guidance and e-filing.
  static const String judiciarySabahSarawakUrl =
      'https://ekss-portal.kehakiman.gov.my/portals/web/home/self_represented';

  /// Retention window after a user deletes their case or account, before
  /// storage objects and soft-deleted records are permanently purged
  /// (§23.3 decision: 30 days; NFR-SEC-15 "within a documented period").
  static const int deletionPurgeDays = 30;

  /// In-app document routes (content authored in Phase 6).
  static const String privacyPolicyRoute = '/privacy';
  static const String termsOfUseRoute = '/terms';
  static const String helpRoute = '/help';

  /// Support/contact inbox shown in the Privacy Policy, Help page, and email
  /// footers (§17). A free Gmail inbox — no custom domain yet, to stay card-free.
  static const String supportEmail = 'deskcontact5@gmail.com';
}
