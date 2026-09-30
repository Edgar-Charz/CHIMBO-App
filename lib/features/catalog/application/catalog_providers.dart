import 'package:chimbo/features/catalog/data/catalog_repository.dart';
import 'package:chimbo/features/catalog/data/models/category.dart';
import 'package:chimbo/features/catalog/data/models/product_details.dart';
import 'package:chimbo/features/catalog/data/models/product_query.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/home/data/home_data.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/data/orders_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final catalog = ref.watch(catalogRepositoryProvider);
  final ordersRepository = ref.watch(ordersRepositoryProvider);
  final home = await catalog.getHome();
  // The current Home endpoint does not populate recently_ordered yet. Build
  // that rail from this customer's orders until the endpoint provides it.
  if (home.recentlyOrdered.isNotEmpty) return home;

  try {
    final orders = await ordersRepository.getOrders(OrderGroup.all);
    final productIds = <int>{};
    for (final order in orders) {
      for (final item in order.items) {
        productIds.add(item.productId);
        if (productIds.length == 8) break;
      }
      if (productIds.length == 8) break;
    }
    final products = await Future.wait(
      productIds.map((id) async {
        try {
          return (await catalog.getProduct(id)).summary;
        } catch (_) {
          // An item may have been removed from the catalog since the order.
          return null;
        }
      }),
    );
    return HomeData(
      topCategories: home.topCategories,
      banners: home.banners,
      deals: home.deals,
      newArrivals: home.newArrivals,
      bestSellers: home.bestSellers,
      recentlyOrdered: products.whereType<ProductSummary>().toList(),
    );
  } catch (_) {
    // A failed order lookup should not prevent the rest of Home from loading.
    return home;
  }
});

typedef CategorySectionsScope = ({
  int categoryId,
  String search,
  ProductSort sort,
  int? minPrice,
  int? maxPrice,
  int? maxMoq,
});

class CategoryProductSections {
  const CategoryProductSections({
    required this.newArrivals,
    required this.bestSellers,
    required this.trending,
    required this.deals,
  });

  final List<ProductSummary> newArrivals;
  final List<ProductSummary> bestSellers;
  final List<ProductSummary> trending;
  final List<ProductSummary> deals;
}

final categoryProductSectionsProvider = FutureProvider.autoDispose
    .family<CategoryProductSections, CategorySectionsScope>((ref, scope) async {
      final catalog = ref.watch(catalogRepositoryProvider);
      Future<List<ProductSummary>> load({
        ProductCollection? collection,
        ProductSort? sort,
      }) async {
        try {
          final page = await catalog.getProducts(
            ProductQuery(
              categoryId: scope.categoryId,
              collection: collection,
              search: scope.search,
              sort: sort ?? scope.sort,
              minPrice: scope.minPrice,
              maxPrice: scope.maxPrice,
              maxMoq: scope.maxMoq,
            ),
            page: 1,
          );
          return page.items.take(8).toList();
        } on Exception {
          // A missing curated collection should not hide other rails or Bidhaa Zote.
          return const <ProductSummary>[];
        }
      }

      final sections = await Future.wait([
        load(
          collection: ProductCollection.newArrivals,
          sort: ProductSort.newest,
        ),
        load(
          collection: ProductCollection.bestSellers,
          sort: ProductSort.popular,
        ),
        load(sort: ProductSort.popular),
        load(collection: ProductCollection.deals, sort: ProductSort.popular),
      ]);
      return CategoryProductSections(
        newArrivals: sections[0],
        bestSellers: sections[1],
        trending: sections[2],
        deals: sections[3],
      );
    });

/// Top categories with their chips; loaded once and kept.
final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(catalogRepositoryProvider).getCategories(),
);

/// One product page's data, cached per product id while it is on screen.
final productDetailsProvider = FutureProvider.autoDispose
    .family<ProductDetails, int>(
      (ref, productId) =>
          ref.watch(catalogRepositoryProvider).getProduct(productId),
    );
