import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:reqres_in/src/features/user/repository/user_repository.dart';
import 'user_state.dart';

// Đăng ký với GetIt/Injectable
@injectable
class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;

  // 1. Tiêm UserRepository qua constructor
  UserCubit(this._userRepository) : super(UserInitial()); // 2. State ban đầu

  /// Hàm công khai để UI gọi và bắt đầu quá trình lấy dữ liệu
  Future<void> fetchUser() async {
    // 3. Phát ra trạng thái Loading
    emit(UserLoading());

    // 4. Gọi repository
    final result = await _userRepository.getMe();

    // 5. Dùng .fold() để xử lý Either<Failure, User>
    result.fold(
      (failure) {
        // 6a. Nếu thất bại (Left), phát ra UserFailure
        emit(UserFailure(failure.message));
      },
      (user) {
        // 6b. Nếu thành công (Right), phát ra UserSuccess
        emit(UserSuccess(user));
      },
    );
  }
}
