import 'package:equatable/equatable.dart';
import 'package:reqres_in/src/features/auth/data/models/auth_models.dart';

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
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}
