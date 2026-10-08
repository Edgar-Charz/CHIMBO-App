import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The phone's name for the server's list of logged-in devices ("Tecno Spark 10"), sent as
/// `auth_token_device_name` when logging in.
abstract final class DeviceName {
  /// `android` or `ios` (`auth_token_platform`).
  static String get platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  /// Null when the phone doesn't say (the name is only a label, so login goes on without it).
  static Future<String?> read() async {
    try {
      final info = DeviceInfoPlugin();
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return (await info.iosInfo).modelName;
      }
      final android = await info.androidInfo;
      return '${android.brand} ${android.model}';
    } on PlatformException {
      return null;
    } on MissingPluginException {
      // Tests and platforms without the plugin.
      return null;
    }
  }
}
