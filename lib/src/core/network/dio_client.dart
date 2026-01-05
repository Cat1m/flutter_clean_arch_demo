// lib/src/core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'package:reqres_in/src/core/network/error_interceptor.dart';

class DioClient {
  Dio? _dio;

  // Nhận trực tiếp, không logic rườm rà
  final String baseUrl;
  final List<Interceptor> interceptors;

  DioClient({required this.baseUrl, this.interceptors = const []});

  Dio get dio {
    if (_dio != null) return _dio!;

    // Cấu hình Dio cơ bản
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    // Add Interceptors được inject vào
    _dio!.interceptors.addAll(interceptors);

    // Luôn đảm bảo có ErrorInterceptor (nếu chưa có)
    if (!_dio!.interceptors.any((e) => e is ErrorInterceptor)) {
      _dio!.interceptors.add(ErrorInterceptor());
    }

    return _dio!;
  }
}
