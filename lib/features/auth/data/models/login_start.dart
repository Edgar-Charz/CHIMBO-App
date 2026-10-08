import 'package:chimbo/features/auth/data/models/otp_request_result.dart';

/// Which screen follows the phone number (`POST /auth/start` → `next_step`).
enum LoginNextStep {
  /// New number, or an account without a PIN yet: the SMS code is already sent.
  otp('otp'),
  pin('pin'),

  /// 5 wrong PINs: only "Umesahau PIN?" (SMS code + new PIN) opens it again.
  pinLocked('pin_locked');

  const LoginNextStep(this.apiValue);

  final String apiValue;

  static LoginNextStep fromApi(String value) =>
      values.firstWhere((step) => step.apiValue == value);
}

/// Answer to `POST /auth/start`.
class LoginStart {
  const LoginStart({required this.phone, required this.nextStep, this.otp});

  factory LoginStart.fromJson(Map<String, dynamic> json) {
    final nextStep = LoginNextStep.fromApi(json['next_step'] as String);
    return LoginStart(
      phone: json['user_phone'] as String,
      nextStep: nextStep,
      otp: nextStep == LoginNextStep.otp
          ? OtpRequestResult.fromJson(json)
          : null,
    );
  }

  /// `+255XXXXXXXXX`.
  final String phone;
  final LoginNextStep nextStep;

  /// The code that was just sent; only for [LoginNextStep.otp].
  final OtpRequestResult? otp;
}
