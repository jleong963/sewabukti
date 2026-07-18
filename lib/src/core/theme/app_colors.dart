import 'package:flutter/material.dart';

/// Sea-blue brand palette raw tokens (§9.3). Sea blue is the dominant brand
/// colour in both display modes. The palette may be fine-tuned during
/// implementation to meet WCAG 2.1 AA contrast (§9.3).
class SeaBlue {
  const SeaBlue._();

  // Light mode
  static const Color primaryLight = Color(0xFF007C91);
  static const Color deepLight = Color(0xFF005B6B);
  static const Color paleLight = Color(0xFFE6F7FA);
  static const Color backgroundLight = Color(0xFFF7FAFB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color primaryTextLight = Color(0xFF172B33);
  static const Color secondaryTextLight = Color(0xFF52666D);
  static const Color errorLight = Color(0xFFB3261E); // accessible dark red
  static const Color successLight = Color(0xFF1E7B4F); // accessible dark green

  // Dark mode
  static const Color primaryDark = Color(0xFF33B5C7);
  static const Color deepDark = Color(0xFF8DDCE6);
  static const Color paleDark = Color(0xFF12343B);
  static const Color backgroundDark = Color(0xFF0E171A);
  static const Color surfaceDark = Color(0xFF172226);
  static const Color primaryTextDark = Color(0xFFF1F7F8);
  static const Color secondaryTextDark = Color(0xFFB5C6CA);
  static const Color errorDark = Color(0xFFF2B8B5); // accessible light red
  static const Color successDark = Color(0xFF6FD99B); // accessible light green
}

/// Brand tokens that do not map cleanly onto Material's [ColorScheme],
/// exposed to widgets through [Theme]. Access with `context.sb`.
///
/// Semantic states (error/success) must not rely on colour alone (§9.2),
/// so pair these with an icon or text label at the call site.
@immutable
class SbColors extends ThemeExtension<SbColors> {
  const SbColors({
    required this.deepSeaBlue,
    required this.paleSeaBlue,
    required this.onPaleSeaBlue,
    required this.success,
    required this.onSuccess,
  });

  /// Headings and high-emphasis accents.
  final Color deepSeaBlue;

  /// Selected surfaces and informational panels.
  final Color paleSeaBlue;
  final Color onPaleSeaBlue;

  /// Successful actions and completion.
  final Color success;
  final Color onSuccess;

  static const SbColors light = SbColors(
    deepSeaBlue: SeaBlue.deepLight,
    paleSeaBlue: SeaBlue.paleLight,
    onPaleSeaBlue: SeaBlue.deepLight,
    success: SeaBlue.successLight,
    onSuccess: Color(0xFFFFFFFF),
  );

  static const SbColors dark = SbColors(
    deepSeaBlue: SeaBlue.deepDark,
    paleSeaBlue: SeaBlue.paleDark,
    onPaleSeaBlue: SeaBlue.deepDark,
    success: SeaBlue.successDark,
    onSuccess: Color(0xFF00391F),
  );

  @override
  SbColors copyWith({
    Color? deepSeaBlue,
    Color? paleSeaBlue,
    Color? onPaleSeaBlue,
    Color? success,
    Color? onSuccess,
  }) {
    return SbColors(
      deepSeaBlue: deepSeaBlue ?? this.deepSeaBlue,
      paleSeaBlue: paleSeaBlue ?? this.paleSeaBlue,
      onPaleSeaBlue: onPaleSeaBlue ?? this.onPaleSeaBlue,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
    );
  }

  @override
  SbColors lerp(SbColors? other, double t) {
    if (other == null) return this;
    return SbColors(
      deepSeaBlue: Color.lerp(deepSeaBlue, other.deepSeaBlue, t)!,
      paleSeaBlue: Color.lerp(paleSeaBlue, other.paleSeaBlue, t)!,
      onPaleSeaBlue: Color.lerp(onPaleSeaBlue, other.onPaleSeaBlue, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
    );
  }
}

/// Convenience accessor for brand tokens: `context.sb.deepSeaBlue`.
extension SbColorsX on BuildContext {
  SbColors get sb => Theme.of(this).extension<SbColors>()!;
}
