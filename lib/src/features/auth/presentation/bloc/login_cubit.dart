// lib/src/features/auth/presentation/bloc/login_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/error/error_event.dart';
import 'package:reqres_in/src/core/error/error_event_service.dart';
import 'package:reqres_in/src/core/error/error_severity.dart';
import 'package:reqres_in/src/core/network/failures.dart' as network;
import '../../repository/auth_repository.dart';
import 'auth_state.dart';

@singleton
class LoginCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final ErrorEventService _errorEventService;
  StreamSubscription<ErrorEvent>? _errorSubscription;

  LoginCubit(this._repository, this._errorEventService) : super(AuthInitial()) {
    _listenToAuthErrors();
  }

  /// Listen Error Bus cho fatal AuthFailure (session expired).
  /// Thay thế AuthEventService — cùng logic, khác nguồn.
  void _listenToAuthErrors() {
    _errorSubscription = _errorEventService.errorStream
        .where(
          (event) =>
              event.severity == ErrorSeverity.fatal &&
              event.failure is network.AuthFailure,
        )
        .listen((_) {
          // Emit state → GoRouter redirect đến /session-expired
          emit(const AuthSessionExpired());
        });
  }

  Future<void> login(String email, String password, bool rememberMe) async {
    emit(AuthLoading());

    final result = await _repository.login(email, password, rememberMe);

    result.fold(
      (failure) => emit(AuthFailure(failure)),
      (response) => emit(AuthSuccess(response)),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(AuthInitial());
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    final result = await _repository.checkAuthStatus();

    result.fold(
      (failure) =>
          emit(AuthInitial()), // Lỗi (không có session) -> Về màn Login
      (response) => emit(AuthSuccess(response)), // Thành công -> Về màn Home
    );
  }

  @override
  Future<void> close() {
    _errorSubscription?.cancel();
    return super.close();
  }
}
