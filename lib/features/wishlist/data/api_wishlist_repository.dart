import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/wishlist/data/wishlist_repository.dart';

/// Saved products from the CHIMBO API (docs/API_REFERENCE.md, "Wishlist"). Needs a login.
class ApiWishlistRepository implements WishlistRepository {
  const ApiWishlistRepository(this._apiClient);

  final ApiClient _apiClient;

  /// `GET /wishlist/ids` — just the ids, to fill in the hearts.
  @override
  Future<Set<int>> getSavedIds() async {
    final response = await _apiClient.get('/wishlist/ids');
    return response.dataAsList.cast<int>().toSet();
  }

  /// `GET /wishlist` — product cards, most recently saved first.
  @override
  Future<List<ProductSummary>> getSavedProducts() async {
    final response = await _apiClient.get('/wishlist');
    return response.dataAsList
        .map((json) => ProductSummary.fromJson(json! as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(int productId) async {
    await _apiClient.post('/wishlist', body: {'product_id': productId});
  }

  @override
  Future<void> remove(int productId) async {
    await _apiClient.delete('/wishlist/$productId');
  }
}
