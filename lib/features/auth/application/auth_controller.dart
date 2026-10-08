import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/features/auth/application/auth_state.dart';
import 'package:chimbo/features/auth/data/auth_repository.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/auth/data/models/login_start.dart';
import 'package:chimbo/features/auth/data/models/otp_request_result.dart';
import 'package:chimbo/features/auth/data/models/pin_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the login state for the whole app. Screens call these methods; the router watches the
/// state and moves to the right screen by itself (phone → PIN or SMS code → Tengeneza PIN →
/// business details → Home, or back to the phone screen after logout).
class AuthController extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    // The global 401 handler: a refused login token anywhere logs out on this phone.
    final subscription = ref
        .read(sessionExpiredEventsProvider)
        .stream
        .listen((_) => _onSessionExpired());
    ref.onDispose(subscription.cancel);
    return const AuthState.unknown();
  }

  /// Called once by the splash.
  Future<void> restoreSession() async {
    final session = await _repository.restoreSession();
    state = session == null
        ? const AuthState.unauthenticated()
        : AuthState.fromSession(session);
  }

  Future<LoginStart> startLogin(String phone) => _repository.startLogin(phone);

  Future<OtpRequestResult> requestOtp(String phone) {
    return _repository.requestOtp(phone);
  }

  /// [isPinReset]: the code came from "Umesahau PIN?", so a new PIN is asked next.
  Future<void> verifyOtp({
    required String phone,
    required String code,
    bool isPinReset = false,
  }) async {
    final session = await _repository.verifyOtp(phone: phone, code: code);
    state = AuthState.fromSession(session, isPinReset: isPinReset);
  }

  Future<void> loginWithPin({
    required String phone,
    required String pin,
  }) async {
    final session = await _repository.loginWithPin(phone: phone, pin: pin);
    state = AuthState.fromSession(session);
  }

  /// Tengeneza PIN, a new PIN after "Umesahau PIN?", or Badilisha PIN.
  Future<void> savePin(PinInput input) async {
    final session = await _repository.savePin(input);
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

  /// Only a logged-in phone is logged out: the splash handles a refused saved login itself,
  /// and later 401s from requests already on their way change nothing.
  Future<void> _onSessionExpired() async {
    final status = state.status;
    if (status == AuthStatus.unknown || status == AuthStatus.unauthenticated) {
      return;
    }
    state = const AuthState.signedOut();
    await _repository.forgetSession();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
