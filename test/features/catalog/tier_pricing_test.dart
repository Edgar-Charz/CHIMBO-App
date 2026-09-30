import 'package:chimbo/features/catalog/data/models/price_tier.dart';
import 'package:chimbo/features/catalog/data/tier_pricing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The Vaseline ladder from the design (PDF p.6).
  const pricing = TierPricing([
    PriceTier(minQuantity: 1, unitPrice: 5500),
    PriceTier(minQuantity: 6, unitPrice: 5000),
    PriceTier(minQuantity: 24, unitPrice: 4700),
    PriceTier(minQuantity: 60, unitPrice: 4400),
  ]);

  test('each quantity gets the price of the highest tier it reaches', () {
    expect(pricing.unitPriceFor(1), 5500);
    expect(pricing.unitPriceFor(5), 5500);
    expect(pricing.unitPriceFor(6), 5000);
    expect(pricing.unitPriceFor(23), 5000);
    expect(pricing.unitPriceFor(24), 4700);
    expect(pricing.unitPriceFor(59), 4700);
    expect(pricing.unitPriceFor(60), 4400);
    expect(pricing.unitPriceFor(500), 4400);
  });

  test('8 pieces save TZS 4,000, as in the design', () {
    expect(pricing.savingsFor(8), 4000);
    expect(pricing.savingsFor(1), 0);
    expect(pricing.totalFor(8), 40000);
  });

  test('the hint names the next cheaper tier until the best one', () {
    final hint = pricing.nextTierHint(8);
    expect(hint?.extraQuantity, 16);
    expect(hint?.tier.unitPrice, 4700);
    expect(pricing.nextTierHint(60), isNull);
  });

  test('tier ranges read 1–5, 6–23, 24–59, 60+', () {
    expect(pricing.maxQuantityOfTier(0), 5);
    expect(pricing.maxQuantityOfTier(2), 59);
    expect(pricing.maxQuantityOfTier(3), isNull);
  });
}
