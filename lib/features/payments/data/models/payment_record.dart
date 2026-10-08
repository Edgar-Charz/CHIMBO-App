import 'package:chimbo/features/orders/data/models/order_payment.dart';

/// One payment in "Malipo yangu" (`GET /payments`): a "Nimelipa" the customer sent, a payment staff
/// recorded for them, or cash collected on delivery.
class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.methodName,
    required this.amount,
    required this.reference,
    required this.status,
    required this.createdAt,
    this.reviewNote,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['payment_id'] as int,
      orderId: json['order_id'] as int,
      orderNumber: json['order_number'] as String,
      methodName: json['payment_method_name'] as String,
      amount: json['payment_amount'] as int,
      reference: json['payment_reference'] as String,
      status: PaymentAttemptStatus.fromApi(json['payment_status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewNote: json['payment_review_note'] as String?,
    );
  }

  final int id;
  final int orderId;
  final String orderNumber;

  /// "M-Pesa", "Lipa ukipokea" …
  final String methodName;
  final int amount;

  /// The confirmation code from the payment SMS ("CASH-CHB…" for cash on delivery).
  final String reference;
  final PaymentAttemptStatus status;
  final DateTime createdAt;

  /// Why staff rejected it.
  final String? reviewNote;
}
