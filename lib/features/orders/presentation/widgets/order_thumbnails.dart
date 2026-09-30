import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_network_image.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_card.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:flutter/material.dart';

/// Small pictures of an order's items.
class OrderThumbnails extends StatelessWidget {
  const OrderThumbnails({super.key, required this.items});

  final List<OrderItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final item in items)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: SizedBox.square(
              dimension: AppSizes.orderThumbnail,
              child: AppNetworkImage(
                url: item.imageUrl,
                placeholderIcon: ProductCard.placeholderIcon,
              ),
            ),
          ),
      ],
    );
  }
}
