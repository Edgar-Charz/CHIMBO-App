import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

/// [primary] (green) navigates or confirms, [accent] (orange) buys, [outlined] is secondary,
/// [danger] (red outline) logs out or deletes.
enum AppButtonVariant { primary, accent, outlined, danger }

/// The app's standard full-width button, with a built-in loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  /// Shows a spinner and ignores taps, so a request can't be sent twice.
  final bool isLoading;

  /// Fills the available width (the default for form and checkout buttons).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final handler = isLoading ? null : onPressed;
    final content = _ButtonContent(
      label: label,
      icon: icon,
      isLoading: isLoading,
    );
    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: handler,
        child: content,
      ),
      AppButtonVariant.accent => FilledButton(
        onPressed: handler,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
        ),
        child: content,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: handler,
        child: content,
      ),
      AppButtonVariant.danger => OutlinedButton(
        onPressed: handler,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: const BorderSide(color: AppColors.danger),
        ),
        child: content,
      ),
    };
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.isLoading,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox.square(
        dimension: AppSizes.buttonProgress,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    final buttonIcon = icon;
    if (buttonIcon == null) {
      return Text(label);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(buttonIcon),
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
