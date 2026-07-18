import 'package:flutter/material.dart';

import 'package:sewabukti/src/core/theme/app_colors.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// SewaBukti wordmark: a neutral document mark in sea blue plus the product
/// name. Deliberately avoids crests, emblems, or court/government imagery
/// (§9.3, §9.1 "never imply that SewaBukti is a government or court service").
class AppWordmark extends StatelessWidget {
  const AppWordmark({super.key, this.markSize = 32, this.showText = true});

  final double markSize;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: markSize,
          height: markSize,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(markSize * 0.28),
          ),
          child: Icon(
            Icons.description_outlined,
            color: scheme.onPrimary,
            size: markSize * 0.6,
          ),
        ),
        if (showText) ...<Widget>[
          const SizedBox(width: 10),
          Text(
            l10n.appName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.sb.deepSeaBlue,
            ),
          ),
        ],
      ],
    );
  }
}
