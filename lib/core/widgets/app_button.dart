import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/chimbo_loader.dart';
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
    this.contentPadding,
    this.labelStyle,
    this.foregroundColor,
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

  /// Optional content padding and label style for compact action bars.
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? labelStyle;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final handler = isLoading ? null : onPressed;
    final content = _ButtonContent(
      label: label,
      icon: icon,
      isLoading: isLoading,
      labelStyle: labelStyle,
    );
    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: handler,
        style: FilledButton.styleFrom(
          padding: contentPadding,
          textStyle: labelStyle,
        ),
        child: content,
      ),
      AppButtonVariant.accent => FilledButton(
        onPressed: handler,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: foregroundColor ?? AppColors.onAccent,
          padding: contentPadding,
          textStyle: labelStyle,
        ),
        child: content,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: handler,
        style: OutlinedButton.styleFrom(
          padding: contentPadding,
          textStyle: labelStyle,
        ),
        child: content,
      ),
      AppButtonVariant.danger => OutlinedButton(
        onPressed: handler,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: const BorderSide(color: AppColors.danger),
          padding: contentPadding,
          textStyle: labelStyle,
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
    required this.labelStyle,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ChimboLoader(compact: true, showMessage: false);
    }
    final buttonIcon = icon;
    if (buttonIcon == null) {
      return Text(label, style: labelStyle);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(buttonIcon),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: labelStyle,
          ),
        ),
      ],
    );
  }
}
