import 'package:chimbo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Short phrases joined by orange dots: "Chagua • Lipa • Pokea".
class SeparatedText extends StatelessWidget {
  const SeparatedText({
    super.key,
    required this.parts,
    this.style,
    this.textAlign = TextAlign.center,
  });

  static const String _separator = '  •  ';

  final List<String> parts;
  final TextStyle? style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          for (final (index, part) in parts.indexed) ...[
            if (index > 0)
              const TextSpan(
                text: _separator,
                style: TextStyle(color: AppColors.accent),
              ),
            TextSpan(text: part),
          ],
        ],
      ),
      textAlign: textAlign,
    );
  }
}
