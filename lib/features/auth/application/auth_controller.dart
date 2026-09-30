import 'package:chimbo/features/auth/application/auth_state.dart';
import 'package:chimbo/features/auth/data/auth_repository.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/auth/data/models/otp_request_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the login state for the whole app. Screens call these methods; the router watches the
/// state and moves to the right screen by itself (phone → business info → Home, or back after
/// logout).
class AuthController extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() => const AuthState.unknown();

  /// Called once by the splash.
  Future<void> restoreSession() async {
    final session = await _repository.restoreSession();
    state = session == null
        ? const AuthState.unauthenticated()
        : AuthState.fromSession(session);
  }

  Future<OtpRequestResult> requestOtp(String phone) {
    return _repository.requestOtp(phone);
  }

  Future<void> verifyOtp({required String phone, required String code}) async {
    final session = await _repository.verifyOtp(phone: phone, code: code);
    state = AuthState.fromSession(session);
  }

  Future<void> completeProfile(BusinessProfileInput input) async {
    final session = await _repository.completeProfile(input);
    state = AuthState.fromSession(session);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState.unauthenticated();
  }

  Future<void> deleteAccount() async {
    await _repository.deleteAccount();
    state = const AuthState.unauthenticated();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
