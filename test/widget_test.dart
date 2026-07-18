import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sewabukti/src/app.dart';
import 'package:sewabukti/src/core/preferences/preferences_providers.dart';

void main() {
  setUp(() {
    // Do not hit the network for fonts during tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Landing page shows the wordmark and Google sign-in CTA', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SewaBuktiApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Landing must explain the product, not be only a Google button (§10.1).
    // In the VM test GIS is unavailable, so the neutral preview control shows
    // (the official Google-branded button only renders on web via the GIS SDK).
    expect(find.text('SewaBukti'), findsWidgets);
    expect(find.text('How it works'), findsOneWidget);
    expect(find.text('Continue (preview)'), findsOneWidget);
  });
}
