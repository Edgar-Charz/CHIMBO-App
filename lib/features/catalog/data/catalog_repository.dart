import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/features/catalog/data/api_catalog_repository.dart';
import 'package:chimbo/features/catalog/data/models/category.dart';
import 'package:chimbo/features/catalog/data/models/product_details.dart';
import 'package:chimbo/features/catalog/data/models/product_page.dart';
import 'package:chimbo/features/catalog/data/models/product_query.dart';
import 'package:chimbo/features/catalog/data/models/product_request.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/catalog/data/models/visual_search_result.dart';
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

  /// `GET /products/{id}/related`: products from the same category.
  Future<List<ProductSummary>> getRelatedProducts(int productId);

  /// `POST /products/search-by-image`.
  Future<VisualSearchResult> searchByImage(String filePath);

  /// Saves a request before the customer shares it externally.
  Future<int> createProductRequest(String description, {String? imagePath});

  /// `GET /product-requests`: non-cancelled requests for the signed-in customer.
  Future<List<ProductRequest>> getProductRequests();

  /// `DELETE /product-requests/{id}`: withdraws a pending or matched request.
  Future<void> cancelProductRequest(int requestId);

  /// `GET /products/{id}/notify-me` — true if the signed-in customer is subscribed.
  Future<bool> isSubscribedStockNotification(int productId);

  /// `POST /products/{id}/notify-me` — subscribe to back-in-stock push. Idempotent.
  Future<void> subscribeStockNotification(int productId);

  /// `DELETE /products/{id}/notify-me` — unsubscribe.
  Future<void> unsubscribeStockNotification(int productId);
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => ApiCatalogRepository(ref.watch(apiClientProvider)),
);
