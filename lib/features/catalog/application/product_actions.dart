import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

typedef ProductShare = Future<void> Function(String text);
typedef ExternalUrlLauncher = Future<bool> Function(Uri uri);

final productShareProvider = Provider<ProductShare>((ref) {
  return (text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  };
});

final externalUrlLauncherProvider = Provider<ExternalUrlLauncher>((ref) {
  return (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
});
