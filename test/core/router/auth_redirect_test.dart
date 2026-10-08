import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/router/auth_redirect.dart';
import 'package:chimbo/features/auth/application/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('logged-out customers can only see onboarding and the login steps', () {
    const status = AuthStatus.unauthenticated;
    expect(authRedirect(status, AppRoutes.onboarding), isNull);
    expect(authRedirect(status, AppRoutes.phone), isNull);
    expect(authRedirect(status, AppRoutes.otp), isNull);
    expect(authRedirect(status, AppRoutes.pinLogin), isNull);
    expect(authRedirect(status, AppRoutes.createPin), AppRoutes.phone);
    expect(authRedirect(status, AppRoutes.home), AppRoutes.phone);
    expect(authRedirect(status, AppRoutes.businessInfo), AppRoutes.phone);
  });

  test('without a PIN, Tengeneza PIN comes before anything else', () {
    const status = AuthStatus.needsPin;
    expect(authRedirect(status, AppRoutes.createPin), isNull);
    expect(authRedirect(status, AppRoutes.otp), AppRoutes.createPin);
    expect(authRedirect(status, AppRoutes.businessInfo), AppRoutes.createPin);
    expect(authRedirect(status, AppRoutes.home), AppRoutes.createPin);
  });

  test('with a PIN but no business details, that step comes next', () {
    const status = AuthStatus.needsProfile;
    expect(authRedirect(status, AppRoutes.businessInfo), isNull);
    expect(authRedirect(status, AppRoutes.createPin), AppRoutes.businessInfo);
    expect(authRedirect(status, AppRoutes.otp), AppRoutes.businessInfo);
    expect(authRedirect(status, AppRoutes.home), AppRoutes.businessInfo);
  });

  test('logged-in customers skip the login screens', () {
    const status = AuthStatus.authenticated;
    expect(authRedirect(status, AppRoutes.home), isNull);
    expect(authRedirect(status, AppRoutes.orders), isNull);
    expect(authRedirect(status, AppRoutes.phone), AppRoutes.home);
    expect(authRedirect(status, AppRoutes.pinLogin), AppRoutes.home);
    expect(authRedirect(status, AppRoutes.createPin), AppRoutes.home);
    expect(authRedirect(status, AppRoutes.businessInfo), AppRoutes.home);
    expect(authRedirect(status, AppRoutes.onboarding), AppRoutes.home);
  });

  test('before the session is known everything waits on the splash', () {
    expect(authRedirect(AuthStatus.unknown, AppRoutes.home), AppRoutes.splash);
    expect(authRedirect(AuthStatus.unknown, AppRoutes.splash), isNull);
  });
}
