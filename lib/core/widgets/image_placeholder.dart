import 'package:chimbo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Soft gradient with icons, shown where a picture will go (missing asset or product photo).
class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key, required this.icons});

  /// Icon size as a share of the frame's shorter side, so icons suit any frame size.
  static const double _iconScale = 0.28;
  static const double _iconGapScale = 0.2;

  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.accentLight, AppColors.background],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final iconSize = constraints.biggest.shortestSide * _iconScale;
          return Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: iconSize * _iconGapScale,
              children: [
                for (final icon in icons)
                  Icon(icon, size: iconSize, color: AppColors.accent),
              ],
            ),
          );
        },
      ),
    );
  }
}
