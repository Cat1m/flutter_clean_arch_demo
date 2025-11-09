// lib/src/features/auth/presentation/bloc/login_cubit.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/navigation/navigation_service.dart';
import 'package:reqres_in/src/core/service/auth_event_service.dart';
import 'package:reqres_in/src/core/widgets/session_expired_dialog.dart';
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
    // Lắng nghe stream từ service
    _authEventSubscription = _authEventService.onSessionExpired.listen((_) {
      // Khi Interceptor báo lỗi, phát ra state mới
      // 1. Thay vì emit state, hãy lấy context từ GlobalKey
      final navigatorContext = navigatorKey.currentContext;

      // 2. Kiểm tra xem context có tồn tại không
      if (navigatorContext != null) {
        // 3. Hiển thị dialog TRỰC TIẾP từ Cubit
        showSessionExpiredDialog(
          // ignore: use_build_context_synchronously
          context: navigatorContext,
          title: 'Phiên đăng nhập hết hạn',
          message:
              'Phiên đăng nhập đã hết hạn hoặc có lỗi xảy ra.\nVui lòng đăng nhập lại.',
          onConfirm: () {
            // 4. Tắt dialog (dùng context của dialog)
            Navigator.of(navigatorContext).pop();

            // 5. GỌI HÀM LOGOUT CỦA CHÍNH CUBIT NÀY
            // (Không cần emit state AuthSessionExpired nữa)
            logout();
          },
        );
      }
    });
  }

  Future<void> login(String email, String password, bool rememberMe) async {
    emit(AuthLoading());

    // 1. Gọi Repository
    final result = await _repository.login(email, password, rememberMe);

    // 2. Repository đã tự lưu token nếu thành công
    // Cubit chỉ cần emit state
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
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
