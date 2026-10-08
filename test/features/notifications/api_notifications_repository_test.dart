import 'package:chimbo/features/notifications/data/api_notifications_repository.dart';
import 'package:chimbo/features/notifications/data/models/app_notification.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

void main() {
  test(
    'the list reads each notification and whether more pages follow',
    () async {
      final (client, adapter) = clientReplying(
        (_) => jsonReply({
          'success': true,
          'data': [
            {
              'notification_id': 7,
              'notification_type': 'order_status',
              'notification_title': 'Oda imetumwa',
              'notification_body': 'Oda #CHB765068 iko njiani.',
              'notification_data': {'order_id': 1},
              'is_read': false,
              'created_at': '2026-09-30T08:00:00+00:00',
            },
            {
              'notification_id': 6,
              'notification_type': 'something_new',
              'notification_title': 'Karibu',
              'notification_body': 'Asante kwa kujiunga.',
              'notification_data': null,
              'is_read': true,
              'created_at': '2026-09-29T08:00:00+00:00',
            },
          ],
          'meta': {'page': 1, 'per_page': 20, 'total': 25, 'last_page': 2},
        }),
      );

      final page = await ApiNotificationsRepository(client)
          .getNotifications(page: 1);

      expect(adapter.lastRequest!.uri.queryParameters, {'page': '1'});
      expect(page.hasMore, isTrue);
      final [order, other] = page.items;
      expect(order.orderId, 1);
      expect(order.isRead, isFalse);
      expect(order.type, NotificationType.orderStatus);
      expect(other.orderId, isNull);
      // A type the app doesn't know yet is shown like a system message.
      expect(other.type, NotificationType.system);
    },
  );

  test('the bell reads the unread count', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': {'unread_count': 2},
      }),
    );

    expect(await ApiNotificationsRepository(client).getUnreadCount(), 2);
    expect(
      adapter.lastRequest!.uri.path,
      endsWith('/notifications/unread-count'),
    );
  });

  test('reading one or all posts to the right address', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({'success': true, 'data': null}),
    );
    final repository = ApiNotificationsRepository(client);

    await repository.markAsRead(7);
    expect(adapter.lastRequest!.method, 'POST');
    expect(adapter.lastRequest!.uri.path, endsWith('/notifications/7/read'));

    await repository.markAllAsRead();
    expect(adapter.lastRequest!.uri.path, endsWith('/notifications/read-all'));
  });
}
