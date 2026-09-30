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
  });

  final IconData icon;
  final String? title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final heading = title;
    final label = actionLabel;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSizes.iconLarge,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (heading != null) ...[
              Text(
                heading,
                style: textTheme.titleMedium,
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
              AppButton(label: label, onPressed: onAction, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}
