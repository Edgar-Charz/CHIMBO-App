import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/cart/application/cart_controller.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/data/orders_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One Oda Zangu tab.
final ordersProvider = FutureProvider.autoDispose
    .family<List<Order>, OrderGroup>((ref, group) {
      ref.watch(authControllerProvider.select((state) => state.user?.id));
      return ref.watch(ordersRepositoryProvider).getOrders(group);
    });

/// Fuatilia Oda.
final orderProvider = FutureProvider.autoDispose.family<Order, int>(
  (ref, orderId) => ref.watch(ordersRepositoryProvider).getOrder(orderId),
);

/// Things a customer can do with an order; each refreshes what it changed.
class OrderActions {
  const OrderActions(this._ref);

  final Ref _ref;

  Future<void> cancel(int orderId) async {
    await _ref.read(ordersRepositoryProvider).cancelOrder(orderId);
    _ref
      ..invalidate(orderProvider(orderId))
      ..invalidate(ordersProvider);
  }

  /// "Agiza Tena": the items go back into the cart. Returns why any were skipped.
  Future<List<String>> reorder(int orderId) async {
    final skipped = await _ref.read(ordersRepositoryProvider).reorder(orderId);
    _ref.read(cartControllerProvider.notifier).reload();
    return skipped;
  }
}

final orderActionsProvider = Provider<OrderActions>(OrderActions.new);
