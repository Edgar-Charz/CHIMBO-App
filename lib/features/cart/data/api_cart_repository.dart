import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/core/network/api_response.dart';
import 'package:chimbo/features/cart/data/cart_repository.dart';
import 'package:chimbo/features/cart/data/models/cart.dart';

/// Kikapu from the CHIMBO API (docs/API_REFERENCE.md, "Cart"). Every call returns the whole
/// cart priced by the server; the app never sends a price.
class ApiCartRepository implements CartRepository {
  const ApiCartRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Cart> getCart() async => _cart(await _apiClient.get('/cart'));

  @override
  Future<Cart> addItem(int productId, int quantity) async {
    return _cart(
      await _apiClient.post(
        '/cart/items',
        body: {'product_id': productId, 'quantity': quantity},
      ),
    );
  }

  @override
  Future<Cart> setQuantity(int productId, int quantity) async {
    return _cart(
      await _apiClient.patch(
        '/cart/items/$productId',
        body: {'quantity': quantity},
      ),
    );
  }

  @override
  Future<Cart> removeItem(int productId) async {
    return _cart(await _apiClient.delete('/cart/items/$productId'));
  }

  @override
  Future<Cart> clear() async => _cart(await _apiClient.delete('/cart'));

  Cart _cart(ApiResponse response) => Cart.fromJson(response.dataAsMap);
}
