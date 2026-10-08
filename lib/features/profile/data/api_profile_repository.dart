import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/profile/data/models/profile.dart';
import 'package:chimbo/features/profile/data/profile_repository.dart';

/// Wasifu from the CHIMBO API (docs/API_REFERENCE.md, "My account").
class ApiProfileRepository implements ProfileRepository {
  const ApiProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Profile> getProfile() async {
    final response = await _apiClient.get('/me');
    return Profile.fromJson(response.dataAsMap);
  }

  /// "Hariri Wasifu": name, shop, region and district in one call (`POST /auth/profile`
  /// also edits later, per the API reference).
  @override
  Future<Profile> updateProfile(BusinessProfileInput input) async {
    final response = await _apiClient.post(
      '/auth/profile',
      body: input.toJson(),
    );
    return Profile.fromJson(response.dataAsMap);
  }

  @override
  Future<Profile> uploadAvatar(String filePath) async {
    final response = await _apiClient.upload(
      '/me/avatar',
      field: 'avatar',
      filePath: filePath,
    );
    return Profile.fromJson(response.dataAsMap);
  }

  @override
  Future<Profile> deleteAvatar() async {
    final response = await _apiClient.delete('/me/avatar');
    return Profile.fromJson(response.dataAsMap);
  }
}
