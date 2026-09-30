import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/features/catalog/data/api_catalog_repository.dart';
import 'package:chimbo/features/catalog/data/models/category.dart';
import 'package:chimbo/features/catalog/data/models/product_details.dart';
import 'package:chimbo/features/catalog/data/models/product_page.dart';
import 'package:chimbo/features/catalog/data/models/product_query.dart';
import 'package:chimbo/features/home/data/home_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Catalog reads (blueprint §12.2 "Home & catalog"). Every method throws `ApiException`.
abstract interface class CatalogRepository {
  /// `GET /home`.
  Future<HomeData> getHome();

  /// `GET /categories`: top categories with their chips.
  Future<List<Category>> getCategories();

  /// `GET /products` — [page] starts at 1.
  Future<ProductPage> getProducts(ProductQuery query, {required int page});

  /// `GET /products/{id}`.
  Future<ProductDetails> getProduct(int productId);
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => ApiCatalogRepository(ref.watch(apiClientProvider)),
);
