import 'package:chimbo/features/notifications/data/models/app_notification.dart';

/// One page of `GET /notifications` + its `meta`.
class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.page,
    required this.lastPage,
  });

  factory NotificationPage.fromJson(
    List<dynamic> data,
    Map<String, dynamic> meta,
  ) {
    return NotificationPage(
      items: data
          .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: meta['page'] as int,
      lastPage: meta['last_page'] as int,
    );
  }

  final List<AppNotification> items;
  final int page;
  final int lastPage;

  bool get hasMore => page < lastPage;
}
