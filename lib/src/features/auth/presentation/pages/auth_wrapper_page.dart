// lib/src/features/auth/presentation/pages/auth_wrapper_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqres_in/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:reqres_in/src/features/auth/presentation/bloc/login_cubit.dart';
import 'package:reqres_in/src/features/auth/presentation/pages/login_page.dart';
import 'package:reqres_in/src/features/home/presentation/pages/home_page.dart';

class AuthWrapperPage extends StatelessWidget {
  const AuthWrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Chỉ cần lắng nghe LoginCubit (đã được cung cấp ở main.dart)
    return BlocBuilder<LoginCubit, AuthState>(
      builder: (context, state) {
        // 1. Nếu đăng nhập thành công (từ auto-login)
        if (state is AuthSuccess) {
          // Trả về HomePage
          return HomePage(userData: state.loginResponse);
        }

        // 2. Nếu đang tải (đang checkAuthStatus)
        if (state is AuthLoading) {
          // Trả về màn hình splash (loading)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 3. Mặc định (AuthInitial hoặc AuthFailure)
        // Trả về LoginPage
        return const LoginPage();
      },
    );
  }
}
