import 'package:chimbo/features/checkout/data/models/payment_method.dart';
import 'package:chimbo/features/orders/data/models/order_payment.dart';
import 'package:chimbo/features/payments/data/models/payment_record.dart';
import 'package:chimbo/features/payments/data/payments_repository.dart';

/// Offline stand-in for `/payments` and `/payment-methods`.
class FakePaymentsRepository implements PaymentsRepository {
  FakePaymentsRepository({List<PaymentRecord>? payments})
    : payments = payments ?? sampleHistory;

  final List<PaymentRecord> payments;

  static final List<PaymentRecord> sampleHistory = [
    PaymentRecord(
      id: 2,
      orderId: 1,
      orderNumber: 'CHB765068',
      methodName: 'M-Pesa',
      amount: 45000,
      reference: 'QJK3X7ABC1',
      status: PaymentAttemptStatus.confirmed,
      createdAt: DateTime.utc(2026, 10, 8, 9, 30),
    ),
    PaymentRecord(
      id: 1,
      orderId: 1,
      orderNumber: 'CHB765068',
      methodName: 'M-Pesa',
      amount: 45000,
      reference: 'QJK3X7ABC0',
      status: PaymentAttemptStatus.rejected,
      createdAt: DateTime.utc(2026, 10, 8, 9),
      reviewNote: 'Hatukupata malipo haya.',
    ),
  ];

  @override
  Future<List<PaymentRecord>> getMyPayments() async => payments;

  @override
  Future<List<PaymentMethod>> getAcceptedMethods() async => const [
    PaymentMethod(
      code: 'mpesa',
      name: 'M-Pesa',
      type: PaymentMethodType.mobileMoney,
      accountName: 'CHIMBO LTD',
      accountNumber: '123456',
      instructions: 'Lipa kwa Lipa Namba, kisha bonyeza "Nimelipa".',
    ),
    PaymentMethod(
      code: 'cod',
      name: 'Lipa ukipokea',
      type: PaymentMethodType.cash,
    ),
  ];
}
