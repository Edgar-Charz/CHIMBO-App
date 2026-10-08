// Sample catalog (PDF pp.4–5 plus a few more) for tests: the app's tests never call the real
// API. Prices are illustrative.

import 'package:chimbo/features/catalog/data/models/category.dart';
import 'package:chimbo/features/catalog/data/models/price_tier.dart';
import 'package:chimbo/features/catalog/data/models/product_details.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';

/// A sample product plus the numbers the server sorts by.
class DevProduct {
  const DevProduct(
    this.details, {
    required this.soldCount,
    required this.addedOrder,
  });

  final ProductDetails details;
  final int soldCount;

  /// Higher = added more recently ("Mpya zaidi").
  final int addedOrder;

  ProductSummary get summary => details.summary;
}

const int devCosmeticsId = 1;
const int devJewelryId = 2;

const String _cosmeticsSeller = 'Shamba la Vipodozi';
const String _jewelrySeller = 'Mrembo Muuza Urembo';

const List<Category> devCategories = [
  Category(
    id: devCosmeticsId,
    name: 'Cosmetics',
    tagline: 'Shamba la Vipodozi',
    children: [
      Category(id: 11, name: 'Skin Care'),
      Category(id: 12, name: 'Hair Care'),
      Category(id: 13, name: 'Body Care'),
      Category(id: 14, name: 'Baby Care'),
      Category(id: 15, name: 'Women Care'),
      Category(id: 16, name: 'Sanitary'),
      Category(id: 17, name: 'Makeup'),
    ],
  ),
  Category(
    id: devJewelryId,
    name: 'Jewelry',
    tagline: 'Mrembo Muuza Urembo',
    children: [
      Category(id: 21, name: 'Earrings'),
      Category(id: 22, name: 'Necklaces'),
      Category(id: 23, name: 'Bracelets'),
      Category(id: 24, name: 'Rings'),
      Category(id: 25, name: 'Anklets'),
      Category(id: 26, name: 'Watches'),
      Category(id: 27, name: 'Hair Accessories'),
      Category(id: 28, name: 'Bags'),
    ],
  ),
];

/// The top category a chip belongs to.
int devTopCategoryOf(int categoryId) =>
    categoryId ~/ 10 == 0 ? categoryId : categoryId ~/ 10;

DevProduct _product({
  required int id,
  required String name,
  required int categoryId,
  required List<(int, int)> tiers,
  ProductBadge? badge,
  int? compareAtPrice,
  int soldCount = 0,
  int stock = 500,
  String? description,
}) {
  final isJewelry = devTopCategoryOf(categoryId) == devJewelryId;
  final priceTiers = [
    for (final (minQuantity, unitPrice) in tiers)
      PriceTier(minQuantity: minQuantity, unitPrice: unitPrice),
  ];
  return DevProduct(
    ProductDetails(
      summary: ProductSummary(
        id: id,
        name: name,
        slug: name
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
            .replaceAll(RegExp(r'^-|-$'), ''),
        categoryId: categoryId,
        price: priceTiers.first.unitPrice,
        priceFrom: priceTiers.last.unitPrice,
        compareAtPrice: compareAtPrice,
        moq: priceTiers.first.minQuantity,
        sellerName: isJewelry ? _jewelrySeller : _cosmeticsSeller,
        isSellerVerified: true,
        isInStock: stock >= priceTiers.first.minQuantity,
        badge: badge,
      ),
      tiers: priceTiers,
      stockQuantity: stock,
      deliveryDaysMin: 2,
      deliveryDaysMax: 3,
      description: description,
    ),
    soldCount: soldCount,
    addedOrder: id,
  );
}

final List<DevProduct> devProducts = [
  _product(
    id: 101,
    name: 'Vaseline Petroleum Jelly 400ml',
    categoryId: 11,
    tiers: [(1, 5500), (6, 5000), (24, 4700), (60, 4400)],
    badge: ProductBadge.bestseller,
    soldCount: 980,
    stock: 520,
    description:
        'Mafuta safi ya petroleum jelly kwa ngozi kavu. Chupa ya 400ml, '
        'inafaa kwa rejareja ya duka lako.',
  ),
  _product(
    id: 102,
    name: 'Hair Food 500ml (Dark & Lovely)',
    categoryId: 12,
    tiers: [(1, 6000), (12, 5600), (48, 5200)],
    soldCount: 640,
  ),
  _product(
    id: 103,
    name: 'Nivea Body Lotion 400ml',
    categoryId: 13,
    tiers: [(1, 7000), (12, 6500), (48, 6100)],
    badge: ProductBadge.newArrival,
    soldCount: 410,
  ),
  _product(
    id: 104,
    name: 'Dove Beauty Soap 100g (Pack of 3)',
    categoryId: 11,
    tiers: [(3, 4200), (24, 3900), (72, 3600)],
    soldCount: 530,
  ),
  _product(
    id: 105,
    name: 'Nourish Body Oil 100ml',
    categoryId: 13,
    tiers: [(2, 4800), (12, 4500), (48, 4200)],
    soldCount: 220,
    stock: 0,
  ),
  _product(
    id: 106,
    name: 'Dettol Wet Wipes 50s (Pack)',
    categoryId: 16,
    tiers: [(4, 3200), (24, 2950), (96, 2700)],
    soldCount: 300,
  ),
  _product(
    id: 107,
    name: "Johnson's Baby Oil 200ml",
    categoryId: 14,
    tiers: [(1, 6500), (12, 6000), (48, 5600)],
    soldCount: 180,
  ),
  _product(
    id: 108,
    name: 'Always Ultra Pads (Pack of 8)',
    categoryId: 15,
    tiers: [(6, 2800), (36, 2550)],
    badge: ProductBadge.deal,
    compareAtPrice: 3400,
    soldCount: 350,
  ),
  _product(
    id: 109,
    name: 'Glow Face Serum 30ml',
    categoryId: 11,
    tiers: [(2, 9500), (12, 8900)],
    badge: ProductBadge.newArrival,
    soldCount: 90,
  ),
  _product(
    id: 110,
    name: 'Matte Lipstick Set (6 colours)',
    categoryId: 17,
    tiers: [(3, 7500), (24, 6900)],
    badge: ProductBadge.deal,
    compareAtPrice: 9000,
    soldCount: 260,
  ),
  _product(
    id: 111,
    name: 'Coconut Hair Oil 250ml',
    categoryId: 12,
    tiers: [(1, 3500), (24, 3200)],
    soldCount: 150,
  ),
  _product(
    id: 112,
    name: 'Shea Butter 250g',
    categoryId: 13,
    tiers: [(1, 5000), (24, 4600)],
    soldCount: 120,
  ),
  _product(
    id: 201,
    name: 'Necklace + Earrings Set',
    categoryId: 22,
    tiers: [(6, 8500), (24, 7900), (60, 7400)],
    badge: ProductBadge.bestseller,
    soldCount: 720,
  ),
  _product(
    id: 202,
    name: 'Hoop Earrings Set',
    categoryId: 21,
    tiers: [(12, 1200), (60, 1050)],
    soldCount: 610,
  ),
  _product(
    id: 203,
    name: 'Gold Plated Bangles',
    categoryId: 23,
    tiers: [(6, 9200), (24, 8600)],
    badge: ProductBadge.newArrival,
    soldCount: 240,
  ),
  _product(
    id: 204,
    name: 'Stainless Steel Rings',
    categoryId: 24,
    tiers: [(12, 2500), (60, 2200)],
    soldCount: 390,
  ),
  _product(
    id: 205,
    name: 'Anklet Set',
    categoryId: 25,
    tiers: [(6, 3800), (36, 3400)],
    soldCount: 170,
  ),
  _product(
    id: 206,
    name: 'Classic Watch',
    categoryId: 26,
    tiers: [(3, 18000), (12, 16500)],
    badge: ProductBadge.deal,
    compareAtPrice: 21500,
    soldCount: 140,
    stock: 80,
  ),
  _product(
    id: 207,
    name: 'Pearl Hair Clips (Set of 6)',
    categoryId: 27,
    tiers: [(12, 1800), (60, 1550)],
    soldCount: 200,
    stock: 0,
  ),
  _product(
    id: 208,
    name: 'Leather Handbag',
    categoryId: 28,
    tiers: [(2, 25000), (10, 23000)],
    badge: ProductBadge.newArrival,
    soldCount: 60,
    stock: 40,
  ),
  _product(
    id: 209,
    name: 'Beaded Bracelet Set',
    categoryId: 23,
    tiers: [(12, 1500), (60, 1300)],
    soldCount: 330,
  ),
  _product(
    id: 210,
    name: 'Crystal Stud Earrings',
    categoryId: 21,
    tiers: [(12, 1400), (60, 1200)],
    soldCount: 280,
  ),
];

/// Pretend order history for Home's "Uliagiza Hivi Karibuni" rail.
const List<int> devRecentlyOrderedIds = [101, 201, 103, 206];

DevProduct devProductById(int productId) =>
    devProducts.firstWhere((product) => product.summary.id == productId);

/// "Cosmetics" / "Jewelry" for any product category (cart groups).
String devTopCategoryName(int categoryId) {
  final topId = devTopCategoryOf(categoryId);
  return devCategories.firstWhere((category) => category.id == topId).name;
}
