import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

// <-- Đăng ký Factory. Mỗi lần gọi là một instance mới.
@injectable
class LoginCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  LoginCubit(this._repository) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    // Gọi Repository
    final result = await _repository.login(email, password);

    // Dùng fold để xử lý kết quả Either từ dartz
    result.fold(
      (failure) => emit(AuthFailure(failure.message)), // Left -> Lỗi
      (token) => emit(AuthSuccess(token)), // Right -> Thành công
    );
  }
}
