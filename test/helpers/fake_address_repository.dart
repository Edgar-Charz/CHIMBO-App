import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/utils/phone.dart';
import 'package:chimbo/features/addresses/data/address_repository.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:chimbo/features/locations/data/location_repository.dart';

import 'fake_customer_store.dart';

/// Addresses kept per customer on the phone, for tests (no network).
class FakeAddressRepository implements AddressRepository {
  const FakeAddressRepository({required this._store, required this._locations});

  static const String _storageName = 'addresses';

  final FakeCustomerStore _store;

  /// The server joins region/district names in; here they come from the locations API.
  final LocationRepository _locations;

  @override
  Future<List<Address>> getAddresses() async {
    final stored = await _store.read(_storageName);
    if (stored is! List<dynamic>) {
      return const [];
    }
    return stored
        .map((json) => Address.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Address> createAddress(AddressInput input) async {
    final phone = TzPhone.normalize(input.phone);
    if (phone == null ||
        input.recipientName.trim().isEmpty ||
        input.street.trim().isEmpty) {
      throw const ApiException(code: ApiErrorCode.validation);
    }
    final existing = await getAddresses();
    final districtId = input.districtId;
    final landmark = input.landmark?.trim();
    final region = (await _locations.getRegions()).firstWhere(
      (region) => region.id == input.regionId,
    );
    final district = districtId == null
        ? null
        : (await _locations.getDistricts(input.regionId))
              .firstWhere((district) => district.id == districtId);
    final address = Address(
      id: existing.length + 1,
      recipientName: input.recipientName.trim(),
      phone: phone,
      regionId: input.regionId,
      regionName: region.name,
      districtId: districtId,
      districtName: district?.name,
      street: input.street.trim(),
      landmark: landmark == null || landmark.isEmpty ? null : landmark,
      isDefault: existing.isEmpty,
    );
    await _store.write(_storageName, [
      for (final saved in [...existing, address]) saved.toJson(),
    ]);
    return address;
  }
}
