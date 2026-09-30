import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:flutter/material.dart';

/// Shows an amount as `TZS 5,500`. [highlight] marks the best (lowest) tier price in orange.
class PriceText extends StatelessWidget {
  const PriceText(this.amount, {super.key, this.highlight = false, this.style});

  /// Whole Tanzanian shillings, exactly as the API sends them.
  final int amount;
  final bool highlight;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.titleMedium;
    return Text(
      Money.format(amount),
      style: highlight
          ? baseStyle?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            )
          : baseStyle,
    );
  }
}
