// lib/core/network/error_interceptor.dart

import 'package:dio/dio.dart';
import 'package:reqres_in/src/core/network/failures.dart';

class ErrorInterceptor extends Interceptor {
  // ✅ Config để linh hoạt hơn, không hardcode
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
    // [Như]: Đổi message sang Technical English (để Log).
    // Việc hiển thị tiếng Việt sẽ do Extension lo.
    final Failure failure = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const ConnectionFailure(
        'Connection Timeout',
      ),

      DioExceptionType.connectionError => const ConnectionFailure(
        'No Internet Connection',
      ),

      // Bad Response giữ nguyên logic handle
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

    // ✅ Check Auth failure dựa trên config
    if (authFailureStatusCodes.contains(statusCode)) {
      return AuthFailure('Unauthorized ($statusCode)', statusCode: statusCode);
    }

    // ✅ Extract message và errorCode linh hoạt hơn
    String message = 'Server Error ($statusCode)';
    String? errorCode;

    if (data is Map<String, dynamic>) {
      // Try multiple keys for message
      message = _extractFirstValue(data, messageKeys) ?? message;

      // Try multiple keys for error code
      errorCode = _extractFirstValue(data, errorCodeKeys);
    } else if (data is String) {
      // Nếu backend trả về string thẳng
      message = data;
    }

    return ServerFailure(message, statusCode: statusCode, errorCode: errorCode);
  }

  // ✅ Helper để extract value từ nhiều possible keys
  String? _extractFirstValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null) {
        return value.toString();
      }
    }
    return null;
  }
}
