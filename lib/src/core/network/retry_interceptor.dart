// lib/core/network/retry_interceptor.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
    final retryCount = err.requestOptions.extra['retry_count'] as int? ?? 0;

    // Check điều kiện retry
    if (!_shouldRetry(err, retryCount)) {
      return handler.next(err);
    }

    final newRetryCount = retryCount + 1;
    err.requestOptions.extra['retry_count'] = newRetryCount;

    // Log warning ở chế độ debug
    if (kDebugMode) {
      print(
        '⚠️ [RetryInterceptor] Retrying ($newRetryCount/$maxRetries): ${err.requestOptions.uri}',
      );
    }

    // Delay (Exponential backoff)
    final delay = retryDelay * newRetryCount;
    await Future.delayed(delay);

    try {
      // ✅ FIX CRITICAL: Tạo Dio instance mới nhưng COPY toàn bộ config cũ.
      // Việc này đảm bảo Headers (Token), Timeouts, và BaseUrl được bảo toàn.
      final retryDio = Dio(
        BaseOptions(
          baseUrl: err.requestOptions.baseUrl,
          connectTimeout: err.requestOptions.connectTimeout,
          receiveTimeout: err.requestOptions.receiveTimeout,
          sendTimeout: err.requestOptions.sendTimeout,
          contentType: err.requestOptions.contentType,
          headers: err.requestOptions.headers, // Quan trọng: Giữ lại Token
          responseType: err.requestOptions.responseType,
        ),
      );

      // Thực hiện lại request với các tham số cũ
      final response = await retryDio.request(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        cancelToken: err.requestOptions.cancelToken,
        onSendProgress: err.requestOptions.onSendProgress,
        onReceiveProgress: err.requestOptions.onReceiveProgress,
        options: Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers, // Double check headers
        ),
      );

      // Nếu thành công, resolve trả về luồng chính
      return handler.resolve(response);
    } on DioException catch (e) {
      // Nếu retry vẫn lỗi, trả về lỗi đó cho UI handle
      return handler.next(e);
    } catch (e) {
      // Catch các lỗi khác (parsing, v.v.)
      return handler.next(
        DioException(requestOptions: err.requestOptions, error: e),
      );
    }
  }

  /// Kiểm tra xem lỗi có thuộc diện được retry hay không
  bool _shouldRetry(DioException err, int retryCount) {
    if (retryCount >= maxRetries) {
      return false;
    }

    // 1. Check theo loại Exception (Timeout, Connection Error)
    if (retryableExceptionTypes.contains(err.type)) {
      return true;
    }

    // 2. Check theo Status Code (Server Errors)
    final statusCode = err.response?.statusCode;
    if (statusCode != null && retryableStatusCodes.contains(statusCode)) {
      return true;
    }

    // 3. Check SocketException (Mất mạng hẳn)
    if (err.error is SocketException) {
      return true;
    }

    return false;
  }
}
