import 'package:chimbo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The splash decoration from the design: a warm glow behind the logo, a green corner, an
/// orange corner and faint product outlines.
class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key});

  static const double _greenCornerSize = 140;
  static const double _orangeCornerSize = 220;
  static const double _outlineIconSize = 44;
  static const double _glowRadius = 0.75;

  /// Glow sits a little above the centre, behind the logo mark.
  static const Alignment _glowCenter = Alignment(0, -0.2);

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: _glowCenter,
              radius: _glowRadius,
              colors: [AppColors.accentLight, AppColors.background],
            ),
          ),
        ),
        Positioned(
          top: -_greenCornerSize / 2,
          left: -_greenCornerSize / 2,
          child: _Circle(size: _greenCornerSize, color: AppColors.primary),
        ),
        Positioned(
          bottom: -_orangeCornerSize / 2,
          right: -_orangeCornerSize / 2,
          child: _Circle(size: _orangeCornerSize, color: AppColors.accent),
        ),
        Align(
          alignment: Alignment(0.75, -0.8),
          child: _OutlineIcon(Icons.diamond_outlined, size: _outlineIconSize),
        ),
        Align(
          alignment: Alignment(-0.75, -0.55),
          child: _OutlineIcon(Icons.spa_outlined, size: _outlineIconSize),
        ),
        Align(
          alignment: Alignment(-0.7, 0.75),
          child: _OutlineIcon(
            Icons.inventory_2_outlined,
            size: _outlineIconSize,
          ),
        ),
        Align(
          alignment: Alignment(0.35, 0.85),
          child: _OutlineIcon(
            Icons.local_shipping_outlined,
            size: _outlineIconSize,
          ),
        ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _OutlineIcon extends StatelessWidget {
  const _OutlineIcon(this.icon, {required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Icon(icon, size: size, color: AppColors.border),
    );
  }
}
