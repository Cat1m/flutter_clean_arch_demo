import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/network/failures.dart';
import 'package:reqres_in/src/core/storage/secure_storage_service.dart';
import 'package:reqres_in/src/core/storage/settings_service.dart';
import 'package:reqres_in/src/shared/data/remote/api_service.dart';

import '../models/auth_models.dart';
import 'auth_repository.dart';

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
        LoginRequest(
          username: email,
          password: password,
          //expiresInMins: 1 //! test thôi mặc định 60p rồi
        ),
      );

      if (rememberMe) {
        // --- PHIÊN ĐĂNG NHẬP "VĨNH VIỄN" ---
        await _storageService.saveUserToken(loginResponse.accessToken);
        await _storageService.saveRefreshToken(loginResponse.refreshToken);
        await _storageService.saveUserData(loginResponse);
        await _settingsService.saveRememberMe(true);
      } else {
        // --- PHIÊN ĐĂNG NHẬP "TẠM THỜI" ---
        // 1. Dọn dẹp mọi token cũ
        await _storageService.clearAllTokens();
        // 2. Chỉ lưu accessToken cho phiên hiện tại
        await _storageService.saveUserToken(loginResponse.accessToken);
        // 3. Đánh dấu là không "nhớ"
        await _settingsService.saveRememberMe(false);
      }
      return Right(loginResponse);

      // ✅ SỬA ĐỔI CHUẨN (ÁP DỤNG CHO MỌI HÀM)
    } on DioException catch (e) {
      // Nếu Interceptor đã biến nó thành Failure rồi thì dùng luôn
      if (e.error is Failure) {
        return Left(e.error as Failure);
      }

      // Fallback nếu sót
      return Left(
        ServerFailure(
          e.message ?? 'Lỗi kết nối máy chủ',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      // Bắt các lỗi code ngu (Null check operator used on a null value...)
      return Left(UnknownFailure('Lỗi ứng dụng: $e'));
    }
  }

  @override
  Future<void> logout() async {
    await _storageService.clearAllTokens();
    await _settingsService.saveRememberMe(false);
  }

  @override
  Future<Either<Failure, LoginResponse>> checkAuthStatus() async {
    final bool rememberMe = _settingsService.getRememberMe();

    if (!rememberMe) {
      // Nếu không nhớ -> coi như phiên hết hạn
      return const Left(AuthFailure('Chế độ ghi nhớ đang tắt'));
    }

    try {
      // 1. Gọi API verify token
      await _apiService.getMe();

      // 2. Lấy data local
      final userData = await _storageService.getUserData();

      if (userData != null) {
        return Right(userData);
      }

      // Case hiếm: Có token nhưng mất data user dưới local -> Logout
      await _storageService.clearAllTokens();
      return const Left(AuthFailure('Dữ liệu người dùng không hợp lệ'));
    } on DioException catch (e) {
      // [Như]: Xử lý thông minh dựa trên loại Failure
      if (e.error is Failure) {
        final failure = e.error as Failure;

        // ⚠️ LOGIC QUAN TRỌNG:
        // Chỉ xóa token (Logout) nếu lỗi là AuthFailure (401, Token hỏng)
        // Nếu là ConnectionFailure (Mất mạng) -> KHÔNG ĐƯỢC XÓA TOKEN!
        if (failure is AuthFailure) {
          await _storageService.clearAllTokens();
        }

        return Left(failure);
      }

      // Các lỗi Dio lạ khác (không phải do Interceptor bắt) -> Logout cho an toàn
      await _storageService.clearAllTokens();
      return Left(UnknownFailure('Lỗi kiểm tra trạng thái: ${e.message}'));
    } catch (e) {
      // Lỗi code Dart (Crash) -> Logout
      await _storageService.clearAllTokens();
      return Left(UnknownFailure('Lỗi hệ thống: $e'));
    }
  }
}
