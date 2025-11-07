import 'package:dio/dio.dart';
import 'package:reqres_in/src/core/env/env.dart';

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

    // Thêm Interceptors
    _dio!.interceptors.addAll([
      // API Key Interceptor
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['x-api-key'] = Env.apiKey;
          return handler.next(options);
        },
      ),
      // Log Interceptor (nên tắt khi release)
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false, // Tắt bớt cho đỡ rối log nếu không cần thiết
      ),
    ]);

    return _dio!;
  }
}
