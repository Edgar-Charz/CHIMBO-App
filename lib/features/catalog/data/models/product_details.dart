import 'package:chimbo/features/catalog/data/models/price_tier.dart';
import 'package:chimbo/features/catalog/data/models/product_photo.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/checkout/data/models/checkout_options.dart';
/// Everything the product page shows (`GET /products/{id}`).
class ProductDetails {
  const ProductDetails({
    required this.summary,
    required this.tiers,
    required this.stockQuantity,
    required this.deliveryDaysMin,
    required this.deliveryDaysMax,
    this.photos = const [],
    this.description,
    this.deliveryOptions = const [],
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    final tiers = json['tiers'] as List<dynamic>;
    final gallery = json['gallery'] as List<dynamic>? ?? const [];
    final images = json['images'] as List<dynamic>? ?? const [];
    return ProductDetails(
      summary: ProductSummary.fromJson(json),
      tiers: tiers
          .map((tier) => PriceTier.fromJson(tier as Map<String, dynamic>))
          .toList(),
      stockQuantity: json['product_stock_quantity'] as int,
      deliveryDaysMin: json['product_delivery_days_min'] as int,
      deliveryDaysMax: json['product_delivery_days_max'] as int,
      // `gallery` has every size; `images` (display order, medium only) is the fallback.
      photos: gallery.isNotEmpty
          ? gallery
                .map(
                  (photo) =>
                      ProductPhoto.fromJson(photo as Map<String, dynamic>),
                )
                .toList()
          : images.cast<String>().map(ProductPhoto.singleSize).toList(),
      description: json['product_description'] as String?,
      deliveryOptions: [
        for (final option
            in json['delivery_options'] as List<dynamic>? ?? const [])
          DeliveryMethod.fromJson(option as Map<String, dynamic>),
      ],
    );
  }

  final ProductSummary summary;

  /// Sorted by [PriceTier.minQuantity]; the first tier starts at the MOQ.
  final List<PriceTier> tiers;
  final int stockQuantity;
  final int deliveryDaysMin;
  final int deliveryDaysMax;

  /// How orders reach customers (Bolt in Dar, upcountry, pickup …); empty from an older server, then
  /// [deliveryDaysMin]–[deliveryDaysMax] is shown.
  final List<DeliveryMethod> deliveryOptions;

  /// The quickest option that brings the order (pickup left out), for the info strip.
  DeliveryMethod? get fastestDelivery {
    final delivered =
        deliveryOptions.where((option) => !option.isPickup).toList()
          ..sort((a, b) => a.daysMax.compareTo(b.daysMax));
    return delivered.firstOrNull;
  }

  /// In display order; empty until the admin uploads photos (a placeholder shows).
  final List<ProductPhoto> photos;
  final String? description;

  Map<String, dynamic> toJson() => {
    ...summary.toJson(),
    'tiers': tiers.map((tier) => tier.toJson()).toList(),
    'product_stock_quantity': stockQuantity,
    'product_delivery_days_min': deliveryDaysMin,
    'product_delivery_days_max': deliveryDaysMax,
    'images': [for (final photo in photos) photo.mediumUrl],
    'gallery': [for (final photo in photos) photo.toJson()],
    'product_description': description,
  };
}
