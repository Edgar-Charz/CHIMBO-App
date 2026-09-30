import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/core/widgets/quantity_stepper.dart';
import 'package:chimbo/features/cart/presentation/add_to_cart.dart';
import 'package:chimbo/features/catalog/application/catalog_providers.dart';
import 'package:chimbo/features/catalog/data/models/product_details.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/catalog/data/tier_pricing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The (+) on a product card: pick a quantity (from the MOQ) and add, without leaving the list.
Future<void> showQuickAddSheet(BuildContext context, ProductSummary product) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _QuickAddSheet(product: product),
  );
}

class _QuickAddSheet extends ConsumerWidget {
  const _QuickAddSheet({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(productDetailsProvider(product.id));
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: details.when(
          data: (value) => _QuickAddForm(details: value),
          error: (error, _) => ErrorState(
            error: error,
            onRetry: () => ref.invalidate(productDetailsProvider(product.id)),
          ),
          loading: () => _QuickAddPreview(product: product),
        ),
      ),
    );
  }
}

/// Immediate first frame while the API loads stock and tier details for the stepper.
class _QuickAddPreview extends StatelessWidget {
  const _QuickAddPreview({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(product.name, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.quickAddTotal(Money.format(product.price * product.moq)),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: Text(l10n.productMoq(product.moq))),
              const SizedBox.square(
                dimension: AppSizes.iconSmall,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _QuickAddForm extends ConsumerStatefulWidget {
  const _QuickAddForm({required this.details});

  final ProductDetails details;

  @override
  ConsumerState<_QuickAddForm> createState() => _QuickAddFormState();
}

class _QuickAddFormState extends ConsumerState<_QuickAddForm> {
  late final TierPricing _pricing = TierPricing(widget.details.tiers);
  late int _quantity = _pricing.moq;
  bool _isAdding = false;

  Future<void> _add() async {
    setState(() => _isAdding = true);
    final added = await addToCart(
      context,
      ref,
      productId: widget.details.summary.id,
      quantity: _quantity,
    );
    if (!mounted) {
      return;
    }
    if (added) {
      Navigator.of(context).pop();
    } else {
      setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final summary = widget.details.summary;
    final savings = _pricing.savingsFor(_quantity);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(summary.name, style: textTheme.titleMedium),
        Text(
          l10n.cartTierLabel(
            _pricing.tierFor(_quantity).minQuantity,
            Money.format(_pricing.unitPriceFor(_quantity)),
          ),
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Text(l10n.quantityLabel, style: textTheme.titleSmall),
            ),
            QuantityStepper(
              value: _quantity,
              min: _pricing.moq,
              max: widget.details.stockQuantity,
              onChanged: (quantity) => setState(() => _quantity = quantity),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.quickAddTotal(Money.format(_pricing.totalFor(_quantity))),
          style: textTheme.titleMedium,
        ),
        if (savings > 0)
          Text(
            l10n.savingsLabel(Money.format(savings)),
            style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
          ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: summary.isInStock
              ? l10n.actionAddToCart
              : l10n.actionOutOfStock,
          icon: Icons.shopping_cart_outlined,
          variant: AppButtonVariant.accent,
          isLoading: _isAdding,
          // Disabled (null) when sold out.
          onPressed: summary.isInStock ? _add : null,
        ),
      ],
    );
  }
}
