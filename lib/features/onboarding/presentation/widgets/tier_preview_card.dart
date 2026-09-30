import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/price_text.dart';
import 'package:flutter/material.dart';

/// One step of the example price ladder.
typedef ExampleTier = ({int minimumQuantity, int unitPrice});

/// White card listing "6+  TZS 5,500" style tiers over the wholesale picture.
class TierPreviewCard extends StatelessWidget {
  const TierPreviewCard({super.key, required this.tiers});

  final List<ExampleTier> tiers;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface.withValues(alpha: 0.94),
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (index, tier) in tiers.indexed) ...[
              if (index > 0) const Divider(height: AppSpacing.md),
              _TierRow(tier: tier, isBest: index == tiers.length - 1),
            ],
          ],
        ),
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({required this.tier, required this.isBest});

  final ExampleTier tier;

  /// The biggest-quantity tier is the cheapest, so its price is highlighted.
  final bool isBest;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.groups_outlined,
          size: AppSizes.iconMedium,
          color: AppColors.accent,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${tier.minimumQuantity}+',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const Spacer(),
        PriceText(tier.unitPrice, highlight: isBest),
      ],
    );
  }
}
