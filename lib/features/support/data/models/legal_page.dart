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
    this.formattedBlocks = const [],
  });

  factory LegalPage.fromJson(Map<String, dynamic> json) {
    return LegalPage(
      title: json['page_title'] as String,
      paragraphs: _paragraphsOf(json['page_body'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      formattedBlocks: _blocksOf(json['page_body_html'] as String? ?? ''),
    );
  }

  /// Blank lines between paragraphs (Windows line endings or stray spaces too).
  static final RegExp _blankLine = RegExp(r'\r?\n\s*\r?\n');

  final String title;

  /// `page_body` is plain text with an empty line between paragraphs; shown as plain text,
  /// never interpreted, so nothing in it can run.
  final List<String> paragraphs;
  final DateTime updatedAt;
  final List<LegalPageBlock> formattedBlocks;

  static List<String> _paragraphsOf(String body) => [
    for (final paragraph in body.split(_blankLine))
      if (paragraph.trim().isNotEmpty) paragraph.trim(),
  ];

  static List<LegalPageBlock> _blocksOf(String html) {
    if (html.trim().isEmpty) return const [];

    final blocks = <LegalPageBlock>[];
    final runs = <LegalTextRun>[];
    final activeTags = <String>[];
    final orderedCounts = <int>[];
    var blockKind = LegalBlockKind.paragraph;
    var listItemDepth = 0;

    void addText(String text) {
      final value = _decodeEntities(text);
      if (value.isEmpty) return;
      final run = LegalTextRun(
        text: value,
        bold: activeTags.contains('strong') || activeTags.contains('b'),
        italic: activeTags.contains('em') || activeTags.contains('i'),
        underline: activeTags.contains('u'),
        strikethrough:
            activeTags.contains('s') ||
            activeTags.contains('strike') ||
            activeTags.contains('del'),
        linkUrl: activeTags
            .where((tag) => tag.startsWith('a:'))
            .map((tag) => tag.substring(2))
            .firstOrNull,
      );
      if (runs.isNotEmpty && runs.last.sameStyle(run)) {
        runs[runs.length - 1] = runs.last.copyWith(
          text: runs.last.text + run.text,
        );
      } else {
        runs.add(run);
      }
    }

    void flushBlock() {
      final text = runs.map((run) => run.text).join().trim();
      if (text.isNotEmpty) {
        blocks.add(
          LegalPageBlock(kind: blockKind, runs: List.unmodifiable(runs)),
        );
      }
      runs.clear();
      blockKind = LegalBlockKind.paragraph;
    }

    final tokenPattern = RegExp(r'<[^>]*>|[^<]+');
    for (final match in tokenPattern.allMatches(html)) {
      final token = match.group(0)!;
      if (!token.startsWith('<')) {
        addText(token);
        continue;
      }

      final tagMatch = RegExp(
        r'^<\s*(/?)\s*([a-z0-9]+)',
        caseSensitive: false,
      ).firstMatch(token);
      if (tagMatch == null) continue;
      final isClosing = tagMatch.group(1) == '/';
      final tag = tagMatch.group(2)!.toLowerCase();

      if (!isClosing) {
        if (tag == 'li') {
          flushBlock();
          blockKind = orderedCounts.isNotEmpty
              ? LegalBlockKind.orderedItem
              : LegalBlockKind.bulletItem;
          listItemDepth++;
          if (orderedCounts.isNotEmpty) {
            orderedCounts[orderedCounts.length - 1]++;
            addText('${orderedCounts.last}. ');
          } else {
            addText('\u2022 ');
          }
        } else if (tag == 'p' ||
            tag == 'h2' ||
            tag == 'h3' ||
            tag == 'blockquote') {
          if (listItemDepth == 0) {
            flushBlock();
            blockKind = switch (tag) {
              'h2' || 'h3' => LegalBlockKind.heading,
              'blockquote' => LegalBlockKind.quote,
              _ => LegalBlockKind.paragraph,
            };
          }
        } else if (tag == 'ul' || tag == 'ol') {
          if (tag == 'ol') orderedCounts.add(0);
        } else if (tag == 'br') {
          addText('\n');
        } else if (tag == 'a') {
          final hrefMatch = RegExp(
            r'''href\s*=\s*['"]([^'"]*)['"]''',
            caseSensitive: false,
          ).firstMatch(token);
          final href = hrefMatch == null
              ? null
              : _safeLink(_decodeEntities(hrefMatch.group(1)!));
          if (href != null) activeTags.add('a:$href');
        } else if (tag == 'strong' ||
            tag == 'b' ||
            tag == 'em' ||
            tag == 'i' ||
            tag == 'u' ||
            tag == 's' ||
            tag == 'strike' ||
            tag == 'del') {
          activeTags.add(tag);
        }
      } else {
        if (tag == 'li') {
          flushBlock();
          if (listItemDepth > 0) listItemDepth--;
        } else if ((tag == 'p' ||
                tag == 'h2' ||
                tag == 'h3' ||
                tag == 'blockquote') &&
            listItemDepth == 0) {
          flushBlock();
        } else if (tag == 'ol') {
          if (orderedCounts.isNotEmpty) orderedCounts.removeLast();
        } else if (tag == 'strong' ||
            tag == 'b' ||
            tag == 'em' ||
            tag == 'i' ||
            tag == 'u' ||
            tag == 's' ||
            tag == 'strike' ||
            tag == 'del' ||
            tag == 'a') {
          final index = activeTags.lastIndexWhere(
            (activeTag) =>
                activeTag == tag || (tag == 'a' && activeTag.startsWith('a:')),
          );
          if (index >= 0) activeTags.removeAt(index);
        }
      }
    }
    flushBlock();
    return List.unmodifiable(blocks);
  }

  static String? _safeLink(String value) {
    final href = value.trim();
    if (href.isEmpty || href.startsWith('//')) return null;
    if (href.startsWith('/') || href.startsWith('#')) return href;
    final uri = Uri.tryParse(href);
    if (uri == null ||
        ![
          'http',
          'https',
          'mailto',
          'tel',
        ].contains(uri.scheme.toLowerCase())) {
      return null;
    }
    return href;
  }

  static String _decodeEntities(String value) => value.replaceAllMapped(
    RegExp(
      r'&(#x[0-9a-f]+|#\d+|amp|lt|gt|quot|apos|nbsp);',
      caseSensitive: false,
    ),
    (match) {
      final entity = match.group(1)!.toLowerCase();
      if (entity.startsWith('#x')) {
        return String.fromCharCode(int.parse(entity.substring(2), radix: 16));
      }
      if (entity.startsWith('#')) {
        return String.fromCharCode(int.parse(entity.substring(1)));
      }
      return switch (entity) {
        'amp' => '&',
        'lt' => '<',
        'gt' => '>',
        'quot' => '"',
        'apos' => "'",
        'nbsp' => '\u00a0',
        _ => match.group(0)!,
      };
    },
  );
}

enum LegalBlockKind { paragraph, heading, quote, bulletItem, orderedItem }

class LegalPageBlock {
  const LegalPageBlock({required this.kind, required this.runs});

  final LegalBlockKind kind;
  final List<LegalTextRun> runs;
}

class LegalTextRun {
  const LegalTextRun({
    required this.text,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.linkUrl,
  });

  final String text;
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final String? linkUrl;

  bool sameStyle(LegalTextRun other) =>
      bold == other.bold &&
      italic == other.italic &&
      underline == other.underline &&
      strikethrough == other.strikethrough &&
      linkUrl == other.linkUrl;

  LegalTextRun copyWith({String? text}) => LegalTextRun(
    text: text ?? this.text,
    bold: bold,
    italic: italic,
    underline: underline,
    strikethrough: strikethrough,
    linkUrl: linkUrl,
  );
}
