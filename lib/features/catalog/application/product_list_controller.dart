import 'package:chimbo/features/catalog/data/catalog_repository.dart';
import 'package:chimbo/features/catalog/data/models/product_query.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which listing a screen shows: a category, a Home collection, or everything (Gundua).
typedef ProductListScope = ({int? categoryId, ProductCollection? collection});

/// The customer's choices on one listing: chip, search, sort and filters.
class ProductQueryController extends Notifier<ProductQuery> {
  // Riverpod families pass their argument to the constructor.
  ProductQueryController(this.scope);

  final ProductListScope scope;

  @override
  ProductQuery build() {
    return ProductQuery(
      categoryId: scope.categoryId,
      collection: scope.collection,
    );
  }

  /// A chip, or null for "Zote" (back to the listing's own category).
  void selectCategory(int? chipCategoryId) {
    state = state.copyWith(
      categoryId: () => chipCategoryId ?? scope.categoryId,
    );
  }

  void search(String text) => state = state.copyWith(search: text.trim());

  void sort(ProductSort sort) => state = state.copyWith(sort: sort);

  void filter({int? minPrice, int? maxPrice, int? maxMoq}) {
    state = state.copyWith(
      minPrice: () => minPrice,
      maxPrice: () => maxPrice,
      maxMoq: () => maxMoq,
    );
  }
}

final productQueryProvider = NotifierProvider.autoDispose
    .family<ProductQueryController, ProductQuery, ProductListScope>(
      ProductQueryController.new,
    );

/// The products loaded so far for the current query.
class ProductListState {
  const ProductListState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<ProductSummary> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  ProductListState copyWith({
    List<ProductSummary>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ProductListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// A paginated listing. It watches the query, so any change (chip, search, sort, filter)
/// reloads page 1 by itself; [loadMore] adds the next page for infinite scroll.
class ProductListController extends AsyncNotifier<ProductListState> {
  ProductListController(this.scope);

  final ProductListScope scope;

  CatalogRepository get _repository => ref.read(catalogRepositoryProvider);

  @override
  Future<ProductListState> build() async {
    final query = ref.watch(productQueryProvider(scope));
    final firstPage = await _repository.getProducts(query, page: 1);
    return ProductListState(
      items: firstPage.items,
      page: firstPage.page,
      hasMore: firstPage.hasMore,
    );
  }

  /// Adds the next page; does nothing while a page is loading or when all are loaded.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final next = await _repository.getProducts(
        ref.read(productQueryProvider(scope)),
        page: current.page + 1,
      );
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          page: next.page,
          hasMore: next.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Exception {
      // Keep what is shown; scrolling again retries.
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final productListControllerProvider = AsyncNotifierProvider.autoDispose
    .family<ProductListController, ProductListState, ProductListScope>(
      ProductListController.new,
    );
