import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

/// Concrete [SharedPreferences] instance, supplied via a `ProviderScope`
/// override in `main()` after prefs load. This lets the preferred language and
/// display mode be applied before first paint, without a page reload
/// (§9.4, FR-PREF-04, FR-PREF-10).
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>(
      (Ref ref) => throw UnimplementedError(
        'sharedPreferencesProvider must be overridden in main()',
      ),
    );

const String _kLanguageKey = 'preferred_language';
const String _kThemeModeKey = 'theme_mode';

/// Current UI locale. First visit defaults to English (FR-PREF-01); an invalid
/// or missing stored value also falls back to English (FR-PREF-12).
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final String? code = ref
        .read(sharedPreferencesProvider)
        .getString(_kLanguageKey);
    return AppLanguage.fromCode(code).locale;
  }

  AppLanguage get current => AppLanguage.fromLocale(state);

  /// Changes the language and persists it locally (FR-PREF-05). The change is
  /// applied immediately because widgets watch this provider (FR-PREF-04).
  /// While signed in, Settings additionally syncs the selection to the user
  /// profile via `AuthController.syncPreferences` (FR-PREF-06).
  Future<void> setLanguage(AppLanguage language) async {
    state = language.locale;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_kLanguageKey, language.code);
  }
}

final NotifierProvider<LocaleController, Locale> localeControllerProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);

/// Current display mode. Light is the default (FR-PREF-08); only light and dark
/// are offered in the MVP (§9.4). A missing/invalid value falls back to light
/// (FR-PREF-12).
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final String? value = ref
        .read(sharedPreferencesProvider)
        .getString(_kThemeModeKey);
    return value == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDark => state == ThemeMode.dark;

  /// Applies the display mode immediately and persists it locally so it can be
  /// restored before the profile loads (§9.4, FR-PREF-10). While signed in,
  /// Settings additionally syncs it to the user profile via
  /// `AuthController.syncPreferences` (FR-PREF-11).
  Future<void> setDark(bool dark) async {
    state = dark ? ThemeMode.dark : ThemeMode.light;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_kThemeModeKey, dark ? 'dark' : 'light');
  }

  void toggle() => setDark(state != ThemeMode.dark);
}

final NotifierProvider<ThemeModeController, ThemeMode>
themeModeControllerProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
