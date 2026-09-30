import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/features/auth/application/auth_state.dart';

/// Which screen a customer in [status] may see. Returns the route to send them to instead, or
/// null to let them through. Kept free of Flutter so the rules are easy to test.
String? authRedirect(AuthStatus status, String location) {
  // The splash restores the session and navigates by itself; tools stay open in debug builds.
  if (location == AppRoutes.splash || location == AppRoutes.debug) {
    return null;
  }
  final isLoginRoute =
      location == AppRoutes.onboarding ||
      location == AppRoutes.phone ||
      location == AppRoutes.otp;

  return switch (status) {
    AuthStatus.unknown => AppRoutes.splash,
    AuthStatus.unauthenticated => isLoginRoute ? null : AppRoutes.phone,
    AuthStatus.needsProfile =>
      location == AppRoutes.businessInfo ? null : AppRoutes.businessInfo,
    AuthStatus.authenticated =>
      isLoginRoute || location == AppRoutes.businessInfo
          ? AppRoutes.home
          : null,
  };
}
