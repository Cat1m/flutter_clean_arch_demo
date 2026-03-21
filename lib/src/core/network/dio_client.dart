// lib/core/network/dio_client.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../error/error_event_service.dart';
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

  // Error Bus service (auto-emit cross-cutting errors)
  final ErrorEventService? errorEventService;

  // Config cho SSL/TLS certificate
  // allowBadCertificate: Cho phép self-signed cert (dev/staging). Mặc định: false
  final bool allowBadCertificate;

  // trustedCertificates: Danh sách PEM bytes để pin certificate cụ thể (enterprise/internal CA)
  final List<Uint8List> trustedCertificates;

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
    this.errorEventService,
    this.allowBadCertificate = false,
    this.trustedCertificates = const [],
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

    // 0. Config SSL/TLS certificate (chỉ áp dụng cho native platform - mobile/desktop)
    //
    // LUÔN set badCertificateCallback để Dio phân loại chính xác:
    // - Có callback trả false → DioExceptionType.badCertificate → CertificateFailure
    // - Không có callback → HandshakeException → DioExceptionType.unknown → ConnectionFailure (sai!)
    //
    // Khi allowBadCertificate = true: callback trả true → cert được chấp nhận
    // Khi allowBadCertificate = false: callback trả false → Dio throw badCertificate
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        // Nếu có trusted certificates → tạo SecurityContext custom
        if (trustedCertificates.isNotEmpty) {
          final context = SecurityContext();
          for (final cert in trustedCertificates) {
            context.setTrustedCertificatesBytes(cert);
          }
          return HttpClient(context: context)
            ..badCertificateCallback = (cert, host, port) =>
                allowBadCertificate;
        }

        return HttpClient()
          ..badCertificateCallback = (cert, host, port) => allowBadCertificate;
      },
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
    dio.interceptors.add(
      ErrorInterceptor(
        networkService: networkService,
        errorEventService: errorEventService,
      ),
    );

    return dio;
  }
}
