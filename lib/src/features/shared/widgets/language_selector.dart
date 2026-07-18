import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sewabukti/src/core/preferences/app_language.dart';
import 'package:sewabukti/src/core/preferences/preferences_providers.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// Language selector offering English, Bahasa Melayu, and 简体中文 (§10.1).
/// Available on the landing page before sign-in and in Settings after sign-in
/// (FR-PREF-02, FR-PREF-07). Selecting a language updates the UI immediately
/// (FR-PREF-04) and persists it (FR-PREF-05).
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

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
      onSelected: (AppLanguage language) =>
          ref.read(localeControllerProvider.notifier).setLanguage(language),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<AppLanguage>>[
        for (final AppLanguage language in AppLanguage.values)
          CheckedPopupMenuItem<AppLanguage>(
            value: language,
            checked: language == current,
            child: Text(language.endonym),
          ),
      ],
      child: Padding(
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
