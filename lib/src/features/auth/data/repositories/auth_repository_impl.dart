import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/network/api_service.dart';
import 'package:reqres_in/src/core/network/failures.dart';
import '../../domain/repositories/auth_repository.dart';

import '../models/auth_models.dart';

// <-- Đăng ký: "Tôi là bản triển khai của AuthRepository"
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, String>> login(String email, String password) async {
    try {
      final response = await _apiService.login(
        LoginRequest(email: email, password: password),
      );
      // Thành công: Trả về token (Entity đơn giản là String)
      return Right(response.token);
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
