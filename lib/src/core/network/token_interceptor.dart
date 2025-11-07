// lib/core/network/token_interceptor.dart

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// TODO: 1. Thay thế bằng service lưu trữ của bạn (SharedPreferences, SecureStorage...)
// Tạm thời giả lập một service để bạn dễ hình dung
class MockTokenStorage {
  String? _accessToken;
  String? _refreshToken;

  Future<void> saveTokens(String newAccess, String newRefresh) async {
    _accessToken = newAccess;
    _refreshToken = newRefresh;
    if (kDebugMode) {
      print('--- TOKENS ĐÃ ĐƯỢC LƯU MỚI ---');
    }
  }

  Future<String?> getAccessToken() async => _accessToken;
  Future<String?> getRefreshToken() async => _refreshToken;
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

// TODO: 2. Tùy chỉnh class này cho phù hợp
class TokenInterceptor extends QueuedInterceptor {
  // Giả lập service lưu trữ token
  final MockTokenStorage tokenStorage = MockTokenStorage();

  // Tạo một Dio instance riêng CHỈ để gọi API refresh token
  // Nó không nên có interceptor này để tránh vòng lặp vô hạn
  final Dio _refreshDio = Dio(
    BaseOptions(
      // TODO: 3. Đặt baseUrl của bạn ở đây
      baseUrl: 'https://api.example.com/api',
    ),
  );

  /// Interceptor này sẽ gắn AccessToken vào MỌI request
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await tokenStorage.getAccessToken();

    // Gắn token vào header
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  /// Interceptor này sẽ xử lý khi API trả về lỗi
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // === Kịch bản 1: Lỗi 401 (AccessToken hết hạn) ===
    // Chúng ta cần refresh token và thử lại
    if (err.response?.statusCode == 401) {
      if (kDebugMode) {
        print('--- LỖI 401: AccessToken hết hạn ---');
      }

      // Lấy RefreshToken đã lưu
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        // Không có refresh token, không thể làm mới -> Đăng xuất
        if (kDebugMode) {
          print('--- Không có RefreshToken, đăng xuất ---');
        }
        unawaited(tokenStorage.clearTokens());
        // Cho lỗi 401 đi tiếp, ErrorInterceptor sẽ bắt
        return handler.reject(err);
      }

      // === Bắt đầu quá trình Refresh Token ===
      // (Trong QueuedInterceptor, lock() sẽ tạm dừng các request khác
      // cho đến khi unlock() được gọi)
      try {
        if (kDebugMode) {
          print('--- Đang gọi API Refresh Token... ---');
        }

        // TODO: 4. Chỉnh sửa API call này cho đúng với backend của bạn
        // GỌI API REFRESH TOKEN
        final response = await _refreshDio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        // Giả sử API trả về { "accessToken": "...", "refreshToken": "..." }
        final newAccessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String;

        // Lưu token mới
        await tokenStorage.saveTokens(newAccessToken, newRefreshToken);

        // Cập nhật header của request VỪA THẤT BẠI
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        if (kDebugMode) {
          print('--- Refresh thành công. Thử lại request... ---');
        }

        // Thử lại request vừa thất bại với token mới
        // Dùng Dio của interceptor (không phải _refreshDio)
        final dio = Dio(BaseOptions(baseUrl: err.requestOptions.baseUrl));
        // Thêm các interceptor khác nếu cần, nhưng KHÔNG thêm TokenInterceptor
        // Hoặc tốt hơn là dùng 1 instance Dio được truyền vào

        final retryResponse = await dio.fetch(err.requestOptions);

        // Nếu retry thành công, resolve() và kết thúc
        return handler.resolve(retryResponse);
      } on DioException catch (e) {
        // === Kịch bản 2: Refresh Token THẤT BẠI ===
        // (Ví dụ: RefreshToken cũng hết hạn, server 500...)
        if (kDebugMode) {
          print('--- LỖI khi đang Refresh Token: $e ---');
        }
        // Xóa hết token cũ -> Đăng xuất
        await tokenStorage.clearTokens();
        // Cho lỗi đi tiếp (có thể là 401, 403, 500...)
        return handler.reject(e);
      }
    }

    // === Kịch bản 3: Lỗi không phải 401 ===
    // (VD: 404, 500, ConnectionFailure...)
    // Chỉ cần cho nó đi qua, ErrorInterceptor sẽ xử lý
    return handler.next(err);
  }
}
