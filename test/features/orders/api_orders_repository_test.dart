import 'package:chimbo/features/checkout/data/models/checkout_options.dart';
import 'package:chimbo/features/orders/data/api_orders_repository.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/data/orders_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

// The order example from docs/API_REFERENCE.md ("Orders — Oda"), dispatched with an agent.
Map<String, Object?> _order({String? estimatedDelivery = '2026-10-02'}) => {
  'order_id': 1,
  'order_number': 'CHB765068',
  'order_status': 'dispatched',
  'order_payment_method': 'cod',
  'order_subtotal': 91000,
  'order_delivery_fee': 5000,
  'order_total': 96000,
  'order_placed_at': '2026-09-29T13:10:00+00:00',
  'order_estimated_delivery_date': estimatedDelivery,
  'can_cancel': false,
  'delivery_method': {
    'delivery_method_id': 1,
    'delivery_method_name': 'Standard (siku 2–3)',
    'delivery_method_fee': 5000,
    'delivery_days_min': 2,
    'delivery_days_max': 3,
  },
  'address': {
    'address_recipient_name': 'Joyce Joseph',
    'address_phone': '+255712345678',
    'region_id': 2,
    'region_name': 'Dar es Salaam',
    'district_name': null,
    'address_street': 'Kariakoo, Lumumba St',
    'address_landmark': null,
  },
  'items': [
    {
      'order_item_id': 1,
      'product_id': 1,
      'product_name': 'Vaseline Petroleum Jelly 400ml',
      'product_image_url': null,
      'order_item_quantity': 8,
      'order_item_unit_price': 5000,
      'order_item_line_total': 40000,
    },
  ],
  'events': [
    {
      'order_status': 'confirmed',
      'status_note': null,
      'created_at': '2026-09-29T13:10:00+00:00',
    },
    {
      'order_status': 'dispatched',
      'status_note': null,
      'created_at': '2026-09-30T08:00:00+00:00',
    },
  ],
  'delivery_agent': {
    'delivery_agent_full_name': 'Juma Mbeva',
    'delivery_agent_phone': '+255712987654',
    'delivery_agent_photo_url': null,
  },
};

void main() {
  test('placing an order sends the checkout key and the choices', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({'success': true, 'data': _order()}, statusCode: 201),
    );

    await ApiOrdersRepository(client).placeOrder(
      const PlaceOrderInput(
        addressId: 3,
        deliveryMethodId: 1,
        paymentMethod: PaymentMethod.cashOnDelivery,
        expectedTotal: 96000,
        idempotencyKey: 'checkout-key-1',
      ),
    );

    expect(adapter.lastRequest!.uri.path, endsWith('/orders'));
    expect(adapter.lastRequest!.headers['Idempotency-Key'], 'checkout-key-1');
    expect(adapter.lastRequest!.data, {
      'address_id': 3,
      'delivery_method_id': 1,
      'payment_method': 'cod',
      'expected_total': 96000,
    });
  });

  test(
    'an order reads the timeline, agent and the server cancel rule',
    () async {
      final (client, adapter) = clientReplying(
        (_) => jsonReply({'success': true, 'data': _order()}),
      );

      final order = await ApiOrdersRepository(client).getOrder(1);

      expect(adapter.lastRequest!.uri.path, endsWith('/orders/1'));
      expect(order.status, OrderStatus.dispatched);
      expect(order.canCancel, isFalse);
      expect(order.estimatedDelivery, DateTime(2026, 10, 2));
      expect(order.events.map((event) => event.status), [
        OrderStatus.confirmed,
        OrderStatus.dispatched,
      ]);
      expect(order.agent?.name, 'Juma Mbeva');
      expect(order.address.fullLocation, 'Kariakoo, Lumumba St, Dar es Salaam');
      expect(order.items.single.lineTotal, 40000);
    },
  );

  test(
    'the list asks for the tab; no date means the slowest delivery day',
    () async {
      final (client, adapter) = clientReplying(
        (_) => jsonReply({
          'success': true,
          'data': [_order(estimatedDelivery: null)],
        }),
      );

      final orders = await ApiOrdersRepository(client)
          .getOrders(OrderGroup.active);

      expect(adapter.lastRequest!.uri.queryParameters, {'group': 'active'});
      expect(
        orders.single.estimatedDelivery,
        DateTime.parse('2026-10-02T13:10:00+00:00'),
      );
    },
  );

  test('Agiza Tena returns why items were skipped', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': {
          'groups': <Object?>[],
          'summary': {'line_count': 0, 'piece_count': 0, 'subtotal': 0},
          'warnings': <Object?>[],
          'skipped_items': [
            {'product_id': 4, 'message': 'Bidhaa hii imeisha.'},
          ],
        },
      }),
    );

    final skipped = await ApiOrdersRepository(client).reorder(1);

    expect(adapter.lastRequest!.uri.path, endsWith('/orders/1/reorder'));
    expect(skipped, ['Bidhaa hii imeisha.']);
  });
}
