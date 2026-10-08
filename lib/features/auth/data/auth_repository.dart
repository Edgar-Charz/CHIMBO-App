import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/core/storage/token_storage.dart';
import 'package:chimbo/features/auth/data/api_auth_repository.dart';
import 'package:chimbo/features/auth/data/models/auth_session.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/auth/data/models/login_start.dart';
import 'package:chimbo/features/auth/data/models/otp_request_result.dart';
import 'package:chimbo/features/auth/data/models/pin_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Phone → PIN login, with SMS codes for new numbers and "Umesahau PIN?" (blueprint §12.5).
/// Every method throws `ApiException` on failure.
abstract interface class AuthRepository {
  /// The phone screen: says whether the PIN or an SMS code (already sent) comes next.
  Future<LoginStart> startLogin(String phone);

  /// Sends a login code to [phone] ("Umesahau PIN?", "Tuma tena").
  Future<OtpRequestResult> requestOtp(String phone);

  /// Checks the SMS code; a new customer gets an account without a PIN or business details.
  Future<AuthSession> verifyOtp({required String phone, required String code});

  /// "Ingia kwa PIN".
  Future<AuthSession> loginWithPin({
    required String phone,
    required String pin,
  });

  /// Tengeneza PIN, a new PIN after "Umesahau PIN?", or "Badilisha PIN" (with the current one).
  /// Other devices are logged out; this one stays logged in.
  Future<AuthSession> savePin(PinInput input);

  /// Business details (the last registration step) for the logged-in customer.
  Future<AuthSession> completeProfile(BusinessProfileInput input);

  /// The saved session from an earlier launch, or null when logged out.
  Future<AuthSession?> restoreSession();

  Future<void> logout();

  /// Forgets the saved login on this phone only (the server already refused it).
  Future<void> forgetSession();

  /// `DELETE /me`: anonymises the account (order records stay) and ends the session on this
  /// phone.
  Future<void> deleteAccount();
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ApiAuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  ),
);
