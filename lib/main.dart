import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sewabukti/src/app.dart';
import 'package:sewabukti/src/core/preferences/preferences_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Locale date symbols for en/ms/zh date formatting (§18).
  await initializeDateFormatting();

  // Load preferences before first paint so the saved language and display mode
  // can be applied immediately (§9.4).
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const SewaBuktiApp(),
    ),
  );
}
