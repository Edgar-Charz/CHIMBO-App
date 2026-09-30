import 'package:flutter/material.dart';

/// A cart icon with the number of cart lines on it; the number is hidden when the cart is empty.
class CartIconBadge extends StatelessWidget {
  const CartIconBadge({
    super.key,
    required this.count,
    this.icon = Icons.shopping_cart_outlined,
  });

  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Badge.count(
      count: count,
      isLabelVisible: count > 0,
      child: Icon(icon),
    );
  }
}
