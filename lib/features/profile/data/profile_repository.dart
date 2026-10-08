import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/profile/data/api_profile_repository.dart';
import 'package:chimbo/features/profile/data/models/profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wasifu data (blueprint §12.2 "Profile"). Every method throws `ApiException` on failure.
abstract interface class ProfileRepository {
  /// `GET /me`.
  Future<Profile> getProfile();

  /// "Hariri Wasifu": name, shop, region and district.
  Future<Profile> updateProfile(BusinessProfileInput input);

  /// `POST /me/avatar`: a JPG, PNG or WEBP photo (up to 8 MB) replaces the current one.
  Future<Profile> uploadAvatar(String filePath);

  /// `DELETE /me/avatar`: back to initials.
  Future<Profile> deleteAvatar();
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ApiProfileRepository(ref.watch(apiClientProvider)),
);
