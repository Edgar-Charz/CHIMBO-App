import 'package:chimbo/app.dart';
import 'package:chimbo/core/config/firebase_ready_provider.dart';
import 'package:chimbo/core/storage/preferences_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  // Needed before using plugins (shared_preferences) ahead of runApp.
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    firebaseReady = true;
  } catch (error) {
    debugPrint('Firebase init error: $error');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        firebaseReadyProvider.overrideWithValue(firebaseReady),
      ],
      // No automatic retries: screens show the error with a "Jaribu tena" button instead.
      retry: (retryCount, error) => null,
      child: const ChimboApp(),
    ),
  );
}
