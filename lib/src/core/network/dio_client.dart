// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';

import 'network.dart';

class DioClient {
  // ✅ Dùng late final để đảm bảo chỉ khởi tạo 1 lần duy nhất
  late final Dio dio = _createDio();

  final String baseUrl;
  final List<Interceptor> interceptors;

  // Config options
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final String contentType;

  // Config cho retry
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

  // ✅ Private factory method - Clean & Direct
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

    // 1. Add custom interceptors từ bên ngoài (nếu có)
    dio.interceptors.addAll(interceptors);

    // 2. Add RetryInterceptor (nếu enable) - Ưu tiên chạy sớm để handle retry
    if (enableRetry) {
      dio.interceptors.add(
        RetryInterceptor(maxRetries: maxRetries, retryDelay: retryDelay),
      );
    }

    // 3. Add LoggerInterceptor (Luôn có để debug dễ dàng)
    dio.interceptors.add(LoggerInterceptor());

    // 4. Add ErrorInterceptor (Luôn nằm cuối cùng để catch & transform errors)
    dio.interceptors.add(ErrorInterceptor());

    return dio;
  }
}
