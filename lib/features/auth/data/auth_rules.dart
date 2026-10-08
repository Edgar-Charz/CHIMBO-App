/// Login rules shared by the screens and the repositories.
abstract final class AuthRules {
  static const int otpLength = 6;
  static const int pinMinLength = 4;
  static const int pinMaxLength = 6;

  static final RegExp _otpPattern = RegExp(
    '^[0-9]{$otpLength}'
    r'$',
  );
  static final RegExp _pinPattern = RegExp(
    '^[0-9]{$pinMinLength,$pinMaxLength}'
    r'$',
  );

  static bool isValidOtp(String code) => _otpPattern.hasMatch(code);

  /// Only the length is checked here; the server also refuses easy PINs (0000, 1234 …).
  static bool isValidPin(String pin) => _pinPattern.hasMatch(pin);
}
