import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/features/addresses/data/address_repository.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:chimbo/features/cart/data/cart_repository.dart';
import 'package:chimbo/features/catalog/data/catalog_repository.dart';
import 'package:chimbo/features/catalog/data/models/product_query.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/checkout/data/checkout_repository.dart';
import 'package:chimbo/features/checkout/data/models/checkout_options.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/data/orders_repository.dart';
import 'package:chimbo/features/profile/data/profile_repository.dart';

import 'fake_customer_store.dart';

/// Offline stand-in for the orders API.
///
/// So tracking can be tested without a back office, a new order moves along by itself:
/// packed after 2 minutes, dispatched after 4, on the way after 6, delivered after 10.
/// A customer's first visit also gets two delivered orders as sample history.
class FakeOrdersRepository implements OrdersRepository {
  const FakeOrdersRepository({
    required this._store,
    required this._cartRepository,
    required this._addressRepository,
    required this._catalog,
    required this._profileRepository,
    required this._checkout,
  });

  static const String _storageName = 'orders';

  /// When each timeline step is reached, counted from placing the order.
  static const Map<OrderStatus, Duration> _stepDelays = {
    OrderStatus.confirmed: Duration.zero,
    OrderStatus.packed: Duration(minutes: 2),
    OrderStatus.dispatched: Duration(minutes: 4),
    OrderStatus.inTransit: Duration(minutes: 6),
    OrderStatus.delivered: Duration(minutes: 10),
  };

  static const DeliveryAgent _agent = (
    name: 'Juma Mbeva',
    phone: '+255712987654',
  );

  /// Two delivered sample orders built from the catalog's best sellers.
  static const List<({int daysAgo, int itemCount})> _sampleHistory = [
    (daysAgo: 12, itemCount: 3),
    (daysAgo: 27, itemCount: 2),
  ];

  /// Sample orders buy each product at twice its MOQ.
  static const int _sampleMoqMultiple = 2;

  final FakeCustomerStore _store;
  final CartRepository _cartRepository;
  final AddressRepository _addressRepository;
  final CatalogRepository _catalog;
  final ProfileRepository _profileRepository;

  /// Real delivery methods and fees (`/checkout/options`).
  final CheckoutRepository _checkout;

  @override
  Future<Order> placeOrder(PlaceOrderInput input) async {
    final cart = await _cartRepository.getCart();
    final addresses = await _addressRepository.getAddresses();
    final address = addresses.where((saved) => saved.id == input.addressId);
    if (cart.isEmpty || address.isEmpty) {
      throw const ApiException(code: ApiErrorCode.validation);
    }
    final options = await _checkout.getOptions(addressId: input.addressId);
    final deliveryMethod = options.deliveryMethods.firstWhere(
      (method) => method.id == input.deliveryMethodId,
    );
    if (cart.subtotal + deliveryMethod.fee != input.expectedTotal) {
      throw const ApiException(code: ApiErrorCode.priceChanged);
    }

    final records = await _readRecords();
    final record = _record(
      id: records.length + 1,
      placedAt: DateTime.now(),
      deliveryMethod: deliveryMethod,
      paymentMethod: input.paymentMethod,
      address: address.first,
      items: [
        for (final line in cart.lines)
          OrderItem(
            productId: line.product.id,
            productName: line.product.name,
            quantity: line.quantity,
            unitPrice: line.unitPrice,
            lineTotal: line.lineTotal,
            imageUrl: line.product.imageUrl,
          ),
      ],
    );
    await _writeRecords([...records, record]);
    await _cartRepository.clear();
    return _toOrder(record);
  }

  @override
  Future<List<Order>> getOrders(OrderGroup group) async {
    final orders = (await _readRecords()).map(_toOrder).toList()
      ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return orders.where((order) => _isInGroup(order.status, group)).toList();
  }

  @override
  Future<Order> getOrder(int orderId) async =>
      _toOrder(_find(await _readRecords(), orderId));

  @override
  Future<Order> cancelOrder(int orderId) async {
    final records = await _readRecords();
    final record = _find(records, orderId);
    if (!_toOrder(record).canCancel) {
      throw const ApiException(code: ApiErrorCode.validation);
    }
    final cancelled = {
      ...record,
      'cancelled_at': DateTime.now().toIso8601String(),
    };
    await _writeRecords([
      for (final saved in records) saved == record ? cancelled : saved,
    ]);
    return _toOrder(cancelled);
  }

  @override
  Future<List<String>> reorder(int orderId) async {
    final order = _toOrder(_find(await _readRecords(), orderId));
    final skipped = <String>[];
    for (final item in order.items) {
      try {
        await _cartRepository.addItem(item.productId, item.quantity);
      } on ApiException catch (error) {
        // Like the server: items that can't be added (stock, MOQ) are skipped.
        skipped.add(error.message ?? item.productName);
      }
    }
    return skipped;
  }

  static bool _isInGroup(OrderStatus status, OrderGroup group) =>
      switch (group) {
        OrderGroup.active => status.isActive,
        OrderGroup.delivered => status == OrderStatus.delivered,
        OrderGroup.all => true,
      };

  Map<String, dynamic> _find(List<Map<String, dynamic>> records, int orderId) {
    for (final record in records) {
      if (record['order_id'] == orderId) {
        return record;
      }
    }
    throw const ApiException(code: ApiErrorCode.notFound);
  }

  Future<List<Map<String, dynamic>>> _readRecords() async {
    final stored = await _store.read(_storageName);
    if (stored is List<dynamic>) {
      return stored.cast<Map<String, dynamic>>();
    }
    final history = await _sampleRecords();
    await _writeRecords(history);
    return history;
  }

  Future<void> _writeRecords(List<Map<String, dynamic>> records) =>
      _store.write(_storageName, records);

  Future<List<Map<String, dynamic>>> _sampleRecords() async {
    final customer = await _profileRepository.getProfile();
    final address = Address(
      id: 0,
      recipientName: customer.user.fullName ?? '',
      phone: customer.user.phone,
      regionId: 2,
      regionName: 'Dar es Salaam',
      street: 'Kariakoo, Mtaa wa Lumumba',
    );
    final standardDelivery =
        (await _checkout.getOptions()).deliveryMethods.first;
    final bestSellers = (await _catalog.getProducts(
      const ProductQuery(collection: ProductCollection.bestSellers),
      page: 1,
    )).items.where((product) => product.isInStock).iterator;
    final records = <Map<String, dynamic>>[];
    for (final (index, sample) in _sampleHistory.indexed) {
      final items = [
        for (
          var item = 0;
          item < sample.itemCount && bestSellers.moveNext();
          item++
        )
          _sampleItem(bestSellers.current),
      ];
      if (items.isEmpty) {
        break;
      }
      records.add(
        _record(
          id: index + 1,
          placedAt: DateTime.now().subtract(Duration(days: sample.daysAgo)),
          deliveryMethod: standardDelivery,
          paymentMethod: PaymentMethod.cashOnDelivery,
          address: address,
          items: items,
        ),
      );
    }
    return records;
  }

  OrderItem _sampleItem(ProductSummary product) {
    final quantity = product.moq * _sampleMoqMultiple;
    return OrderItem(
      productId: product.id,
      productName: product.name,
      quantity: quantity,
      unitPrice: product.price,
      lineTotal: product.price * quantity,
      imageUrl: product.imageUrl,
    );
  }

  Map<String, dynamic> _record({
    required int id,
    required DateTime placedAt,
    required DeliveryMethod deliveryMethod,
    required PaymentMethod paymentMethod,
    required Address address,
    required List<OrderItem> items,
  }) {
    final subtotal = items.fold(0, (sum, item) => sum + item.lineTotal);
    final fee = deliveryMethod.fee;
    return {
      'order_id': id,
      // "CHB" + 6 digits (blueprint §11.1).
      'order_number':
          'CHB${(placedAt.millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0')}',
      'placed_at': placedAt.toIso8601String(),
      'delivery_method': deliveryMethod.toJson(),
      'payment_method': paymentMethod.apiValue,
      'address': address.toJson(),
      'items': [for (final item in items) item.toJson()],
      'order_subtotal': subtotal,
      'order_delivery_fee': fee,
      'order_total': subtotal + fee,
      'cancelled_at': null,
    };
  }

  /// Works out the status from the time passed, like the back office would have moved it.
  Order _toOrder(Map<String, dynamic> record) {
    final placedAt = DateTime.parse(record['placed_at'] as String);
    final cancelledAt = record['cancelled_at'] == null
        ? null
        : DateTime.parse(record['cancelled_at'] as String);
    final now = cancelledAt ?? DateTime.now();
    final events = <OrderEvent>[
      for (final MapEntry(key: status, value: delay) in _stepDelays.entries)
        if (!placedAt.add(delay).isAfter(now))
          (status: status, at: placedAt.add(delay)),
      if (cancelledAt != null) (status: OrderStatus.cancelled, at: cancelledAt),
    ];
    final status = events.last.status;
    final deliveryMethod = DeliveryMethod.fromJson(
      record['delivery_method'] as Map<String, dynamic>,
    );
    return Order(
      id: record['order_id'] as int,
      number: record['order_number'] as String,
      status: status,
      placedAt: placedAt,
      estimatedDelivery: placedAt.add(Duration(days: deliveryMethod.daysMax)),
      items: (record['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: record['order_subtotal'] as int,
      deliveryFee: record['order_delivery_fee'] as int,
      total: record['order_total'] as int,
      deliveryMethod: deliveryMethod,
      paymentMethod: PaymentMethod.fromApi(record['payment_method'] as String),
      address: Address.fromJson(record['address'] as Map<String, dynamic>),
      events: events,
      // Like the server: only before packing.
      canCancel:
          status == OrderStatus.pendingPayment ||
          status == OrderStatus.confirmed,
      agent:
          status.index >= OrderStatus.dispatched.index &&
              status != OrderStatus.cancelled
          ? _agent
          : null,
    );
  }
}
