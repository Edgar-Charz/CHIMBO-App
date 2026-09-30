import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/storage/token_storage.dart';
import 'package:chimbo/features/auth/data/auth_repository.dart';
import 'package:chimbo/features/auth/data/models/app_user.dart';
import 'package:chimbo/features/auth/data/models/auth_session.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/auth/data/models/otp_request_result.dart';
import 'package:flutter/foundation.dart';

/// Phone + OTP login against the CHIMBO API (docs/API_REFERENCE.md, "Customer login").
/// The token is kept in secure storage; `ApiClient` sends it as `Authorization: Bearer`.
class ApiAuthRepository implements AuthRepository {
  const ApiAuthRepository({
    required this._apiClient,
    required this._tokenStorage,
  });

  /// Tells the server which kind of phone holds the token (shown in the admin).
  static String get _platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  @override
  Future<OtpRequestResult> requestOtp(String phone) async {
    final response = await _apiClient.post(
      '/auth/otp/request',
      body: {'user_phone': phone},
    );
    return OtpRequestResult.fromJson(response.dataAsMap);
  }

  @override
  Future<AuthSession> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final response = await _apiClient.post(
      '/auth/otp/verify',
      body: {
        'user_phone': phone,
        'otp_code': code,
        'client': 'app',
        'auth_token_platform': _platform,
      },
    );
    final data = response.dataAsMap;
    final token = data['auth_token'] as String;
    await _tokenStorage.saveToken(token);
    return _session(token, data['user'] as Map<String, dynamic>);
  }

  @override
  Future<AuthSession> completeProfile(BusinessProfileInput input) async {
    final response = await _apiClient.post(
      '/auth/profile',
      body: input.toJson(),
    );
    return _session(await _requireToken(), response.dataAsMap);
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
      return _session(token, response.dataAsMap);
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
  Future<void> deleteAccount() async {
    await _apiClient.delete('/me', body: {'confirm': true});
    await _tokenStorage.deleteToken();
  }

  Future<String> _requireToken() async {
    final token = await _tokenStorage.readToken();
    if (token == null) {
      throw const ApiException(code: ApiErrorCode.unauthenticated);
    }
    return token;
  }

  /// A session from the API's profile object.
  AuthSession _session(String token, Map<String, dynamic> profile) {
    return AuthSession(
      token: token,
      user: AppUser.fromJson(profile),
      isProfileComplete: profile['is_profile_complete'] as bool,
    );
  }
}
