import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
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
        'payment_method': input.paymentMethod.apiValue,
        'expected_total': input.expectedTotal,
      },
    );
    return Order.fromJson(response.dataAsMap);
  }

  @override
  Future<List<Order>> getOrders(OrderGroup group) async {
    final response = await _apiClient.get(
      '/orders',
      query: {'group': group.apiValue},
    );
    return response.dataAsList
        .map((json) => Order.fromJson(json! as Map<String, dynamic>))
        .toList();
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
}
