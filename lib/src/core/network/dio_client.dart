import 'dart:developer';

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
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  Dio? _dio;

  // (2) ĐỊNH NGHĨA CÔNG TẮC VÀ URL TEST
  // -----------------------------------------------------------------
  // Thay đổi URL này thành ngrok hoặc localhost của bạn
  static const String _urlDev = 'http://your-ngrok-url.ngrok.io/api';

  // ĐÂY LÀ CÔNG TẮC CỦA BẠN:
  // - true: Dùng _urlDev (chỉ khi đang debug)
  // - false: Dùng Env.baseUrl (mặc định)
  static const bool _useDevUrl = true;
  // -----------------------------------------------------------------

  Dio get dio {
    if (_dio != null) return _dio!;

    // (3) LOGIC QUYẾT ĐỊNH BASEURL
    //-----------------------------------------------------------------
    // kDebugMode sẽ là 'true' khi bạn chạy debug (F5)
    // kDebugMode sẽ là 'false' khi bạn build --release
    final String finalBaseUrl = (kDebugMode && _useDevUrl)
        ? _urlDev // 1. Ưu tiên URL test nếu đang debug VÀ công tắc bật
        : Env.baseUrl; // 2. Luôn dùng Env.baseUrl nếu là build release
    //    hoặc nếu công tắc đang tắt
    //-----------------------------------------------------------------

    _dio = Dio(
      BaseOptions(
        baseUrl: finalBaseUrl, // <-- (4) SỬ DỤNG URL CUỐI CÙNG
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    final storageService = getIt<SecureStorageService>();

    _dio!.interceptors.addAll([
      AuthInterceptor(storageService),
      TokenInterceptor(storageService),
      ErrorInterceptor(),
    ]);

    if (kDebugMode) {
      // (5) THÊM LOG ĐỂ BIẾT BẠN ĐANG DÙNG URL NÀO
      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Log này cực kỳ quan trọng
            log('--- DIO [${options.method}] -> ${options.uri}');
            return handler.next(options);
          },
        ),
      );

      _dio!.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
        ),
      );
    }

    return _dio!;
  }
}
