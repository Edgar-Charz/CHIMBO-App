import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:chimbo/features/checkout/data/models/checkout_options.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/presentation/widgets/order_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Order _orderEndedAs(OrderStatus status) {
  final placedAt = DateTime(2026, 9, 29, 13, 10);
  return Order(
    id: 1,
    number: 'CHB765068',
    status: status,
    placedAt: placedAt,
    estimatedDelivery: DateTime(2026, 10, 2),
    items: const [],
    subtotal: 0,
    deliveryFee: 0,
    total: 0,
    deliveryMethod: DeliveryMethod.fromJson(const {
      'delivery_method_id': 1,
      'delivery_method_name': 'Standard (siku 2–3)',
      'delivery_method_fee': 5000,
      'delivery_days_min': 2,
      'delivery_days_max': 3,
    }),
    paymentMethod: PaymentMethod.cashOnDelivery,
    address: const Address(
      id: 0,
      recipientName: 'Joyce Joseph',
      phone: '+255712345678',
      regionId: 2,
      regionName: 'Dar es Salaam',
      street: 'Kariakoo',
    ),
    events: [
      (status: OrderStatus.pendingPayment, at: placedAt),
      (status: status, at: placedAt.add(const Duration(hours: 1))),
    ],
    canCancel: false,
  );
}

Future<void> _pumpTimeline(WidgetTester tester, Order order) {
  return tester.pumpWidget(
    MaterialApp(
      locale: const Locale('sw'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: OrderTimeline(order: order)),
    ),
  );
}

void main() {
  // Payment status `cancelled` comes with either order status; both end the same way.
  for (final (status, label) in [
    (OrderStatus.cancelled, 'Imeghairiwa'),
    (OrderStatus.expired, 'Muda umeisha'),
  ]) {
    testWidgets('${status.apiValue}: reached steps, then how it ended', (
      tester,
    ) async {
      await _pumpTimeline(tester, _orderEndedAs(status));

      expect(find.text('Inasubiri malipo'), findsOneWidget);
      expect(find.text(label), findsOneWidget);
      // The delivery steps it never reached are not drawn.
      expect(find.text('Imewasili'), findsNothing);
    });
  }
}
