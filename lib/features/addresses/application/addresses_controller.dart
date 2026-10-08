import 'package:chimbo/features/addresses/data/address_repository.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The customer's saved delivery addresses.
class AddressesController extends AsyncNotifier<List<Address>> {
  @override
  Future<List<Address>> build() async {
    ref.watch(authControllerProvider.select((state) => state.user?.id));
    final addresses = await ref.read(addressRepositoryProvider).getAddresses();
    return _defaultFirst(addresses);
  }

  /// Saves a new address and returns it, so checkout can pick it straight away.
  Future<Address> add(AddressInput input) async {
    final address = await ref
        .read(addressRepositoryProvider)
        .createAddress(input);
    state = AsyncData(_defaultFirst([...state.value ?? const [], address]));
    return address;
  }

  Future<Address> editAddress(int addressId, AddressInput input) async {
    final address = await ref
        .read(addressRepositoryProvider)
        .updateAddress(addressId, input);
    final addresses = state.value ?? const <Address>[];
    state = AsyncData(
      _defaultFirst([
        for (final saved in addresses)
          if (saved.id == address.id) address else saved,
      ]),
    );
    return address;
  }

  Future<void> setDefault(int addressId) async {
    final addresses = await ref
        .read(addressRepositoryProvider)
        .setDefaultAddress(addressId);
    state = AsyncData(_defaultFirst(addresses));
  }

  Future<void> delete(int addressId) async {
    final addresses = await ref
        .read(addressRepositoryProvider)
        .deleteAddress(addressId);
    state = AsyncData(_defaultFirst(addresses));
  }

  List<Address> _defaultFirst(List<Address> addresses) {
    return [
      ...addresses.where((address) => address.isDefault),
      ...addresses.where((address) => !address.isDefault),
    ];
  }
}

final addressesControllerProvider =
    AsyncNotifierProvider<AddressesController, List<Address>>(
      AddressesController.new,
    );
