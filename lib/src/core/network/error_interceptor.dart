// lib/core/network/error_interceptor.dart

import 'package:dio/dio.dart';
import 'package:reqres_in/src/core/network/failures.dart';

class ErrorInterceptor extends Interceptor {
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

      DioExceptionType.unknown => const UnknownFailure('Unknown Error'),
    };

    final newErr = DioException(
      requestOptions: err.requestOptions,
      error: failure,
      type: err.type,
      response: err.response,
    );

    return handler.reject(newErr);
  }

  Failure _handleBadResponse(Response? response) {
    final int statusCode = response?.statusCode ?? 0;
    final dynamic data = response?.data;

    if (statusCode == 401) {
      // Message logging thôi, không phải để hiện lên UI
      return const AuthFailure('Unauthorized (401)');
    }

    // Server trả về message gì thì mình giữ nguyên cái đó
    // Vì đôi khi Backend trả về lỗi validation cụ thể
    String message = 'Server Error ($statusCode)';
    String? errorCode;

    if (data is Map<String, dynamic>) {
      message =
          data['message'] ?? data['error'] ?? data['description'] ?? message;
      errorCode = data['code']?.toString();
    }

    return ServerFailure(message, statusCode: statusCode, errorCode: errorCode);
  }
}
