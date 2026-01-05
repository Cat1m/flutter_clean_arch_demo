import 'package:dio/dio.dart';
import 'error_interceptor.dart';

/// Class quản lý cấu hình Dio cơ bản.
/// Class này KHÔNG biết gì về Auth hay Token. Nó nhận các Interceptor từ bên ngoài (DI).
class DioClient {
  Dio? _dio;

  final String baseUrl;
  final List<Interceptor> interceptors;

  /// [baseUrl]: Đường dẫn gốc của API.
  /// [interceptors]: Danh sách các interceptor tùy chỉnh (Auth, Log, v.v...) được inject từ DI.
  DioClient({required this.baseUrl, this.interceptors = const []});

  Dio get dio {
    if (_dio != null) return _dio!;

    // 1. Cấu hình cơ bản (Timeout, Content-Type)
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    // 2. Add các Interceptor từ bên ngoài vào (Ví dụ: AuthInterceptor)
    _dio!.interceptors.addAll(interceptors);

    // 3. Luôn add ErrorInterceptor (Core requirement) để map lỗi ra Failure
    if (!_dio!.interceptors.any((e) => e is ErrorInterceptor)) {
      _dio!.interceptors.add(ErrorInterceptor());
    }

    // // 4. Cấu hình Logger (Chỉ bật khi Debug)
    // if (kDebugMode) {
    //   _dio!.interceptors.add(
    //     InterceptorsWrapper(
    //       onRequest: (options, handler) {
    //         log('--- DIO [${options.method}] -> ${options.uri}');
    //         return handler.next(options);
    //       },
    //     ),
    //   );

    //   _dio!.interceptors.add(
    //     PrettyDioLogger(
    //       requestHeader: false, // Tắt bớt cho đỡ rối
    //       requestBody: true,
    //       responseBody: true,
    //       responseHeader: false,
    //       error: true,
    //       compact: true,
    //     ),
    //   );
    // }

    return _dio!;
  }
}
