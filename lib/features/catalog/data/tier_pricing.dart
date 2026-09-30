import 'package:chimbo/features/catalog/data/models/price_tier.dart';

/// The next cheaper tier and how many more pieces reach it ("Ongeza pcs 16 …").
typedef NextTierHint = ({int extraQuantity, PriceTier tier});

/// Preview of wholesale prices on the product page, from the tiers the server sent.
///
/// Blueprint §8.3: only a preview — the cart's binding totals always come from the server's
/// `PricingService`. [tiers] is never empty and is sorted by `minQuantity` (the first tier starts
/// at the MOQ) — the server guarantees both.
class TierPricing {
  const TierPricing(this.tiers);

  final List<PriceTier> tiers;

  int get moq => tiers.first.minQuantity;

  /// The tier that applies to [quantity] (the highest one it reaches).
  PriceTier tierFor(int quantity) {
    return tiers.lastWhere(
      (tier) => quantity >= tier.minQuantity,
      orElse: () => tiers.first,
    );
  }

  int unitPriceFor(int quantity) => tierFor(quantity).unitPrice;

  int totalFor(int quantity) => unitPriceFor(quantity) * quantity;

  /// "Unaokoa TZS 4,000": what [quantity] saves compared with paying the MOQ price for each.
  int savingsFor(int quantity) {
    return (tiers.first.unitPrice - unitPriceFor(quantity)) * quantity;
  }

  /// Null when [quantity] already has the best price.
  NextTierHint? nextTierHint(int quantity) {
    for (final tier in tiers) {
      if (tier.minQuantity > quantity) {
        return (extraQuantity: tier.minQuantity - quantity, tier: tier);
      }
    }
    return null;
  }

  /// Last quantity of the tier at [index], or null for the open-ended last tier ("60+").
  int? maxQuantityOfTier(int index) {
    return index + 1 < tiers.length ? tiers[index + 1].minQuantity - 1 : null;
  }
}
