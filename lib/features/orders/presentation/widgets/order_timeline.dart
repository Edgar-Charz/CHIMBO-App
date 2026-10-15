import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/dates.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/presentation/widgets/order_labels.dart';
import 'package:flutter/material.dart';

/// Imethibitishwa → Imepakiwa → Imetumwa → Inasafirishwa → Imewasili, with the date of each
/// reached step. Reached steps are green, the current one orange, the rest grey.
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reachedAt = {
      for (final event in order.events) event.status: event.at,
    };
    // A cancelled or expired order shows the steps it reached, then how it ended.
    final steps = order.status.isStopped
        ? [...reachedAt.keys]
        : order.timelineSteps;

    return Column(
      children: [
        for (final (index, status) in steps.indexed)
          _TimelineStep(
            status: status,
            label: order.statusLabel(l10n, status),
            date: switch (reachedAt[status]) {
              final at? => AppDates.formatDayTime(at, l10n.localeName),
              null => null,
            },
            isCurrent: status == order.status,
            isReached: reachedAt.containsKey(status),
            isLast: index == steps.length - 1,
          ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.status,
    required this.label,
    required this.date,
    required this.isCurrent,
    required this.isReached,
    required this.isLast,
  });

  final OrderStatus status;
  final String label;
  final String? date;
  final bool isCurrent;
  final bool isReached;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = isCurrent
        ? status.color
        : isReached
        ? AppColors.primary
        : AppColors.border;
    final when = date;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: AppSizes.timelineDot / 2,
                backgroundColor: color,
                child: Icon(
                  status.icon,
                  size: AppSizes.iconMedium,
                  color: AppColors.onPrimary,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: AppSizes.borderWidth * 2,
                    color: isReached ? AppColors.primary : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.titleSmall?.copyWith(
                      color: isReached
                          ? (isCurrent ? status.color : AppColors.textPrimary)
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (when != null)
                    Text(
                      when,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
