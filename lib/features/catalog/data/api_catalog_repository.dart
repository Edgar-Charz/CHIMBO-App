import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/features/catalog/data/catalog_repository.dart';
import 'package:chimbo/features/catalog/data/models/category.dart';
import 'package:chimbo/features/catalog/data/models/product_details.dart';
import 'package:chimbo/features/catalog/data/models/product_page.dart';
import 'package:chimbo/features/catalog/data/models/product_query.dart';
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
}
