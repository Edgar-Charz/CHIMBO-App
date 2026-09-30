import 'package:chimbo/core/network/api_exception.dart';

/// A successful API reply: `{"success": true, "data": ..., "meta": {...}}`.
class ApiResponse {
  const ApiResponse({required this.data, this.meta = const {}});

  /// Unwraps the standard envelope, or throws [ApiException] when the body is not a success envelope.
  factory ApiResponse.fromBody(Object? body, {int? statusCode}) {
    if (body is! Map<String, dynamic>) {
      throw ApiException(
        code: ApiErrorCode.invalidResponse,
        statusCode: statusCode,
      );
    }
    if (body['success'] != true) {
      throw ApiException.fromErrorBody(body, statusCode: statusCode);
    }
    return ApiResponse(
      data: body['data'],
      meta: body['meta'] as Map<String, dynamic>? ?? const {},
    );
  }

  final Object? data;
  final Map<String, dynamic> meta;

  /// `data` as a JSON object; throws [ApiException] if the server sent something else.
  Map<String, dynamic> get dataAsMap {
    final value = data;
    if (value is Map<String, dynamic>) {
      return value;
    }
    throw const ApiException(code: ApiErrorCode.invalidResponse);
  }

  /// `data` as a JSON list; throws [ApiException] if the server sent something else.
  List<Object?> get dataAsList {
    final value = data;
    if (value is List<Object?>) {
      return value;
    }
    throw const ApiException(code: ApiErrorCode.invalidResponse);
  }
}
