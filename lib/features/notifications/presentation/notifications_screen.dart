import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/core/widgets/empty_state.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/features/notifications/application/notifications_controller.dart';
import 'package:chimbo/features/notifications/data/models/app_notification.dart';
import 'package:chimbo/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Arifa (from the Home bell): newest first, more load while scrolling. Tapping one marks it
/// read and opens its order.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  NotificationsController _controller(WidgetRef ref) =>
      ref.read(notificationsControllerProvider.notifier);

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) async {
    // Shown as read at once; the server call finishes in the background.
    final markingRead = _controller(ref).markAsRead(notification);
    final orderId = notification.orderId;
    if (orderId != null) {
      context.go(AppRoutes.orderDetails(orderId));
    }
    try {
      await markingRead;
    } on ApiException {
      // Only the read mark failed; it is sent again next time it is opened.
    }
  }

  Future<void> _markAllAsRead(BuildContext context, WidgetRef ref) async {
    final toast = AppToast.of(context);
    final l10n = context.l10n;
    try {
      await _controller(ref).markAllAsRead();
    } on ApiException catch (error) {
      toast.error(l10n.errorMessage(error));
    }
  }

  bool _onScroll(WidgetRef ref, ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical &&
        notification.metrics.extentAfter < AppSizes.loadMoreThreshold) {
      _controller(ref).loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final list = ref.watch(notificationsControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          if (list.value?.hasUnread ?? false)
            TextButton(
              onPressed: () => _markAllAsRead(context, ref),
              child: Text(l10n.actionMarkAllRead),
            ),
        ],
      ),
      body: list.when(
        data: (state) => RefreshIndicator(
          onRefresh: () => ref.refresh(notificationsControllerProvider.future),
          child: state.items.isEmpty
              ? CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.notifications_none_rounded,
                        title: l10n.notificationsEmptyTitle,
                        message: l10n.notificationsEmptyMessage,
                      ),
                    ),
                  ],
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (scroll) => _onScroll(ref, scroll),
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      for (final notification in state.items)
                        NotificationTile(
                          notification: notification,
                          onTap: () => _open(context, ref, notification),
                        ),
                      if (state.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
        ),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(notificationsControllerProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
