import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// The phone's name for the server's list of logged-in devices ("Tecno Spark 10"), sent as
/// `auth_token_device_name` when logging in.
abstract final class DeviceName {
  /// `android` or `ios` (`auth_token_platform`).
  static String get platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  /// Null when the device doesn't say (the name is only a label, so login goes on without it).
  static Future<String?> read() async {
    try {
      final info = DeviceInfoPlugin();
      // In a browser (also with DevTools' phone emulation) only the browser info exists;
      // asking for Android / iOS details there throws.
      if (kIsWeb) {
        return (await info.webBrowserInfo).browserName.name;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return (await info.iosInfo).modelName;
      }
      final android = await info.androidInfo;
      return '${android.brand} ${android.model}';
    } catch (error) {
      // Any failure (missing plugin in tests, unsupported platform …): log in without the label.
      debugPrint('DeviceName.read failed: $error');
      return null;
    }
  }
}
