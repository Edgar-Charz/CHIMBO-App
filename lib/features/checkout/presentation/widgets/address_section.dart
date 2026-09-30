import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/widgets/section_card.dart';
import 'package:chimbo/features/addresses/application/addresses_controller.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:chimbo/features/addresses/presentation/address_details.dart';
import 'package:chimbo/features/addresses/presentation/address_picker_sheet.dart';
import 'package:chimbo/features/checkout/application/checkout_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Anwani ya Uwasilishaji" with Badilisha, or "Ongeza anwani" when there is none yet.
class AddressSection extends ConsumerWidget {
  const AddressSection({super.key});

  Future<void> _addNew(BuildContext context, WidgetRef ref) async {
    final address = await context.push<Address>(AppRoutes.addressForm);
    if (address != null) {
      ref.read(checkoutControllerProvider.notifier).selectAddress(address.id);
    }
  }

  Future<void> _change(
    BuildContext context,
    WidgetRef ref,
    Address current,
  ) async {
    final pick = await showAddressPickerSheet(
      context,
      addresses: ref.read(addressesControllerProvider).value ?? const [],
      selectedId: current.id,
    );
    if (!context.mounted) {
      return;
    }
    switch (pick) {
      case PickedAddress(:final address):
        ref.read(checkoutControllerProvider.notifier).selectAddress(address.id);
      case AddNewAddress():
        await _addNew(context, ref);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final address = ref.watch(checkoutChoicesProvider).address;
    return SectionCard(
      title: l10n.deliveryAddressTitle,
      actionLabel: address == null ? null : l10n.actionChange,
      onAction: address == null ? null : () => _change(context, ref, address),
      child: address == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.noAddressMessage),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _addNew(context, ref),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: Text(l10n.actionAddAddress),
                ),
              ],
            )
          : AddressDetails(address: address),
    );
  }
}
