import 'dart:convert';
import 'dart:typed_data';

import 'package:chimbo/core/network/api_client.dart';
import 'package:dio/dio.dart';

const String testBaseUrl = 'http://api.test/chimbo/api/v1';

/// Answers requests without a network, so we can test how [ApiClient] reads replies.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this._reply);

  final ResponseBody Function(RequestOptions options) _reply;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return _reply(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonReply(Map<String, Object?> body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

/// An [ApiClient] whose every request is answered by [reply] (no network).
(ApiClient, FakeHttpAdapter) clientReplying(
  ResponseBody Function(RequestOptions) reply,
) {
  final adapter = FakeHttpAdapter(reply);
  final dio = Dio(BaseOptions(baseUrl: testBaseUrl))
    ..httpClientAdapter = adapter;
  return (ApiClient(dio), adapter);
}
