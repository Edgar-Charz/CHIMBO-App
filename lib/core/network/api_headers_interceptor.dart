import 'package:chimbo/core/config/env.dart';
import 'package:chimbo/core/storage/token_storage.dart';
import 'package:dio/dio.dart';

/// Adds the headers every API request needs: the tunnel header, the user's language and, once
/// logged in, the token.
class ApiHeadersInterceptor extends Interceptor {
  ApiHeadersInterceptor({
    required this._tokenStorage,
    required this._readLanguageCode,
  });

  final TokenStorage _tokenStorage;
  final String Function() _readLanguageCode;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.addAll(Env.tunnelHeaders);
    options.headers['Accept-Language'] = _readLanguageCode();
    final token = await _tokenStorage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
