import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/features/addresses/data/address_repository.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';

/// Delivery addresses from the CHIMBO API (docs/API_REFERENCE.md, "Addresses").
class ApiAddressRepository implements AddressRepository {
  const ApiAddressRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Address>> getAddresses() async {
    final response = await _apiClient.get('/addresses');
    return response.dataAsList
        .map((json) => Address.fromJson(json! as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Address> createAddress(AddressInput input) async {
    final response = await _apiClient.post('/addresses', body: input.toJson());
    return Address.fromJson(response.dataAsMap);
  }

  @override
  Future<Address> updateAddress(int addressId, AddressInput input) async {
    final response = await _apiClient.patch(
      '/addresses/$addressId',
      body: input.toJson(),
    );
    return Address.fromJson(response.dataAsMap);
  }

  @override
  Future<List<Address>> setDefaultAddress(int addressId) async {
    final response = await _apiClient.post('/addresses/$addressId/default');
    return response.dataAsList
        .map((json) => Address.fromJson(json! as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Address>> deleteAddress(int addressId) async {
    final response = await _apiClient.delete('/addresses/$addressId');
    return response.dataAsList
        .map((json) => Address.fromJson(json! as Map<String, dynamic>))
        .toList();
  }
}
