import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/network/models/log_mode.dart';

@lazySingleton
class LoggerInterceptor extends Interceptor {
  // ---------------------------------------------------------------------------
  // 🔧 CẤU HÌNH LINH HOẠT TẠI ĐÂY
  // ---------------------------------------------------------------------------

  // Config cho chiều ĐI (Request)
  final LogMode _requestMode = LogMode.full; // .oneLine, .short, .full

  // Config cho chiều VỀ (Response)
  final LogMode _responseMode = LogMode.short; // .oneLine, .short, .full

  // Config giới hạn ký tự cho chế độ Short
  final int _maxLogLength = 300;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Lưu thời gian bắt đầu
    options.extra['start_time'] = DateTime.now().millisecondsSinceEpoch;

    if (_requestMode == LogMode.oneLine) {
      _log('🚀 [REQ] ${options.method} ${options.uri}');
    } else if (_requestMode == LogMode.short) {
      _log('🚀 [REQ] ${options.method} ${options.uri}');
      _logHeaders(options.headers, onlyToken: true); // Short: Chỉ soi Token
      _logBody(options.data);
    } else if (_requestMode == LogMode.full) {
      _log('🚀 [REQUEST] ${options.method} ${options.uri}');
      _logHeaders(options.headers, onlyToken: false); // Full: Soi hết Header
      _logBody(options.data);
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['start_time'] as int?;
    final duration = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : 0;

    final status = response.statusCode;
    final icon = (status != null && status >= 200 && status < 300) ? '✅' : '⚠️';
    final basicMsg =
        '$icon [RES] $status ${response.requestOptions.uri} (${duration}ms)';

    if (_responseMode == LogMode.oneLine) {
      _log(basicMsg);
    } else if (_responseMode == LogMode.short) {
      _log(basicMsg);
      // Short: Cắt ngắn body response
      _logBody(response.data, limit: _maxLogLength);
    } else if (_responseMode == LogMode.full) {
      _log(basicMsg);
      // Full: Hiện nguyên hình
      _logBody(response.data);
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Lỗi thì thường nên để Full hoặc Short để debug,
    // ở đây Như để nó follow theo _responseMode cho nhất quán.
    final startTime = err.requestOptions.extra['start_time'] as int?;
    final duration = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : 0;

    _log(
      '❌ [ERR] ${err.requestOptions.method} ${err.requestOptions.uri} (${duration}ms)',
    );
    _log('Message: ${err.message}');

    if (err.response != null) {
      // Nếu response mode là oneLine thì thôi khỏi in body lỗi cho gọn
      if (_responseMode != LogMode.oneLine) {
        _logBody(err.response?.data);
      }
    }

    return handler.next(err);
  }

  // ---------------------------------------------------------------------------
  // 🛠️ HELPER FUNCTIONS
  // ---------------------------------------------------------------------------

  void _log(String message) {
    dev.log(message, name: 'Dio');
  }

  void _logHeaders(Map<String, dynamic> headers, {required bool onlyToken}) {
    if (headers.isEmpty) return;

    if (onlyToken) {
      if (headers.containsKey('Authorization')) {
        _log('🔑 Token: ${headers['Authorization']}');
      }
    } else {
      _log('📂 Headers: $headers');
    }
  }

  void _logBody(dynamic data, {int? limit}) {
    if (data == null) return;

    final String prettyStr = _prettyJson(data);

    if (limit != null && prettyStr.length > limit) {
      final truncated = prettyStr.substring(0, limit);
      _log('📦 Body (Truncated): $truncated ... [See Full Mode for more]');
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
