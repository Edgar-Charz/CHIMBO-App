import 'package:chimbo/features/catalog/data/models/product_summary.dart';

/// One page of a product listing (`GET /products` + its `meta`).
class ProductPage {
  const ProductPage({
    required this.items,
    required this.page,
    required this.lastPage,
  });

  factory ProductPage.fromJson(List<dynamic> data, Map<String, dynamic> meta) {
    return ProductPage(
      items: data
          .map((item) => ProductSummary.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: meta['page'] as int,
      lastPage: meta['last_page'] as int,
    );
  }

  /// Page size the app asks for (blueprint §6.5: lists paginated by 20).
  static const int size = 20;

  final List<ProductSummary> items;
  final int page;
  final int lastPage;

  bool get hasMore => page < lastPage;
}
