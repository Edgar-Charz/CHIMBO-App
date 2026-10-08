import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/profile/data/models/profile.dart';
import 'package:chimbo/features/profile/data/profile_repository.dart';

import 'fake_account_store.dart';

/// Offline stand-in for `/me`: reads and edits the fake account.
class FakeProfileRepository implements ProfileRepository {
  const FakeProfileRepository(this._store);

  final FakeAccountStore _store;

  @override
  Future<Profile> getProfile() => _store.requireCurrent();

  @override
  Future<Profile> updateProfile(BusinessProfileInput input) {
    return _store.updateCurrentProfile(input);
  }

  /// Like the server: the photo gets its own address.
  @override
  Future<Profile> uploadAvatar(String filePath) {
    return _store.setCurrentAvatar('http://api.test/avatars/me.webp');
  }

  @override
  Future<Profile> deleteAvatar() => _store.setCurrentAvatar(null);
}
