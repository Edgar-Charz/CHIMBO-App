import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/features/checkout/data/models/payment_method.dart';
import 'package:chimbo/features/payments/data/models/payment_record.dart';
import 'package:chimbo/features/payments/data/payments_repository.dart';

/// "Malipo yangu" from the CHIMBO API (docs/API_REFERENCE.md, "Payments").
class ApiPaymentsRepository implements PaymentsRepository {
  const ApiPaymentsRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<PaymentRecord>> getMyPayments() async {
    final response = await _apiClient.get('/payments');
    return response.dataAsList
        .map((item) => PaymentRecord.fromJson(item! as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PaymentMethod>> getAcceptedMethods() async {
    final response = await _apiClient.get('/payment-methods');
    return response.dataAsList
        .map((item) => PaymentMethod.fromJson(item! as Map<String, dynamic>))
        .toList();
  }
}
