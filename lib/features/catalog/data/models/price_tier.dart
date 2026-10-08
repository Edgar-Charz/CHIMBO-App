/// One step of a product's wholesale ladder: from [minQuantity] pieces, each costs [unitPrice].
/// JSON keys follow the `product_price_tiers` table columns.
class PriceTier {
  const PriceTier({
    required this.minQuantity,
    required this.unitPrice,
    this.priceBeforeOffer,
  });

  factory PriceTier.fromJson(Map<String, dynamic> json) {
    return PriceTier(
      minQuantity: json['tier_min_quantity'] as int,
      unitPrice: json['tier_unit_price'] as int,
      priceBeforeOffer: json['tier_price_before_offer'] as int?,
    );
  }

  final int minQuantity;

  /// Whole TZS (the offer price while an offer runs).
  final int unitPrice;

  /// The normal price, shown crossed out while an offer runs; null otherwise.
  final int? priceBeforeOffer;

  Map<String, dynamic> toJson() => {
    'tier_min_quantity': minQuantity,
    'tier_unit_price': unitPrice,
    'tier_price_before_offer': priceBeforeOffer,
  };
}
