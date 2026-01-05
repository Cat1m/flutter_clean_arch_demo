import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/network/models/auth_type.dart';
import 'package:reqres_in/src/core/storage/secure_storage_service.dart';

@lazySingleton
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService;

  AuthInterceptor(this._storageService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Lấy config auth_type từ request (mặc định là userToken nếu không set)
    final authType =
        options.extra['auth_type'] as AuthType? ?? AuthType.userToken;

    switch (authType) {
      case AuthType.userToken:
        // Lấy token từ bộ nhớ an toàn
        final token = await _storageService.getUserToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        break;

      case AuthType.apiKey:
        // Nếu dự án có dùng API Key
        // options.headers['x-api-key'] = Env.apiKey;
        break;

      case AuthType.none:
        // Không làm gì cả
        break;
    }

    return handler.next(options);
  }
}
