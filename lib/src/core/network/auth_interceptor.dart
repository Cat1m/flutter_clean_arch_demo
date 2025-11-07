// lib/core/network/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:reqres_in/src/core/env/env.dart';
import '../storage/secure_storage_service.dart';
import 'auth_type.dart';

class AuthInterceptor extends Interceptor {
  // 1. Thay vì tự tạo, hãy "nhận" service từ bên ngoài
  final SecureStorageService _storageService;

  // 2. Đây là constructor
  AuthInterceptor(this._storageService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Đổi tên AuthType theo ý bạn nhé (ví dụ: userToken, apiKey, none)
    final authType = options.extra['auth_type'] as AuthType? ?? AuthType.apiKey;

    switch (authType) {
      // Case 1: Cần token user (userToken)
      case AuthType.userToken:
        // 3. Đọc token từ service đã được "tiêm" vào
        final userToken = await _storageService.getUserToken();

        if (userToken != null) {
          options.headers['Authorization'] = 'Bearer $userToken';
        }
        // Thêm cả api-key nếu cần
        options.headers['x-api-key'] = Env.apiKey;
        break;

      // Case 2: Chỉ cần API Key (apiKey)
      case AuthType.apiKey:
        options.headers['x-api-key'] = Env.apiKey;
        break;

      // Case 3: Không cần gì cả (none)
      case AuthType.none:
        break;
    }

    return handler.next(options);
  }
}
