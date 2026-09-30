/// The one badge a product card may carry (blueprint §6.2: max one per card).
enum ProductBadge {
  bestseller('bestseller'),
  newArrival('new'),
  deal('deal');

  const ProductBadge(this.apiValue);

  final String apiValue;

  static ProductBadge? fromApi(String? value) {
    for (final badge in values) {
      if (badge.apiValue == value) {
        return badge;
      }
    }
    return null;
  }
}

/// What a product card needs (`GET /products` items). JSON keys follow the `products` columns.
class ProductSummary {
  const ProductSummary({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.priceFrom,
    required this.moq,
    required this.sellerName,
    required this.isSellerVerified,
    required this.isInStock,
    this.imageUrl,
    this.badge,
    this.compareAtPrice,
  });

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    return ProductSummary(
      id: json['product_id'] as int,
      name: json['product_name'] as String,
      categoryId: json['category_id'] as int,
      price: json['product_price'] as int,
      priceFrom: json['product_price_from'] as int,
      moq: json['product_moq'] as int,
      sellerName: json['seller_name'] as String,
      isSellerVerified: json['seller_is_verified'] as bool,
      isInStock: json['product_in_stock'] as bool,
      imageUrl: json['product_image_url'] as String?,
      badge: ProductBadge.fromApi(json['product_badge'] as String?),
      compareAtPrice: json['product_compare_at_price'] as int?,
    );
  }

  final int id;
  final String name;

  /// The leaf (sub-)category.
  final int categoryId;

  /// Unit price at the MOQ (first tier), whole TZS.
  final int price;

  /// Best (lowest) tier price. Sent by the API; not shown on cards for now (user choice).
  final int priceFrom;

  /// The old price of a Hot Deal (struck through); null when not on offer.
  final int? compareAtPrice;

  /// Minimum order quantity.
  final int moq;
  final String sellerName;
  final bool isSellerVerified;

  /// False when less than one MOQ is left: the card says "Imeisha" and can't be added.
  final bool isInStock;

  /// Null until the product has a photo (a placeholder is shown).
  final String? imageUrl;
  final ProductBadge? badge;

  /// "-17%" for a deal; null when not on offer.
  int? get discountPercent {
    final oldPrice = compareAtPrice;
    if (oldPrice == null || oldPrice <= price) {
      return null;
    }
    return ((oldPrice - price) * 100 / oldPrice).round();
  }

  Map<String, dynamic> toJson() => {
    'product_id': id,
    'product_name': name,
    'category_id': categoryId,
    'product_price': price,
    'product_price_from': priceFrom,
    'product_compare_at_price': compareAtPrice,
    'product_moq': moq,
    'seller_name': sellerName,
    'seller_is_verified': isSellerVerified,
    'product_in_stock': isInStock,
    'product_image_url': imageUrl,
    'product_badge': badge?.apiValue,
  };
}
