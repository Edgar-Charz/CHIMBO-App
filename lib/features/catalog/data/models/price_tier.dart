/// One step of a product's wholesale ladder: from [minQuantity] pieces, each costs [unitPrice].
/// JSON keys follow the `product_price_tiers` table columns.
class PriceTier {
  const PriceTier({required this.minQuantity, required this.unitPrice});

  factory PriceTier.fromJson(Map<String, dynamic> json) {
    return PriceTier(
      minQuantity: json['tier_min_quantity'] as int,
      unitPrice: json['tier_unit_price'] as int,
    );
  }

  final int minQuantity;

  /// Whole TZS.
  final int unitPrice;

  Map<String, dynamic> toJson() => {
    'tier_min_quantity': minQuantity,
    'tier_unit_price': unitPrice,
  };
}
