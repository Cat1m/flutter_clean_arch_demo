import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:reqres_in/src/core/network/models/log_mode.dart';

class LoggerInterceptor extends Interceptor {
  // ✅ Cho phép config từ constructor thay vì hardcode
  final LogMode requestMode;
  final LogMode responseMode;
  final int maxLogLength;
  final bool enabled;
  final String logName;

  LoggerInterceptor({
    this.requestMode = LogMode.full,
    this.responseMode = LogMode.short,
    this.maxLogLength = 300,
    this.enabled = true,
    this.logName = 'Dio',
  });

  // ✅ Named constructors cho các use cases phổ biến
  LoggerInterceptor.production()
    : requestMode = LogMode.oneLine,
      responseMode = LogMode.oneLine,
      maxLogLength = 100,
      enabled = false,
      logName = 'Dio';

  LoggerInterceptor.development()
    : requestMode = LogMode.full,
      responseMode = LogMode.short,
      maxLogLength = 500,
      enabled = true,
      logName = 'Dio';

  LoggerInterceptor.debug()
    : requestMode = LogMode.full,
      responseMode = LogMode.full,
      maxLogLength = 0, // No limit
      enabled = true,
      logName = 'Dio';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enabled) return handler.next(options);

    // Lưu thời gian bắt đầu
    options.extra['start_time'] = DateTime.now().millisecondsSinceEpoch;

    if (requestMode == LogMode.oneLine) {
      _log('🚀 [REQ] ${options.method} ${options.uri}');
    } else if (requestMode == LogMode.short) {
      _log('🚀 [REQ] ${options.method} ${options.uri}');
      _logHeaders(options.headers, onlyToken: true);
      _logBody(options.data);
    } else if (requestMode == LogMode.full) {
      _log('🚀 [REQUEST] ${options.method} ${options.uri}');
      _logHeaders(options.headers, onlyToken: false);
      _logQueryParameters(options.queryParameters);
      _logBody(options.data);
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!enabled) return handler.next(response);

    final startTime = response.requestOptions.extra['start_time'] as int?;
    final duration = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : 0;

    final status = response.statusCode;
    final icon = (status != null && status >= 200 && status < 300) ? '✅' : '⚠️';
    final basicMsg =
        '$icon [RES] $status ${response.requestOptions.uri} (${duration}ms)';

    if (responseMode == LogMode.oneLine) {
      _log(basicMsg);
    } else if (responseMode == LogMode.short) {
      _log(basicMsg);
      _logBody(response.data, limit: maxLogLength);
    } else if (responseMode == LogMode.full) {
      _log(basicMsg);
      _logResponseHeaders(response.headers);
      _logBody(response.data);
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled) return handler.next(err);

    final startTime = err.requestOptions.extra['start_time'] as int?;
    final duration = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : 0;

    _log(
      '❌ [ERR] ${err.requestOptions.method} ${err.requestOptions.uri} (${duration}ms)',
    );
    _log('Type: ${err.type.name}');
    _log('Message: ${err.message}');

    if (err.response != null && responseMode != LogMode.oneLine) {
      _log('Status: ${err.response?.statusCode}');
      _logBody(err.response?.data);
    }

    // ✅ Log stacktrace trong debug mode
    // ignore: unnecessary_null_comparison
    if (responseMode == LogMode.full && err.stackTrace != null) {
      _log('StackTrace: ${err.stackTrace}');
    }

    return handler.next(err);
  }

  // ---------------------------------------------------------------------------
  // 🛠️ HELPER FUNCTIONS
  // ---------------------------------------------------------------------------

  void _log(String message) {
    dev.log(message, name: logName);
  }

  void _logHeaders(Map<String, dynamic> headers, {required bool onlyToken}) {
    if (headers.isEmpty) return;

    if (onlyToken) {
      final authKeys = ['Authorization', 'authorization', 'auth-token'];
      for (final key in authKeys) {
        if (headers.containsKey(key)) {
          _log('🔑 Token: ${headers[key]}');
          return;
        }
      }
    } else {
      _log('📂 Headers:');
      headers.forEach((key, value) {
        _log('  $key: $value');
      });
    }
  }

  // ✅ Log query parameters
  void _logQueryParameters(Map<String, dynamic> params) {
    if (params.isEmpty) return;
    _log('🔍 Query Parameters: $params');
  }

  // ✅ Log response headers
  void _logResponseHeaders(Headers headers) {
    if (headers.map.isEmpty) return;
    _log('📋 Response Headers:');
    headers.forEach((key, values) {
      _log('  $key: ${values.join(', ')}');
    });
  }

  void _logBody(dynamic data, {int? limit}) {
    if (data == null) return;

    final String prettyStr = _prettyJson(data);

    if (limit != null && limit > 0 && prettyStr.length > limit) {
      final truncated = prettyStr.substring(0, limit);
      _log('📦 Body (Truncated): $truncated... [${prettyStr.length} chars]');
    } else {
      _log('📦 Body: $prettyStr');
    }
  }

  String _prettyJson(dynamic json) {
    if (json == null) return 'null';
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }
}
