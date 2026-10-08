import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/profile/data/models/profile.dart';
import 'package:chimbo/features/profile/data/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The logged-in customer's profile, as loading / error / data (`AsyncValue`).
class ProfileController extends AsyncNotifier<Profile> {
  @override
  Future<Profile> build() {
    // Load again when another customer logs in on this phone.
    ref.watch(authControllerProvider.select((state) => state.user?.id));
    return ref.read(profileRepositoryProvider).getProfile();
  }

  /// Saves "Hariri Wasifu"; errors reach the caller so the form can show them.
  Future<void> save(BusinessProfileInput input) async {
    final profile = await ref
        .read(profileRepositoryProvider)
        .updateProfile(input);
    state = AsyncData(profile);
  }

  /// New profile photo; errors (e.g. `INVALID_IMAGE`) reach the caller to show.
  Future<void> changePhoto(String filePath) async {
    state = AsyncData(
      await ref.read(profileRepositoryProvider).uploadAvatar(filePath),
    );
  }

  Future<void> removePhoto() async {
    state = AsyncData(await ref.read(profileRepositoryProvider).deleteAvatar());
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, Profile>(ProfileController.new);
