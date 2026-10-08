import 'package:chimbo/features/auth/data/models/app_user.dart';

/// A logged-in customer (`POST /auth/otp/verify`, `/auth/pin/login`, `GET /auth/me`, client
/// "app"). The two flags pick the next screen: Tengeneza PIN, business details, or Home.
class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
    required this.hasPin,
    required this.isProfileComplete,
  });

  /// From the API's profile object (`user_*` keys + `user_has_pin`, `is_profile_complete`).
  factory AuthSession.fromProfileJson(
    String token,
    Map<String, dynamic> profile,
  ) {
    return AuthSession(
      token: token,
      user: AppUser.fromJson(profile),
      hasPin: profile['user_has_pin'] as bool,
      isProfileComplete: profile['is_profile_complete'] as bool,
    );
  }

  final String token;
  final AppUser user;

  /// False for a new customer, and for accounts made before PIN login: "Tengeneza PIN" first.
  final bool hasPin;

  /// False for a new customer who still has to fill in the business details.
  final bool isProfileComplete;
}
