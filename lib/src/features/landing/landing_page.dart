import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sewabukti/src/core/auth/auth_controller.dart';
import 'package:sewabukti/src/core/auth/google/gis.dart';
import 'package:sewabukti/src/core/config/app_config.dart';
import 'package:sewabukti/src/core/routing/routes.dart';
import 'package:sewabukti/src/core/session/inactivity_service.dart';
import 'package:sewabukti/src/core/preferences/app_language.dart';
import 'package:sewabukti/src/core/preferences/preferences_providers.dart';
import 'package:sewabukti/src/core/theme/app_colors.dart';
import 'package:sewabukti/src/features/shared/widgets/app_wordmark.dart';
import 'package:sewabukti/src/features/shared/widgets/language_selector.dart';
import 'package:sewabukti/src/features/shared/widgets/legal_notice.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// Landing page, which is also the sign-in page (§10.1). It explains why
/// sensitive documents are requested before offering the single Google
/// sign-in option — it must not be only a Google button (§10.1).
class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  static const double _wideBreakpoint = 720;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top bar: wordmark + pre-auth language selector (FR-PREF-02).
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: <Widget>[
                  const AppWordmark(),
                  const Spacer(),
                  const LanguageSelector(),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints c) {
                          final bool wide = c.maxWidth >= _wideBreakpoint;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              _Hero(l10n: l10n),
                              const SizedBox(height: 40),
                              _HowItWorks(l10n: l10n, wide: wide),
                              const SizedBox(height: 32),
                              _InfoCards(l10n: l10n, wide: wide),
                              const SizedBox(height: 40),
                              _SignInArea(l10n: l10n),
                              const SizedBox(height: 32),
                              const _Footer(),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const AppWordmark(markSize: 48),
        const SizedBox(height: 20),
        Text(
          l10n.appTagline,
          style: text.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.sb.deepSeaBlue,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            l10n.landingIntro,
            style: text.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks({required this.l10n, required this.wide});

  final AppLocalizations l10n;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final List<Widget> cards = <Widget>[
      _StepCard(
        step: 1,
        icon: Icons.folder_copy_outlined,
        title: l10n.stepCompileTitle,
        body: l10n.stepCompileBody,
      ),
      _StepCard(
        step: 2,
        icon: Icons.mail_outline,
        title: l10n.stepDemandTitle,
        body: l10n.stepDemandBody,
      ),
      _StepCard(
        step: 3,
        icon: Icons.inventory_2_outlined,
        title: l10n.stepPrepareTitle,
        body: l10n.stepPrepareBody,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.howItWorksTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        if (wide)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < cards.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(width: 16),
                  Expanded(child: cards[i]),
                ],
              ],
            ),
          )
        else
          Column(
            children: <Widget>[
              for (int i = 0; i < cards.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: 12),
                cards[i],
              ],
            ],
          ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.icon,
    required this.title,
    required this.body,
  });

  final int step;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.sb.paleSeaBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: context.sb.onPaleSeaBlue),
            ),
            const SizedBox(height: 16),
            Text(
              '$step. $title',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: text.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCards extends StatelessWidget {
  const _InfoCards({required this.l10n, required this.wide});

  final AppLocalizations l10n;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final Widget privacy = _InfoCard(
      icon: Icons.lock_outline,
      title: l10n.privacySummaryTitle,
      body: l10n.privacySummaryBody,
    );
    final Widget disclaimer = _InfoCard(
      icon: Icons.gpp_maybe_outlined,
      title: l10n.disclaimerSummaryTitle,
      body: l10n.disclaimerSummaryBody,
    );

    if (wide) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(child: privacy),
            const SizedBox(width: 16),
            Expanded(child: disclaimer),
          ],
        ),
      );
    }

    return Column(
      children: <Widget>[privacy, const SizedBox(height: 12), disclaimer],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: text.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignInArea extends ConsumerStatefulWidget {
  const _SignInArea({required this.l10n});

  final AppLocalizations l10n;

  @override
  ConsumerState<_SignInArea> createState() => _SignInAreaState();
}

class _SignInAreaState extends ConsumerState<_SignInArea> {
  // The only Google-branded button ever shown is the official GIS-rendered one,
  // which always follows the current Google branding guideline (including the
  // 2025 gradient "G") and uses Google Sans. It is used on web with a
  // configured client id; otherwise a neutral, non-Google preview control is
  // shown (dev / tests). A custom Google button is intentionally NOT used, as it
  // could not reproduce the current logo exactly (§10.1.1).
  late final bool _useGis = Gis.isSupported && AppConfig.hasGoogleClientId;
  bool _gisReady = false;
  bool _gisError = false;

  @override
  void initState() {
    super.initState();
    if (_useGis) _initGis();
  }

  Future<void> _initGis() async {
    try {
      await Gis.initialize(
        clientId: AppConfig.googleClientId,
        onCredential: (String idToken) {
          if (!mounted) return;
          ref.read(authControllerProvider.notifier).signInWithIdToken(idToken);
        },
      );
      if (mounted) setState(() => _gisReady = true);
    } catch (_) {
      // GIS script failed to load; surface a retry rather than a stuck spinner.
      if (mounted) setState(() => _gisError = true);
    }
  }

  void _retryGis() {
    setState(() {
      _gisError = false;
      _gisReady = false;
    });
    _initGis();
  }

  static String _gisLocale(AppLanguage language) => switch (language) {
    AppLanguage.en => 'en',
    AppLanguage.ms => 'ms',
    AppLanguage.zhHans => 'zh_CN',
  };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = widget.l10n;
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AuthState auth = ref.watch(authControllerProvider);
    final bool isDark = ref.watch(
      themeModeControllerProvider.select((ThemeMode m) => m == ThemeMode.dark),
    );
    final AppLanguage language = ref.watch(
      localeControllerProvider.select(AppLanguage.fromLocale),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const LegalServiceNotice(),
        const SizedBox(height: 20),
        Text(
          l10n.googleSignInHint,
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Center(child: _buildButton(l10n, isDark, language)),
        if (auth.isAuthenticating) ...<Widget>[
          const SizedBox(height: 14),
          const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
        if (auth.errorCode != null && !auth.isAuthenticating) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            switch (auth.errorCode) {
              kInactiveTimeoutReason => l10n.inactiveSignedOut,
              'beta_full' => l10n.betaFull,
              _ => l10n.signInFailed,
            },
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(
              // Inactivity is an expected, non-error outcome — show it neutrally.
              color: auth.errorCode == kInactiveTimeoutReason
                  ? scheme.onSurfaceVariant
                  : scheme.error,
            ),
          ),
        ],
        if (!_useGis) ...<Widget>[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.construction_outlined,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.previewBuildNotice,
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildButton(
    AppLocalizations l10n,
    bool isDark,
    AppLanguage language,
  ) {
    if (_useGis) {
      if (_gisError) {
        return SizedBox(
          width: 320,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: _retryGis,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l10n.signInFailed),
          ),
        );
      }
      if (!_gisReady) {
        return const SizedBox(
          width: 320,
          height: 44,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }
      return Gis.button(
        isDark: isDark,
        locale: _gisLocale(language),
        width: 320,
      );
    }
    // Neutral, non-Google-branded preview control (no Google logo, colours, or
    // official CTA) — used only when GIS is unavailable (dev / tests).
    return SizedBox(
      width: 320,
      height: 44,
      child: OutlinedButton(
        onPressed: () =>
            ref.read(authControllerProvider.notifier).signInWithPlaceholder(),
        child: Text(l10n.previewSignIn),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        TextButton(
          onPressed: () => context.push(Routes.privacy),
          child: Text(l10n.privacyPolicy),
        ),
        const Text('·'),
        TextButton(
          onPressed: () => context.push(Routes.terms),
          child: Text(l10n.termsOfUse),
        ),
        const Text('·'),
        TextButton(
          onPressed: () => context.push(Routes.help),
          child: Text(l10n.help),
        ),
      ],
    );
  }
}
