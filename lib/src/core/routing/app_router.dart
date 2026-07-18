import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sewabukti/src/core/auth/auth_controller.dart';
import 'package:sewabukti/src/core/routing/routes.dart';
import 'package:sewabukti/src/features/cases/case_wizard_page.dart';
import 'package:sewabukti/src/features/bundle/evidence_bundle_page.dart';
import 'package:sewabukti/src/features/chronology/chronology_page.dart';
import 'package:sewabukti/src/features/dashboard/dashboard_page.dart';
import 'package:sewabukti/src/features/demand_letter/demand_letter_page.dart';
import 'package:sewabukti/src/features/evidence/evidence_page.dart';
import 'package:sewabukti/src/features/landing/landing_page.dart';
import 'package:sewabukti/src/features/legal/legal_info_page.dart';
import 'package:sewabukti/src/features/route/claim_route_page.dart';
import 'package:sewabukti/src/features/settings/settings_page.dart';

/// App router. Unauthenticated users are kept on the landing/sign-in page;
/// authenticated users are redirected away from it to the dashboard
/// (FR-CASE-05 ownership is enforced server-side; this is only navigation).
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  // Bridge Riverpod auth changes to go_router's refresh mechanism.
  final ValueNotifier<bool> refresh = ValueNotifier<bool>(
    ref.read(authControllerProvider).isSignedIn,
  );
  ref.onDispose(refresh.dispose);
  ref.listen<AuthState>(
    authControllerProvider,
    (AuthState? _, AuthState next) => refresh.value = next.isSignedIn,
  );

  return GoRouter(
    initialLocation: Routes.landing,
    refreshListenable: refresh,
    redirect: (_, GoRouterState state) {
      final bool signedIn = ref.read(authControllerProvider).isSignedIn;
      final bool isPublic = Routes.publicRoutes.contains(state.matchedLocation);
      // Unauthenticated users may only see public pages (landing + legal/info).
      if (!signedIn) return isPublic ? null : Routes.landing;
      // Authenticated users are sent from the landing/sign-in page to the app.
      if (state.matchedLocation == Routes.landing) return Routes.dashboard;
      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: Routes.landing, builder: (_, _) => const LandingPage()),
      GoRoute(path: Routes.dashboard, builder: (_, _) => const DashboardPage()),
      GoRoute(
        path: Routes.caseWizard,
        builder: (_, _) => const CaseWizardPage(),
      ),
      GoRoute(
        path: Routes.evidence,
        builder: (_, _) => const CaseEvidencePage(),
      ),
      GoRoute(
        path: Routes.chronology,
        builder: (_, _) => const CaseChronologyPage(),
      ),
      GoRoute(
        path: Routes.demandLetter,
        builder: (_, _) => const DemandLetterPage(),
      ),
      GoRoute(
        path: Routes.evidenceBundle,
        builder: (_, _) => const EvidenceBundlePage(),
      ),
      GoRoute(
        path: Routes.claimRoute,
        builder: (_, _) => const ClaimRoutePage(),
      ),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsPage()),
      GoRoute(
        path: Routes.privacy,
        builder: (_, _) => const PrivacyPolicyPage(),
      ),
      GoRoute(path: Routes.terms, builder: (_, _) => const TermsOfUsePage()),
      GoRoute(path: Routes.help, builder: (_, _) => const HelpPage()),
    ],
  );
});
