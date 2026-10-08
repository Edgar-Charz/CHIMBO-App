import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/features/notifications/data/models/notification_page.dart';
import 'package:chimbo/features/notifications/data/notifications_repository.dart';

/// Notifications from the CHIMBO API (docs/API_REFERENCE.md, "Notifications").
class ApiNotificationsRepository implements NotificationsRepository {
  const ApiNotificationsRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<NotificationPage> getNotifications({required int page}) async {
    final response = await _apiClient.get(
      '/notifications',
      query: {'page': page},
    );
    return NotificationPage.fromJson(response.dataAsList, response.meta);
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get('/notifications/unread-count');
    return response.dataAsMap['unread_count'] as int;
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    await _apiClient.post('/notifications/$notificationId/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await _apiClient.post('/notifications/read-all');
  }
}
