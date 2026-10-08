import 'package:chimbo/features/checkout/data/models/payment_method.dart';
import 'package:chimbo/features/payments/data/models/payment_record.dart';
import 'package:chimbo/features/payments/data/payments_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The customer's payments, loaded each time "Malipo yangu" opens (staff may have reviewed one).
final myPaymentsProvider = FutureProvider.autoDispose<List<PaymentRecord>>(
  (ref) => ref.watch(paymentsRepositoryProvider).getMyPayments(),
);

/// "Njia za malipo tunazokubali" with their "pay to" details.
final acceptedPaymentMethodsProvider =
    FutureProvider.autoDispose<List<PaymentMethod>>(
      (ref) => ref.watch(paymentsRepositoryProvider).getAcceptedMethods(),
    );
