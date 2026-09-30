import 'package:chimbo/core/config/env.dart';
import 'package:chimbo/core/l10n/locale_provider.dart';
import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/core/network/api_headers_interceptor.dart';
import 'package:chimbo/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {Headers.acceptHeader: Headers.jsonContentType},
    ),
  );
  dio.interceptors.add(
    ApiHeadersInterceptor(
      tokenStorage: ref.watch(tokenStorageProvider),
      // Read at request time, so a language change applies to the next call.
      readLanguageCode: () => ref.read(appLocaleProvider).languageCode,
    ),
  );
  ref.onDispose(dio.close);
  return ApiClient(dio);
});
