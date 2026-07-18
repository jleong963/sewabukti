import 'package:flutter/material.dart';

import 'package:sewabukti/src/core/theme/app_colors.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// Subtle, always-visible reminder that SewaBukti is not a law firm, court, or
/// government service (§16, MVP acceptance criterion #16). Uses an icon plus
/// text so meaning does not rely on colour alone (§9.2).
class LegalServiceNotice extends StatelessWidget {
  const LegalServiceNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SbColors sb = context.sb;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: sb.paleSeaBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, size: 20, color: sb.onPaleSeaBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.notLegalServiceNotice,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: sb.onPaleSeaBlue),
            ),
          ),
        ],
      ),
    );
  }
}
