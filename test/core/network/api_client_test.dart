import 'package:chimbo/core/network/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

void main() {
  test('unwraps a success envelope and calls the full URL', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': {'status': 'ok'},
        'meta': {'page': 1},
      }),
    );

    final response = await client.get('/health');

    expect(adapter.lastRequest?.uri.toString(), '$testBaseUrl/health');
    expect(response.dataAsMap['status'], 'ok');
    expect(response.meta['page'], 1);
  });

  test('turns an error envelope into ApiException with the server message and fields', () async {
    final (client, _) = clientReplying(
      (_) => jsonReply({
        'success': false,
        'error': {
          'code': 'VALIDATION_ERROR',
          'message': 'Taarifa si sahihi.',
          'fields': {'user_phone': 'Namba ya simu si sahihi.'},
        },
      }, statusCode: 422),
    );

    final error = await _captureError(
      client.post('/auth/otp', body: {'user_phone': '123'}),
    );

    expect(error.code, 'VALIDATION_ERROR');
    expect(error.statusCode, 422);
    expect(error.message, 'Taarifa si sahihi.');
    expect(error.fields['user_phone'], 'Namba ya simu si sahihi.');
  });

  test('a body that is not JSON is an invalid response', () async {
    final (client, _) = clientReplying(
      (_) => ResponseBody.fromString('<html>', 200),
    );

    final error = await _captureError(client.get('/health'));

    expect(error.code, ApiErrorCode.invalidResponse);
  });

  test(
    'a failed connection is a network error with no server message',
    () async {
      final (client, _) = clientReplying(
        (options) => throw DioException.connectionError(
          requestOptions: options,
          reason: 'Connection refused',
        ),
      );

      final error = await _captureError(client.get('/health'));

      expect(error.code, ApiErrorCode.network);
      expect(error.message, isNull);
    },
  );
}

Future<ApiException> _captureError(Future<Object?> request) async {
  try {
    await request;
  } on ApiException catch (error) {
    return error;
  }
  fail('Expected an ApiException');
}
