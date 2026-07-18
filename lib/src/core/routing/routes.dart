/// Named route paths for the app (§10 screens).
class Routes {
  const Routes._();

  /// Landing page is also the sign-in page (§10.1).
  static const String landing = '/';
  static const String dashboard = '/dashboard';
  static const String caseWizard = '/case';
  static const String evidence = '/evidence';
  static const String chronology = '/chronology';
  static const String demandLetter = '/demand-letter';
  static const String evidenceBundle = '/evidence-bundle';
  static const String claimRoute = '/route';
  static const String settings = '/settings';

  /// Legal / informational pages (§10.9). Public — readable before sign-in.
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String help = '/help';

  /// Routes viewable without authentication (landing + legal/info pages).
  static const Set<String> publicRoutes = <String>{
    landing,
    privacy,
    terms,
    help,
  };
}
