import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/cart/data/cart_repository.dart';
import 'package:chimbo/features/cart/data/models/cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The cart for the whole app (badge, Kikapu, checkout). Each change stores the server's new
/// cart; errors (MOQ, stock) reach the caller so the screen can explain them.
class CartController extends AsyncNotifier<Cart> {
  CartRepository get _repository => ref.read(cartRepositoryProvider);

  @override
  Future<Cart> build() {
    // A logged-out customer has no cart; reload when someone logs in.
    final userId = ref.watch(
      authControllerProvider.select((state) => state.user?.id),
    );
    return userId == null ? Future.value(Cart.empty) : _repository.getCart();
  }

  Future<void> add(int productId, int quantity) async {
    state = AsyncData(await _repository.addItem(productId, quantity));
  }

  Future<void> setQuantity(int productId, int quantity) async {
    state = AsyncData(await _repository.setQuantity(productId, quantity));
  }

  Future<void> remove(int productId) async {
    state = AsyncData(await _repository.removeItem(productId));
  }

  /// After an order or "Agiza Tena": the server changed the cart, so load it again.
  void reload() => ref.invalidateSelf();
}

final cartControllerProvider = AsyncNotifierProvider<CartController, Cart>(
  CartController.new,
);

/// Number on the Kikapu badge (different products in the cart).
final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartControllerProvider).value?.lineCount ?? 0,
);
