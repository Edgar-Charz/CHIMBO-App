/// One of "Maswali ya mara kwa mara" — the same list the website's Msaada shows.
typedef HelpQuestion = ({String question, String answer});

/// "Msaada" (`GET /support`): how to reach CHIMBO, and the common questions.
class SupportContacts {
  const SupportContacts({
    required this.phone,
    required this.whatsappUrl,
    required this.hours,
    this.questions = const [],
  });

  factory SupportContacts.fromJson(Map<String, dynamic> json) {
    return SupportContacts(
      phone: json['support_phone'] as String,
      whatsappUrl: json['support_whatsapp_url'] as String,
      hours: json['support_hours'] as String,
      questions: [
        for (final item in json['help_questions'] as List<dynamic>? ?? const [])
          (
            question: (item as Map<String, dynamic>)['question'] as String,
            answer: item['answer'] as String,
          ),
      ],
    );
  }

  /// `+255XXXXXXXXX`, for the call button.
  final String phone;

  /// Opens a WhatsApp chat with support (`https://wa.me/…`).
  final String whatsappUrl;

  /// "Jumatatu–Jumamosi, saa 2 asubuhi – saa 12 jioni".
  final String hours;

  /// "Ninalipaje?" and the rest; the server keeps them in step with the website.
  final List<HelpQuestion> questions;
}
