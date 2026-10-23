import 'dart:async';
import 'dart:convert';

import 'package:chimbo/core/config/firebase_ready_provider.dart';
import 'package:chimbo/core/l10n/locale_provider.dart';
import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/features/notifications/data/models/app_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final service = PushNotificationService(
    apiClient: ref.watch(apiClientProvider),
    firebaseReady: ref.watch(firebaseReadyProvider),
    readLanguageCode: () => ref.read(appLocaleProvider).languageCode,
  );
  ref.listen(appLocaleProvider, (previous, next) {
    if (previous?.languageCode != next.languageCode) {
      unawaited(service.refreshDeviceLanguage());
    }
  });
  ref.onDispose(service.dispose);
  return service;
});

/// Connects Firebase delivery to this account's in-app notification list and order routes.
class PushNotificationService {
  PushNotificationService({
    required this.apiClient,
    required this.firebaseReady,
    required this.readLanguageCode,
  });

  final ApiClient apiClient;
  final bool firebaseReady;
  final String Function() readLanguageCode;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _registrationSubscription;
  GoRouter? _router;
  VoidCallback? _onNotificationChanged;
  RemoteMessage? _pendingOpen;
  bool _hasSession = false;
  bool _canOpenCustomerPages = false;
  bool _registeredForCurrentSession = false;
  String? _currentDeviceToken;

  /// Hooks foreground, background-tap and terminated-tap events after Firebase initialization.
  Future<void> initialize({
    required GoRouter router,
    GlobalKey<ScaffoldMessengerState>? messengerKey,
    required VoidCallback onNotificationChanged,
  }) async {
    if (!firebaseReady) return;
    _router = router;
    _onNotificationChanged = onNotificationChanged;
    _messageSubscription = FirebaseMessaging.onMessage.listen(
      _onForegroundMessage,
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _onMessageOpened,
    );
    // The backend sends with HTTP v1's message.token field, which needs an FCM token.
    // The newer onRegistered stream emits a Firebase Installation ID instead.
    // ignore: deprecated_member_use
    _registrationSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen((deviceToken) => unawaited(_registerDevice(deviceToken)));
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _pendingOpen = initialMessage;
    _openPendingMessageIfReady();
  }

  /// Registers after sign-in and waits to navigate until account setup is complete.
  void updateSession({
    required bool hasSession,
    required bool canOpenCustomerPages,
  }) {
    _hasSession = hasSession;
    _canOpenCustomerPages = canOpenCustomerPages;
    if (!hasSession) _registeredForCurrentSession = false;
    if (hasSession && !_registeredForCurrentSession && firebaseReady) {
      unawaited(_requestPermissionAndRegister());
    }
    _openPendingMessageIfReady();
  }

  /// Deletes this installation from the API while its bearer session is still valid.
  Future<void> removeCurrentRegistration() async {
    if (!firebaseReady) return;
    try {
      final deviceToken = _currentDeviceToken;
      if (deviceToken != null) {
        await apiClient.delete('/devices', body: {'device_token': deviceToken});
      }
    } catch (_) {
      // The server excludes revoked sessions even when logout happens offline.
    } finally {
      _registeredForCurrentSession = false;
    }
  }

  /// Updates the server preference so system-tray pushes use the selected language.
  Future<void> refreshDeviceLanguage() async {
    final deviceToken = _currentDeviceToken;
    if (!_hasSession || deviceToken == null) return;
    _registeredForCurrentSession = false;
    await _registerDevice(deviceToken);
  }

  void dispose() {
    unawaited(_messageSubscription?.cancel());
    unawaited(_openedSubscription?.cancel());
    unawaited(_registrationSubscription?.cancel());
  }

  Future<void> _requestPermissionAndRegister() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      String? deviceToken;
      try {
        // ignore: deprecated_member_use
        deviceToken = await FirebaseMessaging.instance.getToken();
      } catch (tokenError) {
        debugPrint('Push getToken failed: $tokenError');
        unawaited(
          apiClient.get(
            '/support',
            query: {'push_error': tokenError.toString()},
          ),
        );
        try {
          // ignore: deprecated_member_use
          await FirebaseMessaging.instance.deleteToken();
          // ignore: deprecated_member_use
          deviceToken = await FirebaseMessaging.instance.getToken();
        } catch (_) {}
      }

      if (deviceToken == null) {
        await Future<void>.delayed(const Duration(seconds: 2));
        try {
          // ignore: deprecated_member_use
          deviceToken = await FirebaseMessaging.instance.getToken();
        } catch (_) {}
      }

      if (deviceToken != null) {
        await _registerDevice(deviceToken);
      }
    } catch (error) {
      debugPrint('Push registration error: $error');
      unawaited(
        apiClient.get('/support', query: {'push_error': error.toString()}),
      );
    }
  }

  Future<void> _registerDevice(String deviceToken) async {
    if (_currentDeviceToken != deviceToken) {
      _registeredForCurrentSession = false;
    }
    _currentDeviceToken = deviceToken;
    if (!_hasSession || _registeredForCurrentSession) return;
    final platform = switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => null,
    };
    if (platform == null) return;

    try {
      await apiClient.post(
        '/devices',
        body: {
          'device_token': deviceToken,
          'device_platform': platform,
          'device_language': readLanguageCode(),
        },
      );
      _registeredForCurrentSession = true;
    } catch (_) {
      // Registration is retried on token refresh and the next authenticated launch.
    }
  }

  static const _notificationsPlatform = MethodChannel(
    'com.chimbo.chimbo/notifications',
  );

  void _onForegroundMessage(RemoteMessage message) {
    _onNotificationChanged?.call();
    final languageCode = readLanguageCode();
    final data = Map<String, dynamic>.from(message.data);
    final title = AppNotification.localizedPushText(
      data: data,
      languageCode: languageCode,
      field: 'title',
      fallback: message.notification?.title ?? 'CHIMBO',
    );
    final body = AppNotification.localizedPushText(
      data: data,
      languageCode: languageCode,
      field: 'body',
      fallback: message.notification?.body ?? '',
    );
    if (title.isNotEmpty || body.isNotEmpty) {
      unawaited(_showForegroundSystemNotification(title: title, body: body));
    }
  }

  Future<void> _showForegroundSystemNotification({
    required String title,
    required String body,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _notificationsPlatform.invokeMethod('showNotification', {
        'title': title,
        'body': body,
      });
    } catch (_) {}
  }

  void _onMessageOpened(RemoteMessage message) {
    _pendingOpen = message;
    _onNotificationChanged?.call();
    _openPendingMessageIfReady();
  }

  void _openPendingMessageIfReady() {
    final message = _pendingOpen;
    final router = _router;
    if (message == null || router == null || !_canOpenCustomerPages) return;
    _pendingOpen = null;
    unawaited(_markRead(message));

    final data = Map<String, dynamic>.from(message.data);
    final rawNested = message.data['notification_data'];
    if (rawNested is String && rawNested.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawNested);
        if (decoded is Map) {
          data.addAll(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {}
    }

    final orderId = int.tryParse(data['order_id']?.toString() ?? '');
    final productId = int.tryParse(data['product_id']?.toString() ?? '');
    final categoryId = int.tryParse(data['category_id']?.toString() ?? '');
    final collection = data['collection']?.toString();
    final target = data['target']?.toString() ?? data['screen']?.toString();
    final title = (message.notification?.title ?? data['title'] ?? '')
        .toString()
        .toLowerCase();
    final body = (message.notification?.body ?? data['body'] ?? '')
        .toString()
        .toLowerCase();
    final isWishlist =
        target == 'wishlist' ||
        target == 'vipendwa' ||
        title.contains('vipendwa') ||
        body.contains('vipendwa');

    if (productId != null) {
      router.push(AppRoutes.productDetails(productId));
    } else if (isWishlist) {
      router.push(AppRoutes.wishlist);
    } else if (orderId != null) {
      router.go(AppRoutes.orderDetails(orderId));
    } else if (categoryId != null) {
      router.push(AppRoutes.category(categoryId));
    } else if (collection != null && collection.isNotEmpty) {
      router.push(AppRoutes.collection(collection));
    } else {
      router.go(AppRoutes.notifications);
    }
  }

  Future<void> _markRead(RemoteMessage message) async {
    final notificationId = int.tryParse(
      message.data['notification_id']?.toString() ?? '',
    );
    if (notificationId == null) return;
    try {
      await apiClient.post('/notifications/$notificationId/read');
      _onNotificationChanged?.call();
    } catch (_) {
      // The in-app inbox can mark it read on the next visit.
    }
  }
}
