/// Build-time settings, passed with `--dart-define`.
///
/// Example for a real phone on the same Wi-Fi as the PC:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.20/chimbo/api/v1`
abstract final class Env {
  /// Defaults to the Android emulator's alias for the PC's localhost.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2/chimbo/api/v1',
  );

  /// Sent with every API and image request. The tester server is reached through an ngrok
  /// tunnel, which otherwise answers with an HTML warning page instead of JSON / the image;
  /// other servers simply ignore the header.
  static const Map<String, String> tunnelHeaders = {
    'ngrok-skip-browser-warning': 'true',
  };
}
