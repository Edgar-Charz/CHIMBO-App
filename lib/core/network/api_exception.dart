import 'dart:io';

import 'package:dio/dio.dart';

/// Error codes created by the app itself (the server's codes are listed in blueprint §12.1).
abstract final class ApiErrorCode {
  static const String network = 'NETWORK_ERROR';
  static const String timeout = 'TIMEOUT';
  static const String invalidResponse = 'INVALID_RESPONSE';
  static const String unknown = 'UNKNOWN_ERROR';

  // Server codes the app reacts to.
  static const String validation = 'VALIDATION_ERROR';
  static const String unauthenticated = 'UNAUTHENTICATED';
  static const String otpInvalid = 'OTP_INVALID';
  static const String pinInvalid = 'PIN_INVALID';
  static const String pinLocked = 'PIN_LOCKED';
  static const String notFound = 'NOT_FOUND';
  static const String moqNotMet = 'MOQ_NOT_MET';
  static const String outOfStock = 'OUT_OF_STOCK';
  static const String priceChanged = 'PRICE_CHANGED';
  static const String paymentUnderReview = 'PAYMENT_UNDER_REVIEW';
  static const String paymentTimeOver = 'PAYMENT_TIME_OVER';
  static const String paymentNotExpected = 'PAYMENT_NOT_EXPECTED';
  static const String paymentMethodLocked = 'PAYMENT_METHOD_LOCKED';
}

/// The one error type the rest of the app sees for anything that goes wrong with an API call.
///
/// [message] is the server's ready-to-show text (already in the user's language); it is null
/// for app-side errors, which the UI translates from [code].
class ApiException implements Exception {
  const ApiException({
    required this.code,
    this.message,
    this.statusCode,
    this.fields = const {},
  });

  /// Reads the server's `{"success": false, "error": {...}}` body; anything else becomes [ApiErrorCode.unknown].
  factory ApiException.fromErrorBody(Object? body, {int? statusCode}) {
    if (body is Map<String, dynamic> && body['error'] is Map<String, dynamic>) {
      final error = body['error'] as Map<String, dynamic>;
      return ApiException(
        code: error['code'] as String? ?? ApiErrorCode.unknown,
        message: error['message'] as String?,
        statusCode: statusCode,
        fields: _readFields(error['fields']),
      );
    }
    return ApiException(code: ApiErrorCode.unknown, statusCode: statusCode);
  }

  factory ApiException.fromDioException(DioException exception) {
    return switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const ApiException(
        code: ApiErrorCode.timeout,
      ),
      DioExceptionType.connectionError => const ApiException(
        code: ApiErrorCode.network,
      ),
      DioExceptionType.unknown when exception.error is SocketException =>
        const ApiException(code: ApiErrorCode.network),
      DioExceptionType.badResponse => ApiException.fromErrorBody(
        exception.response?.data,
        statusCode: exception.response?.statusCode,
      ),
      _ => const ApiException(code: ApiErrorCode.unknown),
    };
  }

  final String code;
  final String? message;
  final int? statusCode;

  /// Per-field validation messages, keyed by the field name (e.g. `user_phone`).
  final Map<String, String> fields;

  static Map<String, String> _readFields(Object? fields) {
    if (fields is! Map<String, dynamic>) {
      return const {};
    }
    return fields.map((field, message) => MapEntry(field, message.toString()));
  }

  @override
  String toString() =>
      'ApiException($code, status: $statusCode, message: $message)';
}
