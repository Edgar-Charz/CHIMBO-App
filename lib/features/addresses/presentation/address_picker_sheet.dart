import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:chimbo/features/addresses/presentation/address_details.dart';
import 'package:flutter/material.dart';

/// What the customer picked in the sheet.
sealed class AddressPick {
  const AddressPick();
}

final class PickedAddress extends AddressPick {
  const PickedAddress(this.address);

  final Address address;
}

final class AddNewAddress extends AddressPick {
  const AddNewAddress();
}

/// "Badilisha": the saved addresses plus "Ongeza anwani". Null when dismissed.
Future<AddressPick?> showAddressPickerSheet(
  BuildContext context, {
  required List<Address> addresses,
  required int? selectedId,
}) {
  return showModalBottomSheet<AddressPick>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final l10n = context.l10n;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.chooseAddressTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final address in addresses)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    side: BorderSide(
                      color: address.id == selectedId
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: ListTile(
                    onTap: () =>
                        Navigator.of(context).pop(PickedAddress(address)),
                    title: AddressDetails(address: address),
                    trailing: address.id == selectedId
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pop(const AddNewAddress()),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: Text(l10n.actionAddAddress),
              ),
            ],
          ),
        ),
      );
    },
  );
}
