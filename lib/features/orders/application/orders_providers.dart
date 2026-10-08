import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/cart/application/cart_controller.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/data/models/order_payment.dart';
import 'package:chimbo/features/orders/data/orders_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One Oda Zangu tab.
final ordersProvider = FutureProvider.autoDispose
    .family<List<Order>, OrderGroup>((ref, group) {
      ref.watch(authControllerProvider.select((state) => state.user?.id));
      return ref.watch(ordersRepositoryProvider).getOrders(group);
    });

/// One order (Fuatilia Oda, "Oda Imepokelewa!"). Actions show the order the server sends
/// back with [show] instead of loading it again.
class OrderController extends AsyncNotifier<Order> {
  // Riverpod families pass their argument to the constructor.
  OrderController(this.orderId);

  final int orderId;

  @override
  Future<Order> build() =>
      ref.watch(ordersRepositoryProvider).getOrder(orderId);

  void show(Order order) => state = AsyncData(order);
}

final orderProvider = AsyncNotifierProvider.autoDispose
    .family<OrderController, Order, int>(OrderController.new);

/// Things a customer can do with an order; each refreshes what it changed.
class OrderActions {
  const OrderActions(this._ref);

  final Ref _ref;

  Future<void> cancel(int orderId) async {
    _showUpdated(
      await _ref.read(ordersRepositoryProvider).cancelOrder(orderId),
    );
  }

  /// "Agiza Tena": the items go back into the cart. Returns why any were skipped.
  Future<List<String>> reorder(int orderId) async {
    final skipped = await _ref.read(ordersRepositoryProvider).reorder(orderId);
    _ref.read(cartControllerProvider.notifier).reload();
    return skipped;
  }

  /// "Nimelipa": sends the payer's number and SMS code; the order then shows "Tunakagua
  /// malipo yako". Errors (wrong code, time over …) reach the caller to show.
  Future<void> submitPayment(int orderId, PaymentSubmission submission) async {
    _showUpdated(
      await _ref
          .read(ordersRepositoryProvider)
          .submitPayment(orderId, submission),
    );
  }

  /// "Badilisha njia ya malipo". Returns the updated order (cash on delivery: confirmed).
  Future<Order> changePaymentMethod(
    int orderId,
    String paymentMethodCode,
  ) async {
    final order = await _ref
        .read(ordersRepositoryProvider)
        .changePaymentMethod(orderId, paymentMethodCode);
    _showUpdated(order);
    return order;
  }

  /// Downloads the PDF, then lets the customer choose where to save it.
  Future<void> downloadReceipt(Order order) async {
    final bytes = await _ref
        .read(ordersRepositoryProvider)
        .downloadReceipt(order.id);
    await _downloadsChannel.invokeMethod<void>('savePdf', {
      'fileName': 'Risiti-${order.number}.pdf',
      'bytes': bytes,
    });
  }

  /// Shows the server's answer on the order's screen; the lists reload (status may move).
  void _showUpdated(Order order) {
    _ref.read(orderProvider(order.id).notifier).show(order);
    _ref.invalidate(ordersProvider);
  }

  static const MethodChannel _downloadsChannel = MethodChannel(
    'com.chimbo.chimbo/downloads',
  );
}

final orderActionsProvider = Provider<OrderActions>(OrderActions.new);
