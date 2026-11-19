import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/features/catalog/data/catalog_repository.dart';
import 'package:chimbo/features/catalog/data/models/category.dart';
import 'package:chimbo/features/catalog/data/models/product_details.dart';
import 'package:chimbo/features/catalog/data/models/product_page.dart';
import 'package:chimbo/features/catalog/data/models/product_query.dart';
import 'package:chimbo/features/catalog/data/models/product_request.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/catalog/data/models/visual_search_result.dart';
import 'package:chimbo/features/home/data/home_data.dart';

/// The catalog from the CHIMBO API (docs/API_REFERENCE.md, "Catalog"). Public: no login needed.
class ApiCatalogRepository implements CatalogRepository {
  const ApiCatalogRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<HomeData> getHome() async {
    final response = await _apiClient.get('/home');
    return HomeData.fromJson(response.dataAsMap);
  }

  @override
  Future<List<Category>> getCategories() async {
    final response = await _apiClient.get('/categories');
    return response.dataAsList
        .map((json) => Category.fromJson(json! as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductPage> getProducts(
    ProductQuery query, {
    required int page,
  }) async {
    final response = await _apiClient.get(
      '/products',
      query: {
        ...query.toQueryParameters(page: page),
        'per_page': ProductPage.size,
      },
    );
    return ProductPage.fromJson(response.dataAsList, response.meta);
  }

  /// `GET /products/{id}`: 404 `NOT_FOUND` when the product doesn't exist or is hidden.
  @override
  Future<ProductDetails> getProduct(int productId) async {
    final response = await _apiClient.get('/products/$productId');
    return ProductDetails.fromJson(response.dataAsMap);
  }

  /// `GET /products/{id}/related`: up to ten products from the same category.
  @override
  Future<List<ProductSummary>> getRelatedProducts(int productId) async {
    final response = await _apiClient.get('/products/$productId/related');
    return response.dataAsList
        .map((json) => ProductSummary.fromJson(json! as Map<String, dynamic>))
        .toList();
  }

  /// `POST /products/search-by-image`: analyzes [filePath] and finds matching products.
  @override
  Future<VisualSearchResult> searchByImage(String filePath) async {
    final response = await _apiClient.upload(
      '/products/search-by-image',
      field: 'image',
      filePath: filePath,
    );
    return VisualSearchResult.fromJson(response.dataAsMap);
  }

  @override
  Future<int> createProductRequest(
    String description, {
    String? imagePath,
  }) async {
    final response = imagePath == null
        ? await _apiClient.post(
            '/product-requests',
            body: {'product_request_description': description},
          )
        : await _apiClient.upload(
            '/product-requests',
            field: 'image',
            filePath: imagePath,
            fields: {'product_request_description': description},
          );
    return response.dataAsMap['product_request_id'] as int;
  }

  @override
  Future<List<ProductRequest>> getProductRequests() async {
    final response = await _apiClient.get('/product-requests');
    return response.dataAsList
        .map((json) => ProductRequest.fromJson(json! as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cancelProductRequest(int requestId) async {
    await _apiClient.delete('/product-requests/$requestId');
  }

  /// `GET /products/{id}/notify-me` — true if signed-in customer is subscribed.
  @override
  Future<bool> isSubscribedStockNotification(int productId) async {
    final response = await _apiClient.get('/products/$productId/notify-me');
    return response.dataAsMap['is_subscribed'] as bool? ?? false;
  }

  /// `POST /products/{id}/notify-me` — subscribe to back-in-stock push.
  @override
  Future<void> subscribeStockNotification(int productId) async {
    await _apiClient.post('/products/$productId/notify-me');
  }

  /// `DELETE /products/{id}/notify-me` — unsubscribe.
  @override
  Future<void> unsubscribeStockNotification(int productId) async {
    await _apiClient.delete('/products/$productId/notify-me');
  }
}
