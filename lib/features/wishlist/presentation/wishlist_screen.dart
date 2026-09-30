import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/empty_state.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_grid.dart';
import 'package:chimbo/features/wishlist/application/wishlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Vipendwa: the products the customer saved with the heart, as the usual product cards.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final products = ref.watch(savedProductsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuWishlist)),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(savedProductsProvider.future),
        child: CustomScrollView(
          slivers: [
            ...products.when(
              data: (list) => [
                if (list.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: l10n.wishlistEmptyTitle,
                      message: l10n.wishlistEmptyMessage,
                      actionLabel: l10n.actionStartShopping,
                      onAction: () => context.go(AppRoutes.discover),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    sliver: SliverProductGrid(products: list),
                  ),
              ],
              error: (error, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorState(
                    error: error,
                    onRetry: () => ref.invalidate(savedProductsProvider),
                  ),
                ),
              ],
              loading: () => [
                const SliverPadding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverProductGrid.skeleton(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
