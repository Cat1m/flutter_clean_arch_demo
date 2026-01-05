// lib/src/features/auth/presentation/bloc/login_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/auth/service/auth_event_service.dart';
import '../../repository/auth_repository.dart';
import 'auth_state.dart';
// KHÔNG CẦN import storage service ở đây nữa

@singleton
class LoginCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final AuthEventService _authEventService;
  StreamSubscription? _authEventSubscription; // Biến để lưu việc lắng nghe

  // Constructor giờ chỉ cần AuthRepository
  LoginCubit(this._repository, this._authEventService) : super(AuthInitial()) {
    _listenToAuthEvents();
  }

  void _listenToAuthEvents() {
    _authEventSubscription = _authEventService.onSessionExpired.listen((_) {
      // --- THAY ĐỔI LỚN ---
      // Xóa hết logic dialog/navigatorKey
      // Chỉ cần emit state. GoRouter sẽ tự bắt lấy.
      emit(const AuthSessionExpired());
    });
  }

  Future<void> login(String email, String password, bool rememberMe) async {
    emit(AuthLoading());

    // 1. Gọi Repository
    final result = await _repository.login(email, password, rememberMe);

    // 2. Repository đã tự lưu token nếu thành công
    // Cubit chỉ cần emit state
    result.fold(
      (failure) => emit(AuthFailure(failure)),
      (response) => emit(AuthSuccess(response)),
    );
  }

  Future<void> logout() async {
    // Tương tự, Cubit chỉ cần "yêu cầu" Repository xóa
    await _repository.logout();

    // Và emit state
    emit(AuthInitial());
  }

  Future<void> checkAuthStatus() async {
    // Báo cho UI biết là "đang kiểm tra"
    emit(AuthLoading());

    // Gọi repository
    final result = await _repository.checkAuthStatus();

    // Xử lý kết quả
    result.fold(
      (failure) =>
          emit(AuthInitial()), // Lỗi (không có session) -> Về màn Login
      (response) => emit(AuthSuccess(response)), // Thành công -> Về màn Home
    );
  }

  @override
  Future<void> close() {
    _authEventSubscription?.cancel();
    return super.close();
  }
}
