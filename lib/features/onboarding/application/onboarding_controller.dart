import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/features/onboarding/data/onboarding_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Decides where the app goes after the splash and after the last onboarding slide.
class OnboardingController {
  const OnboardingController(this._repository);

  /// Home; the router sends a logged-out customer on to the phone screen first.
  static const String _routeAfterOnboarding = AppRoutes.home;

  final OnboardingRepository _repository;

  String startRoute() {
    return _repository.hasSeenOnboarding()
        ? _routeAfterOnboarding
        : AppRoutes.onboarding;
  }

  /// Saves that onboarding is done and returns the route to open next.
  Future<String> completeOnboarding() async {
    await _repository.markOnboardingSeen();
    return _routeAfterOnboarding;
  }
}

final onboardingControllerProvider = Provider<OnboardingController>(
  (ref) => OnboardingController(ref.watch(onboardingRepositoryProvider)),
);
