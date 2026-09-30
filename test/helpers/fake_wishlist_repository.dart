import 'package:chimbo/features/catalog/data/catalog_repository.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/wishlist/data/wishlist_repository.dart';

import 'fake_customer_store.dart';

/// Saved product ids kept per customer on the phone, for tests (no network).
class FakeWishlistRepository implements WishlistRepository {
  const FakeWishlistRepository({required this._store, required this._catalog});

  static const String _storageName = 'wishlist';

  final FakeCustomerStore _store;
  final CatalogRepository _catalog;

  @override
  Future<Set<int>> getSavedIds() async {
    final stored = await _store.read(_storageName);
    return stored is List<dynamic> ? stored.cast<int>().toSet() : {};
  }

  @override
  Future<List<ProductSummary>> getSavedProducts() async {
    final ids = await getSavedIds();
    // Stored in the order they were saved; newest first like the server.
    final details = await Future.wait(
      ids.toList().reversed.map(_catalog.getProduct),
    );
    return [for (final product in details) product.summary];
  }

  @override
  Future<void> save(int productId) async =>
      _write({...await getSavedIds(), productId});

  @override
  Future<void> remove(int productId) async =>
      _write({...await getSavedIds()}..remove(productId));

  Future<void> _write(Set<int> ids) => _store.write(_storageName, ids.toList());
}
