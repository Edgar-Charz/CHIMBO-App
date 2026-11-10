import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/features/auth/data/auth_rules.dart';
import 'package:flutter/material.dart';

/// A PIN typed on the app's own number pad (like M-Pesa): dots instead of digits, so the PIN
/// is never shown and no phone keyboard opens. The screen owns the value ([pin]) and gets
/// every change through [onChanged].
class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.pin,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    this.rowSpacing = AppSpacing.md,
  });

  static const List<String> _digits = [
    '1', '2', '3', //
    '4', '5', '6', //
    '7', '8', '9',
  ];

  final String pin;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;
  final double rowSpacing;

  void _add(String digit) {
    if (pin.length < AuthRules.pinMaxLength) {
      onChanged(pin + digit);
    }
  }

  void _removeLast() {
    if (pin.isNotEmpty) {
      onChanged(pin.substring(0, pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = errorText;
    return Column(
      children: [
        _PinDots(filled: pin.length, hasError: error != null),
        AnimatedSize(
          duration: AppDurations.fast,
          curve: Curves.easeOutCubic,
          child: error == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Container(
                    key: ValueKey(error),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.danger,
                          size: AppSizes.iconSmall,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            error,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var row = 0; row < _digits.length; row += 3)
          _KeyRow(
            spacing: rowSpacing,
            children: [
              for (final digit in _digits.sublist(row, row + 3))
                _DigitKey(
                  digit: digit,
                  onTap: enabled ? () => _add(digit) : null,
                ),
            ],
          ),
        _KeyRow(
          spacing: rowSpacing,
          children: [
            const SizedBox.square(dimension: AppSizes.pinKey),
            _DigitKey(digit: '0', onTap: enabled ? () => _add('0') : null),
            SizedBox.square(
              dimension: AppSizes.pinKey,
              child: IconButton(
                onPressed: enabled && pin.isNotEmpty ? _removeLast : null,
                tooltip: context.l10n.actionDelete,
                icon: const Icon(Icons.backspace_outlined),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One dot per typed digit, with at least [AuthRules.pinMinLength] places shown so the
/// customer sees how long a PIN is.
class _PinDots extends StatelessWidget {
  const _PinDots({required this.filled, required this.hasError});

  final int filled;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final places = filled < AuthRules.pinMinLength
        ? AuthRules.pinMinLength
        : filled;
    final color = hasError ? AppColors.danger : AppColors.primary;
    return Semantics(
      label: context.l10n.pinDotsLabel(filled),
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < places; index++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                width: AppSizes.pinDot,
                height: AppSizes.pinDot,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < filled ? color : Colors.transparent,
                  border: Border.all(color: color, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _KeyRow extends StatelessWidget {
  const _KeyRow({required this.children, required this.spacing});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    );
  }
}

class _DigitKey extends StatelessWidget {
  const _DigitKey({required this.digit, required this.onTap});

  final String digit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppSizes.pinKey,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          onTap: onTap,
          child: Center(
            child: Text(
              digit,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ),
    );
  }
}
