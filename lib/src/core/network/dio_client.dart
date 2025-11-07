import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:reqres_in/src/core/di/injection.dart';

import 'package:reqres_in/src/core/env/env.dart';
import 'package:reqres_in/src/core/network/auth_interceptor.dart';
import 'package:reqres_in/src/core/network/error_interceptor.dart';
// ignore: unused_import
import 'package:reqres_in/src/core/network/token_interceptor.dart';
import 'package:reqres_in/src/core/storage/secure_storage_service.dart';

class DioClient {
  // Singleton pattern (tùy chọn, nhưng tốt cho DioClient)
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  Dio? _dio;

  Dio get dio {
    if (_dio != null) return _dio!;

    _dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    final storageService = getIt<SecureStorageService>();

    _dio!.interceptors.addAll([
      // 1. AuthInterceptor: Luôn gắn token cho mọi request (chạy đầu)
      AuthInterceptor(storageService),

      // 2. TokenInterceptor: (TÙY CHỌN)
      //    Chỉ bắt lỗi 401 để refresh (chạy sau Auth)
      TokenInterceptor(storageService),

      // 3. ErrorInterceptor: Bắt tất cả lỗi CÒN LẠI (404, 500,...)
      ErrorInterceptor(),
    ]);

    if (kDebugMode) {
      _dio!.interceptors.add(
        PrettyDioLogger(
          requestHeader: false, // Tắt log Header
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          // compact: true, // In log gọn hơn
          // maxWidth: 90, // Chiều rộng tối đa của log
        ),
      );
    }

    return _dio!;
  }
}
