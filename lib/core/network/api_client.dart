import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/network/api_response.dart';
import 'package:dio/dio.dart';

/// The only class that talks HTTP. Repositories call it; widgets never do.
///
/// Every method returns the unwrapped [ApiResponse] or throws [ApiException].
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<ApiResponse> get(String path, {Map<String, Object?>? query}) {
    return _send(() => _dio.get<Object?>(path, queryParameters: query));
  }

  Future<ApiResponse> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) {
    return _send(
      () => _dio.post<Object?>(
        path,
        data: body,
        options: Options(headers: headers),
      ),
    );
  }

  Future<ApiResponse> patch(String path, {Object? body}) {
    return _send(() => _dio.patch<Object?>(path, data: body));
  }

  Future<ApiResponse> delete(String path, {Object? body}) {
    return _send(() => _dio.delete<Object?>(path, data: body));
  }

  Future<ApiResponse> _send(
    Future<Response<Object?>> Function() request,
  ) async {
    try {
      final response = await request();
      return ApiResponse.fromBody(
        response.data,
        statusCode: response.statusCode,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
