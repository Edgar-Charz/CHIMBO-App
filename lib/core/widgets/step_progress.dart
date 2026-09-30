import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

/// "● ─── ○ ─── ○  Hatua 1 kati ya 3": dots joined by lines, the current step in orange.
/// Used by registration now and checkout later.
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.current, required this.total});

  /// 1-based.
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.stepProgress(current, total),
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var step = 1; step <= total; step++) ...[
                if (step > 1) const _Line(),
                _Dot(isCurrent: step == current),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.stepProgress(current, total),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.isCurrent});

  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final size = isCurrent ? AppSizes.stepDotCurrent : AppSizes.stepDot;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isCurrent ? AppColors.accent : AppColors.border,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.stepLine,
      height: AppSizes.borderWidth * 2,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: AppColors.border,
    );
  }
}
