import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
/// Friendly "nothing here" view: icon + optional title + one sentence + at most one action.
///
/// [ErrorState] uses it too, so empty and error screens look alike.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.title,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
  });

  final IconData icon;
  final String? title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final heading = title;
    final label = actionLabel;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final startScale = reduceMotion ? 1.0 : 0.92;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: startScale, end: 1),
          duration: reduceMotion ? Duration.zero : AppDurations.medium,
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) {
            final opacity = reduceMotion
                ? 1.0
                : ((scale - startScale) / (1 - startScale))
                      .clamp(0.0, 1.0)
                      .toDouble();
            return Opacity(
              opacity: opacity,
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accentLight, AppColors.primaryLight],
                  ),
                  border: Border.all(
                    color: AppColors.surface.withValues(alpha: 0.8),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: AppSizes.iconLarge,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (heading != null) ...[
                Text(
                  heading,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (label != null) ...[
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: label,
                  onPressed: onAction,
                  isLoading: isLoading,
                  expand: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
