import 'package:chimbo/features/checkout/data/models/payment_method.dart';

/// Where staff are with a "Nimelipa" the customer sent (`latest_payment.payment_status`).
enum PaymentAttemptStatus {
  submitted('submitted'),
  confirmed('confirmed'),
  rejected('rejected');

  const PaymentAttemptStatus(this.apiValue);

  final String apiValue;

  static PaymentAttemptStatus fromApi(String value) =>
      values.firstWhere((status) => status.apiValue == value);
}

/// The newest "Nimelipa" for an order.
class PaymentAttempt {
  const PaymentAttempt({
    required this.payerAccount,
    required this.reference,
    required this.status,
    this.reviewNote,
  });

  factory PaymentAttempt.fromJson(Map<String, dynamic> json) {
    return PaymentAttempt(
      payerAccount: json['payment_payer_account'] as String,
      reference: json['payment_reference'] as String,
      status: PaymentAttemptStatus.fromApi(json['payment_status'] as String),
      reviewNote: json['payment_review_note'] as String?,
    );
  }

  final String payerAccount;

  /// The confirmation code from the payment SMS.
  final String reference;
  final PaymentAttemptStatus status;

  /// Why staff rejected it.
  final String? reviewNote;
}

/// The order's payment box (`payment` in the order): where to pay, how much, and the state of
/// the customer's "Nimelipa".
class OrderPayment {
  const OrderPayment({
    required this.method,
    required this.amount,
    required this.noteHint,
    required this.canSubmit,
    this.canChangeMethod = false,
    this.latest,
  });

  factory OrderPayment.fromJson(Map<String, dynamic> json) {
    final method = json['payment_method'] as Map<String, dynamic>?;
    final latest = json['latest_payment'] as Map<String, dynamic>?;
    return OrderPayment(
      method: method == null ? null : PaymentMethod.fromJson(method),
      amount: json['payment_amount'] as int,
      noteHint: json['payment_note_hint'] as String,
      canSubmit: json['can_submit_payment'] as bool,
      canChangeMethod: json['can_change_payment_method'] as bool,
      latest: latest == null ? null : PaymentAttempt.fromJson(latest),
    );
  }

  /// Null when staff removed the method after the order was placed.
  final PaymentMethod? method;

  /// Whole TZS to pay.
  final int amount;

  /// What to write as the payment's description (the order number).
  final String noteHint;

  /// True while the server waits for "Nimelipa" (unpaid, not expired, not cash).
  final bool canSubmit;

  /// "Badilisha njia ya malipo" is offered (unpaid, not under review, time not over).
  final bool canChangeMethod;
  final PaymentAttempt? latest;

  /// Sent and waiting for staff: "Tunakagua malipo yako".
  bool get isUnderReview =>
      !canSubmit && latest?.status == PaymentAttemptStatus.submitted;

  /// Staff refused the last one; the form is shown again with their note.
  bool get wasRejected =>
      canSubmit && latest?.status == PaymentAttemptStatus.rejected;
}

/// What "Nimelipa" sends (`POST /orders/{id}/payment`).
class PaymentSubmission {
  const PaymentSubmission({
    required this.payerAccount,
    required this.reference,
  });

  /// The phone number (mobile money) or account / name (bank) the money came from.
  final String payerAccount;

  /// The confirmation code from the payment SMS.
  final String reference;

  Map<String, dynamic> toJson() => {
    'payment_payer_account': payerAccount,
    'payment_reference': reference,
  };
}
