import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sewabukti/src/core/auth/auth_controller.dart';
import 'package:sewabukti/src/core/auth/auth_repository.dart';
import 'package:sewabukti/src/core/constants/app_limits.dart';
import 'package:sewabukti/src/core/download/file_download.dart';
import 'package:sewabukti/src/core/preferences/app_language.dart';
import 'package:sewabukti/src/core/preferences/preferences_providers.dart';
import 'package:sewabukti/src/core/routing/routes.dart';
import 'package:sewabukti/src/features/account/case_export.dart';
import 'package:sewabukti/src/features/cases/case_controller.dart';
import 'package:sewabukti/src/features/cases/case_model.dart';
import 'package:sewabukti/src/features/chronology/timeline_controller.dart';
import 'package:sewabukti/src/features/chronology/timeline_event.dart';
import 'package:sewabukti/src/features/evidence/evidence_controller.dart';
import 'package:sewabukti/src/features/evidence/evidence_file.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// Settings, account, and privacy screen (§10.9). Language and display-mode
/// changes apply immediately and persist (FR-PREF-04/07/09/10/11). Data
/// controls export the case data, delete the case, and delete the account
/// (FR-CASE-04, NFR-SEC-12/15).
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthState auth = ref.watch(authControllerProvider);
    final AppLanguage language = ref.watch(
      localeControllerProvider.select(AppLanguage.fromLocale),
    );
    final bool isDark = ref.watch(
      themeModeControllerProvider.select((ThemeMode m) => m == ThemeMode.dark),
    );
    final Case? currentCase = ref.watch(caseControllerProvider).asData?.value;
    final List<EvidenceFile> evidence =
        ref.watch(evidenceControllerProvider).asData?.value ?? <EvidenceFile>[];

    final int usedBytes = evidence.fold(
      0,
      (int sum, EvidenceFile e) => sum + e.sizeBytes,
    );
    final String usedMb = (usedBytes / (1024 * 1024)).toStringAsFixed(2);
    final String totalMb =
        (StorageLimits.totalEvidenceBytesPerCase / (1024 * 1024))
            .toStringAsFixed(0);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.dashboard),
        ),
        title: Text(l10n.settingsTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _Section(
                      title: l10n.settingsAccountSection,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(l10n.settingsNameLabel),
                          subtitle: Text(auth.displayName ?? '—'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.email_outlined),
                          title: Text(l10n.settingsEmailLabel),
                          subtitle: Text(auth.email ?? '—'),
                        ),
                      ],
                    ),
                    _Section(
                      title: l10n.settingsPreferencesSection,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.language_outlined),
                          title: Text(l10n.settingsLanguageLabel),
                          subtitle: Text(language.endonym),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () =>
                              _pickLanguage(context, ref, language, l10n),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  const Icon(Icons.brightness_6_outlined),
                                  const SizedBox(width: 16),
                                  Text(l10n.settingsDisplayModeLabel),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SegmentedButton<bool>(
                                segments: <ButtonSegment<bool>>[
                                  ButtonSegment<bool>(
                                    value: false,
                                    label: Text(l10n.displayLight),
                                    icon: const Icon(Icons.light_mode_outlined),
                                  ),
                                  ButtonSegment<bool>(
                                    value: true,
                                    label: Text(l10n.displayDark),
                                    icon: const Icon(Icons.dark_mode_outlined),
                                  ),
                                ],
                                selected: <bool>{isDark},
                                onSelectionChanged: (Set<bool> selection) {
                                  final bool dark = selection.first;
                                  ref
                                      .read(
                                        themeModeControllerProvider.notifier,
                                      )
                                      .setDark(dark);
                                  ref
                                      .read(authControllerProvider.notifier)
                                      .syncPreferences(
                                        themeMode: dark ? 'dark' : 'light',
                                      );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    _Section(
                      title: l10n.settingsStorageSection,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.storage_outlined),
                          title: Text(l10n.dashboardStorageUsed),
                          subtitle: Text(
                            l10n.dashboardStorageValue(usedMb, totalMb),
                          ),
                        ),
                      ],
                    ),
                    _Section(
                      title: l10n.settingsDataSection,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.download_outlined),
                          title: Text(l10n.settingsExportData),
                          enabled: currentCase != null,
                          onTap: currentCase == null
                              ? null
                              : () => _export(context, ref, l10n),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: currentCase == null ? null : scheme.error,
                          ),
                          title: Text(
                            l10n.settingsDeleteCase,
                            style: currentCase == null
                                ? null
                                : TextStyle(color: scheme.error),
                          ),
                          enabled: currentCase != null,
                          onTap: currentCase == null
                              ? null
                              : () => _confirmDeleteCase(context, ref, l10n),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.no_accounts_outlined,
                            color: scheme.error,
                          ),
                          title: Text(
                            l10n.settingsDeleteAccount,
                            style: TextStyle(color: scheme.error),
                          ),
                          onTap: () =>
                              _confirmDeleteAccount(context, ref, l10n),
                        ),
                      ],
                    ),
                    _Section(
                      title: l10n.settingsLegalSection,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.privacy_tip_outlined),
                          title: Text(l10n.privacyPolicy),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(Routes.privacy),
                        ),
                        ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: Text(l10n.termsOfUse),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(Routes.terms),
                        ),
                        ListTile(
                          leading: const Icon(Icons.help_outline),
                          title: Text(l10n.help),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(Routes.help),
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: Text(l10n.signOut),
                          onTap: () => ref
                              .read(authControllerProvider.notifier)
                              .signOut(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _snack(BuildContext context, String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final Case? c = ref.read(caseControllerProvider).asData?.value;
    if (c == null) return;
    final List<EvidenceFile> evidence =
        ref.read(evidenceControllerProvider).asData?.value ?? <EvidenceFile>[];
    final List<TimelineEvent> timeline =
        ref.read(timelineControllerProvider).asData?.value ?? <TimelineEvent>[];
    try {
      final Map<String, dynamic> data = buildCaseExportJson(
        caseData: c,
        evidence: evidence,
        timeline: timeline,
        generatedAt: DateTime.now().toUtc().toIso8601String(),
      );
      downloadTextFile(
        filename: 'sewabukti-case-export.json',
        content: const JsonEncoder.withIndent('  ').convert(data),
      );
      _snack(context, l10n.exportReady);
    } catch (_) {
      _snack(context, l10n.exportFailed);
    }
  }

  Future<void> _confirmDeleteCase(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.deleteCaseConfirmTitle),
        content: Text(l10n.deleteCaseConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(caseControllerProvider.notifier).deleteCase();
      if (context.mounted) _snack(context, l10n.caseDeleted);
    } catch (_) {
      if (context.mounted) _snack(context, l10n.deleteCaseFailed);
    }
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    bool ack = false;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setLocal) => AlertDialog(
          title: Text(l10n.deleteAccountConfirmTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l10n.deleteAccountConfirmBody),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: ack,
                onChanged: (bool? v) => setLocal(() => ack = v ?? false),
                title: Text(l10n.deleteAccountAck),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              onPressed: ack ? () => Navigator.pop(ctx, true) : null,
              child: Text(l10n.deleteAccountAction),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(authControllerProvider.notifier).deleteAccount();
      // Sign-out redirects to the landing page; no further UI needed here.
    } on AuthException catch (_) {
      if (context.mounted) _snack(context, l10n.accountDeleteFailed);
    } catch (_) {
      if (context.mounted) _snack(context, l10n.accountDeleteFailed);
    }
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLanguage current,
    AppLocalizations l10n,
  ) async {
    final AppLanguage? selected = await showDialog<AppLanguage>(
      context: context,
      builder: (BuildContext ctx) {
        return SimpleDialog(
          title: Text(l10n.settingsLanguageLabel),
          children: <Widget>[
            RadioGroup<AppLanguage>(
              groupValue: current,
              onChanged: (AppLanguage? value) => Navigator.pop(ctx, value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final AppLanguage language in AppLanguage.values)
                    RadioListTile<AppLanguage>(
                      value: language,
                      title: Text(language.endonym),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
    if (selected != null) {
      await ref.read(localeControllerProvider.notifier).setLanguage(selected);
      await ref
          .read(authControllerProvider.notifier)
          .syncPreferences(language: selected.code);
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }
}
