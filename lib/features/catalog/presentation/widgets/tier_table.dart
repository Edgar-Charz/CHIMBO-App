import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:chimbo/features/catalog/data/tier_pricing.dart';
import 'package:flutter/material.dart';

/// "Nunua zaidi, lipa kidogo": every tier as "6–23 pcs  TZS 5,000"; the tier the chosen
/// quantity falls in is highlighted in orange.
class TierTable extends StatelessWidget {
  const TierTable({super.key, required this.pricing, required this.quantity});

  final TierPricing pricing;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final activeTier = pricing.tierFor(quantity);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.accentLight, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.accentLight,
            child: Text(l10n.tiersTitle, style: textTheme.titleSmall),
          ),
          for (final (index, tier) in pricing.tiers.indexed)
            _TierRow(
              range: switch (pricing.maxQuantityOfTier(index)) {
                final max? => l10n.tierRange(tier.minQuantity, max),
                null => l10n.tierFrom(tier.minQuantity),
              },
              price: Money.format(tier.unitPrice),
              isActive: identical(tier, activeTier),
            ),
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.range,
    required this.price,
    required this.isActive,
  });

  final String range;
  final String price;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: isActive ? AppColors.accent : AppColors.textPrimary,
      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
    );
    return Container(
      color: isActive ? AppColors.accentLight.withValues(alpha: 0.5) : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(child: Text(range, style: style)),
          Text(price, style: style),
        ],
      ),
    );
  }
}
