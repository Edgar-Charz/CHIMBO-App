/// Answer to `POST /auth/otp/request`: how long the code is valid and when "Tuma tena" unlocks.
class OtpRequestResult {
  const OtpRequestResult({
    required this.expiresIn,
    required this.resendAfter,
    this.debugCode,
  });

  factory OtpRequestResult.fromJson(Map<String, dynamic> json) {
    return OtpRequestResult(
      expiresIn: Duration(seconds: json['otp_expires_in_seconds'] as int),
      resendAfter: Duration(seconds: json['otp_resend_after_seconds'] as int),
      debugCode: json['debug_otp_code'] as String?,
    );
  }

  final Duration expiresIn;
  final Duration resendAfter;

  /// The code itself, sent only by a local/staging server in "show code" mode (never in
  /// production). The OTP screen fills it in so testers don't need a real SMS.
  final String? debugCode;

  Map<String, dynamic> toJson() => {
    'otp_expires_in_seconds': expiresIn.inSeconds,
    'otp_resend_after_seconds': resendAfter.inSeconds,
    'debug_otp_code': debugCode,
  };
}
