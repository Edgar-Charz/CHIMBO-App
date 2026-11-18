import 'package:chimbo/features/checkout/data/models/payment_method.dart';

/// Where staff are with a "Nimelipa" the customer sent (`latest_payment.payment_status`).
enum PaymentAttemptStatus {
  initiated('initiated'),
  pending('pending'),
  failed('failed'),
  submitted('submitted'),
  confirmed('confirmed'),
  rejected('rejected'),
  unknown('unknown');

  const PaymentAttemptStatus(this.apiValue);

  final String apiValue;

  static PaymentAttemptStatus fromApi(String value) => values.firstWhere(
    (status) => status.apiValue == value,
    orElse: () => unknown,
  );
}

/// The newest "Nimelipa" for an order.
class PaymentAttempt {
  const PaymentAttempt({
    required this.payerAccount,
    required this.reference,
    required this.status,
    this.id,
    this.reviewNote,
  });

  factory PaymentAttempt.fromJson(Map<String, dynamic> json) {
    return PaymentAttempt(
      payerAccount: json['payment_payer_account'] as String? ?? '',
      reference: json['payment_reference'] as String? ?? '',
      id: json['payment_id'] as int?,
      status: PaymentAttemptStatus.fromApi(json['payment_status'] as String),
      reviewNote: json['payment_review_note'] as String?,
    );
  }

  final String payerAccount;
  final int? id;

  /// The confirmation code from the payment SMS.
  final String reference;
  final PaymentAttemptStatus status;

  /// Why staff rejected it.
  final String? reviewNote;
}

/// Safe status returned by `POST /payments/initiate` and `GET /payments/{id}/status`.
class SelcomPaymentStatus {
  const SelcomPaymentStatus({
    required this.paymentId,
    required this.orderId,
    required this.status,
  });

  factory SelcomPaymentStatus.fromJson(Map<String, dynamic> json) =>
      SelcomPaymentStatus(
        paymentId: json['payment_id'] as int,
        orderId: json['order_id'] as int,
        status: json['payment_status'] as String,
      );

  final int paymentId;
  final int orderId;
  final String status;
}

/// The order's payment box (`payment` in the order): where to pay, how much, and the state of
/// the customer's "Nimelipa".
class OrderPayment {
  const OrderPayment({
    required this.method,
    required this.amount,
    required this.noteHint,
    required this.canSubmit,
    this.paymentFlow = 'manual',
    this.canInitiate = false,
    this.availableMethods = const [],
    this.canChangeMethod = false,
    this.deadlinePassed = false,
    this.latest,
    this.isBalance = false,
    this.amountPaid = 0,
    this.refundDue = 0,
  });

  factory OrderPayment.fromJson(Map<String, dynamic> json) {
    final method = json['payment_method'] as Map<String, dynamic>?;
    final latest = json['latest_payment'] as Map<String, dynamic>?;
    return OrderPayment(
      method: method == null ? null : PaymentMethod.fromJson(method),
      amount: json['payment_amount'] as int,
      noteHint: json['payment_note_hint'] as String,
      canSubmit: json['can_submit_payment'] as bool,
      paymentFlow: json['payment_flow'] as String? ?? 'manual',
      canInitiate: json['can_initiate_payment'] as bool? ?? false,
      availableMethods:
          (json['available_payment_methods'] as List<dynamic>? ?? [])
              .map(
                (item) => PaymentMethod.fromJson(item as Map<String, dynamic>),
              )
              .toList(growable: false),
      canChangeMethod: json['can_change_payment_method'] as bool,
      deadlinePassed: json['payment_deadline_passed'] as bool? ?? false,
      latest: latest == null ? null : PaymentAttempt.fromJson(latest),
      isBalance: json['is_balance_payment'] as bool? ?? false,
      amountPaid: json['amount_paid'] as int? ?? 0,
      refundDue: json['refund_due'] as int? ?? 0,
    );
  }

  /// Null when staff removed the method after the order was placed.
  final PaymentMethod? method;

  /// Whole TZS to pay now (after staff added to a paid order: only the balance).
  final int amount;

  /// Staff added to the paid order: [amount] is the rest ("Salio la kulipa"), [amountPaid] is already in.
  final bool isBalance;
  final int amountPaid;

  /// Money CHIMBO will give back after staff lowered the total (0 when none).
  final int refundDue;

  /// What to write as the payment's description (the order number).
  final String noteHint;

  /// True while the server waits for "Nimelipa" (unpaid, not expired, not cash).
  final bool canSubmit;

  /// `manual` or `selcom`, as selected in the backend configuration.
  final String paymentFlow;

  /// True when the backend allows a Selcom mobile-money request for this order.
  final bool canInitiate;

  /// Methods available for this order, including Selcom mobile-money networks.
  final List<PaymentMethod> availableMethods;

  /// "Badilisha njia ya malipo" is offered (unpaid, not under review, time not over).
  final bool canChangeMethod;

  /// The deadline passed while the expiry job is waiting to close the order.
  final bool deadlinePassed;
  final PaymentAttempt? latest;

  /// Sent and waiting for staff: "Tunakagua malipo yako".
  bool get isUnderReview =>
      !canSubmit && latest?.status == PaymentAttemptStatus.submitted;

  /// Staff refused the last one; the form is shown again with their note.
  bool get wasRejected =>
      canSubmit && latest?.status == PaymentAttemptStatus.rejected;

  bool get isSelcomPending =>
      paymentFlow == 'selcom' &&
      (latest?.status == PaymentAttemptStatus.initiated ||
          latest?.status == PaymentAttemptStatus.pending);
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
