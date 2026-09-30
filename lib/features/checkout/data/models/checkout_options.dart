/// A way to deliver (`delivery_methods` table): Standard or Haraka (D-9). The server's name
/// already says how long it takes ("Standard (siku 2–3)").
class DeliveryMethod {
  const DeliveryMethod({
    required this.id,
    required this.name,
    required this.fee,
    required this.daysMin,
    required this.daysMax,
  });

  factory DeliveryMethod.fromJson(Map<String, dynamic> json) {
    return DeliveryMethod(
      id: json['delivery_method_id'] as int,
      name: json['delivery_method_name'] as String,
      fee: json['delivery_method_fee'] as int,
      daysMin: json['delivery_days_min'] as int,
      daysMax: json['delivery_days_max'] as int,
    );
  }

  final int id;
  final String name;

  /// Whole TZS.
  final int fee;
  final int daysMin;
  final int daysMax;

  /// "Haraka (kesho)": next-day delivery.
  bool get isNextDay => daysMax == 1;

  Map<String, dynamic> toJson() => {
    'delivery_method_id': id,
    'delivery_method_name': name,
    'delivery_method_fee': fee,
    'delivery_days_min': daysMin,
    'delivery_days_max': daysMax,
  };
}

/// Njia za malipo (blueprint §2.8). Mobile money is paid in Phase 5; COD needs no payment step.
enum PaymentMethod {
  mpesa('mpesa'),
  airtelMoney('airtel_money'),
  mixxByYas('mixx'),
  bank('bank'),
  cashOnDelivery('cod');

  const PaymentMethod(this.apiValue);

  final String apiValue;

  static PaymentMethod fromApi(String value) =>
      values.firstWhere((method) => method.apiValue == value);

  /// Null for a method this version of the app doesn't know yet.
  static PaymentMethod? tryFromApi(Object? value) {
    for (final method in values) {
      if (method.apiValue == value) {
        return method;
      }
    }
    return null;
  }
}

/// `GET /checkout/options?address_id=…`: the delivery methods that reach the address and the
/// payment methods switched on (only Lipa ukipokea until mobile money is connected).
class CheckoutOptions {
  const CheckoutOptions({
    required this.deliveryMethods,
    required this.paymentMethods,
  });

  factory CheckoutOptions.fromJson(Map<String, dynamic> json) {
    return CheckoutOptions(
      deliveryMethods: (json['delivery_methods'] as List<dynamic>)
          .map(
            (method) => DeliveryMethod.fromJson(method as Map<String, dynamic>),
          )
          .toList(),
      paymentMethods: (json['payment_methods'] as List<dynamic>)
          .map(PaymentMethod.tryFromApi)
          .whereType<PaymentMethod>()
          .toList(),
    );
  }

  final List<DeliveryMethod> deliveryMethods;
  final List<PaymentMethod> paymentMethods;
}

/// `POST /checkout/preview`: server-computed totals for Hakiki.
class CheckoutPreview {
  const CheckoutPreview({
    required this.lineCount,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  factory CheckoutPreview.fromJson(Map<String, dynamic> json) {
    return CheckoutPreview(
      lineCount: json['line_count'] as int,
      subtotal: json['subtotal'] as int,
      deliveryFee: json['delivery_fee'] as int,
      total: json['grand_total'] as int,
    );
  }

  final int lineCount;
  final int subtotal;
  final int deliveryFee;
  final int total;
}
