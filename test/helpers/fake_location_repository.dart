import 'package:chimbo/features/locations/data/location_repository.dart';
import 'package:chimbo/features/locations/data/models/district.dart';
import 'package:chimbo/features/locations/data/models/region.dart';

import 'fake_locations.dart';

/// Serves the bundled region list until the backend's `/regions` endpoints exist.
class FakeLocationRepository implements LocationRepository {
  const FakeLocationRepository();

  @override
  Future<List<Region>> getRegions() async => fakeRegions;

  @override
  Future<List<District>> getDistricts(int regionId) async {
    return fakeDistricts
        .where((district) => district.regionId == regionId)
        .toList();
  }
}
