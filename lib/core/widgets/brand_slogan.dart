import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// "Agiza. Amini. Pokea. Kuza Biashara." — the middle two words in orange, as in the design.
class BrandSlogan extends StatelessWidget {
  const BrandSlogan({super.key, this.style, this.textAlign});

  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const highlight = TextStyle(
      color: AppColors.accent,
      fontWeight: FontWeight.w600,
    );

    return Text.rich(
      TextSpan(
        style: style ?? Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(text: '${l10n.sloganOrder} '),
          TextSpan(text: '${l10n.sloganTrust} ', style: highlight),
          TextSpan(text: '${l10n.sloganReceive} ', style: highlight),
          TextSpan(text: l10n.sloganGrow),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
