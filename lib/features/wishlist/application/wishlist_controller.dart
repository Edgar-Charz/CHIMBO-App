import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/wishlist/data/wishlist_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which products the customer has liked. Hearts update at once; if saving fails the heart
/// goes back and the error reaches the caller.
class WishlistController extends AsyncNotifier<Set<int>> {
  WishlistRepository get _repository => ref.read(wishlistRepositoryProvider);

  @override
  Future<Set<int>> build() async {
    final userId = ref.watch(
      authControllerProvider.select((state) => state.user?.id),
    );
    return userId == null ? const {} : _repository.getSavedIds();
  }

  /// Likes or unlikes [productId]; returns true when it is now saved.
  Future<bool> toggle(int productId) async {
    final before = state.value ?? const <int>{};
    final willSave = !before.contains(productId);
    state = AsyncData(
      willSave ? {...before, productId} : ({...before}..remove(productId)),
    );
    try {
      if (willSave) {
        await _repository.save(productId);
      } else {
        await _repository.remove(productId);
      }
      return willSave;
    } on Exception {
      state = AsyncData(before);
      rethrow;
    }
  }
}

final wishlistControllerProvider =
    AsyncNotifierProvider<WishlistController, Set<int>>(WishlistController.new);

/// The Vipendwa screen's cards. Reloads when a heart changes, so an unliked product leaves the
/// list at once.
final savedProductsProvider = FutureProvider.autoDispose<List<ProductSummary>>((
  ref,
) async {
  // selectAsync (not .future): reruns on every heart change, not only on reload.
  final savedIds = await ref.watch(
    wishlistControllerProvider.selectAsync((ids) => ids),
  );
  final products = await ref
      .read(wishlistRepositoryProvider)
      .getSavedProducts();
  // Hearts change at once, before the save finishes; follow the hearts, not the fetch.
  return products.where((product) => savedIds.contains(product.id)).toList();
});
