// lib/core/network/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:reqres_in/src/core/env/env.dart';
import 'auth_type.dart'; // <-- Import enum của chúng ta

// TODO: Thay thế bằng service lưu trữ thật (ví dụ: SharedPreferences)
class MockTokenStorage {
  Future<String?> getUserToken() async {
    // Đây là nơi bạn gọi SharedPreferences.getInstance()...
    // Giả lập là chúng ta có token này sau khi login
    return 'QpwL5tke4Pnpja7X4_USER_TOKEN';
  }
}

class AuthInterceptor extends Interceptor {
  final MockTokenStorage _tokenStorage = MockTokenStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Đọc "nhãn" mà chúng ta đã dán trong api_service.dart
    // Dùng .extra['auth_type']
    final authType =
        options.extra['auth_type'] as AuthType? ??
        AuthType.public; // Mặc định là 'public' nếu không dán nhãn

    // Quyết định gắn header dựa trên nhãn
    switch (authType) {
      // Case 1: Cần token user
      case AuthType.user:
        // Lấy token user (từ SharedPreferences, SecureStorage...)
        final userToken = await _tokenStorage.getUserToken();
        if (userToken != null) {
          options.headers['Authorization'] = 'Bearer $userToken';
        }
        // HỎI BACKEND: Endpoint này có cần cả x-api-key không?
        // Nếu có, thêm dòng này:
        // options.headers['x-api-key'] = Env.apiKey;
        break;

      // Case 2: Chỉ cần API Key (vé vào cổng)
      case AuthType.public:
        options.headers['x-api-key'] = Env.apiKey;
        break;

      // Case 3: Không cần gì cả (Login/Register)
      case AuthType.none:
        // Không làm gì cả
        break;
    }

    // Cho request đi tiếp
    return handler.next(options);
  }
}
