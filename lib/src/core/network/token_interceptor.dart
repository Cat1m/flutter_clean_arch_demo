// lib/core/network/token_interceptor.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:reqres_in/src/core/env/env.dart';
// 1. Import service lưu trữ thật
import 'package:reqres_in/src/core/storage/secure_storage_service.dart';

// TÙY CHỈNH: Đảm bảo class này phù hợp với dự án của bạn
class TokenInterceptor extends QueuedInterceptor {
  // 2. Nhận service qua constructor (giống hệt AuthInterceptor)
  final SecureStorageService _storageService;
  TokenInterceptor(this._storageService);

  // 3. Tạo một Dio instance riêng CHỈ để gọi API refresh token
  // Nó không nên có interceptor này để tránh vòng lặp vô hạn
  final Dio _refreshDio = Dio(
    BaseOptions(
      // TODO: 3. Đặt baseUrl của bạn ở đây
      baseUrl: Env.baseUrl,
    ),
  );

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

      // 6. Dùng service thật để lấy RefreshToken
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        // Không có refresh token, không thể làm mới -> Đăng xuất
        if (kDebugMode) {
          print('--- Không có RefreshToken, đăng xuất ---');
        }
        // 7. Dùng service thật để xóa token
        unawaited(_storageService.clearAllTokens());
        // Cho lỗi 401 đi tiếp, ErrorInterceptor sẽ bắt
        return handler.reject(err);
      }

      // === Bắt đầu quá trình Refresh Token ===
      try {
        if (kDebugMode) {
          print('--- Đang gọi API Refresh Token... ---');
        }

        // TODO: 4. Chỉnh sửa API call này cho đúng với backend của bạn
        final response = await _refreshDio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        final newAccessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String;

        // 8. Dùng service thật để LƯU token mới
        // (SecureStorageService lưu 2 token riêng rẽ)
        await _storageService.saveUserToken(newAccessToken);
        await _storageService.saveRefreshToken(newRefreshToken);

        // Cập nhật header của request VỪA THẤT BẠI
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        if (kDebugMode) {
          print('--- Refresh thành công. Thử lại request... ---');
        }

        // Thử lại request vừa thất bại với token mới
        // Dùng một instance Dio mới, sạch
        final dio = Dio(BaseOptions(baseUrl: err.requestOptions.baseUrl));
        final retryResponse = await dio.fetch(err.requestOptions);

        return handler.resolve(retryResponse);
      } on DioException catch (e) {
        // === Kịch bản 2: Refresh Token THẤT BẠI ===
        if (kDebugMode) {
          print('--- LỖI khi đang Refresh Token: $e ---');
        }
        // 9. Dùng service thật để xóa token
        await _storageService.clearAllTokens();
        return handler.reject(e);
      }
    }

    // === Kịch bản 3: Lỗi không phải 401 ===
    // (VD: 404, 500...)
    // Chỉ cần cho nó đi qua, ErrorInterceptor sẽ xử lý
    return handler.next(err);
  }
}
