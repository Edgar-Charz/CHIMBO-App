import 'package:dio/dio.dart';

/// The global 401 handler: when the server refuses a request that carried a login token
/// (`401 UNAUTHENTICATED` — expired, logged out elsewhere, or revoked by a PIN change on
/// another phone), it calls [_onSessionExpired]. The auth feature then logs out on this phone
/// and the router shows the phone screen. The error still reaches the caller as usual.
class SessionExpiredInterceptor extends Interceptor {
  SessionExpiredInterceptor({required this._onSessionExpired});

  final void Function() _onSessionExpired;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final sentToken = err.requestOptions.headers.containsKey('Authorization');
    if (sentToken && err.response?.statusCode == 401) {
      _onSessionExpired();
    }
    handler.next(err);
  }
}
