import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sewabukti/src/core/constants/legal_config.dart';
import 'package:sewabukti/src/core/formatting/formatting.dart';
import 'package:sewabukti/src/core/legal/legal_content.dart';
import 'package:sewabukti/src/core/preferences/app_language.dart';
import 'package:sewabukti/src/core/routing/routes.dart';
import 'package:sewabukti/src/features/cases/case_controller.dart';
import 'package:sewabukti/src/features/cases/case_model.dart';
import 'package:sewabukti/src/features/legal/legal_info_page.dart';
import 'package:sewabukti/src/features/shared/widgets/language_selector.dart';
import 'package:sewabukti/src/features/shared/widgets/legal_notice.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// Claim-route information (§10.7). Shows the claimed amount, general procedural
/// guidance (from configurable [LegalConfig] values), and a link to official
/// judiciary guidance. It must not claim to submit, lodge, or file a case.
class ClaimRoutePage extends ConsumerWidget {
  const ClaimRoutePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppLanguage lang = AppLanguage.fromLocale(
      Localizations.localeOf(context),
    );
    final Case? c = ref.watch(caseControllerProvider).asData?.value;
    final int claimedSen = c?.amountClaimedSenValue ?? 0;
    final bool aboveCeiling =
        claimedSen > LegalConfig.smallClaimsCeilingRm * 100;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.dashboard),
        ),
        title: Text(l10n.claimRouteTitle),
        actions: const <Widget>[LanguageSelector(compact: true)],
      ),
      body: SafeArea(
        child: InfoView(
          document: claimRouteDoc(lang),
          leading: _Leading(
            l10n: l10n,
            amount: formatRmFromSen(claimedSen),
            aboveCeiling: aboveCeiling,
            ceiling: smallClaimsCeilingLabel(),
          ),
        ),
      ),
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading({
    required this.l10n,
    required this.amount,
    required this.aboveCeiling,
    required this.ceiling,
  });

  final AppLocalizations l10n;
  final String amount;
  final bool aboveCeiling;
  final String ceiling;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Icon(Icons.payments_outlined, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.dashboardAmountClaimed,
                        style: text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        amount,
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (aboveCeiling) ...<Widget>[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: scheme.onTertiaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.claimRouteAboveCeiling(amount, ceiling),
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onTertiaryContainer,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.claimRouteGuidanceNote,
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: () =>
                  _open(context, l10n, LegalConfig.judiciaryPeninsularUrl),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(l10n.regionPeninsular),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  _open(context, l10n, LegalConfig.judiciarySabahSarawakUrl),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(l10n.regionSabahSarawak),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const LegalServiceNotice(),
      ],
    );
  }

  Future<void> _open(
    BuildContext context,
    AppLocalizations l10n,
    String url,
  ) async {
    final bool ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.signInFailed)));
    }
  }
}
