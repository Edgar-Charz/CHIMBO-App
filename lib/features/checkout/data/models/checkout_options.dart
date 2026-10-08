import 'package:chimbo/features/checkout/data/models/payment_method.dart';

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

/// `GET /checkout/options?address_id=…`: the delivery methods that reach the address and the
/// payment methods staff switched on, with their names and "pay to" details.
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
      paymentMethods: (json['payment_method_details'] as List<dynamic>)
          .map(
            (method) => PaymentMethod.fromJson(method as Map<String, dynamic>),
          )
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
