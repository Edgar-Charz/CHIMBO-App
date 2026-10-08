import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/dates.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/core/widgets/section_card.dart';
import 'package:chimbo/features/checkout/presentation/widgets/payment_method_details.dart';
import 'package:chimbo/features/orders/data/models/order_payment.dart';
import 'package:chimbo/features/payments/application/payments_providers.dart';
import 'package:chimbo/features/payments/data/models/payment_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Wasifu → "Malipo yangu", in two tabs: the customer's payments (newest first) and the payment
/// methods CHIMBO accepts with where to send the money. Each tab loads on its own.
class MyPaymentsScreen extends StatelessWidget {
  const MyPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.menuPayments),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.myPaymentsTabHistory),
              Tab(text: l10n.myPaymentsTabMethods),
            ],
          ),
        ),
        body: const TabBarView(children: [_HistoryTab(), _MethodsTab()]),
      ),
    );
  }
}

/// "Historia": every payment, newest first; pull down to refresh (staff may have reviewed one).
class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return ref
        .watch(myPaymentsProvider)
        .when(
          data: (payments) => RefreshIndicator(
            onRefresh: () => ref.refresh(myPaymentsProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                if (payments.isEmpty)
                  Text(
                    context.l10n.myPaymentsEmpty,
                    style: textTheme.bodyMedium,
                  )
                else
                  for (final payment in payments) ...[
                    _PaymentCard(payment: payment),
                    const SizedBox(height: AppSpacing.sm),
                  ],
              ],
            ),
          ),
          error: (error, _) => ErrorState(
            error: error,
            onRetry: () => ref.invalidate(myPaymentsProvider),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
  }
}

/// "Njia za malipo": the methods staff switched on, with the number to pay to (copy button).
class _MethodsTab extends ConsumerWidget {
  const _MethodsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return ref
        .watch(acceptedPaymentMethodsProvider)
        .when(
          data: (methods) => ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(l10n.acceptedMethodsTitle, style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              for (final method in methods) ...[
                SectionCard(
                  title: method.name,
                  child: method.isCashOnDelivery
                      ? Text(
                          l10n.acceptedMethodsCash,
                          style: textTheme.bodyMedium,
                        )
                      : PaymentMethodDetails(method: method),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
          error: (error, _) => ErrorState(
            error: error,
            onRetry: () => ref.invalidate(acceptedPaymentMethodsProvider),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
  }
}

/// One payment: method and amount, the order and date, the confirmation code and where staff are.
/// Tapping it opens the order.
class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment});

  final PaymentRecord payment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final reviewNote = payment.reviewNote;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.large),
        onTap: () => context.push(AppRoutes.orderDetails(payment.orderId)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xs,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      payment.methodName,
                      style: textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    Money.format(payment.amount),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                l10n.paymentOrderLine(
                  payment.orderNumber,
                  AppDates.formatDayTime(payment.createdAt, l10n.localeName),
                ),
                style: textTheme.bodySmall,
              ),
              Text(
                l10n.paymentReferenceLine(payment.reference),
                style: textTheme.bodySmall,
              ),
              _StatusChip(status: payment.status),
              if (payment.status == PaymentAttemptStatus.rejected &&
                  reviewNote != null)
                Text(
                  reviewNote,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.danger),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final PaymentAttemptStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, color, background) = switch (status) {
      PaymentAttemptStatus.submitted => (
        l10n.paymentStatusSubmitted,
        AppColors.accent,
        AppColors.accentLight,
      ),
      PaymentAttemptStatus.confirmed => (
        l10n.paymentStatusConfirmed,
        AppColors.success,
        AppColors.primaryLight,
      ),
      PaymentAttemptStatus.rejected => (
        l10n.paymentStatusRejected,
        AppColors.danger,
        AppColors.dangerLight,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
