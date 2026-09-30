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
}
