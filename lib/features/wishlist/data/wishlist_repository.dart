import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/wishlist/data/api_wishlist_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Saved ("liked") products (blueprint §12.2 "wishlist").
abstract interface class WishlistRepository {
  /// Ids of the saved products (the API also marks cards with `is_wishlisted`).
  Future<Set<int>> getSavedIds();

  /// `GET /wishlist`: the saved products as cards, most recently saved first.
  Future<List<ProductSummary>> getSavedProducts();

  /// `POST /wishlist`.
  Future<void> save(int productId);

  /// `DELETE /wishlist/{product_id}`.
  Future<void> remove(int productId);
}

final wishlistRepositoryProvider = Provider<WishlistRepository>(
  (ref) => ApiWishlistRepository(ref.watch(apiClientProvider)),
);
