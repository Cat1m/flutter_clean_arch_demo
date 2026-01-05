import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/auth/service/auth_event_service.dart';
import 'package:reqres_in/src/core/storage/secure_storage_service.dart';

/// Interceptor chuyên xử lý việc Refresh Token khi gặp lỗi 401.
/// Nó hoạt động độc lập với ApiService chính để tránh vòng lặp phụ thuộc.
@lazySingleton
class TokenInterceptor extends QueuedInterceptor {
  final SecureStorageService _storageService;
  final AuthEventService _authEventService;

  TokenInterceptor(this._storageService, this._authEventService);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Chỉ xử lý khi lỗi là 401 Unauthorized
    if (err.response?.statusCode == 401) {
      if (kDebugMode) {
        print(
          '🔒 [TokenInterceptor] Detected 401 Error. Checking refresh token...',
        );
      }

      final refreshToken = await _storageService.getRefreshToken();

      // 1. Nếu không có refresh token -> Logout ngay
      if (refreshToken == null) {
        _authEventService.notifySessionExpired();
        return handler.next(err); // Chuyền lỗi đi tiếp
      }

      try {
        // 2. Tạo một Dio mới hoàn toàn để gọi Refresh
        // Lý do: Để tránh dính các interceptor cũ (đặc biệt là chính TokenInterceptor này)
        // gây ra vòng lặp vô tận.
        final refreshDio = Dio(
          BaseOptions(
            baseUrl:
                err.requestOptions.baseUrl, // Dùng lại baseUrl của request lỗi
            headers: {
              'Content-Type': 'application/json',
              // Thêm các header cần thiết khác nếu server yêu cầu
            },
          ),
        );

        // Gọi API Refresh (Hardcode path '/auth/refresh' vì đây là logic cốt lõi của Auth)
        // Nếu path này thay đổi, sửa trực tiếp tại đây.
        if (kDebugMode) {
          print('🔄 [TokenInterceptor] Refreshing token...');
        }

        final response = await refreshDio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // 3. Parse kết quả (Giả sử trả về accessToken và refreshToken mới)
          final newAccessToken = response.data['accessToken'];
          final newRefreshToken = response.data['refreshToken']; // Có thể null

          // 4. Lưu lại vào Storage
          if (newAccessToken != null) {
            await _storageService.saveUserToken(newAccessToken);
          }
          if (newRefreshToken != null) {
            await _storageService.saveRefreshToken(newRefreshToken);
          }

          if (kDebugMode) {
            print(
              '✅ [TokenInterceptor] Refresh Success! Retrying original request...',
            );
          }

          // 5. Retry lại request gốc với token mới
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';

          // Dùng 1 Dio instance sạch để retry
          final retryDio = Dio(BaseOptions(baseUrl: opts.baseUrl));

          // Quan trọng: Request retry vẫn cần có khả năng map lỗi
          // nhưng không nên add TokenInterceptor vào để tránh loop.
          // Nếu anh muốn log retry, có thể add logger.
          final clonedRequest = await retryDio.fetch(opts);

          return handler.resolve(clonedRequest);
        } else {
          // Server trả về không phải 200 (ví dụ refresh token cũng hết hạn)
          _authEventService.notifySessionExpired();
          return handler.next(err);
        }
      } catch (e) {
        // Lỗi khi gọi API refresh (mất mạng, server die...)
        if (kDebugMode) {
          print('❌ [TokenInterceptor] Refresh Failed: $e');
        }
        _authEventService.notifySessionExpired();
        return handler.next(err);
      }
    }

    // Các lỗi khác (404, 500...) cho đi qua
    return handler.next(err);
  }
}
