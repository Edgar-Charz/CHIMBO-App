import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Slide position dots; the current one stretches and turns orange.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.onboardingPageIndicator(currentIndex + 1, count),
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < count; index++)
            AnimatedContainer(
              duration: AppDurations.fast,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              width: index == currentIndex
                  ? AppSizes.pageDotActiveWidth
                  : AppSizes.pageDot,
              height: AppSizes.pageDot,
              decoration: BoxDecoration(
                color: index == currentIndex
                    ? AppColors.accent
                    : AppColors.border,
                borderRadius: BorderRadius.circular(AppSizes.pageDot),
              ),
            ),
        ],
      ),
    );
  }
}
