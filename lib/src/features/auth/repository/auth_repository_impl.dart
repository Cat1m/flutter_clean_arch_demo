import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/network/api_service.dart';
import 'package:reqres_in/src/core/network/failures.dart';
import 'package:reqres_in/src/core/storage/secure_storage_service.dart';
import 'package:reqres_in/src/core/storage/settings_service.dart';

import '../models/auth_models.dart';
import 'auth_repository.dart';

// <-- Đăng ký: "Tôi là bản triển khai của AuthRepository"
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final SecureStorageService _storageService;
  final SettingsService _settingsService;

  AuthRepositoryImpl(
    this._apiService,
    this._storageService,
    this._settingsService,
  );

  @override
  Future<Either<Failure, LoginResponse>> login(
    String email,
    String password,
    bool rememberMe,
  ) async {
    try {
      final loginResponse = await _apiService.login(
        LoginRequest(username: email, password: password, expiresInMins: 30),
      );

      // ⭐️ CỔNG KIỂM SOÁT NẰM Ở ĐÂY
      if (rememberMe) {
        // Nếu "Ghi nhớ", LƯU TẤT CẢ
        await _storageService.saveUserToken(loginResponse.accessToken);
        await _storageService.saveRefreshToken(loginResponse.refreshToken);
        await _storageService.saveUserData(loginResponse);
        await _settingsService.saveRememberMe(true); // Lưu cài đặt
      } else {
        // Nếu KHÔNG "Ghi nhớ", XÓA SẠCH
        // (để đảm bảo không còn session cũ nào sót lại)
        await _storageService.clearAllTokens();
        await _settingsService.saveRememberMe(false); // Lưu cài đặt
      }

      // Thành công: Trả về token (Entity đơn giản là String)
      return Right(loginResponse);
    } on DioException catch (e) {
      // Reqres trả về lỗi 400 kèm JSON { "error": "..." }
      // Ta lấy message đó ra để hiển thị
      final errorMessage =
          e.response?.data['error'] ?? e.message ?? 'Lỗi không xác định';
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    // Khi logout, XÓA HẾT
    await _storageService.clearAllTokens();
    await _settingsService.saveRememberMe(false); // <-- Rất quan trọng
  }

  // ⭐️ IMPLEMENT HÀM MỚI
  @override
  Future<Either<Failure, LoginResponse>> checkAuthStatus() async {
    // ⭐️ CỔNG KIỂM SOÁT SỐ 2 (QUAN TRỌNG NHẤT)
    // 1. Kiểm tra cài đặt "Ghi nhớ" trước (việc này rất nhanh)
    final bool rememberMe = _settingsService.getRememberMe();

    if (!rememberMe) {
      // Nếu user đã chọn KHÔNG GHI NHỚ, ta không cần
      // gọi API /me tốn kém. Trả về lỗi ngay lập tức.
      return const Left(ServerFailure("Chế độ 'Ghi nhớ' đang tắt."));
    }

    try {
      // 1. Gọi /me để xác thực token.
      // Giả định rằng Dio Interceptor của bạn sẽ tự động
      // đọc token từ _storageService và đính kèm vào request này.
      await _apiService.getMe();

      // 2. Nếu 'getMe()' thành công (không ném exception),
      //    nghĩa là token vẫn còn hạn.
      //    Giờ ta lấy dữ liệu User đầy đủ (LoginResponse) đã lưu.
      final userData = await _storageService.getUserData();

      if (userData != null) {
        // Có token hợp lệ + Có data local = Auto login thành công
        return Right(userData);
      } else {
        // Lỗi hiếm gặp: Token hợp lệ nhưng không tìm thấy data local.
        // Bắt người dùng đăng nhập lại cho an toàn.
        await _storageService.clearAllTokens();
        return const Left(
          ServerFailure(
            'Phiên đăng nhập bị lỗi (mất dữ liệu local). Vui lòng đăng nhập lại.',
          ),
        );
      }
    } on DioException catch (e) {
      // 3. Xử lý lỗi từ Dio (quan trọng nhất là lỗi 401/403)

      // Kiểm tra xem có phải lỗi do token hết hạn/không hợp lệ không
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        // Token không hợp lệ -> Xóa sạch session
        await _storageService.clearAllTokens();
        return const Left(ServerFailure('Phiên đăng nhập đã hết hạn.'));
      }

      // Lỗi khác (mất mạng, server 500...)
      final errorMessage =
          e.message ?? 'Lỗi mạng khi kiểm tra phiên đăng nhập.';
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      // 4. Lỗi chung khác
      await _storageService.clearAllTokens();
      return Left(ServerFailure(e.toString()));
    }
  }
}
