import 'dart:typed_data';

import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/features/checkout/data/models/payment_method.dart';
import 'package:chimbo/features/orders/data/api_orders_repository.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/data/models/order_list_page.dart';
import 'package:chimbo/features/orders/data/models/order_payment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What "Thibitisha Oda" sends (`POST /orders`).
class PlaceOrderInput {
  const PlaceOrderInput({
    required this.addressId,
    required this.deliveryMethodId,
    required this.paymentMethodCode,
    required this.expectedTotal,
    required this.idempotencyKey,
  });

  final int addressId;
  final int deliveryMethodId;

  /// `payment_method_code` of the chosen [PaymentMethod] ("mpesa", "cod" …).
  final String paymentMethodCode;

  /// The total the customer saw; the server refuses with `PRICE_CHANGED` if it differs.
  final int expectedTotal;

  /// One per checkout, the same on every retry, so the order is created only once.
  final String idempotencyKey;
}

/// Orders (blueprint §12.2 "Checkout, orders"). Every method throws `ApiException`.
abstract interface class OrdersRepository {
  /// `POST /orders`: turns the cart into an order and empties the cart.
  Future<Order> placeOrder(PlaceOrderInput input);

  /// `GET /orders?group=…`, newest first.
  Future<OrderListPage> getOrders(OrderGroup group);

  /// `GET /orders/{id}` + `/tracking`.
  Future<Order> getOrder(int orderId);

  /// `POST /orders/{id}/cancel` (only before packing).
  Future<Order> cancelOrder(int orderId);

  /// `POST /orders/{id}/reorder`: puts the items back in the cart. Returns why each item that
  /// could not be added was skipped (sold out, hidden …), ready to show.
  Future<List<String>> reorder(int orderId);

  /// `POST /orders/{id}/payment` — "Nimelipa": the customer says they paid; staff check it.
  Future<Order> submitPayment(int orderId, PaymentSubmission submission);

  /// `POST /orders/{id}/payment-method` — "Badilisha njia ya malipo" on an unpaid order.
  /// Cash on delivery confirms the order at once.
  Future<Order> changePaymentMethod(int orderId, String paymentMethodCode);

  /// `GET /orders/{id}/receipt`: "Pakua Risiti" as PDF bytes.
  Future<Uint8List> downloadReceipt(int orderId);
}

/// API-backed orders repository.
final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => ApiOrdersRepository(ref.watch(apiClientProvider)),
);
