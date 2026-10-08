import 'package:chimbo/features/auth/data/models/app_user.dart';
import 'package:chimbo/features/auth/data/models/auth_session.dart';

/// Where the customer is in the login journey; the router picks the screen from this.
enum AuthStatus {
  /// Saved session not checked yet (only while the splash shows).
  unknown,
  unauthenticated,

  /// Logged in without a PIN (new customer, or an account from before PIN login), or right
  /// after "Umesahau PIN?": "Tengeneza PIN" / "Weka PIN mpya" comes first.
  needsPin,

  /// PIN set, business details not filled in yet.
  needsProfile,
  authenticated,
}

class AuthState {
  const AuthState._(
    this.status,
    this.user, {
    this.isPinReset = false,
    this.wasSignedOut = false,
  });

  const AuthState.unknown() : this._(AuthStatus.unknown, null);

  const AuthState.unauthenticated() : this._(AuthStatus.unauthenticated, null);

  /// The server refused this phone's login (expired, or the PIN changed on another phone).
  const AuthState.signedOut()
    : this._(AuthStatus.unauthenticated, null, wasSignedOut: true);

  /// The next screen for [session]: no PIN → Tengeneza PIN, else no business details → that
  /// step, else Home. [isPinReset] (SMS login from "Umesahau PIN?") always asks for a new PIN.
  factory AuthState.fromSession(
    AuthSession session, {
    bool isPinReset = false,
  }) {
    final needsPin = isPinReset || !session.hasPin;
    final status = switch ((needsPin, session.isProfileComplete)) {
      (true, _) => AuthStatus.needsPin,
      (false, false) => AuthStatus.needsProfile,
      (false, true) => AuthStatus.authenticated,
    };
    return AuthState._(status, session.user, isPinReset: isPinReset);
  }

  final AuthStatus status;

  /// Null while unknown or logged out.
  final AppUser? user;

  /// The PIN screen is replacing a forgotten PIN (not creating the first one).
  final bool isPinReset;

  /// Logged out by the server, not by the customer: the phone screen says why.
  final bool wasSignedOut;
}
