import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/network/failures.dart';
import 'package:reqres_in/src/features/user/models/user_model.dart';
import 'package:reqres_in/src/features/user/repository/user_repository.dart';
import 'package:reqres_in/src/shared/data/remote/api_service.dart';

// <-- Đăng ký: "Tôi là bản triển khai của UserRepository"
@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;
  // Không cần SecureStorageService ở đây
  // vì AuthInterceptor/TokenInterceptor đã tự xử lý token rồi.

  UserRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, User>> getMe() async {
    try {
      // 1. Chỉ cần gọi ApiService
      // Toàn bộ logic gắn AccessToken đã được AuthInterceptor lo.
      // Toàn bộ logic RefreshToken đã được TokenInterceptor lo.
      final user = await _apiService.getMe();

      // 2. Thành công: Trả về đối tượng User
      return Right(user);
    } on DioException catch (e) {
      // 3. Xử lý lỗi
      // Nếu lỗi 401 (token hết hạn), TokenInterceptor sẽ tự xử lý
      // và retry. Lỗi chỉ đến đây khi:
      // a) Refresh token cũng hết hạn -> Bị logout (do TokenInterceptor).
      // b) Lỗi 401 nhưng không phải do token (ví dụ: bị ban).
      // c) Lỗi 404, 500, timeout...

      // Chúng ta sẽ dùng ErrorInterceptor để dịch lỗi này sang Failure,
      // nhưng nếu chưa set up, ta làm thủ công như AuthRepo:
      final failure = (e.error is Failure)
          ? e.error
                as Failure // Lỗi đã được ErrorInterceptor dịch
          : ServerFailure(
              e.response?.data['message'] ?? e.message ?? 'Lỗi không xác định',
            ); // Tự dịch

      return Left(failure);
    } catch (e) {
      // 4. Các lỗi khác (ví dụ: lỗi parse JSON,...)
      return Left(UnknownFailure(e.toString()));
    }
  }
}
