import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/features/checkout/data/models/checkout_options.dart';
import 'package:flutter/material.dart';

/// Names and icons for payment methods. Brand names stay as they are; the rest is Kiswahili.
extension PaymentMethodLabel on PaymentMethod {
  String label(AppLocalizations l10n) => switch (this) {
    PaymentMethod.mpesa => 'M-Pesa',
    PaymentMethod.airtelMoney => 'Airtel Money',
    PaymentMethod.mixxByYas => 'Mixx by Yas',
    PaymentMethod.bank => l10n.paymentBank,
    PaymentMethod.cashOnDelivery => l10n.paymentCashOnDelivery,
  };

  IconData get icon => switch (this) {
    PaymentMethod.mpesa ||
    PaymentMethod.airtelMoney ||
    PaymentMethod.mixxByYas => Icons.phone_android_rounded,
    PaymentMethod.bank => Icons.account_balance_outlined,
    PaymentMethod.cashOnDelivery => Icons.payments_outlined,
  };
}

extension DeliveryMethodLabel on DeliveryMethod {
  /// "siku 2–3" / "kesho". (The server's [DeliveryMethod.name] already includes it.)
  String eta(AppLocalizations l10n) =>
      isNextDay ? l10n.deliveryTomorrow : l10n.deliveryDays(daysMin, daysMax);
}

/// ①──②──③──④ with labels; done and current steps are green, the last step (Hakiki) turns
/// orange when it is current, as in the design. Each line takes the colour of the step it
/// leads into.
class CheckoutStepper extends StatelessWidget {
  const CheckoutStepper({super.key, required this.currentStep});

  /// 1-based: 1 Anwani, 2 Usafirishaji, 3 Malipo, 4 Hakiki.
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [
      l10n.stepAddress,
      l10n.stepDelivery,
      l10n.stepPayment,
      l10n.stepReview,
    ];
    Color colorOf(int step) => step > currentStep
        ? AppColors.border
        : step == labels.length
        ? AppColors.accent
        : AppColors.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, label) in labels.indexed)
          Expanded(
            child: _Step(
              number: index + 1,
              label: label,
              color: colorOf(index + 1),
              isReached: index + 1 <= currentStep,
              // Half-lines on both sides of the circle join up with the neighbours'.
              lineBefore: index == 0 ? null : colorOf(index + 1),
              lineAfter: index == labels.length - 1 ? null : colorOf(index + 2),
            ),
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.label,
    required this.color,
    required this.isReached,
    required this.lineBefore,
    required this.lineAfter,
  });

  final int number;
  final String label;
  final Color color;
  final bool isReached;

  /// Colour of the half-line on each side; null at the ends.
  final Color? lineBefore;
  final Color? lineAfter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _HalfLine(color: lineBefore)),
            CircleAvatar(
              radius: AppSizes.stepCircle / 2,
              backgroundColor: isReached ? color : AppColors.surface,
              child: Text(
                '$number',
                style: textTheme.labelLarge?.copyWith(
                  color: isReached
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(child: _HalfLine(color: lineAfter)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelMedium?.copyWith(
            color: isReached ? color : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// One side of the line between two steps; empty (no line) at the ends.
class _HalfLine extends StatelessWidget {
  const _HalfLine({required this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.borderWidth * 2,
      color: color ?? Colors.transparent,
    );
  }
}

/// A selectable row with a radio circle ("Standard (siku 2–3)  TZS 5,000", "M-Pesa").
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.leading,
    this.trailing,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final lead = leading;
    final end = trailing;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              const SizedBox(width: AppSpacing.md),
              if (lead != null) ...[lead, const SizedBox(width: AppSpacing.sm)],
              Expanded(child: Text(title)),
              ?end,
            ],
          ),
        ),
      ),
    );
  }
}
