import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/features/catalog/data/models/product_details.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_info_strip.dart';
import 'package:chimbo/features/checkout/presentation/widgets/checkout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The product page shows how orders really reach customers (`delivery_options`), not a fixed
/// number of days per product.
Map<String, Object?> _option(
  int id,
  String name,
  int min,
  int max, {
  bool isPickup = false,
}) => {
  'delivery_method_id': id,
  'delivery_method_name': name,
  'delivery_method_fee': 0,
  'delivery_days_min': min,
  'delivery_days_max': max,
  'delivery_method_is_pickup': isPickup,
};

ProductDetails _details({List<Object?> options = const []}) =>
    ProductDetails.fromJson({
      'product_id': 1,
      'product_name': 'Vaseline Petroleum Jelly 400ml',
      'product_slug': 'vaseline',
      'category_id': 2,
      'product_price_from': 4400,
      'seller_name': 'CHIMBO',
      'seller_is_verified': true,
      'product_unit_label': 'pc',
      'product_moq': 1,
      'product_price': 5500,
      'product_in_stock': true,
      'product_image_url': null,
      'product_stock_quantity': 120,
      'product_delivery_days_min': 2,
      'product_delivery_days_max': 3,
      'tiers': [
        {'tier_min_quantity': 1, 'tier_unit_price': 5500},
      ],
      'delivery_options': options,
    });

void main() {
  late AppLocalizations l10n;
  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('sw'));
  });

  test('the quickest delivered option leads; pickup is not counted', () {
    final details = _details(
      options: [
        _option(3, 'Usafiri wa mikoani', 2, 5),
        _option(1, 'Bolt (Dar es Salaam)', 0, 1),
        _option(4, 'Nitachukua mwenyewe dukani', 0, 0, isPickup: true),
      ],
    );

    expect(details.fastestDelivery?.name, 'Bolt (Dar es Salaam)');
    expect(details.fastestDelivery?.eta(l10n), 'leo au kesho');
    expect(
      _details().fastestDelivery,
      isNull,
    ); // an older server: days from the product
  });

  testWidgets('every option is listed with its time, pickup as free', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sw'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ProductDeliveryOptions(
            details: _details(
              options: [
                _option(1, 'Bolt (Dar es Salaam)', 0, 1),
                _option(3, 'Usafiri wa mikoani', 2, 5),
                _option(4, 'Nitachukua mwenyewe dukani', 0, 0, isPickup: true),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('leo au kesho'), findsOneWidget);
    expect(find.text('siku 2–5'), findsOneWidget);
    expect(find.text('Bure'), findsOneWidget);
  });
}
