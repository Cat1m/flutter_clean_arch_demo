import 'package:dartz/dartz.dart';
import 'package:reqres_in/src/core/network/failures.dart';
import 'package:reqres_in/src/features/user/models/user_model.dart';

/// Lớp trừu tượng (Interface) cho User Repository
abstract class UserRepository {
  /// Lấy thông tin người dùng hiện tại (người đã đăng nhập)
  Future<Either<Failure, User>> getMe();

  // (Trong tương lai có thể thêm các hàm khác ở đây)
  // Future<Either<Failure, User>> getUserById(String id);
  // Future<Either<Failure, void>> updateUserProfile(User user);
}
