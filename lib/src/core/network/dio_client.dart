import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:reqres_in/src/core/network/error_interceptor.dart';
import 'package:reqres_in/src/core/network/models/env_mode.dart';

class DioClient {
  Dio? _dio;

  final String baseUrl;
  final List<Interceptor> interceptors;

  // ---------------------------------------------------------------------------
  // 🔧 CẤU HÌNH MÔI TRƯỜNG (Developer Config)
  // ---------------------------------------------------------------------------

  // 1. CHỌN MODE Ở ĐÂY (Sửa dòng này để đổi môi trường)
  static const EnvMode _currentMode = EnvMode.prod;

  // 2. KHAI BÁO CÁC URL TEST (Chỉ dùng khi Debug)
  static const Map<EnvMode, String> _devUrls = {
    EnvMode.dev: 'https://dev-api.reqres.in',
    EnvMode.localAndroid: 'http://10.0.2.2:8080',
    EnvMode.localIos: 'http://localhost:8080',
    EnvMode.ngrok: 'https://ca32-14-232-123.ngrok-free.app',
  };

  // ---------------------------------------------------------------------------

  DioClient({required this.baseUrl, this.interceptors = const []});

  Dio get dio {
    if (_dio != null) return _dio!;

    // 🎯 LOGIC CHỌN URL AN TOÀN TUYỆT ĐỐI
    String finalUrl = baseUrl; // Mặc định là Prod (Env)

    // Chỉ cho phép đổi URL nếu đang chạy DEBUG
    if (kDebugMode && _currentMode != EnvMode.prod) {
      final devUrl = _devUrls[_currentMode];

      if (devUrl != null && devUrl.isNotEmpty) {
        finalUrl = devUrl;
        if (kDebugMode) {
          print(
            '⚠️⚠️⚠️ [WARNING] ĐANG CHẠY MÔI TRƯỜNG: ${_currentMode.name.toUpperCase()} ⚠️⚠️⚠️',
          );
        }
        if (kDebugMode) {
          print('👉 URL: $finalUrl');
        }
      }
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: finalUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    _dio!.interceptors.addAll(interceptors);

    if (!_dio!.interceptors.any((e) => e is ErrorInterceptor)) {
      _dio!.interceptors.add(ErrorInterceptor());
    }

    return _dio!;
  }
}
