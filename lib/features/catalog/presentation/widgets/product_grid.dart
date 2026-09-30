import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 2-column product grid for a [CustomScrollView].
///
/// Built row by row: each row is as tall as its taller card, so long names or large system
/// text never overflow (a fixed-height grid would cut them off).
class SliverProductGrid extends StatelessWidget {
  const SliverProductGrid({super.key, required this.products})
    : isSkeleton = false;

  /// Grey card shapes while the first page loads (blueprint §6.4).
  const SliverProductGrid.skeleton({super.key})
    : products = const [],
      isSkeleton = true;

  static const int _columns = 2;
  static const int _skeletonCount = 6;

  final List<ProductSummary> products;
  final bool isSkeleton;

  @override
  Widget build(BuildContext context) {
    final shown = isSkeleton
        ? List.filled(_skeletonCount, ProductCard.skeletonProduct)
        : products;
    final rowCount = (shown.length / _columns).ceil();
    final grid = SliverList.builder(
      itemCount: rowCount,
      itemBuilder: (context, row) {
        final first = row * _columns;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.md,
              children: [
                for (var column = 0; column < _columns; column++)
                  Expanded(
                    child: first + column < shown.length
                        ? ProductCard(product: shown[first + column])
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        );
      },
    );
    return isSkeleton ? Skeletonizer.sliver(child: grid) : grid;
  }
}
