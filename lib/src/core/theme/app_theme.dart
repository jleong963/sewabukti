import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Sea-blue Material 3 theme for light and dark display modes (§9.3, §9.4).
///
/// Both modes use the same sea-blue brand palette. Typography is Noto Sans with
/// Noto Sans SC as a fallback so Latin and Simplified Chinese render
/// consistently (§9.3).
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final ColorScheme scheme = _scheme(brightness);
    final ThemeData base = ThemeData(colorScheme: scheme);
    final TextTheme textTheme = _textTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: isLight
          ? SeaBlue.backgroundLight
          : SeaBlue.backgroundDark,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[
        isLight ? SbColors.light : SbColors.dark,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ColorScheme _scheme(Brightness brightness) {
    if (brightness == Brightness.light) {
      return ColorScheme.fromSeed(
        seedColor: SeaBlue.primaryLight,
        brightness: Brightness.light,
      ).copyWith(
        primary: SeaBlue.primaryLight,
        onPrimary: const Color(0xFFFFFFFF),
        primaryContainer: SeaBlue.paleLight,
        onPrimaryContainer: SeaBlue.deepLight,
        secondary: SeaBlue.deepLight,
        onSecondary: const Color(0xFFFFFFFF),
        surface: SeaBlue.surfaceLight,
        onSurface: SeaBlue.primaryTextLight,
        onSurfaceVariant: SeaBlue.secondaryTextLight,
        error: SeaBlue.errorLight,
        onError: const Color(0xFFFFFFFF),
        outline: const Color(0xFFB7C7CC),
        outlineVariant: const Color(0xFFDCE7EA),
      );
    }
    return ColorScheme.fromSeed(
      seedColor: SeaBlue.primaryDark,
      brightness: Brightness.dark,
    ).copyWith(
      primary: SeaBlue.primaryDark,
      onPrimary: const Color(0xFF00323B),
      primaryContainer: SeaBlue.paleDark,
      onPrimaryContainer: SeaBlue.deepDark,
      secondary: SeaBlue.deepDark,
      onSecondary: const Color(0xFF00323B),
      surface: SeaBlue.surfaceDark,
      onSurface: SeaBlue.primaryTextDark,
      onSurfaceVariant: SeaBlue.secondaryTextDark,
      error: SeaBlue.errorDark,
      onError: const Color(0xFF601410),
      outline: const Color(0xFF41565B),
      outlineVariant: const Color(0xFF2A393D),
    );
  }

  /// Noto Sans body/UI type with a Noto Sans SC fallback for CJK glyphs.
  static TextTheme _textTheme(TextTheme base) {
    final TextTheme noto = GoogleFonts.notoSansTextTheme(base);
    final String? scFamily = GoogleFonts.notoSansSc().fontFamily;
    final List<String> fallback = <String>[?scFamily];

    TextStyle? withFallback(TextStyle? style) =>
        style?.copyWith(fontFamilyFallback: fallback);

    return TextTheme(
      displayLarge: withFallback(noto.displayLarge),
      displayMedium: withFallback(noto.displayMedium),
      displaySmall: withFallback(noto.displaySmall),
      headlineLarge: withFallback(noto.headlineLarge),
      headlineMedium: withFallback(noto.headlineMedium),
      headlineSmall: withFallback(noto.headlineSmall),
      titleLarge: withFallback(noto.titleLarge),
      titleMedium: withFallback(noto.titleMedium),
      titleSmall: withFallback(noto.titleSmall),
      bodyLarge: withFallback(noto.bodyLarge),
      bodyMedium: withFallback(noto.bodyMedium),
      bodySmall: withFallback(noto.bodySmall),
      labelLarge: withFallback(noto.labelLarge),
      labelMedium: withFallback(noto.labelMedium),
      labelSmall: withFallback(noto.labelSmall),
    );
  }
}
