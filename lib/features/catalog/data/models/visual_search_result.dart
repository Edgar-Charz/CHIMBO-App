import 'package:chimbo/features/catalog/data/models/product_summary.dart';
/// The result returned by `POST /products/search-by-image`.
class VisualSearchResult {
  const VisualSearchResult({
    required this.detectedQuery,
    required this.items,
    this.isAiActive,
  });

  factory VisualSearchResult.fromJson(Map<String, dynamic> json) {
    final detected = json['detected'] as Map<String, dynamic>?;
    final searchQuery = detected?['search_query'] as String? ?? '';
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return VisualSearchResult(
      detectedQuery: searchQuery,
      isAiActive: detected?['is_ai_active'] as bool?,
      items: rawItems
          .map((item) => ProductSummary.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final String detectedQuery;
  final bool? isAiActive;
  final List<ProductSummary> items;
}
