import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/core/widgets/confirm_dialog.dart';
import 'package:chimbo/core/widgets/empty_state.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/features/addresses/application/addresses_controller.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:chimbo/features/addresses/presentation/address_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _AddressAction { edit, setDefault, delete }

class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  bool _isMutating = false;

  Future<void> _selectAction(
    BuildContext context,
    Address address,
    _AddressAction action,
  ) async {
    switch (action) {
      case _AddressAction.edit:
        await context.push<void>(
          AppRoutes.editProfileAddress(address.id),
          extra: address,
        );
      case _AddressAction.setDefault:
        await _runMutation(
          () => ref
              .read(addressesControllerProvider.notifier)
              .setDefault(address.id),
        );
      case _AddressAction.delete:
        await _confirmDelete(address);
    }
  }

  Future<void> _confirmDelete(Address address) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteAddressConfirmTitle,
      message: l10n.deleteAddressConfirmMessage,
      confirmLabel: l10n.actionDelete,
      isDestructive: true,
    );
    if (confirmed) {
      await _runMutation(
        () => ref.read(addressesControllerProvider.notifier).delete(address.id),
      );
    }
  }

  Future<void> _runMutation(Future<void> Function() mutation) async {
    setState(() => _isMutating = true);
    try {
      await mutation();
    } catch (error) {
      if (mounted) {
        AppToast.of(context).error(context.l10n.errorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isMutating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final addresses = ref.watch(addressesControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuAddresses)),
      body: addresses.when(
        data: (values) => values.isEmpty
            ? EmptyState(
                icon: Icons.location_on_outlined,
                message: l10n.addressesEmpty,
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .refresh(addressesControllerProvider.future)
                      .then<void>((_) {});
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: values.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) => _AddressCard(
                    address: values[index],
                    isMutating: _isMutating,
                    onAction: (action) =>
                        _selectAction(context, values[index], action),
                  ),
                ),
              ),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(addressesControllerProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            label: l10n.actionAddAddress,
            icon: Icons.add_location_alt_outlined,
            onPressed: _isMutating
                ? null
                : () => context.push<void>(AppRoutes.addProfileAddress),
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isMutating,
    required this.onAction,
  });

  final Address address;
  final bool isMutating;
  final ValueChanged<_AddressAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AddressDetails(address: address),
                    if (address.isDefault) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(l10n.defaultAddressLabel),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            PopupMenuButton<_AddressAction>(
              key: ValueKey('address-menu-${address.id}'),
              enabled: !isMutating,
              tooltip: l10n.addressActions,
              onSelected: onAction,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _AddressAction.edit,
                  child: Text(l10n.actionEditAddress),
                ),
                if (!address.isDefault)
                  PopupMenuItem(
                    value: _AddressAction.setDefault,
                    child: Text(l10n.actionSetDefaultAddress),
                  ),
                PopupMenuItem(
                  value: _AddressAction.delete,
                  child: Text(l10n.actionDelete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
