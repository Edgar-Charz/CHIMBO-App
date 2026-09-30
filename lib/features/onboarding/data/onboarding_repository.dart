import 'package:chimbo/core/storage/preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether this phone has already seen the onboarding slides.
class OnboardingRepository {
  const OnboardingRepository(this._preferences);

  static const String _seenKey = 'onboarding_seen';

  final SharedPreferences _preferences;

  bool hasSeenOnboarding() => _preferences.getBool(_seenKey) ?? false;

  Future<void> markOnboardingSeen() async {
    await _preferences.setBool(_seenKey, true);
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepository(ref.watch(sharedPreferencesProvider)),
);
