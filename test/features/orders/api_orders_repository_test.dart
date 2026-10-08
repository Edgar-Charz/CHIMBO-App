import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/features/orders/data/api_orders_repository.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/data/models/order_payment.dart';
import 'package:chimbo/features/orders/data/orders_repository.dart';
import 'package:dio/dio.dart';
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
  'payment': {
    'payment_method': {
      'payment_method_code': 'cod',
      'payment_method_name': 'Lipa ukipokea',
      'payment_method_type': 'cash',
      'payment_method_account_name': null,
      'payment_method_account_number': null,
      'payment_method_bank_name': null,
      'payment_method_instructions': null,
    },
    'payment_amount': 96000,
    'payment_note_hint': 'CHB765068',
    'can_submit_payment': false,
    'can_change_payment_method': false,
    'latest_payment': null,
  },
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
        paymentMethodCode: 'cod',
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

  test('Pakua Risiti returns the PDF bytes', () async {
    final pdf = '%PDF-1.4'.codeUnits;
    final (client, adapter) = clientReplying(
      (_) => ResponseBody.fromBytes(
        pdf,
        200,
        headers: {
          Headers.contentTypeHeader: ['application/pdf'],
        },
      ),
    );

    final bytes = await ApiOrdersRepository(client).downloadReceipt(1);

    expect(adapter.lastRequest!.uri.path, endsWith('/orders/1/receipt'));
    expect(bytes, pdf);
  });

  test('a refused receipt still shows the server message', () async {
    final (client, _) = clientReplying(
      (_) => jsonReply({
        'success': false,
        'error': {'code': 'NOT_FOUND', 'message': 'Oda haikupatikana.'},
      }, statusCode: 404),
    );

    await expectLater(
      ApiOrdersRepository(client).downloadReceipt(99),
      throwsA(
        isA<ApiException>()
            .having((error) => error.code, 'code', 'NOT_FOUND')
            .having((error) => error.message, 'message', 'Oda haikupatikana.'),
      ),
    );
  });

  test('a mobile money order: where to pay, then "Nimelipa"', () async {
    Map<String, Object?> mpesaOrder({required bool sent}) => {
      ..._order(),
      'order_status': 'pending_payment',
      'order_payment_method': 'mpesa',
      'order_expires_at': '2026-10-07T08:00:00+00:00',
      'can_cancel': !sent,
      'payment': {
        'payment_method': {
          'payment_method_code': 'mpesa',
          'payment_method_name': 'M-Pesa',
          'payment_method_type': 'mobile_money',
          'payment_method_account_name': 'CHIMBO LTD',
          'payment_method_account_number': '5544332',
          'payment_method_bank_name': null,
          'payment_method_instructions': 'Piga *150*00#.',
        },
        'payment_amount': 96000,
        'payment_note_hint': 'CHB765068',
        'can_submit_payment': !sent,
        'can_change_payment_method': !sent,
        'latest_payment': sent
            ? {
                'payment_id': 4,
                'payment_payer_account': '+255712000111',
                'payment_reference': 'QJK3X7ABC1',
                'payment_status': 'submitted',
                'payment_review_note': null,
                'created_at': '2026-10-06T08:00:00+00:00',
              }
            : null,
      },
    };
    final (client, adapter) = clientReplying(
      (options) => jsonReply({
        'success': true,
        'data': mpesaOrder(sent: options.method == 'POST'),
      }),
    );
    final repository = ApiOrdersRepository(client);

    final waiting = await repository.getOrder(1);
    expect(waiting.payment.canSubmit, isTrue);
    expect(waiting.payment.canChangeMethod, isTrue);
    expect(waiting.payment.method?.accountNumber, '5544332');
    expect(waiting.payment.noteHint, 'CHB765068');
    expect(waiting.expiresAt, DateTime.parse('2026-10-07T08:00:00+00:00'));

    final sent = await repository.submitPayment(
      1,
      const PaymentSubmission(
        payerAccount: '0712000111',
        reference: 'QJK3X7ABC1',
      ),
    );
    expect(adapter.lastRequest!.uri.path, endsWith('/orders/1/payment'));
    expect(adapter.lastRequest!.data, {
      'payment_payer_account': '0712000111',
      'payment_reference': 'QJK3X7ABC1',
    });
    expect(sent.payment.isUnderReview, isTrue);
    expect(sent.payment.latest?.reference, 'QJK3X7ABC1');
  });

  test('a rejected payment shows the form again with the note', () {
    final payment = OrderPayment.fromJson({
      'payment_method': null,
      'payment_amount': 96000,
      'payment_note_hint': 'CHB765068',
      'can_submit_payment': true,
      'can_change_payment_method': true,
      'latest_payment': {
        'payment_payer_account': '+255712000111',
        'payment_reference': 'QJK3X7ABC1',
        'payment_status': 'rejected',
        'payment_review_note': 'Hatukupata muamala huu.',
      },
    });

    expect(payment.wasRejected, isTrue);
    expect(payment.isUnderReview, isFalse);
    expect(payment.latest?.reviewNote, 'Hatukupata muamala huu.');
  });

  test('changing the payment method sends the chosen code', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({'success': true, 'data': _order()}),
    );

    final order = await ApiOrdersRepository(client)
        .changePaymentMethod(1, 'cod');

    expect(adapter.lastRequest!.uri.path, endsWith('/orders/1/payment-method'));
    expect(adapter.lastRequest!.data, {'payment_method': 'cod'});
    expect(order.payment.method?.isCashOnDelivery, isTrue);
    expect(order.payment.canChangeMethod, isFalse);
  });

  test('cash above the limit is refused with the server message', () async {
    final (client, _) = clientReplying(
      (_) => jsonReply({
        'success': false,
        'error': {
          'code': 'VALIDATION_ERROR',
          'message': 'Tafadhali rekebisha taarifa zilizokosewa.',
          'fields': {
            'payment_method': 'Lipa ukipokea ni kwa oda hadi TZS 500,000.',
          },
        },
      }, statusCode: 422),
    );

    await expectLater(
      ApiOrdersRepository(client).changePaymentMethod(1, 'cod'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.fields['payment_method'],
          'payment_method',
          'Lipa ukipokea ni kwa oda hadi TZS 500,000.',
        ),
      ),
    );
  });

  test('Agiza Tena only for orders that are over', () {
    expect(OrderStatus.delivered.canReorder, isTrue);
    expect(OrderStatus.cancelled.canReorder, isTrue);
    expect(OrderStatus.pendingPayment.canReorder, isFalse);
    expect(OrderStatus.inTransit.canReorder, isFalse);
    expect(OrderStatus.expired.canReorder, isFalse);
  });
}
