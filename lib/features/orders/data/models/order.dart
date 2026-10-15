import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:chimbo/features/checkout/data/models/checkout_options.dart';
import 'package:chimbo/features/orders/data/models/order_payment.dart';

/// The order status machine (blueprint §11.3).
enum OrderStatus {
  pendingPayment('pending_payment'),
  confirmed('confirmed'),
  packed('packed'),
  dispatched('dispatched'),
  inTransit('in_transit'),
  delivered('delivered'),
  cancelled('cancelled'),
  expired('expired');

  const OrderStatus(this.apiValue);

  final String apiValue;

  /// A pickup order: ready ("Tayari kuchukuliwa") → collected ("Imechukuliwa"), never sent.
  static const List<OrderStatus> pickupTimeline = [
    confirmed,
    packed,
    delivered,
  ];

  /// The happy path shown on the tracking timeline, in order.
  static const List<OrderStatus> timeline = [
    confirmed,
    packed,
    dispatched,
    inTransit,
    delivered,
  ];

  static OrderStatus fromApi(String value) =>
      values.firstWhere((status) => status.apiValue == value);

  /// Ended without delivery (payment status `cancelled`): shown the same way either way.
  bool get isStopped => this == cancelled || this == expired;

  /// "Agiza Tena" is offered only for orders that are over: delivered, cancelled, or expired
  /// (the time to pay ran out — the same products again at today's prices).
  bool get canReorder =>
      this == delivered || this == cancelled || this == expired;

  /// "Zinazoendelea" tab.
  bool get isActive =>
      this != delivered && this != cancelled && this != expired;
}

/// Oda Zangu tabs (`group` param of `GET /orders`).
enum OrderGroup {
  active('active'),
  delivered('delivered'),
  all('all');

  const OrderGroup(this.apiValue);

  final String apiValue;
}

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.imageUrl,
    this.offerPercent = 0,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      quantity: json['order_item_quantity'] as int,
      unitPrice: json['order_item_unit_price'] as int,
      lineTotal: json['order_item_line_total'] as int,
      imageUrl: json['product_image_url'] as String?,
      offerPercent: json['order_item_offer_percent'] as int? ?? 0,
    );
  }

  final int productId;
  final String productName;
  final int quantity;
  final int unitPrice;
  final int lineTotal;
  final String? imageUrl;

  /// The offer's discount when ordered ("Ofa −15%"); 0 when none.
  final int offerPercent;

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'product_name': productName,
    'order_item_quantity': quantity,
    'order_item_unit_price': unitPrice,
    'order_item_line_total': lineTotal,
    'product_image_url': imageUrl,
    'order_item_offer_percent': offerPercent,
  };
}

/// One reached step of the timeline ("Imepakiwa — 14 Mei, 14:30").
typedef OrderEvent = ({OrderStatus status, DateTime at});

/// The person bringing the order (`delivery_agents`).
typedef DeliveryAgent = ({String name, String phone});

/// An order with everything Oda Zangu and Fuatilia Oda show.
class Order {
  const Order({
    required this.id,
    required this.number,
    required this.status,
    required this.placedAt,
    required this.estimatedDelivery,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    this.discountTotal = 0,
    this.discountNote,
    required this.total,
    required this.deliveryMethod,
    required this.payment,
    required this.address,
    required this.events,
    required this.canCancel,
    this.agent,
    this.expiresAt,
    this.pickupPoint,
  });

  /// An order from `GET /orders`, `GET /orders/{id}` or `POST /orders`.
  factory Order.fromJson(Map<String, dynamic> json) {
    final placedAt = DateTime.parse(json['order_placed_at'] as String);
    final deliveryMethod = DeliveryMethod.fromJson(
      json['delivery_method'] as Map<String, dynamic>,
    );
    final estimated = json['order_estimated_delivery_date'] as String?;
    final agent = json['delivery_agent'] as Map<String, dynamic>?;
    final expiresAt = json['order_expires_at'] as String?;
    return Order(
      id: json['order_id'] as int,
      number: json['order_number'] as String,
      status: OrderStatus.fromApi(json['order_status'] as String),
      placedAt: placedAt,
      // Without a date from the server, the slowest delivery day is the best guess.
      estimatedDelivery: estimated == null
          ? placedAt.add(Duration(days: deliveryMethod.daysMax))
          : DateTime.parse(estimated),
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: json['order_subtotal'] as int,
      deliveryFee: json['order_delivery_fee'] as int,
      discountTotal: json['order_discount_total'] as int? ?? 0,
      discountNote: json['order_discount_note'] as String?,
      total: json['order_total'] as int,
      deliveryMethod: deliveryMethod,
      payment: OrderPayment.fromJson(json['payment'] as Map<String, dynamic>),
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      events: [
        for (final event in json['events'] as List<dynamic>? ?? const [])
          _eventFromJson(event as Map<String, dynamic>),
      ],
      canCancel: json['can_cancel'] as bool,
      expiresAt: expiresAt == null ? null : DateTime.parse(expiresAt),
      pickupPoint: switch (json['pickup_point']) {
        final Map<String, dynamic> point => PickupPoint.fromJson(point),
        _ => null,
      },
      agent: agent == null
          ? null
          : (
              name: agent['delivery_agent_full_name'] as String,
              phone: agent['delivery_agent_phone'] as String,
            ),
    );
  }

  static OrderEvent _eventFromJson(Map<String, dynamic> json) => (
    status: OrderStatus.fromApi(json['order_status'] as String),
    at: DateTime.parse(json['created_at'] as String),
  );

  final int id;

  /// "CHB123456" (shown with a #).
  final String number;
  final OrderStatus status;
  final DateTime placedAt;
  final DateTime estimatedDelivery;
  final List<OrderItem> items;
  final int subtotal;
  final int deliveryFee;

  /// A discount staff gave on the products (0 when none), and why ("Mteja wa kudumu").
  final int discountTotal;
  final String? discountNote;
  final int total;
  final DeliveryMethod deliveryMethod;
  final OrderPayment payment;
  final Address address;

  /// Steps reached so far, oldest first.
  final List<OrderEvent> events;

  /// Decided by the server: only before packing (blueprint §11.3).
  final bool canCancel;

  /// An unpaid mobile money / bank order is cancelled by itself after this time.
  final DateTime? expiresAt;

  /// Known once the order is dispatched.
  final DeliveryAgent? agent;

  /// Where to collect it (pickup orders only).
  final PickupPoint? pickupPoint;

  /// "Nitachukua mwenyewe dukani": collected at the shop, never sent.
  bool get isPickup => deliveryMethod.isPickup;

  /// Upcountry: staff are measuring the load to confirm the transport price; no paying yet.
  bool get isAwaitingTransportPrice =>
      status == OrderStatus.pendingPayment &&
      deliveryMethod.feeStatus == DeliveryFeeStatus.awaitingConfirmation;

  DateTime? get deliveredAt {
    for (final event in events) {
      if (event.status == OrderStatus.delivered) {
        return event.at;
      }
    }
    return null;
  }
}
