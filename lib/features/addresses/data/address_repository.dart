import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/features/addresses/data/api_address_repository.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Delivery addresses (blueprint §12.2 "addresses").
abstract interface class AddressRepository {
  /// `GET /addresses` — the default one first.
  Future<List<Address>> getAddresses();

  /// `POST /addresses`. The first address becomes the default.
  Future<Address> createAddress(AddressInput input);
}

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => ApiAddressRepository(ref.watch(apiClientProvider)),
);
