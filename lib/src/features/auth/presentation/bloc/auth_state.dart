import 'package:equatable/equatable.dart';
import 'package:reqres_in/src/core/network/failures.dart';
import 'package:reqres_in/src/features/auth/models/auth_models.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final LoginResponse loginResponse;
  const AuthSuccess(this.loginResponse);
  @override
  List<Object?> get props => [loginResponse];
}

class AuthFailure extends AuthState {
  final Failure failure;
  const AuthFailure(this.failure);
  @override
  List<Object?> get props => [failure];
}

class AuthSessionExpired extends AuthState {
  const AuthSessionExpired();
}
