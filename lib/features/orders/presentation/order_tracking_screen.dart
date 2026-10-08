import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/dates.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/core/widgets/confirm_dialog.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/core/widgets/section_card.dart';
import 'package:chimbo/core/widgets/totals_card.dart';
import 'package:chimbo/features/addresses/presentation/address_details.dart';
import 'package:chimbo/features/catalog/presentation/widgets/offer_widgets.dart';
import 'package:chimbo/features/checkout/presentation/widgets/checkout_widgets.dart';
import 'package:chimbo/features/orders/application/orders_providers.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/presentation/order_feedback.dart';
import 'package:chimbo/features/orders/presentation/widgets/agent_card.dart';
import 'package:chimbo/features/orders/presentation/widgets/order_labels.dart';
import 'package:chimbo/features/orders/presentation/widgets/order_payment_section.dart';
import 'package:chimbo/features/orders/presentation/widgets/order_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fuatilia Oda (design PDF p.9): status banner, timeline, ETA, agent, and the order itself.
/// The live map is deferred (D-15).
class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final int orderId;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.cancelOrderConfirmTitle,
      message: l10n.cancelOrderConfirmMessage,
      confirmLabel: l10n.actionCancelOrder,
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    final toast = AppToast.of(context);
    try {
      await ref.read(orderActionsProvider).cancel(orderId);
      toast.success(l10n.orderCancelledMessage);
    } on ApiException catch (error) {
      toast.error(l10n.errorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final order = ref.watch(orderProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.actionTrackOrder)),
      body: order.when(
        data: (value) => RefreshIndicator(
          onRefresh: () => ref.refresh(orderProvider(orderId).future),
          child: _TrackingContent(
            order: value,
            onCancel: () => _cancel(context, ref),
            onReorder: () => reorderAndOpenCart(context, ref, orderId),
          ),
        ),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(orderProvider(orderId)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _TrackingContent extends StatelessWidget {
  const _TrackingContent({
    required this.order,
    required this.onCancel,
    required this.onReorder,
  });

  final Order order;
  final VoidCallback onCancel;
  final VoidCallback onReorder;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final agent = order.agent;
    final deliveredAt = order.deliveredAt;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(l10n.orderNumber(order.number), style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        _StatusBanner(status: order.status),
        const SizedBox(height: AppSpacing.lg),
        OrderPaymentSection(order: order),
        if (order.payment.canSubmit || order.payment.isUnderReview)
          const SizedBox(height: AppSpacing.lg),
        OrderTimeline(order: order),
        SectionCard(
          title: deliveredAt == null
              ? l10n.estimatedDeliveryTitle
              : l10n.deliveredOnTitle,
          child: Text(
            AppDates.formatDate(
              deliveredAt ?? order.estimatedDelivery,
              l10n.localeName,
            ),
            style: textTheme.titleMedium,
          ),
        ),
        if (agent != null && order.status.isActive) ...[
          const SizedBox(height: AppSpacing.md),
          AgentCard(agent: agent),
        ],
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: l10n.deliveryAddressTitle,
          child: AddressDetails(address: order.address),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: l10n.orderSummaryTitle,
          child: Column(
            children: [
              for (final item in order.items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(item.productName),
                  // The offer's discount when ordered.
                  leading: item.offerPercent > 0
                      ? OfferLabel(percent: item.offerPercent)
                      : null,
                  subtitle: Text(
                    l10n.orderItemLine(
                      item.quantity,
                      Money.format(item.unitPrice),
                    ),
                  ),
                  trailing: Text(Money.format(item.lineTotal)),
                ),
              if (order.payment.method case final method?)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(method.icon, color: AppColors.primary),
                  title: Text(method.name),
                  subtitle: Text(order.deliveryMethod.name),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TotalsCard(
          rows: [
            (
              label: l10n.summaryItems(order.items.length),
              amount: order.subtotal,
            ),
            (label: l10n.summaryDelivery, amount: order.deliveryFee),
          ],
          totalLabel: l10n.summaryTotal,
          total: order.total,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (order.canCancel)
          AppButton(
            label: l10n.actionCancelOrder,
            variant: AppButtonVariant.danger,
            onPressed: onCancel,
          ),
        if (order.status.canReorder)
          AppButton(
            label: l10n.quickReorder,
            variant: AppButtonVariant.accent,
            onPressed: onReorder,
          ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: AppSizes.iconMedium,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                l10n.onboardingDeliveryPromise,
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// "Njiani — Oda yako inakuja." in the status colour.
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: status.color.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.bannerTitle(l10n),
                    style: textTheme.headlineSmall?.copyWith(
                      color: status.color,
                    ),
                  ),
                  Text(status.bannerMessage(l10n), style: textTheme.bodyMedium),
                ],
              ),
            ),
            Icon(status.icon, size: AppSizes.iconLarge, color: status.color),
          ],
        ),
      ),
    );
  }
}
