import 'package:chimbo/features/auth/data/models/app_user.dart';

/// Result of a successful OTP check (`POST /auth/otp/verify`, client "app").
class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
    required this.isProfileComplete,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      isProfileComplete: json['profile_complete'] as bool,
    );
  }

  final String token;
  final AppUser user;

  /// False for a new customer who still has to fill in registration step 3.
  final bool isProfileComplete;

  Map<String, dynamic> toJson() => {
    'token': token,
    'user': user.toJson(),
    'profile_complete': isProfileComplete,
  };

  AuthSession copyWith({AppUser? user, bool? isProfileComplete}) {
    return AuthSession(
      token: token,
      user: user ?? this.user,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}
