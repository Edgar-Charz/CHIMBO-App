import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/profile/data/models/profile.dart';
import 'package:chimbo/features/profile/data/profile_repository.dart';

import 'fake_account_store.dart';

/// Reads and edits the dev account until the backend's `/me` endpoints exist.
class FakeProfileRepository implements ProfileRepository {
  const FakeProfileRepository(this._store);

  final FakeAccountStore _store;

  @override
  Future<Profile> getProfile() => _store.requireCurrent();

  @override
  Future<Profile> updateProfile(BusinessProfileInput input) {
    return _store.updateCurrentProfile(input);
  }
}
