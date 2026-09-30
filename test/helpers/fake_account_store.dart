import 'dart:convert';

import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/storage/token_storage.dart';
import 'package:chimbo/features/auth/data/models/app_user.dart';
import 'package:chimbo/features/auth/data/models/auth_session.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/profile/data/models/business_profile.dart';
import 'package:chimbo/features/profile/data/models/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_locations.dart';

/// The server's `users` + `business_profiles` for tests: accounts kept in memory-backed
/// preferences, keyed by phone number. Used by [FakeAuthRepository] and [FakeProfileRepository].
class FakeAccountStore {
  FakeAccountStore({required this._tokenStorage, required this._preferences});

  static const String _accountsKey = 'dev_accounts';
  static const String _currentPhoneKey = 'dev_current_phone';

  final TokenStorage _tokenStorage;
  final SharedPreferences _preferences;

  /// The logged-in account, or null when logged out.
  Future<Profile?> readCurrent() async {
    final token = await _tokenStorage.readToken();
    final phone = _preferences.getString(_currentPhoneKey);
    if (token == null || phone == null) {
      return null;
    }
    return _readAccounts()[phone];
  }

  /// Like [readCurrent], but a missing login is an error (as a `401` from the server would be).
  Future<Profile> requireCurrent() async {
    final current = await readCurrent();
    if (current == null) {
      throw const ApiException(code: ApiErrorCode.unauthenticated);
    }
    return current;
  }

  /// Logs [phone] in, creating the account on first login. Returns the session.
  Future<AuthSession> signIn(String phone) async {
    final accounts = _readAccounts();
    final account =
        accounts[phone] ??
        Profile(
          user: AppUser(id: accounts.length + 1, phone: phone),
        );
    await _writeAccounts({...accounts, phone: account});
    await _tokenStorage.saveToken(
      'dev-${DateTime.now().microsecondsSinceEpoch}',
    );
    await _preferences.setString(_currentPhoneKey, phone);
    return (await sessionOf(account))!;
  }

  /// Saves registration step 3 / "Hariri Wasifu" for the logged-in account.
  Future<Profile> updateCurrentProfile(BusinessProfileInput input) async {
    final current = await requireCurrent();
    final fullName = input.fullName.trim();
    if (fullName.isEmpty || !_regionExists(input.regionId)) {
      throw const ApiException(code: ApiErrorCode.validation);
    }
    final updated = Profile(
      user: current.user.copyWith(fullName: fullName),
      business: _businessFrom(input),
    );
    await _writeAccounts({..._readAccounts(), current.user.phone: updated});
    return updated;
  }

  Future<void> signOut() async {
    await _tokenStorage.deleteToken();
    await _preferences.remove(_currentPhoneKey);
  }

  /// Removes the logged-in account and logs out.
  Future<void> deleteCurrent() async {
    final current = await requireCurrent();
    await _writeAccounts({..._readAccounts()}..remove(current.user.phone));
    await signOut();
  }

  /// The session for [account] with the saved token, or null when logged out.
  Future<AuthSession?> sessionOf(Profile account) async {
    final token = await _tokenStorage.readToken();
    if (token == null) {
      return null;
    }
    return AuthSession(
      token: token,
      user: account.user,
      isProfileComplete: account.business != null,
    );
  }

  bool _regionExists(int regionId) =>
      fakeRegions.any((region) => region.id == regionId);

  // The server joins the names in; here they come from the bundled list.
  BusinessProfile _businessFrom(BusinessProfileInput input) {
    final businessName = input.businessName?.trim();
    final districtId = input.districtId;
    return BusinessProfile(
      businessName: businessName == null || businessName.isEmpty
          ? null
          : businessName,
      regionId: input.regionId,
      regionName: fakeRegions
          .firstWhere((region) => region.id == input.regionId)
          .name,
      districtId: districtId,
      districtName: districtId == null
          ? null
          : fakeDistricts
                .firstWhere((district) => district.id == districtId)
                .name,
    );
  }

  Map<String, Profile> _readAccounts() {
    final stored = _preferences.getString(_accountsKey);
    if (stored == null) {
      return const {};
    }
    final decoded = jsonDecode(stored) as Map<String, dynamic>;
    return decoded.map(
      (phone, json) =>
          MapEntry(phone, Profile.fromJson(json as Map<String, dynamic>)),
    );
  }

  Future<void> _writeAccounts(Map<String, Profile> accounts) async {
    await _preferences.setString(
      _accountsKey,
      jsonEncode(
        accounts.map((phone, account) => MapEntry(phone, account.toJson())),
      ),
    );
  }
}
