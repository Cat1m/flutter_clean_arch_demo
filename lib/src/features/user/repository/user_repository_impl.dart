import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/network/network.dart';
import 'package:reqres_in/src/features/user/models/user_model.dart';
import 'package:reqres_in/src/features/user/repository/user_repository.dart';
import 'package:reqres_in/src/shared/data/remote/api_service.dart';

// <-- Đăng ký: "Tôi là bản triển khai của UserRepository"
@LazySingleton(as: UserRepository)
class UserRepositoryImpl with BaseRepository implements UserRepository {
  final ApiService _apiService;
  // Không cần SecureStorageService ở đây
  // vì AuthInterceptor/TokenInterceptor đã tự xử lý token rồi.

  UserRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, User>> getMe() =>
      safeApiCall(() => _apiService.getMe());
}
