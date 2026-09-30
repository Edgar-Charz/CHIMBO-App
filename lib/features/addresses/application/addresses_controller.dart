import 'package:chimbo/features/addresses/data/address_repository.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The customer's saved delivery addresses.
class AddressesController extends AsyncNotifier<List<Address>> {
  @override
  Future<List<Address>> build() {
    ref.watch(authControllerProvider.select((state) => state.user?.id));
    return ref.read(addressRepositoryProvider).getAddresses();
  }

  /// Saves a new address and returns it, so checkout can pick it straight away.
  Future<Address> add(AddressInput input) async {
    final address = await ref
        .read(addressRepositoryProvider)
        .createAddress(input);
    state = AsyncData([...state.value ?? const [], address]);
    return address;
  }
}

final addressesControllerProvider =
    AsyncNotifierProvider<AddressesController, List<Address>>(
      AddressesController.new,
    );
