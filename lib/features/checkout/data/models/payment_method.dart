/// How a payment method is paid; decides the icon and whether "Nimelipa" is needed.
enum PaymentMethodType {
  mobileMoney('mobile_money'),
  bank('bank'),
  cash('cash');

  const PaymentMethodType(this.apiValue);

  final String apiValue;

  /// A type added on the server later is treated like mobile money (pay first, then
  /// "Nimelipa"), the safe choice: nothing is delivered before staff confirm the money.
  static PaymentMethodType fromApi(String value) => values.firstWhere(
    (type) => type.apiValue == value,
    orElse: () => mobileMoney,
  );
}

/// A way to pay that staff switched on (payment method object in docs/API_REFERENCE.md,
/// "Checkout"): its name for the list, and the "pay to" details shown after ordering.
class PaymentMethod {
  const PaymentMethod({
    required this.code,
    required this.name,
    required this.type,
    this.accountName,
    this.accountNumber,
    this.bankName,
    this.instructions,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      code: json['payment_method_code'] as String,
      name: json['payment_method_name'] as String,
      type: PaymentMethodType.fromApi(json['payment_method_type'] as String),
      accountName: json['payment_method_account_name'] as String?,
      accountNumber: json['payment_method_account_number'] as String?,
      bankName: json['payment_method_bank_name'] as String?,
      instructions: json['payment_method_instructions'] as String?,
    );
  }

  /// Sent as `payment_method` when ordering ("mpesa", "cod" …).
  final String code;

  /// "M-Pesa", "Lipa ukipokea" — already in Kiswahili.
  final String name;
  final PaymentMethodType type;

  /// Who the money goes to ("CHIMBO LTD").
  final String? accountName;

  /// Lipa Namba, phone number or bank account.
  final String? accountNumber;
  final String? bankName;
  final String? instructions;

  bool get isCashOnDelivery => type == PaymentMethodType.cash;
}
