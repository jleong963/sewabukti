import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sewabukti/src/core/auth/auth_controller.dart';
import 'package:sewabukti/src/core/preferences/app_language.dart';
import 'package:sewabukti/src/core/preferences/preferences_providers.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// Language selector offering English, Bahasa Melayu, and 简体中文 (§10.1).
/// Shown on the landing page before sign-in, in Settings, and in every in-app
/// AppBar (FR-PREF-02, FR-PREF-07). Selecting a language updates the UI
/// immediately (FR-PREF-04), persists it locally (FR-PREF-05), and — while
/// signed in — syncs it to the user profile (FR-PREF-06). The sync is a no-op
/// when signed out, so the same widget is safe on the pre-auth landing page.
///
/// Pass [compact] for a globe [IconButton] suited to an AppBar `actions` slot;
/// the default shows the current language endonym with a dropdown affordance
/// (used on the landing top bar).
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key, this.compact = false});

  /// When true, render only a globe icon button (for AppBar `actions`).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppLanguage current = ref.watch(
      localeControllerProvider.select(AppLanguage.fromLocale),
    );

    return PopupMenuButton<AppLanguage>(
      tooltip: l10n.languageLabel,
      initialValue: current,
      position: PopupMenuPosition.under,
      onSelected: (AppLanguage language) {
        ref.read(localeControllerProvider.notifier).setLanguage(language);
        // Persist to the user profile too; no-op when signed out (FR-PREF-06).
        ref
            .read(authControllerProvider.notifier)
            .syncPreferences(language: language.code);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<AppLanguage>>[
        for (final AppLanguage language in AppLanguage.values)
          CheckedPopupMenuItem<AppLanguage>(
            value: language,
            checked: language == current,
            child: Text(language.endonym),
          ),
      ],
      icon: compact ? const Icon(Icons.language_outlined) : null,
      child: compact
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.language_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(current.endonym),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
    );
  }
}
