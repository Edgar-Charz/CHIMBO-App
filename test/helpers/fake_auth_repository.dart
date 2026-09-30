import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/utils/phone.dart';
import 'package:chimbo/features/auth/data/auth_repository.dart';
import 'package:chimbo/features/auth/data/auth_rules.dart';
import 'package:chimbo/features/auth/data/models/auth_session.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/auth/data/models/otp_request_result.dart';

import 'fake_account_store.dart';

/// Pretend login used until the backend's `/auth/*` endpoints exist: no SMS is sent, any valid
/// Tanzanian mobile and **any 6-digit code** are accepted.
///
/// Logging out and back in with the same number skips step 3, like the real server will.
class FakeAuthRepository implements AuthRepository {
  const FakeAuthRepository(this._store);

  // Same values the real server is planned to send.
  static const Duration _codeLifetime = Duration(minutes: 5);
  static const Duration _resendDelay = Duration(seconds: 60);

  final FakeAccountStore _store;

  @override
  Future<OtpRequestResult> requestOtp(String phone) async {
    _normalizeOrThrow(phone);
    return const OtpRequestResult(
      expiresIn: _codeLifetime,
      resendAfter: _resendDelay,
    );
  }

  @override
  Future<AuthSession> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final normalizedPhone = _normalizeOrThrow(phone);
    if (!AuthRules.isValidOtp(code)) {
      throw const ApiException(code: ApiErrorCode.otpInvalid);
    }
    return _store.signIn(normalizedPhone);
  }

  @override
  Future<AuthSession> completeProfile(BusinessProfileInput input) async {
    final profile = await _store.updateCurrentProfile(input);
    return (await _store.sessionOf(profile))!;
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final current = await _store.readCurrent();
    return current == null ? null : _store.sessionOf(current);
  }

  @override
  Future<void> logout() => _store.signOut();

  @override
  Future<void> deleteAccount() => _store.deleteCurrent();

  String _normalizeOrThrow(String phone) {
    final normalized = TzPhone.normalize(phone);
    if (normalized == null) {
      throw const ApiException(code: ApiErrorCode.validation);
    }
    return normalized;
  }
}
