import 'package:chimbo/core/l10n/app_localizations.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:flutter/widgets.dart';
export 'package:chimbo/core/l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  /// Short access to translated strings: `context.l10n.navHome`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension ErrorMessages on AppLocalizations {
  String fieldErrorMessage(ApiException error, String field) {
    if (localeName == 'en') {
      return errorValidationField;
    }
    return error.fields[field] ?? errorMessage(error);
  }

  /// A message the user can read for any error: the server's own text, or a translated fallback.
  String errorMessage(Object error) {
    if (error is! ApiException) {
      return errorUnknown;
    }
    if (localeName == 'en') {
      return switch (error.code) {
        ApiErrorCode.validation => errorValidation,
        ApiErrorCode.unauthenticated => errorSessionExpired,
        ApiErrorCode.forbidden => errorForbidden,
        ApiErrorCode.rateLimited => errorRateLimited,
        ApiErrorCode.otpInvalid => otpInvalid,
        ApiErrorCode.otpExpired => errorOtpExpired,
        ApiErrorCode.otpTooManyAttempts => errorRateLimited,
        ApiErrorCode.pinInvalid => errorPinInvalid,
        ApiErrorCode.pinLocked => errorPinLocked,
        ApiErrorCode.moqNotMet => errorMoqNotMet,
        ApiErrorCode.outOfStock => errorOutOfStock,
        ApiErrorCode.priceChanged => errorPriceChanged,
        ApiErrorCode.notFound => errorNotFound,
        ApiErrorCode.paymentTimeOver => errorPaymentTimeOver,
        ApiErrorCode.paymentNotExpected => errorPaymentNotExpected,
        ApiErrorCode.paymentMethodLocked => errorPaymentMethodLocked,
        ApiErrorCode.network => errorNetwork,
        ApiErrorCode.timeout => errorTimeout,
        _ => errorUnknown,
      };
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
      ApiErrorCode.notFound => error.message ?? orderNotFoundMessage,
      _ => error.message ?? errorUnknown,
    };
  }
}
