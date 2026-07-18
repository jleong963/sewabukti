/// Public, browser-safe build configuration.
///
/// Only values explicitly permitted in the Flutter build may live here
/// (requirements §7.3 "Flutter build configuration"). Every value compiled
/// into Flutter Web is inspectable by a browser user, so server-side secrets
/// (Vercel / Supabase service-role / Turso tokens / Gmail app password) must
/// NEVER be referenced from client code (§8.1 security boundary).
///
/// Values are injected at build time with `--dart-define` /
/// `--dart-define-from-file` (see `.env.example`).
class AppConfig {
  const AppConfig._();

  /// Environment name such as `production` (defaults to development locally).
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  /// Public Supabase project URL. Intended for browser use; it does NOT
  /// authenticate a SewaBukti user and storage denies anonymous access.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase publishable / anonymous key. Public by design (§7.3): treating
  /// it as hidden is not a security control.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Public Google OAuth web client id. Also the expected ID-token audience
  /// verified server-side (FR-AUTH-07).
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_OAUTH_CLIENT_ID',
  );

  /// Client keep-alive ping interval, in seconds (0 disables). Sourced from the
  /// `KEEPALIVE_INTERVAL_SECONDS` GitHub Actions Variable via `--dart-define`.
  /// Keeps the Supabase project warm while the app is open; a scheduled
  /// workflow covers zero-user periods.
  static const int keepAliveIntervalSeconds = int.fromEnvironment(
    'KEEPALIVE_INTERVAL_SECONDS',
  );

  /// Auto-logout a signed-in user after this many seconds of no interaction
  /// (0 disables). Sourced from the `INACTIVE_TIMEOUT` GitHub Actions Variable
  /// via `--dart-define`. Enforced client-side only (a convenience/hygiene
  /// control, not a server session guard).
  static const int inactiveTimeoutSeconds = int.fromEnvironment(
    'INACTIVE_TIMEOUT',
  );

  static bool get isProduction => appEnv == 'production';

  /// Whether real Google Identity Services sign-in can be initialised.
  static bool get hasGoogleClientId => googleClientId.isNotEmpty;

  /// Whether backend calls can be made (Supabase Edge Functions reachable).
  static bool get hasBackend => supabaseUrl.isNotEmpty;
}
