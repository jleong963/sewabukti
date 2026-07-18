import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sewabukti/src/core/keepalive/keep_alive_service.dart';
import 'package:sewabukti/src/core/preferences/preferences_providers.dart';
import 'package:sewabukti/src/core/session/inactivity_guard.dart';
import 'package:sewabukti/src/core/routing/app_router.dart';
import 'package:sewabukti/src/core/theme/app_theme.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// Root application widget. Wires the sea-blue light/dark themes, the persisted
/// locale and display mode, localisation delegates, and the router. Starts the
/// keep-alive heartbeat and inactivity auto-logout (both no-op unless
/// configured).
class SewaBuktiApp extends ConsumerStatefulWidget {
  const SewaBuktiApp({super.key});

  @override
  ConsumerState<SewaBuktiApp> createState() => _SewaBuktiAppState();
}

class _SewaBuktiAppState extends ConsumerState<SewaBuktiApp> {
  @override
  void initState() {
    super.initState();
    ref.read(keepAliveServiceProvider).start();
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(routerProvider);
    final Locale locale = ref.watch(localeControllerProvider);
    final ThemeMode themeMode = ref.watch(themeModeControllerProvider);

    return InactivityGuard(
      child: MaterialApp.router(
        onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context).appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    );
  }
}
