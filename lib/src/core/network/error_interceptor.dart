// lib/core/network/error_interceptor.dart

import 'package:dio/dio.dart';

import 'network.dart';

class ErrorInterceptor extends Interceptor {
  // Config keys
  final List<int> authFailureStatusCodes;
  final List<String> messageKeys;
  final List<String> errorCodeKeys;

  ErrorInterceptor({
    this.authFailureStatusCodes = const [401, 403],
    this.messageKeys = const ['message', 'error', 'description', 'detail'],
    this.errorCodeKeys = const ['code', 'error_code', 'errorCode'],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Convert DioException -> Failure
    final Failure failure = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const ConnectionFailure(
        'Connection Timeout',
      ),

      DioExceptionType.connectionError => const ConnectionFailure(
        'No Internet Connection',
      ),

      DioExceptionType.badResponse => _handleBadResponse(err.response),

      DioExceptionType.cancel => const UnknownFailure('Request Cancelled'),

      DioExceptionType.badCertificate => const UnknownFailure(
        'Bad Certificate',
      ),

      DioExceptionType.unknown => UnknownFailure(
        'Unknown Error: ${err.message ?? "No details"}',
        errorObject: err.error,
      ),
    };

    // Reject với error mới là Failure
    final newErr = DioException(
      requestOptions: err.requestOptions,
      error: failure,
      type: err.type,
      response: err.response,
      stackTrace: err.stackTrace,
    );

    return handler.reject(newErr);
  }

  Failure _handleBadResponse(Response? response) {
    final int statusCode = response?.statusCode ?? 0;
    final dynamic data = response?.data;

    // 1. Check Auth Failure
    if (authFailureStatusCodes.contains(statusCode)) {
      return AuthFailure('Unauthorized ($statusCode)', statusCode: statusCode);
    }

    // 2. Extract Server Error Message
    String message = 'Server Error ($statusCode)';
    String? errorCode;

    if (data is Map<String, dynamic>) {
      message = _extractFirstValue(data, messageKeys) ?? message;
      errorCode = _extractFirstValue(data, errorCodeKeys);
    } else if (data is String) {
      message = data;
    }

    return ServerFailure(message, statusCode: statusCode, errorCode: errorCode);
  }

  // ✅ REFACTOR: Sử dụng Dart 3 Pattern Matching
  // Thay vì check null thủ công, ta dùng case check + guard clause
  String? _extractFirstValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      // Nếu data[key] khác null (gán vào val) VÀ val convert string không rỗng
      if (data[key] case final val? when val.toString().trim().isNotEmpty) {
        return val.toString();
      }
    }
    return null;
  }
}
