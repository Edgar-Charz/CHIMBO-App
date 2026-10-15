import 'dart:math' as math;

import 'package:chimbo/core/assets/app_images.dart';
import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/separated_text.dart';
import 'package:chimbo/features/app_images/data/models/app_image_slot.dart';
import 'package:chimbo/features/app_images/presentation/widgets/replaceable_image_slot.dart';
import 'package:flutter/material.dart';

/// The CHIMBO logo: mark, "CHI" (green) + "MBO" (orange) wordmark and the three-part tagline.
/// The mark is the logo uploaded in the admin when there is one (Settings → Logo & pictures),
/// else the bundled one.
/// Every part scales with [markSize], so one widget serves the splash and smaller headers.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.markSize = 96, this.showTagline = true});

  static const double _wordmarkScale = 0.5;
  static const double _taglineScale = 0.1;
  static const double _gapScale = 0.08;
  static const double _cornerScale = 0.25;
  static const double _minTaglineSize = 9;

  final double markSize;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.appTitle,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: markSize,
            child: _LogoMark(
              borderRadius: BorderRadius.circular(markSize * _cornerScale),
            ),
          ),
          SizedBox(height: markSize * _gapScale),
          _Wordmark(fontSize: markSize * _wordmarkScale),
          if (showTagline) ...[
            const SizedBox(height: AppSpacing.xs),
            _Tagline(
              fontSize: math.max(markSize * _taglineScale, _minTaglineSize),
            ),
          ],
        ],
      ),
    );
  }
}

/// Header version for Home: mark on the left, wordmark and tagline beside it.
class AppLogoInline extends StatelessWidget {
  const AppLogoInline({super.key, this.height = 44});

  static const double _wordmarkScale = 0.6;
  static const double _taglineSize = 9;

  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.appTitle,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: height, width: height, child: const _LogoMark()),
          const SizedBox(width: AppSpacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Wordmark(fontSize: height * _wordmarkScale),
              const _Tagline(fontSize: _taglineSize),
            ],
          ),
        ],
      ),
    );
  }
}

/// "CHI" (green) + "MBO" (orange).
class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.fontSize});

  // The wordmark is the brand itself, so it is never translated.
  static const String _green = 'CHI';
  static const String _orange = 'MBO';

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
        children: const [
          TextSpan(
            text: _green,
            style: TextStyle(color: AppColors.primary),
          ),
          TextSpan(
            text: _orange,
            style: TextStyle(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

/// "BIDHAA BORA • BEI NAFUU • BIASHARA IMARA".
class _Tagline extends StatelessWidget {
  const _Tagline({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SeparatedText(
      parts: [
        l10n.brandTaglineQuality,
        l10n.brandTaglinePrice,
        l10n.brandTaglineBusiness,
      ],
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }
}

/// The mark alone: the uploaded logo (slot `logo`), falling back to the bundled one.
class _LogoMark extends StatelessWidget {
  const _LogoMark({this.borderRadius = BorderRadius.zero});

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ReplaceableImageSlot(
      slot: AppImageSlot.logo,
      asset: AppImages.logoMark,
      placeholderIcons: const [Icons.shopping_cart_rounded],
      // A logo may be wider than tall; contain never crops it.
      fit: BoxFit.contain,
      borderRadius: borderRadius,
    );
  }
}
