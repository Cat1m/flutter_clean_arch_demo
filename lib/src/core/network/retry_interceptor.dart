// lib/core/network/retry_interceptor.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// ✅ BONUS: Retry Interceptor để tự động retry khi gặp lỗi có thể retry được
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  final List<int> retryableStatusCodes;
  final List<DioExceptionType> retryableExceptionTypes;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.retryableExceptionTypes = const [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ],
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Lấy số lần đã retry từ extra
    final retryCount = err.requestOptions.extra['retry_count'] as int? ?? 0;

    // Check xem có nên retry không
    if (!_shouldRetry(err, retryCount)) {
      return handler.next(err);
    }

    // Tăng retry count
    final newRetryCount = retryCount + 1;
    err.requestOptions.extra['retry_count'] = newRetryCount;

    // Log retry attempt
    if (kDebugMode) {
      print(
        '🔄 Retrying request ($newRetryCount/$maxRetries): ${err.requestOptions.uri}',
      );
    }

    // Delay trước khi retry (exponential backoff)
    final delay = retryDelay * newRetryCount;
    await Future.delayed(delay);

    try {
      // Retry request
      final dio = Dio();
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      // Nếu retry vẫn fail, pass error xuống
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err, int retryCount) {
    // Không retry nếu đã vượt quá max retries
    if (retryCount >= maxRetries) {
      return false;
    }

    // Check exception type
    if (retryableExceptionTypes.contains(err.type)) {
      return true;
    }

    // Check status code
    final statusCode = err.response?.statusCode;
    if (statusCode != null && retryableStatusCodes.contains(statusCode)) {
      return true;
    }

    // Check nếu là SocketException (no internet)
    if (err.error is SocketException) {
      return true;
    }

    return false;
  }
}
