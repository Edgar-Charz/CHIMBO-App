import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/dates.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/presentation/widgets/order_labels.dart';
import 'package:chimbo/features/orders/presentation/widgets/order_thumbnails.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// One order in Oda Zangu. Active: status, ETA, Fuatilia Oda. Delivered: date, items, total,
/// Agiza Tena and Pakua Risiti.
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onReorder,
    required this.onDownloadReceipt,
  });

  final Order order;
  final VoidCallback onReorder;
  final VoidCallback onDownloadReceipt;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final status = order.status;
    final locale = l10n.localeName;
    final deliveredAt = order.deliveredAt;
    void open() => context.push(AppRoutes.orderDetails(order.id));

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: open,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.orderNumber(order.number),
                      style: textTheme.titleMedium,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              Text(
                status.label(l10n),
                style: textTheme.titleSmall?.copyWith(color: status.color),
              ),
              const SizedBox(height: AppSpacing.xs),
              if (status.isActive)
                _LabelledValue(
                  label: l10n.estimatedDeliveryTitle,
                  value: AppDates.formatDate(order.estimatedDelivery, locale),
                )
              else if (deliveredAt != null)
                _LabelledValue(
                  label: l10n.deliveredOnTitle,
                  value: AppDates.formatDate(deliveredAt, locale),
                ),
              const SizedBox(height: AppSpacing.md),
              OrderThumbnails(items: order.items),
              const SizedBox(height: AppSpacing.md),
              _LabelledValue(
                label: l10n.summaryTotal,
                value: Money.format(order.total),
                isEmphasised: true,
              ),
              const SizedBox(height: AppSpacing.md),
              if (status.isActive)
                AppButton(label: l10n.actionTrackOrder, onPressed: open)
              else ...[
                if (status.canReorder)
                  AppButton(
                    label: l10n.quickReorder,
                    variant: AppButtonVariant.accent,
                    onPressed: onReorder,
                  ),
                if (status == OrderStatus.delivered)
                  TextButton.icon(
                    onPressed: onDownloadReceipt,
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: Text(l10n.actionDownloadReceipt),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LabelledValue extends StatelessWidget {
  const _LabelledValue({
    required this.label,
    required this.value,
    this.isEmphasised = false,
  });

  final String label;
  final String value;
  final bool isEmphasised;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: isEmphasised ? textTheme.titleMedium : textTheme.bodyMedium,
        ),
      ],
    );
  }
}
