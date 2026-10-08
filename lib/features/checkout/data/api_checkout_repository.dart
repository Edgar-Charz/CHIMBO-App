import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/features/checkout/data/checkout_repository.dart';
import 'package:chimbo/features/checkout/data/models/checkout_options.dart';
import 'package:chimbo/features/checkout/data/models/payment_method.dart';

/// Checkout from the CHIMBO API (docs/API_REFERENCE.md, "Checkout").
class ApiCheckoutRepository implements CheckoutRepository {
  const ApiCheckoutRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<CheckoutOptions> getOptions({int? addressId}) async {
    final response = await _apiClient.get(
      '/checkout/options',
      query: {'address_id': ?addressId},
    );
    return CheckoutOptions.fromJson(response.dataAsMap);
  }

  /// `CART_EMPTY` / `CART_HAS_PROBLEMS` (409) come back as `ApiException` with a message to show.
  @override
  Future<CheckoutPreview> preview({
    required int deliveryMethodId,
    required int addressId,
  }) async {
    final response = await _apiClient.post(
      '/checkout/preview',
      body: {'delivery_method_id': deliveryMethodId, 'address_id': addressId},
    );
    return CheckoutPreview.fromJson(response.dataAsMap);
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods() async {
    final response = await _apiClient.get('/payment-methods');
    return response.dataAsList
        .map((json) => PaymentMethod.fromJson(json! as Map<String, dynamic>))
        .toList();
  }
}
