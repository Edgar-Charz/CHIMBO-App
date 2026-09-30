import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/features/debug/data/health_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// System endpoints of the API (blueprint §12.2).
class SystemRepository {
  const SystemRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<HealthStatus> fetchHealth() async {
    final response = await _apiClient.get('/health');
    return HealthStatus.fromJson(response.dataAsMap);
  }
}

final systemRepositoryProvider = Provider<SystemRepository>(
  (ref) => SystemRepository(ref.watch(apiClientProvider)),
);
