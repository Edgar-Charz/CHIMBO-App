import 'package:chimbo/core/device/device_name.dart';
import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/storage/token_storage.dart';
import 'package:chimbo/features/auth/data/auth_repository.dart';
import 'package:chimbo/features/auth/data/models/auth_session.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/auth/data/models/login_start.dart';
import 'package:chimbo/features/auth/data/models/otp_request_result.dart';
import 'package:chimbo/features/auth/data/models/pin_input.dart';

/// Phone → PIN login against the CHIMBO API (docs/API_REFERENCE.md, "Customer login").
/// The token is kept in secure storage; `ApiClient` sends it as `Authorization: Bearer`.
class ApiAuthRepository implements AuthRepository {
  const ApiAuthRepository({
    required this._apiClient,
    required this._tokenStorage,
    this._readDeviceName = DeviceName.read,
  });

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  /// The phone's name for the server's device list (tests pass their own).
  final Future<String?> Function() _readDeviceName;

  @override
  Future<LoginStart> startLogin(String phone) async {
    final response = await _apiClient.post(
      '/auth/start',
      body: {'user_phone': phone},
    );
    return LoginStart.fromJson(response.dataAsMap);
  }

  @override
  Future<OtpRequestResult> requestOtp(String phone) async {
    final response = await _apiClient.post(
      '/auth/otp/request',
      body: {'user_phone': phone},
    );
    return OtpRequestResult.fromJson(response.dataAsMap);
  }

  @override
  Future<AuthSession> verifyOtp({required String phone, required String code}) {
    return _logIn('/auth/otp/verify', {'user_phone': phone, 'otp_code': code});
  }

  @override
  Future<AuthSession> loginWithPin({
    required String phone,
    required String pin,
  }) {
    return _logIn('/auth/pin/login', {'user_phone': phone, 'user_pin': pin});
  }

  @override
  Future<AuthSession> savePin(PinInput input) async {
    final response = await _apiClient.post('/auth/pin', body: input.toJson());
    return AuthSession.fromProfileJson(
      await _requireToken(),
      response.dataAsMap,
    );
  }

  @override
  Future<AuthSession> completeProfile(BusinessProfileInput input) async {
    final response = await _apiClient.post(
      '/auth/profile',
      body: input.toJson(),
    );
    return AuthSession.fromProfileJson(
      await _requireToken(),
      response.dataAsMap,
    );
  }

  /// `GET /auth/me` with the saved token. An expired or revoked token logs out quietly;
  /// other errors (no network) reach the splash, which offers "Jaribu tena".
  @override
  Future<AuthSession?> restoreSession() async {
    final token = await _tokenStorage.readToken();
    if (token == null) {
      return null;
    }
    try {
      final response = await _apiClient.get('/auth/me');
      return AuthSession.fromProfileJson(token, response.dataAsMap);
    } on ApiException catch (error) {
      if (error.code != ApiErrorCode.unauthenticated) {
        rethrow;
      }
      await _tokenStorage.deleteToken();
      return null;
    }
  }

  /// Revokes the token on the server; the phone forgets it even if that call fails (offline).
  @override
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } on ApiException {
      // Logged out on this phone either way; the token also expires on its own.
    } finally {
      await _tokenStorage.deleteToken();
    }
  }

  @override
  Future<void> forgetSession() => _tokenStorage.deleteToken();

  @override
  Future<void> deleteAccount() async {
    await _apiClient.delete('/me', body: {'confirm': true});
    await _tokenStorage.deleteToken();
  }

  /// Both logins answer `{user, auth_token}`; the token is saved before anything else runs.
  Future<AuthSession> _logIn(String path, Map<String, String> body) async {
    final deviceName = await _deviceNameOrNull();
    final response = await _apiClient.post(
      path,
      body: {
        ...body,
        'client': 'app',
        'auth_token_platform': DeviceName.platform,
        'auth_token_device_name': ?deviceName,
      },
    );
    final data = response.dataAsMap;
    final token = data['auth_token'] as String;
    await _tokenStorage.saveToken(token);
    return AuthSession.fromProfileJson(
      token,
      data['user'] as Map<String, dynamic>,
    );
  }

  /// The device name is only a label on the server: if reading it fails, log in without it.
  Future<String?> _deviceNameOrNull() async {
    try {
      return await _readDeviceName();
    } catch (_) {
      return null;
    }
  }

  Future<String> _requireToken() async {
    final token = await _tokenStorage.readToken();
    if (token == null) {
      throw const ApiException(code: ApiErrorCode.unauthenticated);
    }
    return token;
  }
}
