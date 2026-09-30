import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:flutter/material.dart';

/// "Bidhaa (4)  TZS 94,400 / Usafirishaji  TZS 5,000 / Jumla  TZS 99,400".
/// Amounts are whole TZS from the server; this widget only shows them.
class TotalsCard extends StatelessWidget {
  const TotalsCard({
    super.key,
    required this.rows,
    required this.totalLabel,
    required this.total,
  });

  final List<({String label, int amount})> rows;
  final String totalLabel;
  final int total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _AmountRow(
                  label: row.label,
                  amount: row.amount,
                  style: textTheme.bodyMedium,
                ),
              ),
            const Divider(height: AppSpacing.lg),
            _AmountRow(
              label: totalLabel,
              amount: total,
              style: textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.amount, this.style});

  final String label;
  final int amount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(Money.format(amount), style: style),
      ],
    );
  }
}
