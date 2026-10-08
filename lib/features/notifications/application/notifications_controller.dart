import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/notifications/data/models/app_notification.dart';
import 'package:chimbo/features/notifications/data/notifications_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The number on the Home bell; 0 when logged out. Reloads when someone logs in, and after
/// notifications are read.
final unreadNotificationsProvider = FutureProvider<int>((ref) {
  final userId = ref.watch(
    authControllerProvider.select((state) => state.user?.id),
  );
  return userId == null
      ? Future.value(0)
      : ref.watch(notificationsRepositoryProvider).getUnreadCount();
});

/// The notifications loaded so far.
class NotificationListState {
  const NotificationListState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<AppNotification> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  bool get hasUnread => items.any((notification) => !notification.isRead);

  NotificationListState copyWith({
    List<AppNotification>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return NotificationListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// The "Arifa" list: page 1 on open, [loadMore] for infinite scroll, and reading.
class NotificationsController extends AsyncNotifier<NotificationListState> {
  NotificationsRepository get _repository =>
      ref.read(notificationsRepositoryProvider);

  @override
  Future<NotificationListState> build() async {
    final firstPage = await _repository.getNotifications(page: 1);
    return NotificationListState(
      items: firstPage.items,
      page: firstPage.page,
      hasMore: firstPage.hasMore,
    );
  }

  /// Adds the next page; does nothing while a page is loading or when all are loaded.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final next = await _repository.getNotifications(page: current.page + 1);
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          page: next.page,
          hasMore: next.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Exception {
      // Keep what is shown; scrolling again retries.
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  /// Shown as read at once (the customer is already opening it), then saved on the server.
  Future<void> markAsRead(AppNotification notification) async {
    if (notification.isRead) {
      return;
    }
    _showAsRead((item) => item.id == notification.id);
    await _repository.markAsRead(notification.id);
    ref.invalidate(unreadNotificationsProvider);
  }

  /// "Soma zote".
  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    _showAsRead((_) => true);
    ref.invalidate(unreadNotificationsProvider);
  }

  void _showAsRead(bool Function(AppNotification item) matches) {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        items: [
          for (final item in current.items)
            matches(item) ? item.copyWith(isRead: true) : item,
        ],
      ),
    );
  }
}

final notificationsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationsController,
      NotificationListState
    >(NotificationsController.new);
