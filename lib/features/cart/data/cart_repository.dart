import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/features/cart/data/api_cart_repository.dart';
import 'package:chimbo/features/cart/data/models/cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The customer's cart (blueprint §12.2 "cart"). Every change returns the full priced cart.
abstract interface class CartRepository {
  /// `GET /cart`.
  Future<Cart> getCart();

  /// `POST /cart/items`: adds [quantity] to what is already in the cart.
  Future<Cart> addItem(int productId, int quantity);

  /// `PATCH /cart/items/{product_id}`: MOQ is a hard minimum (D-8).
  Future<Cart> setQuantity(int productId, int quantity);

  /// `DELETE /cart/items/{product_id}`.
  Future<Cart> removeItem(int productId);

  /// `DELETE /cart` (also done by the server when an order is placed).
  Future<Cart> clear();
}

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => ApiCartRepository(ref.watch(apiClientProvider)),
);
