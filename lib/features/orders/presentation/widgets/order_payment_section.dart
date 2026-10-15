import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/dates.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/section_card.dart';
import 'package:chimbo/features/checkout/presentation/widgets/payment_method_details.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/data/models/order_payment.dart';
import 'package:chimbo/features/orders/presentation/widgets/change_payment_method_sheet.dart';
import 'package:chimbo/features/orders/presentation/widgets/payment_submit_sheet.dart';
import 'package:flutter/material.dart';

/// Paying a mobile money / bank order (staff check it by hand):
/// - upcountry, transport price not confirmed yet → "Tunapima mzigo wako" (no paying yet);
/// - waiting for payment → where to pay and "Nimelipa" (after a rejection, staff's note first);
/// - sent → "Tunakagua malipo yako";
/// - anything else (cash, paid, expired) → nothing.
class OrderPaymentSection extends StatelessWidget {
  const OrderPaymentSection({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final payment = order.payment;
    final latest = payment.latest;
    if (order.isAwaitingTransportPrice) {
      final estimate = order.deliveryMethod.feeEstimate ?? 0;
      final region = order.address.regionName;
      return _Notice(
        icon: Icons.local_shipping_outlined,
        color: AppColors.accent,
        background: AppColors.accentLight,
        title: l10n.transportPendingTitle,
        message: estimate > 0
            ? l10n.transportPendingMessage(region, Money.format(estimate))
            : l10n.transportPendingNoEstimateMessage(region),
      );
    }
    if (payment.isUnderReview && latest != null) {
      return _Notice(
        icon: Icons.hourglass_top_rounded,
        color: AppColors.info,
        background: AppColors.infoLight,
        title: l10n.paymentUnderReviewTitle,
        message: l10n.paymentUnderReviewMessage(latest.reference),
      );
    }
    if (!payment.canSubmit) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (payment.wasRejected) ...[
          _Notice(
            icon: Icons.error_outline_rounded,
            color: AppColors.danger,
            background: AppColors.dangerLight,
            title: l10n.paymentRejectedTitle,
            message: latest?.reviewNote ?? l10n.paymentRejectedMessage,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        _PayToCard(payment: payment, expiresAt: order.expiresAt),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l10n.actionIPaid,
          icon: Icons.check_circle_outline_rounded,
          variant: AppButtonVariant.accent,
          onPressed: () => showPaymentSubmitSheet(context, order),
        ),
        if (payment.canChangeMethod)
          TextButton(
            onPressed: () => showChangePaymentMethodSheet(context, order),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: Text(l10n.actionChangePaymentMethod),
          ),
      ],
    );
  }
}

/// "Lipa TZS 96,000 kwa M-Pesa": the number (with copy), account name, bank, instructions and
/// the order number to write as the payment's description.
class _PayToCard extends StatelessWidget {
  const _PayToCard({required this.payment, required this.expiresAt});

  final OrderPayment payment;
  final DateTime? expiresAt;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final method = payment.method;
    final deadline = expiresAt;
    return SectionCard(
      color: AppColors.goldLight,
      title: payment.isBalance
          ? l10n.payBalanceTitle(
              Money.format(payment.amount),
              method?.name ?? '',
            )
          : l10n.payToTitle(Money.format(payment.amount), method?.name ?? ''),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (method != null) PaymentMethodDetails(method: method),
          const Divider(height: AppSpacing.lg),
          CopyValueRow(label: l10n.payToNoteHint, value: payment.noteHint),
          if (deadline != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.payBefore(AppDates.formatDayTime(deadline, l10n.localeName)),
              style: textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ],
        ],
      ),
    );
  }
}

/// A coloured box with an icon, a title and a message (under review / rejected).
class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(color: color),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(message, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
