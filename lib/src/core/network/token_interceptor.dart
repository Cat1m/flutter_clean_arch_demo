// lib/core/network/token_interceptor.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:reqres_in/src/core/network/api_service.dart';
import 'package:reqres_in/src/core/service/auth_event_service.dart';
// 1. Import service lưu trữ thật
import 'package:reqres_in/src/core/storage/secure_storage_service.dart';
import 'package:reqres_in/src/features/auth/models/auth_models.dart';

// TÙY CHỈNH: Đảm bảo class này phù hợp với dự án của bạn
class TokenInterceptor extends QueuedInterceptor {
  // 2. Nhận service qua constructor (giống hệt AuthInterceptor)
  final SecureStorageService _storageService;
  final AuthEventService _authEventService;

  TokenInterceptor(this._storageService, this._authEventService);

  /// 4. (RẤT QUAN TRỌNG) XÓA BỎ HÀM onREQUEST
  /// Chúng ta KHÔNG xử lý onRequest ở đây nữa.
  /// AuthInterceptor đã làm việc này rồi (gắn 'Authorization' hoặc 'x-api-key').
  /// Vai trò của file này CHỈ LÀ xử lý lỗi 401.

  /// 5. Interceptor này sẽ xử lý khi API trả về lỗi
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // === Kịch bản 1: Lỗi 401 (AccessToken hết hạn) ===
    if (err.response?.statusCode == 401) {
      if (kDebugMode) {
        print('--- LỖI 401: AccessToken hết hạn ---');
      }

      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        if (kDebugMode) {
          print('--- Không có RefreshToken, đăng xuất ---');
        }

        _authEventService.notifySessionExpired();

        return handler.reject(err);
      }

      // === Bắt đầu quá trình Refresh Token ===
      try {
        if (kDebugMode) {
          print('--- Đang gọi API Refresh Token... ---');
        }

        // 1. Lấy baseUrl từ request VỪA THẤT BẠI
        // (Đây có thể là Env.baseUrl hoặc _urlDev, tùy vào DioClient)
        final originalBaseUrl = err.requestOptions.baseUrl;

        final refreshDio = Dio(
          BaseOptions(
            baseUrl: originalBaseUrl,
            headers: {'Content-Type': 'application/json'},
          ),
        );

        // 3. Tạo ApiService từ Dio instance đó
        final refreshApiService = ApiService(refreshDio);

        final refreshRequest = RefreshRequest(
          refreshToken: refreshToken,
          expiresInMins: 1,
        );

        // 9. Gọi API refresh một cách type-safe
        final response = await refreshApiService.refresh(refreshRequest);

        // 10. Lấy token mới từ response (đã được type-safe)
        final newAccessToken = response.accessToken;
        final newRefreshToken = response.refreshToken;
        // --- THAY ĐỔI (Kết thúc) ---

        // 11. Dùng service thật để LƯU token mới
        await _storageService.saveUserToken(newAccessToken);
        await _storageService.saveRefreshToken(newRefreshToken);

        // 12. Cập nhật header của request VỪA THẤT BẠI
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        if (kDebugMode) {
          print('--- Refresh thành công. Thử lại request... ---');
        }

        // 13. Thử lại request vừa thất bại với token mới
        // Dùng một instance Dio mới, sạch để fetch
        final dio = Dio(BaseOptions(baseUrl: originalBaseUrl));
        final retryResponse = await dio.fetch(err.requestOptions);

        return handler.resolve(retryResponse);
      } on DioException catch (e) {
        // === Kịch bản 2: Refresh Token THẤT BẠI ===
        // (Ví dụ: refresh token cũng hết hạn, server trả 401, 403...)
        if (kDebugMode) {
          print('--- LỖI khi đang Refresh Token: $e ---');
        }

        _authEventService.notifySessionExpired();
        // Từ chối request gốc với lỗi của việc refresh
        return handler.reject(e);
      }
    }

    // === Kịch bản 3: Lỗi không phải 401 ===
    // (VD: 404, 500...)
    // Cho nó đi qua, ErrorInterceptor sẽ xử lý
    return handler.next(err);
  }
}
