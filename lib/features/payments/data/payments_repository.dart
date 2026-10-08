import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/features/checkout/data/models/payment_method.dart';
import 'package:chimbo/features/payments/data/api_payments_repository.dart';
import 'package:chimbo/features/payments/data/models/payment_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Malipo yangu": the customer's payments and the methods CHIMBO accepts. Every method throws
/// `ApiException`.
abstract interface class PaymentsRepository {
  /// `GET /payments` — newest first (the first 20).
  Future<List<PaymentRecord>> getMyPayments();

  /// `GET /payment-methods` — the methods switched on, with their "pay to" details.
  Future<List<PaymentMethod>> getAcceptedMethods();
}

final paymentsRepositoryProvider = Provider<PaymentsRepository>(
  (ref) => ApiPaymentsRepository(ref.watch(apiClientProvider)),
);
