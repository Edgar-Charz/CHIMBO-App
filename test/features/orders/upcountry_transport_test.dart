import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:chimbo/features/checkout/application/checkout_controller.dart';
import 'package:chimbo/features/checkout/data/models/checkout_options.dart';
import 'package:chimbo/features/checkout/data/models/payment_method.dart';
import 'package:chimbo/features/checkout/presentation/widgets/checkout_widgets.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/data/models/order_payment.dart';
import 'package:chimbo/features/orders/presentation/widgets/order_labels.dart';
import 'package:chimbo/features/orders/presentation/widgets/order_payment_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Upcountry transport (blueprint R-25): the region's estimate at checkout, staff confirm the
/// price after measuring the load, and only then the customer pays.
const _upcountryJson = {
  'delivery_method_id': 3,
  'delivery_method_name': 'Usafiri wa mikoani (siku 2–5)',
  'delivery_method_fee': 15000,
  'delivery_fee_needs_confirmation': true,
  'delivery_days_min': 2,
  'delivery_days_max': 5,
};

const _cash = PaymentMethod(
  code: 'cod',
  name: 'Lipa ukipokea',
  type: PaymentMethodType.cash,
);
const _mpesa = PaymentMethod(
  code: 'mpesa',
  name: 'M-Pesa',
  type: PaymentMethodType.mobileMoney,
);

Order _upcountryOrder({required Map<String, Object?> feeFields}) {
  final placedAt = DateTime(2026, 10, 9, 10);
  return Order(
    id: 7,
    number: 'CHB012474',
    status: OrderStatus.pendingPayment,
    placedAt: placedAt,
    estimatedDelivery: DateTime(2026, 10, 14),
    items: const [],
    subtotal: 40000,
    deliveryFee: 15000,
    total: 55000,
    deliveryMethod: DeliveryMethod.fromJson({
      ..._upcountryJson,
      'delivery_fee_needs_confirmation': null,
      ...feeFields,
    }),
    payment: const OrderPayment(
      method: _mpesa,
      amount: 55000,
      noteHint: 'CHB012474',
      canSubmit: false,
    ),
    address: const Address(
      id: 0,
      recipientName: 'Joyce Joseph',
      phone: '+255712345678',
      regionId: 19,
      regionName: 'Mwanza',
      street: 'Kirumba',
    ),
    events: [(status: OrderStatus.pendingPayment, at: placedAt)],
    canCancel: true,
  );
}

void main() {
  group('checkout', () {
    test('an upcountry option reads the estimate, or none yet', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('sw'));

      final withEstimate = DeliveryMethod.fromJson(_upcountryJson);
      expect(withEstimate.needsConfirmation, isTrue);
      expect(withEstimate.feeLabel(l10n), '~${Money.format(15000)}');

      final withoutEstimate = DeliveryMethod.fromJson({
        ..._upcountryJson,
        'delivery_method_fee': null,
      });
      expect(withoutEstimate.fee, isNull);
      expect(withoutEstimate.feeLabel(l10n), 'Bei itathibitishwa');
    });

    test(
      'no cash on delivery while the transport price is to be confirmed',
      () async {
        final container = ProviderContainer(
          overrides: [
            checkoutOptionsProvider.overrideWith(
              (ref) => CheckoutOptions(
                deliveryMethods: [DeliveryMethod.fromJson(_upcountryJson)],
                paymentMethods: const [_cash, _mpesa],
              ),
            ),
          ],
        );
        addTearDown(container.dispose);
        await container.read(checkoutOptionsProvider.future);

        expect(
          container.read(checkoutPaymentMethodsProvider)?.map((m) => m.code),
          ['mpesa'],
        );
        expect(
          container.read(checkoutChoicesProvider).paymentMethod?.code,
          'mpesa',
        );
      },
    );
  });

  group('order', () {
    Future<void> pumpSection(WidgetTester tester, Order order) {
      return tester.pumpWidget(
        MaterialApp(
          locale: const Locale('sw'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: OrderPaymentSection(order: order)),
        ),
      );
    }

    testWidgets('waiting for the price: "Tunapima mzigo wako", no paying yet', (
      tester,
    ) async {
      final order = _upcountryOrder(
        feeFields: {
          'delivery_fee_status': 'awaiting_confirmation',
          'delivery_fee_estimate': 15000,
        },
      );
      expect(order.isAwaitingTransportPrice, isTrue);

      await pumpSection(tester, order);

      expect(find.text('Tunapima mzigo wako'), findsOneWidget);
      expect(find.textContaining('hadi Mwanza'), findsOneWidget);
      expect(find.textContaining(Money.format(15000)), findsOneWidget);
      expect(find.text('Nimelipa'), findsNothing);
    });

    test('the status says the stage: measuring the load', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('sw'));
      final order = _upcountryOrder(
        feeFields: {'delivery_fee_status': 'awaiting_confirmation'},
      );

      expect(order.statusLabel(l10n), 'Tunapima mzigo');
      expect(
        order.statusLabel(l10n, OrderStatus.pendingPayment),
        'Inasubiri malipo',
      ); // the timeline step
    });

    test('confirmed: the reason staff gave comes with the order', () {
      final order = _upcountryOrder(
        feeFields: {
          'delivery_fee_status': 'confirmed',
          'delivery_fee_estimate': 15000,
          'delivery_fee_note': 'Mzigo mkubwa, katoni 6',
        },
      );

      expect(order.isAwaitingTransportPrice, isFalse);
      expect(order.deliveryMethod.feeStatus, DeliveryFeeStatus.confirmed);
      expect(order.deliveryMethod.feeNote, 'Mzigo mkubwa, katoni 6');
    });
  });
}
