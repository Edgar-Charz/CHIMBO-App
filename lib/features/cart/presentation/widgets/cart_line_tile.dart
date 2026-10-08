import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:chimbo/core/widgets/app_network_image.dart';
import 'package:chimbo/core/widgets/quantity_stepper.dart';
import 'package:chimbo/features/cart/data/models/cart.dart';
import 'package:chimbo/features/catalog/presentation/widgets/offer_widgets.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Compact cart row: picture and product details, with the line total and MOQ visible at a glance.
/// In edit mode ("Hariri") a remove button shows.
class CartLineTile extends StatelessWidget {
  const CartLineTile({
    super.key,
    required this.line,
    required this.isEditing,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final CartLine line;
  final bool isEditing;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final product = line.product;

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () =>
                      context.push(AppRoutes.productDetails(product.id)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    child: SizedBox.square(
                      dimension: AppSizes.cartLineImage,
                      child: AppNetworkImage(
                        url: product.imageUrl,
                        placeholderIcon: ProductCard.placeholderIcon,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleSmall,
                            ),
                          ),
                          if (isEditing)
                            IconButton(
                              onPressed: onRemove,
                              tooltip: l10n.actionRemove,
                              visualDensity: VisualDensity.compact,
                              color: AppColors.danger,
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                        ],
                      ),
                      Text(
                        l10n.cartTierLabel(
                          line.tierMinQuantity,
                          Money.format(line.unitPrice),
                        ),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (line.offerPercent > 0) ...[
                        const SizedBox(height: AppSpacing.xs),
                        OfferLabel(percent: line.offerPercent),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      // Stepper bottom-left; line total above "MOQ imetimia" on the right
                      // (design PDF p.7).
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          QuantityStepper(
                            value: line.quantity,
                            min: product.moq,
                            // No more than the server says is left.
                            max: line.availableQuantity,
                            compact: true,
                            onChanged: onQuantityChanged,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  Money.format(line.lineTotal),
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (line.problem == null && line.isMoqMet) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  const _MoqMetTag(),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (line.problem case final problem?)
              _ProblemNote(
                line: line,
                problem: problem,
                onQuantityChanged: onQuantityChanged,
                onRemove: onRemove,
              ),
          ],
        ),
      ),
    );
  }
}

/// What went wrong with this line since it was added (stock or MOQ changed), in red, with the
/// one-tap fix: lower to what's left, raise to the MOQ, or remove.
class _ProblemNote extends StatelessWidget {
  const _ProblemNote({
    required this.line,
    required this.problem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final CartLine line;
  final CartLineProblem problem;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final available = line.availableQuantity ?? 0;
    final moq = line.product.moq;
    final (message, fixLabel, fix) = switch (problem) {
      CartLineProblem.notEnoughStock => (
        l10n.cartProblemNotEnoughStock(available),
        l10n.cartFixLowerTo(available),
        () => onQuantityChanged(available),
      ),
      CartLineProblem.outOfStock => (
        l10n.outOfStock,
        l10n.actionRemove,
        onRemove,
      ),
      CartLineProblem.belowMoq => (
        l10n.cartProblemBelowMoq(moq),
        l10n.cartFixRaiseTo(moq),
        () => onQuantityChanged(moq),
      ),
    };
    return Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: AppSizes.iconSmall,
          color: AppColors.danger,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.danger),
          ),
        ),
        TextButton(
          onPressed: fix,
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: AppColors.danger,
          ),
          child: Text(fixLabel),
        ),
      ],
    );
  }
}

class _MoqMetTag extends StatelessWidget {
  const _MoqMetTag();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs / 2,
        ),
        child: Text(
          context.l10n.moqMet,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
