import 'package:chimbo/core/storage/preferences_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class AppLocales {
  static const Locale swahili = Locale('sw');
  static const Locale english = Locale('en');
}

/// Loads and saves the customer's app language on this device.
final appLocaleProvider = NotifierProvider<AppLocaleController, Locale>(
  AppLocaleController.new,
);

class AppLocaleController extends Notifier<Locale> {
  static const String _languageKey = 'app_language';

  @override
  Locale build() {
    final languageCode = ref
        .watch(sharedPreferencesProvider)
        .getString(_languageKey);
    return languageCode == AppLocales.english.languageCode
        ? AppLocales.english
        : AppLocales.swahili;
  }

  Future<void> setLocale(Locale locale) async {
    if (locale != AppLocales.swahili && locale != AppLocales.english) {
      return;
    }
    if (state == locale) return;

    await ref
        .read(sharedPreferencesProvider)
        .setString(_languageKey, locale.languageCode);
    state = locale;
  }
}
