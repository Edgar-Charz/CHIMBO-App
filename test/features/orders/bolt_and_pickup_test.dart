import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:chimbo/features/checkout/data/models/checkout_options.dart';
import 'package:chimbo/features/checkout/presentation/widgets/checkout_widgets.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/data/models/order_payment.dart';
import 'package:chimbo/features/orders/presentation/widgets/order_labels.dart';
import 'package:chimbo/features/orders/presentation/widgets/order_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dar by Bolt (the customer pays the rider) and pickup at the shop (blueprint R-26).
const _boltJson = {
  'delivery_method_id': 1,
  'delivery_method_name': 'Bolt (Dar es Salaam)',
  'delivery_method_fee': 0,
  'delivery_fee_paid_to_rider': true,
  'delivery_days_min': 0,
  'delivery_days_max': 1,
};

const _pickupJson = {
  'delivery_method_id': 3,
  'delivery_method_name': 'Nitachukua mwenyewe dukani',
  'delivery_method_fee': 0,
  'delivery_method_is_pickup': true,
  'delivery_days_min': 0,
  'delivery_days_max': 1,
};

Order _pickupOrder(OrderStatus status) {
  final placedAt = DateTime(2026, 10, 15, 9);
  return Order(
    id: 9,
    number: 'CHB596477',
    status: status,
    placedAt: placedAt,
    estimatedDelivery: DateTime(2026, 10, 16),
    items: const [],
    subtotal: 40000,
    deliveryFee: 0,
    total: 40000,
    deliveryMethod: DeliveryMethod.fromJson(_pickupJson),
    payment: const OrderPayment(
      method: null,
      amount: 40000,
      noteHint: 'CHB596477',
      canSubmit: false,
    ),
    address: const Address(
      id: 0,
      recipientName: 'Asha Musa',
      phone: '+255712000222',
      regionId: 2,
      regionName: 'Dar es Salaam',
      street: 'Mtaa wa Uhuru',
    ),
    events: [
      (status: OrderStatus.confirmed, at: placedAt),
      (status: OrderStatus.packed, at: placedAt.add(const Duration(hours: 2))),
    ],
    canCancel: false,
    pickupPoint: const PickupPoint(
      address: 'Kariakoo, Mtaa wa Congo',
      hours: 'Jumatatu - Jumamosi, 08:00 - 18:00',
    ),
  );
}

void main() {
  late AppLocalizations l10n;
  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('sw'));
  });

  test('Bolt is paid to the rider: words, never an amount', () {
    final bolt = DeliveryMethod.fromJson(_boltJson);

    expect(bolt.isPaidToRider, isTrue);
    expect(bolt.feeLabel(l10n), 'Unamlipa dereva');
    expect(bolt.feeWords(l10n), 'Unamlipa dereva');
  });

  test('pickup is free and comes with where to collect', () {
    final options = CheckoutOptions.fromJson({
      'delivery_methods': [_boltJson, _pickupJson],
      'payment_method_details': <Object>[],
      'pickup_point': {
        'pickup_address': 'Kariakoo, Mtaa wa Congo',
        'pickup_hours': 'Jumatatu - Jumamosi, 08:00 - 18:00',
      },
    });
    final pickup = options.deliveryMethods.last;

    expect(pickup.isPickup, isTrue);
    expect(pickup.feeLabel(l10n), 'Bure');
    expect(pickup.feeWords(l10n), 'Bure (dukani)');
    expect(options.pickupPoint?.address, 'Kariakoo, Mtaa wa Congo');
  });

  test('a pickup order uses its own words for ready and collected', () {
    final ready = _pickupOrder(OrderStatus.packed);

    expect(ready.statusLabel(l10n), 'Tayari kuchukuliwa');
    expect(ready.bannerMessage(l10n), contains('njoo uichukue'));
    expect(ready.statusLabel(l10n, OrderStatus.delivered), 'Imechukuliwa');
  });

  testWidgets('the pickup timeline skips "sent" and "on the way"', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sw'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: OrderTimeline(order: _pickupOrder(OrderStatus.packed)),
        ),
      ),
    );

    expect(find.text('Tayari kuchukuliwa'), findsOneWidget);
    expect(find.text('Imechukuliwa'), findsOneWidget);
    expect(find.text('Imetumwa'), findsNothing);
    expect(find.text('Inasafirishwa'), findsNothing);
  });
}
