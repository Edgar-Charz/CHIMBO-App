import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/section_header.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';

/// A titled, sideways-scrolling row of product cards ("Uliagiza Hivi Karibuni", …).
class ProductRail extends StatelessWidget {
  const ProductRail({
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
        // A rail holds a handful of cards, so building them all at once is fine; the row takes
        // the height of the tallest card.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          // Room for the cards' shadows, which the scroll area would otherwise cut off.
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
