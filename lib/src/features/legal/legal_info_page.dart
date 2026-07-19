import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sewabukti/src/core/legal/legal_content.dart';
import 'package:sewabukti/src/core/preferences/app_language.dart';
import 'package:sewabukti/src/core/routing/routes.dart';
import 'package:sewabukti/src/features/shared/widgets/language_selector.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// Renders an [InfoDocument] (privacy, terms, help, or claim route) with a
/// consistent layout: an optional "pending legal review" banner, an intro, then
/// headed sections of paragraphs and bullets, and a footer.
class InfoView extends StatelessWidget {
  const InfoView({super.key, required this.document, this.leading});

  final InfoDocument document;

  /// Optional widget shown above the document body (e.g. the claimed amount).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (leading != null) ...<Widget>[
                  leading!,
                  const SizedBox(height: 16),
                ],
                if (document.reviewPending) ...<Widget>[
                  _Banner(text: l10n.legalReviewBanner),
                  const SizedBox(height: 16),
                ],
                if (document.intro != null) ...<Widget>[
                  Text(
                    document.intro!,
                    style: text.bodyLarge?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 16),
                ],
                for (final InfoSection section in document.sections)
                  _SectionView(section: section),
                if (document.footer != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    document.footer!,
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: 18,
            color: scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionView extends StatelessWidget {
  const _SectionView({required this.section});

  final InfoSection section;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (section.heading != null) ...<Widget>[
            Text(
              section.heading!,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
          ],
          for (final String p in section.paragraphs) ...<Widget>[
            Text(p, style: text.bodyMedium?.copyWith(height: 1.45)),
            const SizedBox(height: 6),
          ],
          for (final String b in section.bullets)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 10),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      b,
                      style: text.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Scaffold wrapper for a document page reachable from both the landing page
/// (pre-auth) and Settings; the back arrow pops to wherever it was opened from.
class _InfoScaffold extends StatelessWidget {
  const _InfoScaffold({required this.document});

  final InfoDocument document;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.landing),
        ),
        title: Text(document.title),
        actions: const <Widget>[LanguageSelector(compact: true)],
      ),
      body: SafeArea(child: InfoView(document: document)),
    );
  }
}

AppLanguage _lang(BuildContext context) =>
    AppLanguage.fromLocale(Localizations.localeOf(context));

class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _InfoScaffold(document: privacyPolicyDoc(_lang(context)));
}

class TermsOfUsePage extends ConsumerWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _InfoScaffold(document: termsOfUseDoc(_lang(context)));
}

class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _InfoScaffold(document: helpDoc(_lang(context)));
}
