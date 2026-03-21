// lib/core/network/error_interceptor.dart

import 'dart:developer' as dev;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../error/error_event.dart';
import '../error/error_event_service.dart';
import '../error/error_severity.dart';
import 'network.dart';

class ErrorInterceptor extends Interceptor {
  // Config keys
  final NetworkService? _networkService;
  final ErrorEventService? _errorEventService;
  final List<int> authFailureStatusCodes;
  final List<String> messageKeys;
  final List<String> errorCodeKeys;

  ErrorInterceptor({
    NetworkService? networkService,
    ErrorEventService? errorEventService,
    this.authFailureStatusCodes = const [401, 403],
    this.messageKeys = const ['message', 'error', 'description', 'detail'],
    this.errorCodeKeys = const ['code', 'error_code', 'errorCode'],
  })  : _networkService = networkService,
        _errorEventService = errorEventService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Nếu đã biết chắc offline (từ request trước fail) → reject ngay, không gửi request
    // → Tránh chờ 15s timeout vô ích cho các request tiếp theo.
    // Request đầu tiên khi mất mạng vẫn phải chờ (vì chưa biết offline).
    final networkService = _networkService;
    if (networkService != null && !networkService.lastKnownStatus) {
      if (kDebugMode) {
        dev.log(
          '⏭️ Fast-fail: device offline — ${options.method} ${options.uri}',
          name: 'ErrorInterceptor',
        );
      }
      final error = DioException(
        requestOptions: options,
        error: const ConnectionFailure('No Internet Connection'),
        type: DioExceptionType.connectionError,
      );
      return handler.reject(error);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Request thành công = chắc chắn online
    _networkService?.reportConnectionSuccess();
    handler.next(response);
  }

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

      DioExceptionType.badCertificate => const CertificateFailure(
        'Bad Certificate',
      ),

      // Khi mobile data bật nhưng không có internet thực tế,
      // Dio wrap SocketException thành DioExceptionType.unknown
      // (vì OS báo network interface vẫn UP).
      // → Cần kiểm tra err.error bên trong để phân loại chính xác.
      DioExceptionType.unknown => _handleUnknownError(err),
    };

    // Đồng bộ trạng thái mạng khi phát hiện lỗi kết nối
    if (failure is ConnectionFailure) {
      _networkService?.reportConnectionFailure();
    }

    // Auto-emit cross-cutting errors lên Error Bus
    _maybeEmitToErrorBus(failure);

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

  /// Phân loại lỗi [DioExceptionType.unknown].
  ///
  /// Khi mobile data bật nhưng không có internet thực tế, Dio vẫn cố gửi
  /// request (vì OS báo interface UP). Kết quả:
  /// - [SocketException]: TCP connection fail (Network unreachable, Connection refused)
  /// - [HandshakeException]: TCP OK nhưng TLS handshake fail (packets mất giữa chừng)
  /// - [HttpException]: Connection reset sau khi HTTP bắt đầu
  ///
  /// Tất cả đều kế thừa [IOException], và Dio đã handle [badCertificate]
  /// riêng → nên check [IOException] an toàn, cover mọi case network.
  Failure _handleUnknownError(DioException err) {
    final error = err.error;

    // Debug log để xem chính xác error type
    if (kDebugMode) {
      dev.log(
        '🔍 Unknown error details:\n'
        '   runtimeType: ${error.runtimeType}\n'
        '   error: $error\n'
        '   message: ${err.message}',
        name: 'ErrorInterceptor',
      );
    }

    // HandshakeException chứa "CERTIFICATE" → lỗi certificate, không phải mạng.
    // Khi badCertificateCallback trả false, HttpClient throw HandshakeException
    // với osError chứa "CERTIFICATE_VERIFY_FAILED" — Dio wrap thành unknown.
    // Dùng toString() vì certificate info nằm trong osError, không phải message.
    if (error is HandshakeException &&
        error.toString().toUpperCase().contains('CERTIFICATE')) {
      return const CertificateFailure('Bad Certificate');
    }

    // IOException bao gồm: SocketException, HandshakeException (non-cert),
    // HttpException, TlsException — tất cả đều là lỗi kết nối.
    if (error is IOException) {
      return const ConnectionFailure('No Internet Connection');
    }

    return UnknownFailure(
      'Unknown Error: ${err.message ?? "No details"}',
      errorObject: error,
    );
  }

  /// Auto-emit cross-cutting errors lên Error Bus.
  ///
  /// Mapping:
  /// - [ConnectionFailure] → warning (snackbar)
  /// - [AuthFailure] → fatal (LoginCubit listen → GoRouter redirect)
  /// - [ServerFailure] 500/503 → critical (dialog)
  /// - Các loại khác → không emit (cubit/repo tự handle)
  void _maybeEmitToErrorBus(Failure failure) {
    final errorEventService = _errorEventService;
    if (errorEventService == null) return;

    final ErrorSeverity? severity = switch (failure) {
      ConnectionFailure() => ErrorSeverity.warning,
      AuthFailure() => ErrorSeverity.fatal,
      CertificateFailure() => ErrorSeverity.critical,
      ServerFailure(statusCode: 500 || 503) => ErrorSeverity.critical,
      _ => null,
    };

    if (severity != null) {
      errorEventService.emit(
        ErrorEvent(
          failure: failure,
          severity: severity,
          source: 'ErrorInterceptor',
        ),
      );
    }
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
