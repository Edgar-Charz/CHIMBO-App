import 'package:chimbo/features/cart/data/cart_repository.dart';
import 'package:chimbo/features/checkout/data/checkout_repository.dart';
import 'package:chimbo/features/checkout/data/models/checkout_options.dart';

/// Checkout for tests, like the server: Standard and Haraka, only "Lipa ukipokea" switched on,
/// totals from the (fake) cart.
class FakeCheckoutRepository implements CheckoutRepository {
  const FakeCheckoutRepository(this._cartRepository);

  static const List<DeliveryMethod> deliveryMethods = [
    DeliveryMethod(
      id: 1,
      name: 'Standard (siku 2–3)',
      fee: 5000,
      daysMin: 2,
      daysMax: 3,
    ),
    DeliveryMethod(
      id: 2,
      name: 'Haraka (kesho)',
      fee: 10000,
      daysMin: 1,
      daysMax: 1,
    ),
  ];

  final CartRepository _cartRepository;

  @override
  Future<CheckoutOptions> getOptions({int? addressId}) async {
    return const CheckoutOptions(
      deliveryMethods: deliveryMethods,
      paymentMethods: [PaymentMethod.cashOnDelivery],
    );
  }

  @override
  Future<CheckoutPreview> preview({
    required int deliveryMethodId,
    required int addressId,
  }) async {
    final cart = await _cartRepository.getCart();
    final fee = deliveryMethods
        .firstWhere((method) => method.id == deliveryMethodId)
        .fee;
    return CheckoutPreview(
      lineCount: cart.lineCount,
      subtotal: cart.subtotal,
      deliveryFee: fee,
      total: cart.subtotal + fee,
    );
  }
}
