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
      id:
          existing.fold<int>(
            0,
            (highestId, address) =>
                address.id > highestId ? address.id : highestId,
          ) +
          1,
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

  @override
  Future<Address> updateAddress(int addressId, AddressInput input) async {
    final phone = TzPhone.normalize(input.phone);
    if (phone == null ||
        input.recipientName.trim().isEmpty ||
        input.street.trim().isEmpty) {
      throw const ApiException(code: ApiErrorCode.validation);
    }
    final existing = await getAddresses();
    final previous = existing.firstWhere((address) => address.id == addressId);
    final region = (await _locations.getRegions()).firstWhere(
      (region) => region.id == input.regionId,
    );
    final district = input.districtId == null
        ? null
        : (await _locations.getDistricts(input.regionId))
              .firstWhere((district) => district.id == input.districtId);
    final landmark = input.landmark?.trim();
    final address = Address(
      id: addressId,
      recipientName: input.recipientName.trim(),
      phone: phone,
      regionId: input.regionId,
      regionName: region.name,
      districtId: input.districtId,
      districtName: district?.name,
      street: input.street.trim(),
      landmark: landmark == null || landmark.isEmpty ? null : landmark,
      isDefault: previous.isDefault,
    );
    await _store.write(_storageName, [
      for (final saved in existing)
        (saved.id == addressId ? address : saved).toJson(),
    ]);
    return address;
  }

  @override
  Future<List<Address>> setDefaultAddress(int addressId) async {
    final addresses = await getAddresses();
    final updated =
        [
          for (final address in addresses)
            Address(
              id: address.id,
              recipientName: address.recipientName,
              phone: address.phone,
              regionId: address.regionId,
              regionName: address.regionName,
              districtId: address.districtId,
              districtName: address.districtName,
              street: address.street,
              landmark: address.landmark,
              isDefault: address.id == addressId,
            ),
        ]..sort((first, second) {
          if (first.isDefault == second.isDefault) return 0;
          return first.isDefault ? -1 : 1;
        });
    await _store.write(_storageName, [
      for (final address in updated) address.toJson(),
    ]);
    return updated;
  }

  @override
  Future<List<Address>> deleteAddress(int addressId) async {
    final addresses = await getAddresses();
    final removed = addresses.firstWhere((address) => address.id == addressId);
    final remaining = addresses
        .where((address) => address.id != addressId)
        .toList();
    if (removed.isDefault && remaining.isNotEmpty) {
      final nextDefault = remaining.reduce(
        (newest, address) => address.id > newest.id ? address : newest,
      );
      remaining[remaining.indexOf(nextDefault)] = Address(
        id: nextDefault.id,
        recipientName: nextDefault.recipientName,
        phone: nextDefault.phone,
        regionId: nextDefault.regionId,
        regionName: nextDefault.regionName,
        districtId: nextDefault.districtId,
        districtName: nextDefault.districtName,
        street: nextDefault.street,
        landmark: nextDefault.landmark,
        isDefault: true,
      );
      remaining.sort((first, second) {
        if (first.isDefault == second.isDefault) return 0;
        return first.isDefault ? -1 : 1;
      });
    }
    await _store.write(_storageName, [
      for (final address in remaining) address.toJson(),
    ]);
    return remaining;
  }
}
