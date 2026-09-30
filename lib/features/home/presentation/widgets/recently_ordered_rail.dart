import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_network_image.dart';
import 'package:chimbo/core/widgets/section_header.dart';
import 'package:chimbo/features/cart/presentation/quick_add_sheet.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// "Uliagiza Hivi Karibuni" as picture-only tiles, like the "buy again" rows of modern shop
/// apps: customers recognise what they bought by its picture. Tap = product page; the small
/// (+) re-adds it through the quick-add sheet.
class RecentlyOrderedRail extends StatelessWidget {
  const RecentlyOrderedRail({
    super.key,
    required this.title,
    required this.products,
    required this.actionLabel,
    required this.onViewAll,
  });

  final String title;
  final List<ProductSummary> products;
  final String actionLabel;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: title,
          actionLabel: actionLabel,
          onAction: onViewAll,
        ),
        SizedBox(
          height: AppSizes.recentOrderTile,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) =>
                _PictureTile(product: products[index]),
          ),
        ),
      ],
    );
  }
}

class _PictureTile extends StatelessWidget {
  const _PictureTile({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: product.name,
      button: true,
      child: SizedBox.square(
        dimension: AppSizes.recentOrderTile,
        child: Material(
          color: AppColors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
            side: const BorderSide(color: AppColors.border),
          ),
          child: InkWell(
            onTap: () => context.push(AppRoutes.productDetails(product.id)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(
                  url: product.imageUrl,
                  placeholderIcon: ProductCard.placeholderIcon,
                ),
                Positioned(
                  right: AppSpacing.xs,
                  bottom: AppSpacing.xs,
                  child: IconButton.filled(
                    onPressed: () => showQuickAddSheet(context, product),
                    tooltip: context.l10n.quickReorder,
                    visualDensity: VisualDensity.compact,
                    iconSize: AppSizes.iconMedium,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.onAccent,
                    ),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
