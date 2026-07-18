import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sewabukti/src/core/auth/auth_controller.dart';
import 'package:sewabukti/src/core/constants/app_limits.dart';
import 'package:sewabukti/src/core/formatting/formatting.dart';
import 'package:sewabukti/src/core/routing/routes.dart';
import 'package:sewabukti/src/core/theme/app_colors.dart';
import 'package:sewabukti/src/features/cases/case_controller.dart';
import 'package:sewabukti/src/features/cases/case_model.dart';
import 'package:sewabukti/src/features/evidence/evidence_controller.dart';
import 'package:sewabukti/src/features/evidence/evidence_file.dart';
import 'package:sewabukti/src/features/shared/widgets/legal_notice.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// Dashboard (§10.2). Shows the single active case (or an empty state) with
/// completion, amount claimed, and status, plus account controls.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthState auth = ref.watch(authControllerProvider);
    final AsyncValue<Case?> caseAsync = ref.watch(caseControllerProvider);
    final List<EvidenceFile> evidence =
        ref.watch(evidenceControllerProvider).asData?.value ?? <EvidenceFile>[];
    final int usedBytes = evidence.fold(
      0,
      (int sum, EvidenceFile e) => sum + e.sizeBytes,
    );
    final String name = auth.displayName ?? auth.email ?? '';

    void openWizard() => context.go(Routes.caseWizard);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navDashboard),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.navSettings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go(Routes.settings),
          ),
          _AccountMenu(email: auth.email),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      l10n.dashboardWelcome(name),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 20),
                    caseAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, _) => _EmptyCaseCard(onStart: openWizard),
                      data: (Case? c) => c == null
                          ? _EmptyCaseCard(onStart: openWizard)
                          : _ActiveCaseCard(
                              caseData: c,
                              onContinue: openWizard,
                            ),
                    ),
                    const SizedBox(height: 20),
                    _StatusTiles(
                      l10n: l10n,
                      caseData: caseAsync.asData?.value,
                      usedBytes: usedBytes,
                      hasEvidence: evidence.isNotEmpty,
                    ),
                    const SizedBox(height: 24),
                    const LegalServiceNotice(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountMenu extends ConsumerWidget {
  const _AccountMenu({this.email});

  final String? email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      tooltip: l10n.settingsAccountSection,
      icon: const Icon(Icons.account_circle_outlined),
      onSelected: (String value) {
        if (value == 'signout') {
          ref.read(authControllerProvider.notifier).signOut();
        } else if (value == 'settings') {
          context.go(Routes.settings);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (email != null)
          PopupMenuItem<String>(
            enabled: false,
            child: Text(email!, style: Theme.of(context).textTheme.bodySmall),
          ),
        if (email != null) const PopupMenuDivider(),
        PopupMenuItem<String>(value: 'settings', child: Text(l10n.navSettings)),
        PopupMenuItem<String>(value: 'signout', child: Text(l10n.signOut)),
      ],
    );
  }
}

class _EmptyCaseCard extends StatelessWidget {
  const _EmptyCaseCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.sb.paleSeaBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.folder_open_outlined,
                    color: context.sb.onPaleSeaBlue,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    l10n.dashboardNoCaseTitle,
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.dashboardNoCaseBody,
              style: text.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.add),
                label: Text(l10n.dashboardStartCase),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveCaseCard extends StatelessWidget {
  const _ActiveCaseCard({required this.caseData, required this.onContinue});

  final Case caseData;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final int percent = caseCompletionPercent(caseData);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.dashboardActiveCaseTitle,
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(l10n.dashboardCompletion(percent)),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.dashboardContinueCase),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go(Routes.evidence),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: Text(l10n.dashboardManageEvidence),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go(Routes.chronology),
                  icon: const Icon(Icons.timeline_outlined),
                  label: Text(l10n.dashboardChronology),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go(Routes.demandLetter),
                  icon: const Icon(Icons.mail_outline),
                  label: Text(l10n.dashboardDemandLetter),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go(Routes.evidenceBundle),
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: Text(l10n.dashboardEvidenceBundle),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go(Routes.claimRoute),
                  icon: const Icon(Icons.gavel_outlined),
                  label: Text(l10n.dashboardClaimRoute),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTiles extends StatelessWidget {
  const _StatusTiles({
    required this.l10n,
    required this.caseData,
    required this.usedBytes,
    required this.hasEvidence,
  });

  final AppLocalizations l10n;
  final Case? caseData;
  final int usedBytes;
  final bool hasEvidence;

  @override
  Widget build(BuildContext context) {
    final String usedMb = (usedBytes / (1024 * 1024)).toStringAsFixed(2);
    final String totalMb =
        (StorageLimits.totalEvidenceBytesPerCase / (1024 * 1024))
            .toStringAsFixed(0);
    // A successful email send records the accepted payment deadline on the
    // case (see DemandLetterPage._send), so it doubles as the sent marker.
    final bool demandSent = (caseData?.demandDeadlineDate ?? '')
        .trim()
        .isNotEmpty;

    final List<Widget> tiles = <Widget>[
      _StatTile(
        icon: Icons.payments_outlined,
        label: l10n.dashboardAmountClaimed,
        value: formatRmFromSen(caseData?.amountClaimedSenValue ?? 0),
      ),
      _StatTile(
        icon: Icons.mail_outline,
        label: l10n.dashboardDemandLetter,
        value: demandSent ? l10n.statusSent : l10n.statusNotStarted,
      ),
      _StatTile(
        icon: Icons.inventory_2_outlined,
        label: l10n.dashboardEvidenceBundle,
        // The bundle is generated locally on demand; with evidence uploaded it
        // is ready to generate.
        value: hasEvidence ? l10n.statusReady : l10n.statusNotStarted,
      ),
      _StatTile(
        icon: Icons.storage_outlined,
        label: l10n.dashboardStorageUsed,
        value: l10n.dashboardStorageValue(usedMb, totalMb),
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final int columns = c.maxWidth >= 640 ? 2 : 1;
        const double gap = 12;
        final double tileWidth = (c.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final Widget tile in tiles)
              SizedBox(width: tileWidth, child: tile),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
