import 'dart:io';

import 'package:dio/dio.dart';

/// Reads the server's time from the HTTP `Date` header of API answers (errors included) and
/// passes it on, so the app can count down to server times on a phone with a wrong clock.
class ServerTimeInterceptor extends Interceptor {
  ServerTimeInterceptor({required this._onServerTime});

  final void Function(DateTime serverTime) _onServerTime;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _read(response.headers);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.headers case final headers?) {
      _read(headers);
    }
    handler.next(err);
  }

  void _read(Headers headers) {
    final date = headers.value(HttpHeaders.dateHeader);
    if (date == null) {
      return;
    }
    try {
      _onServerTime(HttpDate.parse(date));
    } on HttpException {
      // A malformed header: keep the phone's clock.
    }
  }
}
