import 'dart:async';

import 'package:chimbo/core/config/env.dart';
import 'package:chimbo/core/l10n/locale_provider.dart';
import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/core/network/api_headers_interceptor.dart';
import 'package:chimbo/core/network/server_time_interceptor.dart';
import 'package:chimbo/core/network/session_expired_interceptor.dart';
import 'package:chimbo/core/storage/token_storage.dart';
import 'package:chimbo/core/time/server_clock.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fires when the server refused this phone's login token (see [SessionExpiredInterceptor]).
/// The auth controller listens and logs out; the network layer never needs to know about it.
final sessionExpiredEventsProvider = Provider<StreamController<void>>((ref) {
  final events = StreamController<void>.broadcast();
  ref.onDispose(events.close);
  return events;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {Headers.acceptHeader: Headers.jsonContentType},
    ),
  );
  final sessionExpiredEvents = ref.watch(sessionExpiredEventsProvider);
  dio.interceptors.addAll([
    ApiHeadersInterceptor(
      tokenStorage: ref.watch(tokenStorageProvider),
      // Read at request time, so a language change applies to the next call.
      readLanguageCode: () => ref.read(appLocaleProvider).languageCode,
    ),
    SessionExpiredInterceptor(
      onSessionExpired: () => sessionExpiredEvents.add(null),
    ),
    // Offer countdowns use the server's time, not the phone's.
    ServerTimeInterceptor(
      onServerTime: (time) => ref.read(serverClockProvider.notifier).sync(time),
    ),
  ]);
  ref.onDispose(dio.close);
  return ApiClient(dio);
});
