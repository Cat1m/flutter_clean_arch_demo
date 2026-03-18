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

  // Logger (null hoặc disabled = không add vào chain)
  final LoggerInterceptor? logger;

  // Network status service (phối hợp connectivity_plus + Dio)
  final NetworkService? networkService;

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
    this.logger,
    this.networkService,
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

    // 2. Add RetryInterceptor (nếu enable) - Truyền dio gốc để retry qua interceptor chain
    if (enableRetry) {
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          networkService: networkService,
          maxRetries: maxRetries,
          retryDelay: retryDelay,
        ),
      );
    }

    // 3. Add LoggerInterceptor (chỉ khi được cung cấp và enabled)
    if (logger case final l? when l.enabled) {
      dio.interceptors.add(l);
    }

    // 4. Add ErrorInterceptor (Luôn nằm cuối cùng để catch & transform errors)
    // Nhận NetworkService để đồng bộ trạng thái mạng từ Dio response/error
    dio.interceptors.add(ErrorInterceptor(networkService: networkService));

    return dio;
  }
}
