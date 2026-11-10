import 'dart:async';

import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/l10n/locale_provider.dart';
import 'package:chimbo/core/router/app_router.dart';
import 'package:chimbo/core/theme/app_theme.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/auth/application/auth_state.dart';
import 'package:chimbo/features/notifications/application/notifications_controller.dart';
import 'package:chimbo/features/notifications/data/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
/// Root widget: theme, language and navigation.
class ChimboApp extends ConsumerStatefulWidget {
  const ChimboApp({super.key});

  @override
  ConsumerState<ChimboApp> createState() => _ChimboAppState();
}

class _ChimboAppState extends ConsumerState<ChimboApp> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = ref.read(pushNotificationServiceProvider);
      unawaited(
        service.initialize(
          router: ref.read(appRouterProvider),
          messengerKey: _messengerKey,
          onNotificationChanged: () {
            ref.invalidate(unreadNotificationsProvider);
            ref.invalidate(notificationsControllerProvider);
          },
        ),
      );
      _updatePushSession(ref.read(authControllerProvider));
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      _updatePushSession(next);
    });
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: AppTheme.light(),
      routerConfig: ref.watch(appRouterProvider),
      scaffoldMessengerKey: _messengerKey,
      locale: ref.watch(appLocaleProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
    );
  }

  void _updatePushSession(AuthState state) {
    final hasSession =
        state.status != AuthStatus.unknown &&
        state.status != AuthStatus.unauthenticated;
    ref
        .read(pushNotificationServiceProvider)
        .updateSession(
          hasSession: hasSession,
          canOpenCustomerPages: state.status == AuthStatus.authenticated,
        );
  }
}
