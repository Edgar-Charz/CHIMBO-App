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
    final paymentExpired =
        order.status == OrderStatus.pendingPayment &&
        order.payment.deadlinePassed;
    final isExpired = order.status == OrderStatus.expired || paymentExpired;
    final steps = switch ((isExpired, order.status.isStopped)) {
      (true, _) => _expiredSteps(reachedAt.keys),
      (false, true) => [...reachedAt.keys],
      _ => order.timelineSteps,
    };

    return Column(
      children: [
        for (final (index, status) in steps.indexed)
          _TimelineStep(
            status: status,
            label: order.statusLabel(l10n, status),
            date: _stepDate(status, reachedAt, isExpired, l10n.localeName),
            isCurrent: isExpired
                ? status == OrderStatus.expired
                : status == order.status,
            isReached:
                reachedAt.containsKey(status) ||
                (isExpired && status == OrderStatus.pendingPayment),
            isLast: index == steps.length - 1,
          ),
      ],
    );
  }

  List<OrderStatus> _expiredSteps(Iterable<OrderStatus> reachedStatuses) {
    final steps = reachedStatuses
        .where((status) => status != OrderStatus.expired)
        .toList();
    if (!steps.contains(OrderStatus.pendingPayment)) {
      steps.insert(0, OrderStatus.pendingPayment);
    }
    steps.add(OrderStatus.expired);
    return steps;
  }

  String? _stepDate(
    OrderStatus status,
    Map<OrderStatus, DateTime> reachedAt,
    bool isExpired,
    String localeName,
  ) {
    final date = switch (status) {
      OrderStatus.expired => reachedAt[status] ?? order.expiresAt,
      OrderStatus.pendingPayment when isExpired =>
        reachedAt[status] ?? order.placedAt,
      _ => reachedAt[status],
    };
    return date == null ? null : AppDates.formatDayTime(date, localeName);
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
              AnimatedContainer(
                duration: AppDurations.fast,
                curve: Curves.easeOutCubic,
                width: AppSizes.timelineDot,
                height: AppSizes.timelineDot,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: AnimatedSwitcher(
                  duration: AppDurations.fast,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Icon(
                    key: ValueKey(status),
                    status.icon,
                    size: AppSizes.iconMedium,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    curve: Curves.easeOutCubic,
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
                  AnimatedDefaultTextStyle(
                    duration: AppDurations.fast,
                    style: (textTheme.titleSmall ?? const TextStyle()).copyWith(
                      color: isReached
                          ? (isCurrent ? status.color : AppColors.textPrimary)
                          : AppColors.textSecondary,
                    ),
                    child: Text(label),
                  ),
                  AnimatedSwitcher(
                    duration: AppDurations.fast,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: when == null
                        ? const SizedBox.shrink(key: ValueKey('no-step-date'))
                        : Text(
                            when,
                            key: ValueKey(when),
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
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
