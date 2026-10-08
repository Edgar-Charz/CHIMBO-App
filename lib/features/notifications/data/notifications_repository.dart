import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/features/notifications/data/api_notifications_repository.dart';
import 'package:chimbo/features/notifications/data/models/notification_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bell (docs/API_REFERENCE.md, "Notifications"). Every method throws `ApiException`.
abstract interface class NotificationsRepository {
  /// `GET /notifications`, newest first; [page] starts at 1.
  Future<NotificationPage> getNotifications({required int page});

  /// `GET /notifications/unread-count`: the number on the bell.
  Future<int> getUnreadCount();

  /// `POST /notifications/{id}/read`.
  Future<void> markAsRead(int notificationId);

  /// `POST /notifications/read-all`.
  Future<void> markAllAsRead();
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => ApiNotificationsRepository(ref.watch(apiClientProvider)),
);
