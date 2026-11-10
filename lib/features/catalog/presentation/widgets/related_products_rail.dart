import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/section_header.dart';
import 'package:chimbo/features/catalog/application/catalog_providers.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Same-category product suggestions below the product description.
class RelatedProductsRail extends ConsumerWidget {
  const RelatedProductsRail({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(relatedProductsProvider(productId));
    return state.when(
      loading: () => const _RelatedProductsSkeleton(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.errorMessage(error),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: () =>
                  ref.invalidate(relatedProductsProvider(productId)),
              child: Text(context.l10n.actionRetry),
            ),
          ],
        ),
      ),
      data: (products) => products.isEmpty
          ? const SizedBox.shrink()
          : _RelatedProductsContent(products: products),
    );
  }
}

class _RelatedProductsContent extends StatelessWidget {
  const _RelatedProductsContent({required this.products});

  final List<ProductSummary> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SectionHeader(
            title: context.l10n.relatedProductsTitle,
            isCompact: true,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.md,
              children: [
                for (final product in products)
                  SizedBox(
                    width: AppSizes.railCardWidth,
                    child: ProductCard(product: product),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RelatedProductsSkeleton extends StatelessWidget {
  const _RelatedProductsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SectionHeader(
            title: context.l10n.relatedProductsTitle,
            isCompact: true,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Row(
            spacing: AppSpacing.md,
            children: [
              for (var index = 0; index < 3; index++)
                const _RelatedProductCardSkeleton(),
            ],
          ),
        ),
      ],
    );
  }
}

class _RelatedProductCardSkeleton extends StatelessWidget {
  const _RelatedProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.large),
    );
    return SizedBox(
      width: AppSizes.railCardWidth,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: shape,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AspectRatio(
              aspectRatio: 1,
              child: ColoredBox(color: AppColors.border),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(color: AppColors.border),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: AppSizes.railCardWidth * 0.55,
                    height: AppSpacing.sm,
                    color: AppColors.border,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: AppSizes.railCardWidth * 0.7,
                    height: AppSpacing.sm,
                    color: AppColors.border,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
