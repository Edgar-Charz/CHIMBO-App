import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Shared layout of each onboarding slide, with artwork kept at its designed 4:5 ratio.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.title,
    required this.subtitle,
    required this.illustration,
    this.header,
    this.footer,
  });

  final String title;
  final Widget subtitle;
  final Widget illustration;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final slideHeader = header;
    final slideFooter = footer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          DefaultTextStyle.merge(
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            child: subtitle,
          ),
          if (slideHeader != null) ...[
            const SizedBox(height: AppSpacing.lg),
            slideHeader,
          ],
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Center(
              child: AspectRatio(aspectRatio: 4 / 5, child: illustration),
            ),
          ),
          if (slideFooter != null) ...[
            const SizedBox(height: AppSpacing.md),
            slideFooter,
          ],
        ],
      ),
    );
  }
}
