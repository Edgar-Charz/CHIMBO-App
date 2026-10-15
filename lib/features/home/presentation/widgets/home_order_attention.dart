import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/features/orders/application/orders_providers.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/presentation/widgets/order_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Keeps the customer's most actionable active order visible near the top of Home.
class HomeOrderAttention extends ConsumerWidget {
  const HomeOrderAttention({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider(OrderGroup.active));
    return orders.when(
      data: (page) {
        final items = page.orders;
        if (items.isEmpty) return const SizedBox.shrink();
        final order =
            items.where((item) => item.payment.canSubmit).firstOrNull ??
            items.first;
        return _OrderAttentionCard(order: order);
      },
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class _OrderAttentionCard extends StatelessWidget {
  const _OrderAttentionCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final needsPayment = order.payment.canSubmit;
    final color = needsPayment ? AppColors.accent : AppColors.primary;
    final title = needsPayment
        ? l10n.homeOrderNeedsPayment
        : l10n.homeOrderInProgress;
    final action = needsPayment
        ? l10n.homeOrderActionPay
        : l10n.homeOrderActionTrack;

    void openOrder() => context.push(AppRoutes.orderDetails(order.id));

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: BorderSide(color: color.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        onTap: openOrder,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                foregroundColor: color,
                child: Icon(
                  needsPayment
                      ? Icons.payments_outlined
                      : Icons.local_shipping_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.homeOrderLine(order.number, order.statusLabel(l10n)),
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: openOrder,
                      style: TextButton.styleFrom(
                        foregroundColor: color,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, AppSizes.compactControl),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(action),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
