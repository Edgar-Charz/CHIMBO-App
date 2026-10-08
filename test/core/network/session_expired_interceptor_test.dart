import 'package:chimbo/core/network/session_expired_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

void main() {
  /// How often the interceptor reports an expired login for one refused request.
  Future<int> countExpiries({
    required int statusCode,
    required bool sendToken,
  }) async {
    var expiries = 0;
    final dio = Dio(BaseOptions(baseUrl: testBaseUrl))
      ..httpClientAdapter = FakeHttpAdapter(
        (_) => jsonReply({
          'success': false,
          'error': {'code': 'UNAUTHENTICATED', 'message': 'Tafadhali ingia.'},
        }, statusCode: statusCode),
      )
      ..interceptors.add(
        SessionExpiredInterceptor(onSessionExpired: () => expiries++),
      );
    await expectLater(
      dio.get<Object?>(
        '/cart',
        options: Options(
          headers: {if (sendToken) 'Authorization': 'Bearer old'},
        ),
      ),
      throwsA(isA<DioException>()),
    );
    return expiries;
  }

  test('a 401 on a logged-in request reports the expired login', () async {
    expect(await countExpiries(statusCode: 401, sendToken: true), 1);
  });

  test('a 401 without a token, or another error, reports nothing', () async {
    expect(await countExpiries(statusCode: 401, sendToken: false), 0);
    expect(await countExpiries(statusCode: 403, sendToken: true), 0);
  });
}
