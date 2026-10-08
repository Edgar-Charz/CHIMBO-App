import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/utils/phone.dart';
import 'package:chimbo/features/auth/data/auth_repository.dart';
import 'package:chimbo/features/auth/data/auth_rules.dart';
import 'package:chimbo/features/auth/data/models/auth_session.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/auth/data/models/login_start.dart';
import 'package:chimbo/features/auth/data/models/otp_request_result.dart';
import 'package:chimbo/features/auth/data/models/pin_input.dart';

import 'fake_account_store.dart';

/// Offline stand-in for `/auth/*` with the server's rules: no SMS is sent and **any 6-digit
/// code** is accepted; PINs are 4–6 digits, `0000` and `1234` are refused as easy, and 5 wrong
/// PINs lock the account until a new PIN is set after an SMS code.
class FakeAuthRepository implements AuthRepository {
  const FakeAuthRepository(this._store);

  static const Duration _codeLifetime = Duration(minutes: 5);
  static const Duration _resendDelay = Duration(seconds: 60);
  static const int _maxPinTries = 5;
  static const Set<String> _easyPins = {'0000', '1234'};

  static const OtpRequestResult _codeSent = OtpRequestResult(
    expiresIn: _codeLifetime,
    resendAfter: _resendDelay,
  );

  final FakeAccountStore _store;

  @override
  Future<LoginStart> startLogin(String phone) async {
    final normalized = _normalizeOrThrow(phone);
    if (!_store.hasAccount(normalized) || _store.pinOf(normalized) == null) {
      return LoginStart(
        phone: normalized,
        nextStep: LoginNextStep.otp,
        otp: _codeSent,
      );
    }
    return LoginStart(
      phone: normalized,
      nextStep: _isLocked(normalized)
          ? LoginNextStep.pinLocked
          : LoginNextStep.pin,
    );
  }

  @override
  Future<OtpRequestResult> requestOtp(String phone) async {
    _normalizeOrThrow(phone);
    return _codeSent;
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
  Future<AuthSession> loginWithPin({
    required String phone,
    required String pin,
  }) async {
    final normalized = _normalizeOrThrow(phone);
    await _checkPin(normalized, pin);
    return _store.signIn(normalized);
  }

  @override
  Future<AuthSession> savePin(PinInput input) async {
    final phone = (await _store.requireCurrent()).user.phone;
    if (input.currentPin case final current?) {
      await _checkPin(phone, current);
    }
    if (!AuthRules.isValidPin(input.pin) || _easyPins.contains(input.pin)) {
      throw const ApiException(
        code: ApiErrorCode.validation,
        fields: {'user_pin': 'Chagua PIN isiyo rahisi kukisia.'},
      );
    }
    if (input.confirmation != input.pin) {
      throw const ApiException(
        code: ApiErrorCode.validation,
        fields: {'user_pin_confirmation': 'PIN hazilingani.'},
      );
    }
    final profile = await _store.saveCurrentPin(input.pin);
    return (await _store.sessionOf(profile))!;
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
  Future<void> forgetSession() => _store.signOut();

  @override
  Future<void> deleteAccount() => _store.deleteCurrent();

  bool _isLocked(String phone) => _store.failedPinTries(phone) >= _maxPinTries;

  /// Like the server: a wrong PIN counts, the 5th locks, a right one resets the count.
  Future<void> _checkPin(String phone, String pin) async {
    if (_isLocked(phone)) {
      throw const ApiException(code: ApiErrorCode.pinLocked);
    }
    if (_store.pinOf(phone) == pin) {
      await _store.setFailedPinTries(phone, 0);
      return;
    }
    final tries = _store.failedPinTries(phone) + 1;
    await _store.setFailedPinTries(phone, tries);
    if (tries >= _maxPinTries) {
      throw const ApiException(code: ApiErrorCode.pinLocked);
    }
    throw ApiException(
      code: ApiErrorCode.pinInvalid,
      message: 'PIN si sahihi. Umebakiza majaribio ${_maxPinTries - tries}.',
    );
  }

  String _normalizeOrThrow(String phone) {
    final normalized = TzPhone.normalize(phone);
    if (normalized == null) {
      throw const ApiException(code: ApiErrorCode.validation);
    }
    return normalized;
  }
}
