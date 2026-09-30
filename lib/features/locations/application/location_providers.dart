import 'package:chimbo/features/locations/data/location_repository.dart';
import 'package:chimbo/features/locations/data/models/district.dart';
import 'package:chimbo/features/locations/data/models/region.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// All regions, loaded once and kept while the app runs.
final regionsProvider = FutureProvider<List<Region>>(
  (ref) => ref.watch(locationRepositoryProvider).getRegions(),
);

/// The districts of one region (`.family` = one cached list per region id).
final districtsProvider = FutureProvider.family<List<District>, int>(
  (ref, regionId) =>
      ref.watch(locationRepositoryProvider).getDistricts(regionId),
);
