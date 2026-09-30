import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class AppLocales {
  static const Locale swahili = Locale('sw');
}

/// The app's language. Kiswahili only for now; `app_en.arb` is a placeholder until English
/// is switched on later (this provider then gets a `change` method and saves the choice).
final appLocaleProvider = Provider<Locale>((ref) => AppLocales.swahili);
