import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/network/api_service.dart';
import 'package:reqres_in/src/core/network/failures.dart';
import 'package:reqres_in/src/core/storage/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';

import '../models/auth_models.dart';

// <-- Đăng ký: "Tôi là bản triển khai của AuthRepository"
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final SecureStorageService _storageService;

  AuthRepositoryImpl(this._apiService, this._storageService);

  @override
  Future<Either<Failure, LoginResponse>> login(
    String email,
    String password,
  ) async {
    try {
      final loginResponse = await _apiService.login(
        LoginRequest(username: email, password: password, expiresInMins: 30),
      );

      // 2. LƯU CẢ HAI TOKEN (Rất quan trọng)
      // Dùng SecureStorageService bạn đã cung cấp
      await _storageService.saveUserToken(loginResponse.accessToken);
      await _storageService.saveRefreshToken(loginResponse.refreshToken);

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
}
