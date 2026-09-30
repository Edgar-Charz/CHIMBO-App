import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/features/catalog/data/models/product_details.dart';
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
              value: l10n.piecesCount(details.summary.moq),
            ),
            _InfoItem(
              icon: Icons.warehouse_outlined,
              label: l10n.infoStock,
              value: !details.summary.isInStock
                  ? l10n.outOfStock
                  : stock >= _stockDisplayCap
                  ? l10n.stockAtLeast(_stockDisplayCap)
                  : l10n.piecesCount(stock),
              valueColor: details.summary.isInStock ? null : AppColors.danger,
            ),
            _InfoItem(
              icon: Icons.local_shipping_outlined,
              label: l10n.infoDelivery,
              value: l10n.deliveryDays(
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
