import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/features/checkout/data/models/checkout_options.dart';
import 'package:flutter/material.dart';

/// Where and when to collect a pickup order ("Nitachukua mwenyewe dukani"), and what to bring.
class PickupPointDetails extends StatelessWidget {
  const PickupPointDetails({
    super.key,
    required this.pickupPoint,
    required this.orderNumber,
  });

  final PickupPoint pickupPoint;
  final String orderNumber;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(pickupPoint.address, style: textTheme.titleSmall),
        Text(pickupPoint.hours, style: secondary),
        Text(context.l10n.pickupPointHint(orderNumber), style: secondary),
      ],
    );
  }
}
