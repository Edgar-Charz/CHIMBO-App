/// The public text pages (`GET /pages/{name}`).
enum LegalPageType {
  terms('terms'),
  privacy('privacy');

  const LegalPageType(this.apiValue);

  final String apiValue;

  /// From the route, or null for a name the app doesn't know.
  static LegalPageType? fromApi(String value) {
    for (final type in values) {
      if (type.apiValue == value) {
        return type;
      }
    }
    return null;
  }
}

/// "Vigezo na Masharti" / "Sera ya Faragha".
class LegalPage {
  const LegalPage({
    required this.title,
    required this.paragraphs,
    required this.updatedAt,
  });

  factory LegalPage.fromJson(Map<String, dynamic> json) {
    return LegalPage(
      title: json['page_title'] as String,
      paragraphs: _paragraphsOf(json['page_body'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Blank lines between paragraphs (Windows line endings or stray spaces too).
  static final RegExp _blankLine = RegExp(r'\r?\n\s*\r?\n');

  final String title;

  /// `page_body` is plain text with an empty line between paragraphs; shown as plain text,
  /// never interpreted, so nothing in it can run.
  final List<String> paragraphs;
  final DateTime updatedAt;

  static List<String> _paragraphsOf(String body) => [
    for (final paragraph in body.split(_blankLine))
      if (paragraph.trim().isNotEmpty) paragraph.trim(),
  ];
}
