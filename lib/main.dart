import 'package:chimbo/app.dart';
import 'package:chimbo/core/storage/preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // Needed before using plugins (shared_preferences) ahead of runApp.
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      // No automatic retries: screens show the error with a "Jaribu tena" button instead.
      retry: (retryCount, error) => null,
      child: const ChimboApp(),
    ),
  );
}
