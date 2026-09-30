import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Small non-secret settings (onboarding seen, later the language).
///
/// Loaded once in `main()` and passed in with `overrideWithValue`, so every read afterwards is
/// synchronous — the splash can decide where to go without waiting.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError(
    'sharedPreferencesProvider must be overridden in main() with a loaded instance.',
  ),
);
