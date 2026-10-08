/// A time-limited offer running on a product (`product_offer`): every tier is [percent] cheaper
/// until [endsAt]. The prices the API sends already include it.
class ProductOffer {
  const ProductOffer({required this.percent, required this.endsAt});

  factory ProductOffer.fromJson(Map<String, dynamic> json) {
    return ProductOffer(
      percent: json['product_offer_percent'] as int,
      endsAt: DateTime.parse(json['product_offer_ends_at'] as String),
    );
  }

  /// "Ofa −15%".
  final int percent;
  final DateTime endsAt;

  Map<String, dynamic> toJson() => {
    'product_offer_percent': percent,
    'product_offer_ends_at': endsAt.toIso8601String(),
  };
}
