import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/features/checkout/data/api_checkout_repository.dart';
import 'package:chimbo/features/checkout/data/models/checkout_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Checkout choices and totals (docs/API_REFERENCE.md, "Checkout").
abstract interface class CheckoutRepository {
  /// Delivery methods that reach [addressId] (all of them without one) and the payment methods
  /// switched on.
  Future<CheckoutOptions> getOptions({int? addressId});

  /// Totals computed by the server for the cart, this delivery method and address.
  Future<CheckoutPreview> preview({
    required int deliveryMethodId,
    required int addressId,
  });
}

final checkoutRepositoryProvider = Provider<CheckoutRepository>(
  (ref) => ApiCheckoutRepository(ref.watch(apiClientProvider)),
);
