import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/features/locations/data/location_repository.dart';
import 'package:chimbo/features/locations/data/models/district.dart';
import 'package:chimbo/features/locations/data/models/region.dart';

/// Regions and districts from the CHIMBO API (docs/API_REFERENCE.md, "Locations").
class ApiLocationRepository implements LocationRepository {
  const ApiLocationRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Region>> getRegions() async {
    final response = await _apiClient.get('/regions');
    return response.dataAsList
        .map((json) => Region.fromJson(json! as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<District>> getDistricts(int regionId) async {
    final response = await _apiClient.get('/regions/$regionId/districts');
    // The reply lists districts without their region id; it's the one in the URL.
    return response.dataAsList
        .map(
          (json) => District.fromJson({
            ...json! as Map<String, dynamic>,
            'region_id': regionId,
          }),
        )
        .toList();
  }
}
