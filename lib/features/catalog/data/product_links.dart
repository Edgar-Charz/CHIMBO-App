import 'package:chimbo/core/config/env.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';

abstract final class ProductLinks {
  static String webUrl(ProductSummary product) {
    final websiteBaseUrl = Env.apiBaseUrl.replaceFirst(
      RegExp(r'/api/v1/?$'),
      '',
    );
    return '$websiteBaseUrl/p/${product.id}-${product.slug}';
  }
}
