import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/features/catalog/data/catalog_repository.dart';
import 'package:chimbo/features/catalog/data/models/category.dart';
import 'package:chimbo/features/catalog/data/models/product_details.dart';
import 'package:chimbo/features/catalog/data/models/product_page.dart';
import 'package:chimbo/features/catalog/data/models/product_query.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/home/data/home_data.dart';

import 'fake_catalog_data.dart';

/// Serves the sample catalog the way the server does (filtering, sorting, sold-out last, pages
/// of 20), so widget tests run without a network.
class FakeCatalogRepository implements CatalogRepository {
  const FakeCatalogRepository();

  static const int _homeRailLength = 8;

  @override
  Future<HomeData> getHome() async {
    final bestSellers = [...devProducts]
      ..sort((a, b) => b.soldCount.compareTo(a.soldCount));
    return HomeData(
      topCategories: devCategories,
      bestSellers: bestSellers
          .take(_homeRailLength)
          .map((product) => product.summary)
          .toList(),
      recentlyOrdered: [
        for (final id in devRecentlyOrderedIds) _find(id).summary,
      ],
    );
  }

  @override
  Future<List<Category>> getCategories() async => devCategories;

  @override
  Future<ProductPage> getProducts(
    ProductQuery query, {
    required int page,
  }) async {
    final byQuery = _comparator(query);
    // Like the server: products that can be ordered first, sold-out ones last.
    final matches =
        devProducts.where((product) => _matches(product, query)).toList()..sort(
          (a, b) => a.summary.isInStock == b.summary.isInStock
              ? byQuery(a, b)
              : (a.summary.isInStock ? -1 : 1),
        );
    // An empty result is still "page 1 of 1".
    final lastPage = matches.isEmpty
        ? 1
        : (matches.length / ProductPage.size).ceil();
    return ProductPage(
      items: matches
          .skip((page - 1) * ProductPage.size)
          .take(ProductPage.size)
          .map((product) => product.summary)
          .toList(),
      page: page,
      lastPage: lastPage,
    );
  }

  @override
  Future<ProductDetails> getProduct(int productId) async {
    return _find(productId).details;
  }

  DevProduct _find(int productId) {
    for (final product in devProducts) {
      if (product.summary.id == productId) {
        return product;
      }
    }
    throw const ApiException(code: ApiErrorCode.notFound);
  }

  bool _matches(DevProduct product, ProductQuery query) {
    final summary = product.summary;
    final categoryId = query.categoryId;
    final search = query.search.trim().toLowerCase();
    final priceBand = query.priceBand;
    final moqBand = query.moqBand;
    return (categoryId == null ||
            summary.categoryId == categoryId ||
            devTopCategoryOf(summary.categoryId) == categoryId) &&
        (query.collection == null ||
            _inCollection(summary, query.collection!)) &&
        (search.isEmpty || summary.name.toLowerCase().contains(search)) &&
        (priceBand == null || priceBand.contains(summary.price)) &&
        (moqBand == null || summary.moq <= moqBand.maxMoq);
  }

  bool _inCollection(ProductSummary summary, ProductCollection collection) {
    return switch (collection) {
      ProductCollection.offers => summary.offer != null,
      ProductCollection.deals => summary.badge == ProductBadge.deal,
      ProductCollection.newArrivals => summary.badge == ProductBadge.newArrival,
      // Best sellers = every product, ordered by sales.
      ProductCollection.bestSellers => true,
    };
  }

  int Function(DevProduct, DevProduct) _comparator(ProductQuery query) {
    final sort = query.collection == ProductCollection.bestSellers
        ? ProductSort.popular
        : query.sort;
    return switch (sort) {
      ProductSort.popular => (a, b) => b.soldCount.compareTo(a.soldCount),
      ProductSort.newest => (a, b) => b.addedOrder.compareTo(a.addedOrder),
      ProductSort.priceLowToHigh => (a, b) => a.summary.price.compareTo(
        b.summary.price,
      ),
      ProductSort.priceHighToLow => (a, b) => b.summary.price.compareTo(
        a.summary.price,
      ),
    };
  }
}
