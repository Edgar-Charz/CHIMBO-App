import 'package:chimbo/core/utils/idempotency_key.dart';
import 'package:chimbo/features/addresses/application/addresses_controller.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:chimbo/features/cart/application/cart_controller.dart';
import 'package:chimbo/features/catalog/application/catalog_providers.dart';
import 'package:chimbo/features/checkout/data/checkout_repository.dart';
import 'package:chimbo/features/checkout/data/models/checkout_options.dart';
import 'package:chimbo/features/checkout/data/models/payment_method.dart';
import 'package:chimbo/features/orders/application/orders_providers.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/data/orders_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The customer's choices across the checkout screens. Null = not chosen yet: the default
/// address, the first delivery method that reaches it, the first payment method switched on.
class CheckoutSelection {
  const CheckoutSelection({
    required this.orderKey,
    this.addressId,
    this.deliveryMethodId,
    this.paymentMethodCode,
  });

  /// The `Idempotency-Key` for this checkout: kept while retrying, new after an order is placed.
  final String orderKey;
  final int? addressId;
  final int? deliveryMethodId;
  final String? paymentMethodCode;

  CheckoutSelection copyWith({
    int? addressId,
    int? deliveryMethodId,
    String? paymentMethodCode,
  }) {
    return CheckoutSelection(
      orderKey: orderKey,
      addressId: addressId ?? this.addressId,
      deliveryMethodId: deliveryMethodId ?? this.deliveryMethodId,
      paymentMethodCode: paymentMethodCode ?? this.paymentMethodCode,
    );
  }
}

/// Holds the checkout choices from "Malipo na Usafirishaji" to "Thibitisha Oda".
class CheckoutController extends Notifier<CheckoutSelection> {
  @override
  CheckoutSelection build() => CheckoutSelection(orderKey: newIdempotencyKey());

  void selectAddress(int addressId) =>
      state = state.copyWith(addressId: addressId);

  void selectDelivery(int deliveryMethodId) =>
      state = state.copyWith(deliveryMethodId: deliveryMethodId);

  void selectPayment(PaymentMethod method) =>
      state = state.copyWith(paymentMethodCode: method.code);

  /// "Thibitisha Oda": places the order, then refreshes the cart, the order lists and Home.
  /// A failed attempt keeps the key, so retrying after a timeout can't order twice.
  Future<Order> placeOrder({
    required Address address,
    required DeliveryMethod deliveryMethod,
    required PaymentMethod paymentMethod,
    required int expectedTotal,
  }) async {
    final order = await ref
        .read(ordersRepositoryProvider)
        .placeOrder(
          PlaceOrderInput(
            addressId: address.id,
            deliveryMethodId: deliveryMethod.id,
            paymentMethodCode: paymentMethod.code,
            expectedTotal: expectedTotal,
            idempotencyKey: state.orderKey,
          ),
        );
    ref.read(cartControllerProvider.notifier).reload();
    ref.invalidate(ordersProvider);
    ref.invalidate(homeDataProvider);
    ref.invalidateSelf();
    return order;
  }
}

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, CheckoutSelection>(
      CheckoutController.new,
    );

/// The chosen address (the default one until the customer picks another); null when the
/// customer has none yet.
final checkoutAddressProvider = Provider<Address?>((ref) {
  final selectedId = ref.watch(
    checkoutControllerProvider.select((selection) => selection.addressId),
  );
  final addresses = ref.watch(addressesControllerProvider).value ?? const [];
  for (final address in addresses) {
    if (selectedId == null ? address.isDefault : address.id == selectedId) {
      return address;
    }
  }
  return null;
});

/// Delivery methods that reach the chosen address (Haraka is Dar es Salaam only) and the payment
/// methods switched on. Reloads when the address changes.
final checkoutOptionsProvider = FutureProvider<CheckoutOptions>((ref) {
  final addressId = ref.watch(
    checkoutAddressProvider.select((address) => address?.id),
  );
  return ref.watch(checkoutRepositoryProvider).getOptions(addressId: addressId);
});

typedef CheckoutChoices = ({
  Address? address,
  DeliveryMethod? deliveryMethod,
  PaymentMethod? paymentMethod,
});

/// What will actually be ordered: the chosen options, or the first available ones when nothing
/// (or something no longer offered) is chosen. Parts are null while loading.
final checkoutChoicesProvider = Provider<CheckoutChoices>((ref) {
  final selection = ref.watch(checkoutControllerProvider);
  final options = ref.watch(checkoutOptionsProvider).value;
  return (
    address: ref.watch(checkoutAddressProvider),
    deliveryMethod: _chosenOrFirst(
      options?.deliveryMethods,
      (method) => method.id == selection.deliveryMethodId,
    ),
    paymentMethod: _chosenOrFirst(
      options?.paymentMethods,
      (method) => method.code == selection.paymentMethodCode,
    ),
  );
});

T? _chosenOrFirst<T>(List<T>? available, bool Function(T option) isChosen) {
  if (available == null || available.isEmpty) {
    return null;
  }
  return available.firstWhere(isChosen, orElse: () => available.first);
}

/// Server-computed totals for the chosen address and delivery method.
final checkoutPreviewProvider = FutureProvider.autoDispose<CheckoutPreview?>((
  ref,
) async {
  final choices = ref.watch(checkoutChoicesProvider);
  final address = choices.address;
  final deliveryMethod = choices.deliveryMethod;
  // Recompute when the cart changes.
  ref.watch(cartControllerProvider);
  if (address == null || deliveryMethod == null) {
    return null;
  }
  return ref
      .read(checkoutRepositoryProvider)
      .preview(deliveryMethodId: deliveryMethod.id, addressId: address.id);
});

/// Every payment method switched on ("Badilisha njia ya malipo").
final paymentMethodsProvider = FutureProvider.autoDispose<List<PaymentMethod>>(
  (ref) => ref.watch(checkoutRepositoryProvider).getPaymentMethods(),
);
