import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/utils/phone.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:flutter/material.dart';

/// "Joyce Joseph / +255 712 345 678 / Kariakoo, Lumumba Street, Dar es Salaam".
class AddressDetails extends StatelessWidget {
  const AddressDetails({super.key, required this.address});

  final Address address;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(address.recipientName, style: textTheme.titleSmall),
        Text(TzPhone.format(address.phone), style: secondary),
        Text(address.fullLocation, style: secondary),
      ],
    );
  }
}
