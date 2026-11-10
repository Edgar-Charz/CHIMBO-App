import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/features/catalog/data/models/product_details.dart';
import 'package:chimbo/features/catalog/presentation/widgets/catalog_labels.dart';
import 'package:chimbo/features/checkout/presentation/widgets/checkout_widgets.dart';
import 'package:flutter/material.dart';

/// MOQ · Stock · Uwasilishaji, side by side.
class ProductInfoStrip extends StatelessWidget {
  const ProductInfoStrip({super.key, required this.details});

  /// Large stock shows as "500+ pcs", like most shops do.
  static const int _stockDisplayCap = 500;

  final ProductDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stock = details.stockQuantity;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            _InfoItem(
              icon: Icons.inventory_outlined,
              label: l10n.moqFilter,
              value: details.summary.unitLabel.formatQuantity(
                details.summary.moq,
              ),
            ),
            _InfoItem(
              icon: Icons.warehouse_outlined,
              label: l10n.infoStock,
              value: !details.summary.isInStock
                  ? l10n.outOfStock
                  : stock >= _stockDisplayCap
                  ? '$_stockDisplayCap+ ${details.summary.unitLabel.pluralized}'
                  : details.summary.unitLabel.formatQuantity(stock),
              valueColor: details.summary.isInStock ? null : AppColors.danger,
            ),
            _InfoItem(
              icon: Icons.local_shipping_outlined,
              label: l10n.infoDelivery,
              // The quickest real option ("leo au kesho" with Bolt); the per-product guess if none
              value:
                  details.fastestDelivery?.eta(l10n) ??
                  l10n.deliveryDays(
                    details.deliveryDaysMin,
                    details.deliveryDaysMax,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Red for "Imeisha"; default text colour otherwise.
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.labelMedium),
                Text(
                  value,
                  style: textTheme.bodySmall?.copyWith(color: valueColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Every delivery option under the info strip: "Bolt (Dar es Salaam) · leo au kesho",
/// "Usafiri wa mikoani · siku 2–5", "Nitachukua mwenyewe dukani · Bure" — the same as the website.
class ProductDeliveryOptions extends StatelessWidget {
  const ProductDeliveryOptions({super.key, required this.details});

  final ProductDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in details.deliveryOptions)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                Icon(
                  option.isPickup
                      ? Icons.storefront_outlined
                      : Icons.local_shipping_outlined,
                  size: AppSizes.iconMedium,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(option.name, style: textTheme.bodyMedium)),
                Text(
                  option.isPickup ? l10n.deliveryFree : option.eta(l10n),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
