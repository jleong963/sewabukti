import 'dart:ui' show Locale;

import 'package:intl/intl.dart';

/// Currency and date formatting per §18: Malaysian Ringgit with two decimals,
/// and unambiguous localised dates (`12 July 2026`, `12 Julai 2026`,
/// `2026年7月12日`).

/// Formats integer sen as `RM 1,234.56`.
String formatRmFromSen(int sen) {
  final double rm = sen / 100.0;
  return 'RM ${NumberFormat('#,##0.00').format(rm)}';
}

/// Parses a user-entered RM amount (e.g. `1500`, `1,500.50`, `RM 1500.5`) into
/// sen. Returns null when empty or not a valid non-negative number.
int? parseRmToSen(String input) {
  final String cleaned = input
      .replaceAll('RM', '')
      .replaceAll(',', '')
      .replaceAll(RegExp(r'\s'), '')
      .trim();
  if (cleaned.isEmpty) return null;
  final double? value = double.tryParse(cleaned);
  if (value == null || value < 0 || value.isNaN || value.isInfinite) {
    return null;
  }
  return (value * 100).round();
}

/// Localised long date from an ISO `yyyy-MM-dd` string, per the app locale.
String formatIsoDate(String? iso, Locale locale) {
  if (iso == null || iso.isEmpty) return '';
  final DateTime? date = DateTime.tryParse(iso);
  if (date == null) return iso;
  final String lang = locale.languageCode;
  // Chinese uses year-first (2026年7月12日); English/Malay use day-first.
  final DateFormat format = lang == 'zh'
      ? DateFormat.yMMMMd('zh')
      : DateFormat('d MMMM y', lang);
  return format.format(date);
}

/// ISO `yyyy-MM-dd` for storage.
String toIsoDate(DateTime date) {
  final String y = date.year.toString().padLeft(4, '0');
  final String m = date.month.toString().padLeft(2, '0');
  final String d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
