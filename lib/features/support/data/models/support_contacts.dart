/// "Msaada" (`GET /support`): how to reach CHIMBO.
class SupportContacts {
  const SupportContacts({
    required this.phone,
    required this.whatsappUrl,
    required this.hours,
  });

  factory SupportContacts.fromJson(Map<String, dynamic> json) {
    return SupportContacts(
      phone: json['support_phone'] as String,
      whatsappUrl: json['support_whatsapp_url'] as String,
      hours: json['support_hours'] as String,
    );
  }

  /// `+255XXXXXXXXX`, for the call button.
  final String phone;

  /// Opens a WhatsApp chat with support (`https://wa.me/…`).
  final String whatsappUrl;

  /// "Jumatatu–Jumamosi, saa 2 asubuhi – saa 12 jioni".
  final String hours;
}
