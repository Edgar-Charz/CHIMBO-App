import 'package:flutter/material.dart';

/// An icon with a count on it (cart lines, unread notifications); the number is hidden at 0.
class CountIconBadge extends StatelessWidget {
  const CountIconBadge({
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
