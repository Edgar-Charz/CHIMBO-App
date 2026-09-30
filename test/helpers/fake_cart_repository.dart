import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/features/cart/data/cart_repository.dart';
import 'package:chimbo/features/cart/data/models/cart.dart';
import 'package:chimbo/features/catalog/data/catalog_repository.dart';
import 'package:chimbo/features/catalog/data/models/category.dart';
import 'package:chimbo/features/catalog/data/models/product_details.dart';
import 'package:chimbo/features/catalog/data/tier_pricing.dart';

import 'fake_customer_store.dart';

/// The server cart for tests: keeps {product id: quantity} per customer and prices it the way
/// the server does (tiers, MOQ, stock).
class FakeCartRepository implements CartRepository {
  const FakeCartRepository({required this._store, required this._catalog});

  static const String _storageName = 'cart';

  final FakeCustomerStore _store;
  final CatalogRepository _catalog;

  @override
  Future<Cart> getCart() async => _price(await _readQuantities());

  @override
  Future<Cart> addItem(int productId, int quantity) async {
    final quantities = await _readQuantities();
    return _save({
      ...quantities,
      productId: (quantities[productId] ?? 0) + quantity,
    });
  }

  @override
  Future<Cart> setQuantity(int productId, int quantity) async {
    return _save({...await _readQuantities(), productId: quantity});
  }

  @override
  Future<Cart> removeItem(int productId) async {
    return _save({...await _readQuantities()}..remove(productId));
  }

  @override
  Future<Cart> clear() => _save({});

  /// Checks MOQ and stock like the server, then stores and prices the cart.
  Future<Cart> _save(Map<int, int> quantities) async {
    final products = await _productsFor(quantities.keys);
    for (final MapEntry(key: productId, value: quantity)
        in quantities.entries) {
      final product = products[productId]!;
      if (quantity < product.summary.moq) {
        throw const ApiException(code: ApiErrorCode.moqNotMet);
      }
      if (quantity > product.stockQuantity) {
        throw const ApiException(code: ApiErrorCode.outOfStock);
      }
    }
    await _store.write(
      _storageName,
      quantities.map((productId, quantity) => MapEntry('$productId', quantity)),
    );
    return _priceWith(quantities, products);
  }

  Future<Map<int, int>> _readQuantities() async {
    final stored = await _store.read(_storageName);
    if (stored is! Map<String, dynamic>) {
      return {};
    }
    return stored.map(
      (productId, quantity) => MapEntry(int.parse(productId), quantity as int),
    );
  }

  Future<Map<int, ProductDetails>> _productsFor(
    Iterable<int> productIds,
  ) async {
    final details = await Future.wait(productIds.map(_catalog.getProduct));
    return {for (final product in details) product.summary.id: product};
  }

  Future<Cart> _price(Map<int, int> quantities) async {
    return _priceWith(quantities, await _productsFor(quantities.keys));
  }

  Future<Cart> _priceWith(
    Map<int, int> quantities,
    Map<int, ProductDetails> products,
  ) async {
    final categories = quantities.isEmpty
        ? const <Category>[]
        : await _catalog.getCategories();
    final groups = <String, List<CartLine>>{};
    for (final MapEntry(key: productId, value: quantity)
        in quantities.entries) {
      final product = products[productId]!;
      final pricing = TierPricing(product.tiers);
      final tier = pricing.tierFor(quantity);
      final hint = pricing.nextTierHint(quantity);
      groups
          .putIfAbsent(
            _topCategoryName(product.summary.categoryId, categories),
            () => [],
          )
          .add(
            CartLine(
              product: product.summary,
              quantity: quantity,
              unitPrice: tier.unitPrice,
              tierMinQuantity: tier.minQuantity,
              lineTotal: pricing.totalFor(quantity),
              nextTierExtraQuantity: hint?.extraQuantity,
              nextTierUnitPrice: hint?.tier.unitPrice,
            ),
          );
    }
    final lines = groups.values.expand((lines) => lines);
    return Cart(
      groups: [
        for (final MapEntry(key: name, value: lines) in groups.entries)
          CartGroup(categoryName: name, lines: lines),
      ],
      lineCount: lines.length,
      pieceCount: lines.fold(0, (sum, line) => sum + line.quantity),
      subtotal: lines.fold(0, (sum, line) => sum + line.lineTotal),
    );
  }

  /// "Cosmetics" for a product in any of its chips (the cart groups by top category).
  String _topCategoryName(int categoryId, List<Category> categories) {
    for (final category in categories) {
      if (category.id == categoryId ||
          category.children.any((child) => child.id == categoryId)) {
        return category.name;
      }
    }
    return '';
  }
}
