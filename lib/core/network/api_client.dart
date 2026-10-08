import 'dart:convert';
import 'dart:typed_data';

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

  /// `multipart/form-data` upload of one file (e.g. the profile photo) under [field].
  Future<ApiResponse> upload(
    String path, {
    required String field,
    required String filePath,
  }) async {
    final form = FormData.fromMap({
      field: await MultipartFile.fromFile(filePath),
    });
    return _send(() => _dio.post<Object?>(path, data: form));
  }

  /// A file the server sends as-is (e.g. a receipt PDF) instead of the JSON envelope.
  /// Errors still arrive as the JSON error body and become [ApiException] as usual.
  Future<Uint8List> download(String path) async {
    try {
      final response = await _dio.get<List<int>>(
        path,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data ?? const []);
    } on DioException catch (exception) {
      final bytes = exception.response?.data;
      throw bytes is List<int>
          ? ApiException.fromErrorBody(
              _decodeJson(bytes),
              statusCode: exception.response?.statusCode,
            )
          : ApiException.fromDioException(exception);
    }
  }

  static Object? _decodeJson(List<int> bytes) {
    try {
      return jsonDecode(utf8.decode(bytes));
    } on FormatException {
      return null;
    }
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
