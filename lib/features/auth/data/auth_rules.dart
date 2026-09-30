/// Login rules shared by the screens and the repositories.
abstract final class AuthRules {
  static const int otpLength = 6;

  static final RegExp _otpPattern = RegExp('^\\d{$otpLength}\$');

  static bool isValidOtp(String code) => _otpPattern.hasMatch(code);
}
