import 'dart:io';

import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/server_time_interceptor.dart';
import 'package:chimbo/core/time/server_clock.dart';
import 'package:chimbo/features/cart/data/models/cart.dart';
import 'package:chimbo/features/catalog/data/api_catalog_repository.dart';
import 'package:chimbo/features/catalog/data/models/product_query.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/catalog/presentation/widgets/offer_widgets.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

// A card during a 15% offer (docs/API_REFERENCE.md, "Product card"): prices already include
// it, the normal price is the crossed-out one.
const Map<String, Object?> _offerCard = {
  'product_id': 7,
  'product_name': 'Nivea Cream 200ml',
  'category_id': 4,
  'product_price': 4250,
  'product_price_from': 3825,
  'product_compare_at_price': 5000,
  'product_moq': 6,
  'product_in_stock': true,
  'product_image_url': null,
  'product_offer': {
    'product_offer_percent': 15,
    'product_offer_ends_at': '2026-10-12T17:00:00+00:00',
  },
  'product_badge': 'offer',
  'seller_name': 'Shamba la Vipodozi',
  'seller_is_verified': true,
};

void main() {
  test('a card reads the offer, its badge and the crossed-out price', () {
    final card = ProductSummary.fromJson(_offerCard);

    expect(card.badge, ProductBadge.offer);
    expect(card.offer?.percent, 15);
    expect(card.offer?.endsAt, DateTime.utc(2026, 10, 12, 17));
    expect(card.compareAtPrice, 5000);
    // Without an offer the field is null.
    expect(
      ProductSummary.fromJson({..._offerCard, 'product_offer': null}).offer,
      isNull,
    );
  });

  test('product page tiers keep the price before the offer', () async {
    final (client, _) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': {
          ..._offerCard,
          'product_stock_quantity': 100,
          'product_delivery_days_min': 2,
          'product_delivery_days_max': 3,
          'tiers': [
            {
              'tier_min_quantity': 6,
              'tier_unit_price': 4250,
              'tier_price_before_offer': 5000,
            },
            {
              'tier_min_quantity': 24,
              'tier_unit_price': 3825,
              'tier_price_before_offer': 4500,
            },
          ],
        },
      }),
    );

    final details = await ApiCatalogRepository(client).getProduct(7);

    expect(details.tiers.map((tier) => tier.priceBeforeOffer), [5000, 4500]);
    expect(details.tiers.first.unitPrice, 4250);
  });

  test('Home reads the "Ofa za muda" rail; the list asks for offers', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': {
          'top_categories': <Object?>[],
          'best_sellers': <Object?>[],
          'deals': <Object?>[],
          'offers': [_offerCard],
          'new_arrivals': <Object?>[],
          'recently_ordered': <Object?>[],
        },
      }),
    );

    final home = await ApiCatalogRepository(client).getHome();

    expect(home.offers.single.offer?.percent, 15);
    expect(ProductCollection.fromApi('offers'), ProductCollection.offers);
    expect(adapter.lastRequest!.uri.path, endsWith('/home'));
  });

  test('cart and order lines keep the offer percent (0 = none)', () {
    final line = CartLine.fromJson({
      'product': _offerCard,
      'cart_quantity': 6,
      'unit_price': 4250,
      'tier_min_quantity': 6,
      'line_total': 25500,
      'offer_percent': 15,
    });
    final item = OrderItem.fromJson({
      'product_id': 7,
      'product_name': 'Nivea Cream 200ml',
      'order_item_quantity': 6,
      'order_item_unit_price': 4250,
      'order_item_line_total': 25500,
      'order_item_offer_percent': 0,
    });

    expect(line.offerPercent, 15);
    expect(item.offerPercent, 0);
  });

  test('the countdown reads DD:HH:MM:SS, or HH:MM:SS under a day', () {
    expect(
      OfferCountdown.format(
        const Duration(days: 10, hours: 23, minutes: 34, seconds: 12),
      ),
      '10:23:34:12',
    );
    expect(
      OfferCountdown.format(const Duration(hours: 23, minutes: 4, seconds: 5)),
      '23:04:05',
    );
    expect(OfferCountdown.format(const Duration(seconds: 9)), '00:00:09');
    // Hours run 0–23: 25 hours is 1 day and 1 hour.
    expect(OfferCountdown.format(const Duration(hours: 25)), '01:01:00:00');
  });

  test('the server clock corrects a wrong phone clock, once per start', () {
    var phoneTime = DateTime.utc(2026, 10, 8, 12);
    final container = ProviderContainer(
      overrides: [phoneClockProvider.overrideWithValue(() => phoneTime)],
    );
    addTearDown(container.dispose);
    final clock = container.read(serverClockProvider.notifier);

    // The phone is 10 minutes slow.
    clock.sync(DateTime.utc(2026, 10, 8, 12, 10));
    expect(clock.now(), DateTime.utc(2026, 10, 8, 12, 10));
    // Later answers don't move it again.
    clock.sync(DateTime.utc(2026, 10, 8, 18));
    phoneTime = phoneTime.add(const Duration(seconds: 5));
    expect(clock.now(), DateTime.utc(2026, 10, 8, 12, 10, 5));
  });

  test('the Date header of an API answer sets the server time', () async {
    DateTime? received;
    final dio = Dio(BaseOptions(baseUrl: testBaseUrl))
      ..httpClientAdapter = FakeHttpAdapter(
        (_) => ResponseBody.fromString(
          '{"success": true, "data": null}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
            HttpHeaders.dateHeader: ['Thu, 08 Oct 2026 12:10:00 GMT'],
          },
        ),
      )
      ..interceptors.add(
        ServerTimeInterceptor(onServerTime: (time) => received = time),
      );

    await dio.get<Object?>('/health');

    expect(received, DateTime.utc(2026, 10, 8, 12, 10));
  });

  /// One countdown per offer, sharing the ticker; the phone clock is moved by hand.
  Future<Future<void> Function(Duration)> pumpCountdowns(
    WidgetTester tester,
    List<({DateTime endsAt, VoidCallback onEnded})> offers,
  ) async {
    var phoneTime = DateTime.utc(2026, 10, 8, 12);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [phoneClockProvider.overrideWithValue(() => phoneTime)],
        child: MaterialApp(
          locale: const Locale('sw'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Column(
              children: [
                for (final offer in offers)
                  OfferCountdown(endsAt: offer.endsAt, onEnded: offer.onEnded),
              ],
            ),
          ),
        ),
      ),
    );
    return (Duration step) async {
      phoneTime = phoneTime.add(step);
      await tester.pump(step);
    };
  }

  testWidgets('countdowns tick every second and reload once at zero', (
    tester,
  ) async {
    var reloads = 0;
    final advance = await pumpCountdowns(tester, [
      (endsAt: DateTime.utc(2026, 10, 8, 12, 0, 3), onEnded: () => reloads++),
      (endsAt: DateTime.utc(2026, 10, 10, 13), onEnded: () {}),
    ]);
    expect(find.text('00:00:03'), findsOneWidget);
    expect(find.text('02:01:00:00'), findsOneWidget);

    await advance(const Duration(seconds: 1));
    expect(find.text('00:00:02'), findsOneWidget);
    expect(find.text('02:00:59:59'), findsOneWidget);

    await advance(const Duration(seconds: 2));
    await tester.pump();
    expect(reloads, 1);
    expect(find.text('00:00:00'), findsNothing);

    await advance(const Duration(seconds: 3));
    expect(reloads, 1);
    // Removing the countdowns stops the shared ticker.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an offer already over shows nothing and never reloads', (
    tester,
  ) async {
    var reloads = 0;
    final advance = await pumpCountdowns(tester, [
      (endsAt: DateTime.utc(2026, 10, 8, 11, 59), onEnded: () => reloads++),
    ]);
    await advance(const Duration(seconds: 5));

    expect(find.byType(Text), findsNothing);
    expect(reloads, 0);
    await tester.pumpWidget(const SizedBox());
  });
}
