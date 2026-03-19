import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/error/error_event.dart';
import 'package:reqres_in/src/core/error/error_event_service.dart';
import 'package:reqres_in/src/core/error/error_severity.dart';
import 'package:reqres_in/src/core/network/failures.dart';
import 'package:reqres_in/src/core/storage/secure_storage_service.dart';

/// Interceptor chuyên xử lý việc Refresh Token khi gặp lỗi 401.
/// Nó hoạt động độc lập với ApiService chính để tránh vòng lặp phụ thuộc.
@lazySingleton
class TokenInterceptor extends QueuedInterceptor {
  final SecureStorageService _storageService;
  final ErrorEventService _errorEventService;

  TokenInterceptor(this._storageService, this._errorEventService);

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

      // 1. Nếu không có refresh token -> Notify session expired qua Error Bus
      if (refreshToken == null) {
        _notifySessionExpired();
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
            },
          ),
        );

        // Gọi API Refresh (Hardcode path '/auth/refresh' vì đây là logic cốt lõi của Auth)
        if (kDebugMode) {
          print('🔄 [TokenInterceptor] Refreshing token...');
        }

        final response = await refreshDio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // 3. Parse kết quả
          final newAccessToken = response.data['accessToken'];
          final newRefreshToken = response.data['refreshToken'];

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

          final retryDio = Dio(BaseOptions(baseUrl: opts.baseUrl));
          final clonedRequest = await retryDio.fetch(opts);

          return handler.resolve(clonedRequest);
        } else {
          // Server trả về không phải 200 (refresh token cũng hết hạn)
          _notifySessionExpired();
          return handler.next(err);
        }
      } catch (e) {
        // Lỗi khi gọi API refresh (mất mạng, server die...)
        if (kDebugMode) {
          print('❌ [TokenInterceptor] Refresh Failed: $e');
        }
        _notifySessionExpired();
        return handler.next(err);
      }
    }

    // Các lỗi khác (404, 500...) cho đi qua
    return handler.next(err);
  }

  /// Emit fatal AuthFailure lên Error Bus.
  /// LoginCubit listen event này → emit AuthSessionExpired → GoRouter redirect.
  void _notifySessionExpired() {
    _errorEventService.emit(
      ErrorEvent(
        failure: AuthFailure.tokenExpired,
        severity: ErrorSeverity.fatal,
        source: 'TokenInterceptor',
      ),
    );
  }
}
