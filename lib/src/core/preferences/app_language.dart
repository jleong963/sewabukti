import 'dart:ui' show Locale;

/// MVP languages and locale identifiers (§18). English is the default and the
/// guaranteed fallback (FR-PREF-01, FR-PREF-12).
///
/// [code] is the value persisted locally and in the user profile
/// (`users.preferred_language`, §13.1): `en`, `ms`, or `zh-Hans`. Simplified
/// Chinese resolves to the Flutter [Locale] `zh`, whose glyphs render via the
/// Noto Sans SC font fallback.
enum AppLanguage {
  en('en', 'English', Locale('en')),
  ms('ms', 'Bahasa Melayu', Locale('ms')),
  zhHans('zh-Hans', '简体中文', Locale('zh'));

  const AppLanguage(this.code, this.endonym, this.locale);

  /// Persistence / profile code (matches `users.preferred_language`).
  final String code;

  /// Native-language label shown in the language selector (§10.1).
  final String endonym;

  /// The Flutter [Locale] this language resolves to.
  final Locale locale;

  static AppLanguage fromCode(String? code) => AppLanguage.values.firstWhere(
    (AppLanguage l) => l.code == code,
    orElse: () => AppLanguage.en,
  );

  static AppLanguage fromLocale(Locale locale) => switch (locale.languageCode) {
    'ms' => AppLanguage.ms,
    'zh' => AppLanguage.zhHans,
    _ => AppLanguage.en,
  };
}
