import 'dart:typed_data';

import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/data/models/order_list_page.dart';
import 'package:chimbo/features/orders/data/models/order_payment.dart';
import 'package:chimbo/features/orders/data/orders_repository.dart';

/// Orders and tracking from the CHIMBO API (docs/API_REFERENCE.md, "Orders").
class ApiOrdersRepository implements OrdersRepository {
  const ApiOrdersRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Order> placeOrder(PlaceOrderInput input) async {
    final response = await _apiClient.post(
      '/orders',
      headers: {'Idempotency-Key': input.idempotencyKey},
      body: {
        'address_id': input.addressId,
        'delivery_method_id': input.deliveryMethodId,
        'payment_method': input.paymentMethodCode,
        'expected_total': input.expectedTotal,
      },
    );
    return Order.fromJson(response.dataAsMap);
  }

  @override
  Future<OrderListPage> getOrders(OrderGroup group) async {
    final response = await _apiClient.get(
      '/orders',
      query: {'group': group.apiValue},
    );
    final orders = response.dataAsList
        .map((json) => Order.fromJson(json! as Map<String, dynamic>))
        .toList();
    return OrderListPage(
      orders: orders,
      total: response.meta['total'] as int? ?? orders.length,
    );
  }

  @override
  Future<Order> getOrder(int orderId) async {
    final response = await _apiClient.get('/orders/$orderId');
    return Order.fromJson(response.dataAsMap);
  }

  @override
  Future<Order> cancelOrder(int orderId) async {
    final response = await _apiClient.post('/orders/$orderId/cancel');
    return Order.fromJson(response.dataAsMap);
  }

  @override
  Future<List<String>> reorder(int orderId) async {
    final response = await _apiClient.post('/orders/$orderId/reorder');
    final skipped = response.dataAsMap['skipped_items'] as List<dynamic>;
    return [
      for (final item in skipped)
        (item as Map<String, dynamic>)['message'] as String,
    ];
  }

  @override
  Future<Order> submitPayment(int orderId, PaymentSubmission submission) async {
    final response = await _apiClient.post(
      '/orders/$orderId/payment',
      body: submission.toJson(),
    );
    return Order.fromJson(response.dataAsMap);
  }

  @override
  Future<Order> changePaymentMethod(
    int orderId,
    String paymentMethodCode,
  ) async {
    final response = await _apiClient.post(
      '/orders/$orderId/payment-method',
      body: {'payment_method': paymentMethodCode},
    );
    return Order.fromJson(response.dataAsMap);
  }

  @override
  Future<Uint8List> downloadReceipt(int orderId) {
    return _apiClient.download('/orders/$orderId/receipt');
  }
}
