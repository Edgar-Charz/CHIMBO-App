import 'package:chimbo/features/checkout/data/models/payment_method.dart';
import 'package:chimbo/features/orders/data/models/order_payment.dart';
import 'package:chimbo/features/payments/data/api_payments_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

void main() {
  test('reads the customer payments from /payments', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': [
          {
            'payment_id': 4,
            'order_id': 9,
            'order_number': 'CHB765068',
            'payment_method_code': 'cod',
            'payment_method_name': 'Lipa ukipokea',
            'payment_amount': 45000,
            'payment_payer_account': '+255712000111',
            'payment_reference': 'CASH-CHB765068',
            'payment_status': 'confirmed',
            'payment_review_note': null,
            'created_at': '2026-10-08T09:30:00+00:00',
            'payment_reviewed_at': '2026-10-08T09:30:00+00:00',
          },
        ],
        'meta': {'page': 1, 'per_page': 20, 'total': 1, 'last_page': 1},
      }),
    );

    final payments = await ApiPaymentsRepository(client).getMyPayments();

    expect(adapter.lastRequest!.uri.path, endsWith('/payments'));
    expect(payments.single.orderNumber, 'CHB765068');
    expect(payments.single.methodName, 'Lipa ukipokea');
    expect(payments.single.amount, 45000);
    expect(payments.single.status, PaymentAttemptStatus.confirmed);
  });

  test('reads the accepted methods from /payment-methods', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': [
          {
            'payment_method_code': 'mpesa',
            'payment_method_name': 'M-Pesa',
            'payment_method_type': 'mobile_money',
            'payment_method_account_name': 'CHIMBO LTD',
            'payment_method_account_number': '123456',
            'payment_method_bank_name': null,
            'payment_method_instructions': null,
          },
        ],
      }),
    );

    final methods = await ApiPaymentsRepository(client).getAcceptedMethods();

    expect(adapter.lastRequest!.uri.path, endsWith('/payment-methods'));
    expect(methods.single.type, PaymentMethodType.mobileMoney);
    expect(methods.single.accountNumber, '123456');
  });
}
