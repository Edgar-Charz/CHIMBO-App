/// Ready-made product lists behind Home's quick actions (`collection` param).
enum ProductCollection {
  /// "Ofa za muda": running time-limited offers, ending soonest first.
  offers('offers'),
  deals('deals'),
  newArrivals('new'),
  bestSellers('best_sellers');

  const ProductCollection(this.apiValue);

  final String apiValue;

  static ProductCollection? fromApi(String? value) {
    for (final collection in values) {
      if (collection.apiValue == value) {
        return collection;
      }
    }
    return null;
  }
}

/// "Panga" options (`sort` param).
enum ProductSort {
  popular('popular'),
  newest('newest'),
  priceLowToHigh('price_asc'),
  priceHighToLow('price_desc');

  const ProductSort(this.apiValue);

  final String apiValue;
}

/// Legacy price bands accepted for compatibility with older callers.
enum PriceBand {
  under5000(null, 4999),
  from5000To10000(5000, 10000),
  over10000(10001, null);

  const PriceBand(this.minPrice, this.maxPrice);

  final int? minPrice;
  final int? maxPrice;

  bool contains(int price) =>
      (minPrice == null || price >= minPrice!) &&
      (maxPrice == null || price <= maxPrice!);
}

/// Legacy MOQ bands accepted for compatibility with older callers.
enum MoqBand {
  single(1),
  upTo6(6),
  upTo12(12);

  const MoqBand(this.maxMoq);

  final int maxMoq;
}

/// Everything that decides which products a listing shows. Immutable: each change makes a copy.
class ProductQuery {
  const ProductQuery({
    this.categoryId,
    this.collection,
    this.search = '',
    this.sort = ProductSort.popular,
    this.minPrice,
    this.maxPrice,
    this.maxMoq,
    this.priceBand,
    this.moqBand,
  });

  /// A top category or a chip (sub-category); null = all products.
  final int? categoryId;
  final ProductCollection? collection;
  final String search;
  final ProductSort sort;
  final int? minPrice;
  final int? maxPrice;
  final int? maxMoq;
  final PriceBand? priceBand;
  final MoqBand? moqBand;

  bool get hasFilters =>
      minPrice != null ||
      maxPrice != null ||
      maxMoq != null ||
      priceBand != null ||
      moqBand != null;

  // Nullable fields use a function so "set to null" and "leave as is" can be told apart.
  ProductQuery copyWith({
    int? Function()? categoryId,
    String? search,
    ProductSort? sort,
    int? Function()? minPrice,
    int? Function()? maxPrice,
    int? Function()? maxMoq,
    PriceBand? Function()? priceBand,
    MoqBand? Function()? moqBand,
  }) {
    return ProductQuery(
      categoryId: categoryId == null ? this.categoryId : categoryId(),
      collection: collection,
      search: search ?? this.search,
      sort: sort ?? this.sort,
      minPrice: minPrice == null ? this.minPrice : minPrice(),
      maxPrice: maxPrice == null ? this.maxPrice : maxPrice(),
      maxMoq: maxMoq == null ? this.maxMoq : maxMoq(),
      priceBand: priceBand == null ? this.priceBand : priceBand(),
      moqBand: moqBand == null ? this.moqBand : moqBand(),
    );
  }

  /// Request params for `GET /products` (blueprint §12.2).
  Map<String, dynamic> toQueryParameters({required int page}) {
    final queryMinPrice = minPrice ?? priceBand?.minPrice;
    final queryMaxPrice = maxPrice ?? priceBand?.maxPrice;
    final queryMaxMoq = maxMoq ?? moqBand?.maxMoq;
    return {
      'category_id': ?categoryId,
      'collection': ?collection?.apiValue,
      if (search.isNotEmpty) 'q': search,
      'sort': sort.apiValue,
      'min_price': ?queryMinPrice,
      'max_price': ?queryMaxPrice,
      'max_moq': ?queryMaxMoq,
      'page': page,
    };
  }
}
