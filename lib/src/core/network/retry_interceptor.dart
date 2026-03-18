// lib/core/network/retry_interceptor.dart

import 'dart:developer' as dev;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'network_service.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio; // Dùng chính Dio gốc để retry qua cùng interceptor chain
  final NetworkService? _networkService;
  final int maxRetries;
  final Duration retryDelay;
  final List<int> retryableStatusCodes;
  final List<DioExceptionType> retryableExceptionTypes;

  RetryInterceptor({
    required this.dio,
    NetworkService? networkService,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.retryableExceptionTypes = const [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ],
  }) : _networkService = networkService;

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
      dev.log(
        '⚠️ Retrying ($newRetryCount/$maxRetries): ${err.requestOptions.uri}',
        name: 'RetryInterceptor',
      );
    }

    // Delay (Exponential backoff: 1s, 2s, 4s, ...)
    final delay = retryDelay * (1 << (newRetryCount - 1));
    await Future.delayed(delay);

    try {
      // ✅ Dùng chính Dio gốc để retry → đi qua đầy đủ interceptor chain
      // (Auth, Token, Logger, Error). fetch() nhận thẳng RequestOptions.
      final response = await dio.fetch(err.requestOptions);

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

    // Skip retry nếu đã biết chắc offline (tránh chờ vô ích)
    if (_networkService != null && !_networkService.lastKnownStatus) {
      if (kDebugMode) {
        dev.log(
          '⏭️ Skip retry — device offline',
          name: 'RetryInterceptor',
        );
      }
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
