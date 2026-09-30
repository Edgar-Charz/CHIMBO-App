import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

/// [ − 8 + ]: never goes below [min] (the MOQ) or above [max] (stock).
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.min,
    required this.onChanged,
    this.max,
    this.compact = false,
  });

  final int value;
  final int min;
  final int? max;
  final ValueChanged<int> onChanged;

  /// The cart's smaller, outlined [ − │ 8 │ + ] look.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final upperLimit = max;
    final canIncrease = upperLimit == null || value < upperLimit;
    if (compact) {
      return _CompactStepper(
        value: value,
        canDecrease: value > min,
        canIncrease: canIncrease,
        decreaseLabel: l10n.actionDecrease,
        increaseLabel: l10n.actionIncrease,
        onChanged: onChanged,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            label: l10n.actionDecrease,
            icon: Icons.remove_rounded,
            enabled: value > min,
            onPressed: () => onChanged(value - 1),
          ),
          SizedBox(
            width: AppSizes.stepperValueWidth,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _StepperButton(
            label: l10n.actionIncrease,
            icon: Icons.add_rounded,
            enabled: canIncrease,
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

/// The cart's small stepper (design PDF p.7): an outlined box split into [ − │ 8 │ + ].
class _CompactStepper extends StatelessWidget {
  const _CompactStepper({
    required this.value,
    required this.canDecrease,
    required this.canIncrease,
    required this.decreaseLabel,
    required this.increaseLabel,
    required this.onChanged,
  });

  final int value;
  final bool canDecrease;
  final bool canIncrease;
  final String decreaseLabel;
  final String increaseLabel;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const divider = VerticalDivider(
      width: AppSizes.borderWidth,
      thickness: AppSizes.borderWidth,
      color: AppColors.border,
    );
    return Container(
      height: AppSizes.compactStepperHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CompactButton(
            label: decreaseLabel,
            icon: Icons.remove_rounded,
            onPressed: canDecrease ? () => onChanged(value - 1) : null,
          ),
          divider,
          SizedBox(
            width: AppSizes.compactStepperHeight,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          divider,
          _CompactButton(
            label: increaseLabel,
            icon: Icons.add_rounded,
            onPressed: canIncrease ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _CompactButton extends StatelessWidget {
  const _CompactButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;

  /// Null = disabled (at the MOQ or at the stock limit).
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: AppSizes.compactStepperHeight,
        height: AppSizes.compactStepperHeight,
      ),
      color: AppColors.accent,
      iconSize: AppSizes.iconMedium,
      icon: Icon(icon),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      color: AppColors.accent,
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
    );
  }
}
