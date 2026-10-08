/// What `POST /auth/pin` sends. PINs are text, so a leading zero ("0482") is kept.
class PinInput {
  const PinInput({
    required this.pin,
    required this.confirmation,
    this.currentPin,
  });

  final String pin;
  final String confirmation;

  /// Only for "Badilisha PIN"; creating a PIN or a new one after an SMS code needs none.
  final String? currentPin;

  Map<String, dynamic> toJson() => {
    'user_pin': pin,
    'user_pin_confirmation': confirmation,
    'current_pin': ?currentPin,
  };
}
