import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/features/auth/application/auth_state.dart';

/// Which screen a customer in [status] may see. Returns the route to send them to instead, or
/// null to let them through. Kept free of Flutter so the rules are easy to test.
String? authRedirect(AuthStatus status, String location) {
  // The splash restores the session and navigates by itself; tools stay open in debug builds;
  // the legal pages are public (the login screen links to them).
  if (location == AppRoutes.splash ||
      location == AppRoutes.debug ||
      AppRoutes.isPublicPage(location)) {
    return null;
  }
  final isLoginRoute = _loginRoutes.contains(location);

  return switch (status) {
    AuthStatus.unknown => AppRoutes.splash,
    AuthStatus.unauthenticated => isLoginRoute ? null : AppRoutes.phone,
    // One step at a time: PIN first, then business details.
    AuthStatus.needsPin => _only(AppRoutes.createPin, location),
    AuthStatus.needsProfile => _only(AppRoutes.businessInfo, location),
    AuthStatus.authenticated =>
      isLoginRoute ||
              location == AppRoutes.createPin ||
              location == AppRoutes.businessInfo
          ? AppRoutes.home
          : null,
  };
}

/// Screens a logged-out customer may see.
const Set<String> _loginRoutes = {
  AppRoutes.onboarding,
  AppRoutes.phone,
  AppRoutes.otp,
  AppRoutes.pinLogin,
};

String? _only(String route, String location) =>
    location == route ? null : route;
