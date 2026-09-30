import 'package:chimbo/features/auth/data/models/app_user.dart';
import 'package:chimbo/features/auth/data/models/auth_session.dart';

/// Where the customer is in the login journey; the router picks the screen from this.
enum AuthStatus {
  /// Saved session not checked yet (only while the splash shows).
  unknown,
  unauthenticated,

  /// Phone verified, registration step 3 not done yet.
  needsProfile,
  authenticated,
}

class AuthState {
  const AuthState._(this.status, this.user);

  const AuthState.unknown() : this._(AuthStatus.unknown, null);

  const AuthState.unauthenticated() : this._(AuthStatus.unauthenticated, null);

  factory AuthState.fromSession(AuthSession session) {
    return AuthState._(
      session.isProfileComplete
          ? AuthStatus.authenticated
          : AuthStatus.needsProfile,
      session.user,
    );
  }

  final AuthStatus status;

  /// Null while unknown or logged out.
  final AppUser? user;
}
