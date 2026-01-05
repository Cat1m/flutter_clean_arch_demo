import 'package:dio/dio.dart';
import 'package:reqres_in/src/core/network/error_interceptor.dart';
import 'package:reqres_in/src/core/network/logger_interceptor.dart';
import 'package:reqres_in/src/core/network/retry_interceptor.dart';

class DioClient {
  // ✅ Dùng late final thay vì nullable + getter
  // -> Đảm bảo chỉ khởi tạo 1 lần duy nhất
  late final Dio dio = _createDio();

  final String baseUrl;
  final List<Interceptor> interceptors;

  // ✅ Thêm config options để linh hoạt hơn
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final String contentType;

  // ✅ Config cho retry
  final bool enableRetry;
  final int maxRetries;
  final Duration retryDelay;

  DioClient({
    required this.baseUrl,
    this.interceptors = const [],
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.contentType = 'application/json',
    this.enableRetry = false,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  // ✅ Private factory method - clean và testable
  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        contentType: contentType,
      ),
    );

    // 1. Add custom interceptors trước (để có thể override behavior)
    dio.interceptors.addAll(interceptors);

    // 2. Add RetryInterceptor nếu được bật (phải ở trước ErrorInterceptor)
    if (enableRetry) {
      _addInterceptorIfNotExists<RetryInterceptor>(
        dio,
        RetryInterceptor(maxRetries: maxRetries, retryDelay: retryDelay),
      );
    }

    // 3. Add LoggerInterceptor nếu chưa có
    _addInterceptorIfNotExists<LoggerInterceptor>(dio, LoggerInterceptor());

    // 4. Add ErrorInterceptor ở cuối (để catch tất cả errors)
    _addInterceptorIfNotExists<ErrorInterceptor>(dio, ErrorInterceptor());

    return dio;
  }

  // ✅ Helper method để tránh duplicate interceptors
  void _addInterceptorIfNotExists<T extends Interceptor>(
    Dio dio,
    T interceptor,
  ) {
    if (!dio.interceptors.any((e) => e.runtimeType == T)) {
      dio.interceptors.add(interceptor);
    }
  }

  // ✅ Utility method để clear và rebuild Dio (dùng khi cần refresh config)
  void rebuild() {
    // Force rebuild bằng cách tạo exception nếu đã init
    throw UnsupportedError(
      'DioClient cannot be rebuilt. Create a new instance instead.',
    );
  }
}
