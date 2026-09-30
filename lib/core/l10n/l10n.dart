import 'package:chimbo/core/l10n/app_localizations.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:flutter/widgets.dart';

export 'package:chimbo/core/l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  /// Short access to translated strings: `context.l10n.navHome`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension ErrorMessages on AppLocalizations {
  /// A message the user can read for any error: the server's own text, or a translated fallback.
  String errorMessage(Object error) {
    if (error is! ApiException) {
      return errorUnknown;
    }
    return switch (error.code) {
      // The field's own message says exactly what's wrong ("Kiwango cha chini … (MOQ).");
      // the top-level one is generic.
      ApiErrorCode.validation when error.fields.isNotEmpty =>
        error.fields.values.first,
      ApiErrorCode.network => errorNetwork,
      ApiErrorCode.timeout => errorTimeout,
      ApiErrorCode.otpInvalid => error.message ?? otpInvalid,
      ApiErrorCode.moqNotMet => error.message ?? errorMoqNotMet,
      ApiErrorCode.outOfStock => error.message ?? errorOutOfStock,
      ApiErrorCode.priceChanged => error.message ?? errorPriceChanged,
      _ => error.message ?? errorUnknown,
    };
  }
}
