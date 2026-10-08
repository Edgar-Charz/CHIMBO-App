import 'package:chimbo/features/notifications/data/models/app_notification.dart';
import 'package:chimbo/features/notifications/data/models/notification_page.dart';
import 'package:chimbo/features/notifications/data/notifications_repository.dart';

/// Offline stand-in for the notifications API: two unread (one about sample order 1) and one
/// read, all on one page.
class FakeNotificationsRepository implements NotificationsRepository {
  FakeNotificationsRepository();

  final List<AppNotification> _notifications = [
    AppNotification(
      id: 3,
      type: NotificationType.orderStatus,
      title: 'Oda imetumwa',
      body: 'Oda yako iko njiani.',
      isRead: false,
      createdAt: DateTime(2026, 9, 30, 9),
      orderId: 1,
    ),
    AppNotification(
      id: 2,
      type: NotificationType.promo,
      title: 'Ofa ya wiki',
      body: 'Punguzo kwenye vipodozi.',
      isRead: false,
      createdAt: DateTime(2026, 9, 29, 9),
    ),
    AppNotification(
      id: 1,
      type: NotificationType.system,
      title: 'Karibu CHIMBO',
      body: 'Asante kwa kujiunga.',
      isRead: true,
      createdAt: DateTime(2026, 9, 28, 9),
    ),
  ];

  @override
  Future<NotificationPage> getNotifications({required int page}) async =>
      NotificationPage(items: [..._notifications], page: page, lastPage: 1);

  @override
  Future<int> getUnreadCount() async =>
      _notifications.where((notification) => !notification.isRead).length;

  @override
  Future<void> markAsRead(int notificationId) async =>
      _markRead((notification) => notification.id == notificationId);

  @override
  Future<void> markAllAsRead() async => _markRead((_) => true);

  void _markRead(bool Function(AppNotification notification) matches) {
    for (final (index, notification) in _notifications.indexed) {
      if (matches(notification)) {
        _notifications[index] = notification.copyWith(isRead: true);
      }
    }
  }
}
