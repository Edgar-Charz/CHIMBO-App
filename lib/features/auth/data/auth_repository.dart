import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/core/storage/token_storage.dart';
import 'package:chimbo/features/auth/data/api_auth_repository.dart';
import 'package:chimbo/features/auth/data/models/auth_session.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/auth/data/models/otp_request_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Phone + OTP login (blueprint §12.2 "Auth"). Every method throws `ApiException` on failure.
abstract interface class AuthRepository {
  /// Sends a login code to [phone] (also used for "Tuma tena").
  Future<OtpRequestResult> requestOtp(String phone);

  /// Checks the code; a new customer gets an account with `isProfileComplete == false`.
  Future<AuthSession> verifyOtp({required String phone, required String code});

  /// Registration step 3 for the logged-in customer.
  Future<AuthSession> completeProfile(BusinessProfileInput input);

  /// The saved session from an earlier launch, or null when logged out.
  Future<AuthSession?> restoreSession();

  Future<void> logout();

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
