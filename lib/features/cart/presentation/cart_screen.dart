import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/core/widgets/empty_state.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/features/cart/application/cart_controller.dart';
import 'package:chimbo/features/cart/data/models/cart.dart';
import 'package:chimbo/features/cart/presentation/widgets/cart_line_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Kikapu Chako (design PDF p.7): lines grouped by category, "better price" nudge, summary.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isEditing = false;

  CartController get _cart => ref.read(cartControllerProvider.notifier);

  /// Runs a cart change and shows the server's reason if it is refused (MOQ, stock).
  Future<void> _change(Future<void> Function() action) async {
    try {
      await action();
    } on ApiException catch (error) {
      if (mounted) {
        AppToast.of(context).error(context.l10n.errorMessage(error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cart = ref.watch(cartControllerProvider);
    final hasItems = cart.value?.isEmpty == false;
    // Products that left the shop were removed by the server: say so once, when it happens.
    ref.listen(cartControllerProvider, (previous, next) {
      final warnings = next.value?.warnings ?? const <String>[];
      if (warnings.isNotEmpty && previous?.value?.warnings != warnings) {
        AppToast.of(context).info(warnings.join(' '));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cartTitle),
        actions: [
          if (hasItems)
            TextButton(
              onPressed: () => setState(() => _isEditing = !_isEditing),
              child: Text(_isEditing ? l10n.actionDone : l10n.actionEdit),
            ),
        ],
      ),
      body: cart.when(
        data: (value) => value.isEmpty
            ? Center(
                child: EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: l10n.cartEmptyTitle,
                  message: l10n.cartEmptyMessage,
                  actionLabel: l10n.actionStartShopping,
                  onAction: () => context.go(AppRoutes.discover),
                ),
              )
            : _CartContent(
                cart: value,
                isEditing: _isEditing,
                onQuantityChanged: (productId, quantity) =>
                    _change(() => _cart.setQuantity(productId, quantity)),
                onRemove: (productId) => _change(() => _cart.remove(productId)),
              ),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(cartControllerProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _CartContent extends StatelessWidget {
  const _CartContent({
    required this.cart,
    required this.isEditing,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final Cart cart;
  final bool isEditing;
  final void Function(int productId, int quantity) onQuantityChanged;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nudge = cart.bestNudge;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            children: [
              if (nudge != null) ...[
                _NudgeBanner(line: nudge),
                const SizedBox(height: AppSpacing.md),
              ],
              for (final group in cart.groups) ...[
                _GroupHeader(name: group.categoryName),
                for (final line in group.lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: CartLineTile(
                      line: line,
                      isEditing: isEditing,
                      onQuantityChanged: (quantity) =>
                          onQuantityChanged(line.product.id, quantity),
                      onRemove: () => onRemove(line.product.id),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
              ],
              _CartTotals(cart: cart),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.cartDeliveryNote,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!cart.canCheckout) ...[
                Text(
                  l10n.cartCannotCheckout,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.danger),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              AppButton(
                label: l10n.actionContinueToCheckout,
                variant: AppButtonVariant.accent,
                // Blocked by the server while a line has a problem (stock / MOQ).
                onPressed: cart.canCheckout
                    ? () => context.push(AppRoutes.checkout)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "Ongeza pcs 16 za Vaseline… upate TZS 4,700 kila moja."
/// Compact, unboxed summary like the cart design. Delivery is added at checkout, where
/// the customer chooses a delivery method and receives the server's final quote.
class _CartTotals extends StatelessWidget {
  const _CartTotals({required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.summaryItems(cart.lineCount),
                  style: textTheme.bodySmall,
                ),
              ),
              Text(Money.format(cart.subtotal), style: textTheme.bodySmall),
            ],
          ),
          if (cart.savings > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.summarySavings,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
                Text(
                  '- ${Money.format(cart.savings)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.summaryTotal,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                Money.format(cart.subtotal),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NudgeBanner extends StatelessWidget {
  const _NudgeBanner({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.accent,
              size: AppSizes.iconSmall,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                context.l10n.cartNudge(
                  line.nextTierExtraQuantity!,
                  line.product.name,
                  Money.format(line.nextTierUnitPrice!),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Cosmetics" with the green "Bei ya jumla" tag.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(name, style: textTheme.titleMedium)),
          DecoratedBox(
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
                context.l10n.wholesalePriceTag,
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
