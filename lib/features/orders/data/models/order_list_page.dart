import 'package:chimbo/features/orders/data/models/order.dart';

/// One page of orders and the server's total count for the selected group.
class OrderListPage {
  const OrderListPage({required this.orders, required this.total});

  final List<Order> orders;
  final int total;
}
