import 'package:dio/dio.dart';

/// Typed exception describing a failed API call.
///
/// The backend always returns errors as `{ "error": "message" }` with an
/// appropriate HTTP status, so [fromDioException] extracts that shape.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  /// Human-readable message (from the backend `error` field when available).
  final String message;

  /// HTTP status code, or null for transport-level failures (timeout, no host).
  final int? statusCode;

  /// Raw response payload, when present.
  final dynamic data;

  /// True when the server rejected the request because the token is
  /// missing/expired/invalid.
  bool get isUnauthorized => statusCode == 401;

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'The connection timed out. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message:
              'Could not reach the server. Check your connection and try again.',
        );
      case DioExceptionType.cancel:
        return const ApiException(message: 'Request cancelled.');
      case DioExceptionType.badCertificate:
        return const ApiException(message: 'Invalid server certificate.');
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return ApiException._fromResponse(error);
    }
  }

  factory ApiException._fromResponse(DioException error) {
    final Response<dynamic>? response = error.response;
    final dynamic data = response?.data;

    String message = 'Something went wrong. Please try again.';
    if (data is Map && data['error'] is String) {
      message = data['error'] as String;
    } else if (data is Map && data['message'] is String) {
      message = data['message'] as String;
    } else if (error.message != null && error.message!.isNotEmpty) {
      message = error.message!;
    }

    return ApiException(
      message: message,
      statusCode: response?.statusCode,
      data: data,
    );
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
