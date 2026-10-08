import 'package:chimbo/features/catalog/data/api_catalog_repository.dart';
import 'package:chimbo/features/catalog/data/models/product_details.dart';
import 'package:chimbo/features/catalog/data/models/product_query.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

// Trimmed copies of real replies from the local API (2026-09-29).
const Map<String, Object?> _dealCard = {
  'product_id': 4,
  'product_name': 'Dove Beauty Soap 100g (Pack of 3)',
  'product_slug': 'dove-beauty-soap-100g-pack-of-3',
  'category_id': 4,
  'product_price': 4200,
  'product_price_from': 3700,
  'product_compare_at_price': 4800,
  'product_moq': 3,
  'product_unit_label': 'pack',
  'product_in_stock': true,
  'product_image_url': null,
  'product_badge': 'deal',
  'seller_name': 'Shamba la Vipodozi',
  'seller_is_verified': true,
};

const Map<String, Object?> _cosmetics = {
  'category_id': 1,
  'category_name': 'Cosmetics',
  'category_slug': 'cosmetics',
  'category_tagline': 'Shamba la Vipodozi',
  'category_image_url': null,
  'children': [
    {
      'category_id': 4,
      'category_name': 'Body Care',
      'category_slug': 'cosmetics-body-care',
      'category_tagline': null,
      'category_image_url': null,
    },
  ],
};

void main() {
  test('products: sends the query and reads cards and pages', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': [_dealCard],
        'meta': {'page': 1, 'per_page': 20, 'total': 21, 'last_page': 2},
      }),
    );

    final page = await ApiCatalogRepository(client).getProducts(
      const ProductQuery(
        categoryId: 1,
        search: 'dove',
        collection: ProductCollection.deals,
        sort: ProductSort.priceLowToHigh,
        moqBand: MoqBand.upTo6,
      ),
      page: 1,
    );

    final sent = adapter.lastRequest!.uri.queryParameters;
    expect(adapter.lastRequest!.uri.path, endsWith('/products'));
    expect(sent, {
      'category_id': '1',
      'collection': 'deals',
      'q': 'dove',
      'sort': 'price_asc',
      'max_moq': '6',
      'page': '1',
      'per_page': '20',
    });

    final card = page.items.single;
    expect(card.name, 'Dove Beauty Soap 100g (Pack of 3)');
    expect(card.badge, ProductBadge.deal);
    expect(card.discountPercent, 13);
    expect(card.isInStock, isTrue);
    expect(page.hasMore, isTrue);
  });

  test('home: categories with chips and the product rails', () async {
    final (client, _) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': {
          'banners': <Object?>[],
          'top_categories': [_cosmetics],
          'best_sellers': [_dealCard],
          'deals': [_dealCard],
          'new_arrivals': <Object?>[],
          'recently_ordered': <Object?>[],
        },
      }),
    );

    final home = await ApiCatalogRepository(client).getHome();

    final cosmetics = home.topCategories.single;
    expect(cosmetics.tagline, 'Shamba la Vipodozi');
    expect(cosmetics.children.single.name, 'Body Care');
    expect(cosmetics.children.single.children, isEmpty);
    expect(home.bestSellers.single.id, 4);
    expect(home.recentlyOrdered, isEmpty);
  });

  test('home: reads the admin category and banner image URLs', () async {
    final (client, _) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': {
          'banners': [
            {
              'banner_title': 'Bei za jumla',
              'banner_image_url': 'https://images.test/banner-v2.webp',
            },
          ],
          'top_categories': [
            {
              'category_id': 1,
              'category_name': 'Cosmetics',
              'category_image_url': 'https://images.test/cosmetics-v3.webp',
              'children': <Object?>[],
            },
          ],
          'best_sellers': <Object?>[],
          'deals': <Object?>[],
          'new_arrivals': <Object?>[],
          'recently_ordered': <Object?>[],
        },
      }),
    );

    final home = await ApiCatalogRepository(client).getHome();

    expect(
      home.topCategories.single.imageUrl,
      'https://images.test/cosmetics-v3.webp',
    );
    expect(home.banners.single.imageUrl, 'https://images.test/banner-v2.webp');
  });

  test('categories: reads the tree', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': [_cosmetics],
      }),
    );

    final categories = await ApiCatalogRepository(client).getCategories();

    expect(adapter.lastRequest!.uri.path, endsWith('/categories'));
    expect(categories.single.name, 'Cosmetics');
  });

  test('product page: tiers, stock, delivery days and photos', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': {
          ..._dealCard,
          'product_brand': 'Dove',
          'product_description': null,
          'category_name': 'Body Care',
          'parent_category_name': 'Cosmetics',
          'product_stock_quantity': 500,
          'product_delivery_days_min': 2,
          'product_delivery_days_max': 3,
          'tiers': [
            {'tier_min_quantity': 3, 'tier_unit_price': 4200},
            {'tier_min_quantity': 24, 'tier_unit_price': 3700},
          ],
          'images': ['http://api.test/media/products/4/a-medium.webp'],
          'gallery': [
            {
              'product_image_id': 3,
              'product_image_thumb_url':
                  'http://api.test/media/products/4/a-thumb.webp',
              'product_image_medium_url':
                  'http://api.test/media/products/4/a-medium.webp',
              'product_image_large_url':
                  'http://api.test/media/products/4/a-large.webp',
              'product_image_is_primary': true,
            },
          ],
        },
      }),
    );

    final details = await ApiCatalogRepository(client).getProduct(4);

    expect(adapter.lastRequest!.uri.path, endsWith('/products/4'));
    expect(details.summary.moq, 3);
    expect(details.tiers.map((tier) => tier.unitPrice), [4200, 3700]);
    expect(details.stockQuantity, 500);
    expect(details.deliveryDaysMax, 3);
    final photo = details.photos.single;
    expect(photo.thumbUrl, endsWith('a-thumb.webp'));
    expect(photo.mediumUrl, endsWith('a-medium.webp'));
    expect(photo.largeUrl, endsWith('a-large.webp'));
  });

  test('product page without gallery sizes uses the images list', () {
    final details = ProductDetails.fromJson({
      ..._dealCard,
      'product_stock_quantity': 10,
      'product_delivery_days_min': 2,
      'product_delivery_days_max': 3,
      'tiers': [
        {'tier_min_quantity': 3, 'tier_unit_price': 4200},
      ],
      'images': ['http://api.test/b-medium.webp'],
    });

    final photo = details.photos.single;
    expect(photo.thumbUrl, photo.largeUrl);
    expect(photo.mediumUrl, 'http://api.test/b-medium.webp');
  });
}
