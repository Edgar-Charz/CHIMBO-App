import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/features/locations/data/api_location_repository.dart';
import 'package:chimbo/features/locations/data/models/district.dart';
import 'package:chimbo/features/locations/data/models/region.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Regions and districts for registration (and later delivery addresses).
///
/// API: `GET /regions`, `GET /regions/{id}/districts` (blueprint §12.2).
abstract interface class LocationRepository {
  Future<List<Region>> getRegions();

  Future<List<District>> getDistricts(int regionId);
}

final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => ApiLocationRepository(ref.watch(apiClientProvider)),
);
