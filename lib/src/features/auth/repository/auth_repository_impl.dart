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
      // 1. Kiểm tra xem ErrorInterceptor có gửi "Failure" không
      if (e.error is Failure) {
        return Left(e.error as Failure);
      } else {
        // 2. Nếu không phải Failure, đó là một lỗi Dio lạ
        return Left(UnknownFailure('Lỗi Dio không xác định: ${e.message}'));
      }
    } catch (e) {
      // 3. Bắt các lỗi Dart thông thường (lỗi parse, lỗi logic...)
      return Left(UnknownFailure('Lỗi hệ thống: ${e.toString()}'));
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
      return const Left(ServerFailure("Chế độ 'Ghi nhớ' đang tắt."));
    }

    try {
      // 1. Gọi /me để xác thực token.
      await _apiService.getMe();

      // 2. Token hợp lệ, lấy data local
      final userData = await _storageService.getUserData();

      if (userData != null) {
        return Right(userData);
      } else {
        await _storageService.clearAllTokens();
        return const Left(
          ServerFailure(
            'Phiên đăng nhập bị lỗi (mất dữ liệu local). Vui lòng đăng nhập lại.',
          ),
        );
      }

      // ✅ SỬA ĐỔI CHUẨN (ÁP DỤNG CHO MỌI HÀM)
    } on DioException catch (e) {
      // 1. Kiểm tra xem ErrorInterceptor có gửi "Failure" không
      if (e.error is Failure) {
        // Nếu là ServerFailure (ví dụ: 401) thì Interceptor đã xử lý
        // Nếu là ConnectionFailure (mất mạng) thì Interceptor cũng đã xử lý

        // Logic đặc biệt: Nếu lỗi, ta nên xóa token cho an toàn
        // (đặc biệt là lỗi 401 mà TokenInterceptor không xử lý được)
        await _storageService.clearAllTokens();

        return Left(e.error as Failure);
      } else {
        // 2. Nếu không phải Failure, đó là một lỗi Dio lạ
        await _storageService.clearAllTokens();
        return Left(UnknownFailure('Lỗi Dio không xác định: ${e.message}'));
      }
    } catch (e) {
      // 3. Bắt các lỗi Dart thông thường
      await _storageService.clearAllTokens();
      return Left(UnknownFailure('Lỗi hệ thống: ${e.toString()}'));
    }
  }
}
