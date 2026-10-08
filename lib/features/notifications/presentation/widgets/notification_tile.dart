import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/dates.dart';
import 'package:chimbo/features/notifications/data/models/app_notification.dart';
import 'package:flutter/material.dart';

/// One notification: an icon for its type, title, text and time. Unread ones have a bold
/// title and an orange dot.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = _styleOf(notification.type);
    final isUnread = !notification.isRead;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: isUnread ? AppColors.surface : AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: style.background,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: SizedBox.square(
                  dimension: AppSizes.menuIconBox,
                  child: Icon(
                    style.icon,
                    color: style.color,
                    size: AppSizes.iconMedium,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: isUnread ? FontWeight.w700 : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(notification.body, style: textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppDates.formatDayTime(
                        notification.createdAt,
                        context.l10n.localeName,
                      ),
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isUnread)
                const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(dimension: AppSizes.pageDot),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon and colours per notification type (same tones as the Wasifu menu).
typedef _TypeStyle = ({IconData icon, Color color, Color background});

_TypeStyle _styleOf(NotificationType type) => switch (type) {
  NotificationType.orderStatus => (
    icon: Icons.local_shipping_outlined,
    color: AppColors.accent,
    background: AppColors.accentLight,
  ),
  NotificationType.payment => (
    icon: Icons.payments_outlined,
    color: AppColors.info,
    background: AppColors.infoLight,
  ),
  NotificationType.promo => (
    icon: Icons.local_offer_outlined,
    color: AppColors.gold,
    background: AppColors.goldLight,
  ),
  NotificationType.system => (
    icon: Icons.info_outline_rounded,
    color: AppColors.purple,
    background: AppColors.purpleLight,
  ),
};
