import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Round gold "OKOA ZAIDI" seal on the wholesale slide.
class SavingsSeal extends StatelessWidget {
  const SavingsSeal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.savingsSeal,
      height: AppSizes.savingsSeal,
      padding: const EdgeInsets.all(AppSpacing.sm),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.gold,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: AppSpacing.xs),
      ),
      child: Text(
        context.l10n.onboardingSaveMore,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: AppColors.surface, fontWeight: FontWeight.w700),
      ),
    );
  }
}
