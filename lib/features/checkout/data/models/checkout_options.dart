import 'package:chimbo/features/checkout/data/models/payment_method.dart';

/// Where an order's transport price stands (blueprint R-25): a fixed fee, the region's estimate
/// waiting for staff to measure the load, or the price staff confirmed.
enum DeliveryFeeStatus {
  fixed('fixed'),
  awaitingConfirmation('awaiting_confirmation'),
  confirmed('confirmed');

  const DeliveryFeeStatus(this.apiValue);

  final String apiValue;

  static DeliveryFeeStatus fromApi(String? value) => values.firstWhere(
    (status) => status.apiValue == value,
    orElse: () => fixed,
  );
}

/// Where and when to collect a pickup order ("Nitachukua mwenyewe dukani", blueprint R-26).
class PickupPoint {
  const PickupPoint({required this.address, required this.hours});

  factory PickupPoint.fromJson(Map<String, dynamic> json) => PickupPoint(
    address: json['pickup_address'] as String? ?? '',
    hours: json['pickup_hours'] as String? ?? '',
  );

  final String address;
  final String hours;
}

/// A way to deliver (`delivery_methods` table): "Bolt (Dar es Salaam)" (the customer pays the
/// rider), "Usafiri wa mikoani" elsewhere, and "Nitachukua mwenyewe dukani" (pickup) everywhere.
/// In an order it also carries the transport price's status ([feeStatus], [feeEstimate],
/// [feeNote]).
class DeliveryMethod {
  const DeliveryMethod({
    required this.id,
    required this.name,
    required this.fee,
    required this.daysMin,
    required this.daysMax,
    this.needsConfirmation = false,
    this.isPaidToRider = false,
    this.isPickup = false,
    this.feeStatus = DeliveryFeeStatus.fixed,
    this.feeEstimate,
    this.feeNote,
  });

  factory DeliveryMethod.fromJson(Map<String, dynamic> json) {
    return DeliveryMethod(
      id: json['delivery_method_id'] as int,
      name: json['delivery_method_name'] as String,
      fee: json['delivery_method_fee'] as int?,
      daysMin: json['delivery_days_min'] as int,
      daysMax: json['delivery_days_max'] as int,
      needsConfirmation:
          json['delivery_fee_needs_confirmation'] as bool? ?? false,
      isPaidToRider: json['delivery_fee_paid_to_rider'] as bool? ?? false,
      isPickup: json['delivery_method_is_pickup'] as bool? ?? false,
      feeStatus: DeliveryFeeStatus.fromApi(
        json['delivery_fee_status'] as String?,
      ),
      feeEstimate: json['delivery_fee_estimate'] as int?,
      feeNote: json['delivery_fee_note'] as String?,
    );
  }

  final int id;
  final String name;

  /// Whole TZS. At checkout, an upcountry option carries the region's estimate, or null when
  /// the region has none yet ("Bei itathibitishwa").
  final int? fee;
  final int daysMin;
  final int daysMax;

  /// Checkout: the fee is an estimate; staff confirm the price after measuring the load and
  /// only then the customer pays (so no cash on delivery with it).
  final bool needsConfirmation;

  /// Bolt in Dar: the customer pays the rider directly, so the fee is never in CHIMBO's total.
  final bool isPaidToRider;

  /// Collected at the shop ([PickupPoint]); never sent.
  final bool isPickup;

  /// Orders only.
  final DeliveryFeeStatus feeStatus;

  /// Orders only: the estimate given at checkout (0 = the region had none).
  final int? feeEstimate;

  /// Orders only: why staff changed the price ("Mzigo mkubwa, katoni 6").
  final String? feeNote;

  Map<String, dynamic> toJson() => {
    'delivery_method_id': id,
    'delivery_method_name': name,
    'delivery_method_fee': fee,
    'delivery_days_min': daysMin,
    'delivery_days_max': daysMax,
    'delivery_fee_needs_confirmation': needsConfirmation,
    'delivery_fee_paid_to_rider': isPaidToRider,
    'delivery_method_is_pickup': isPickup,
    'delivery_fee_status': feeStatus.apiValue,
    'delivery_fee_estimate': feeEstimate,
    'delivery_fee_note': feeNote,
  };
}

/// `GET /checkout/options?address_id=…`: the delivery methods that reach the address and the
/// payment methods staff switched on, with their names and "pay to" details.
class CheckoutOptions {
  const CheckoutOptions({
    required this.deliveryMethods,
    required this.paymentMethods,
    this.pickupPoint,
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
      pickupPoint: switch (json['pickup_point']) {
        final Map<String, dynamic> point => PickupPoint.fromJson(point),
        _ => null,
      },
    );
  }

  final List<DeliveryMethod> deliveryMethods;
  final List<PaymentMethod> paymentMethods;

  /// Where pickup orders are collected.
  final PickupPoint? pickupPoint;
}

/// `POST /checkout/preview`: server-computed totals for Hakiki.
class CheckoutPreview {
  const CheckoutPreview({
    required this.lineCount,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.deliveryFeeNeedsConfirmation = false,
  });

  factory CheckoutPreview.fromJson(Map<String, dynamic> json) {
    return CheckoutPreview(
      lineCount: json['line_count'] as int,
      subtotal: json['subtotal'] as int,
      deliveryFee: json['delivery_fee'] as int,
      total: json['grand_total'] as int,
      deliveryFeeNeedsConfirmation:
          json['delivery_fee_needs_confirmation'] as bool? ?? false,
    );
  }

  final int lineCount;
  final int subtotal;
  final int deliveryFee;
  final int total;

  /// The transport (and so the total) is an estimate until staff confirm it.
  final bool deliveryFeeNeedsConfirmation;
}
