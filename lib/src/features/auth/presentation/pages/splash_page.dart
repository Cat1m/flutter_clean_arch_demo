// lib/src/features/auth/presentation/pages/splash_page.dart
// (File cũ là auth_wrapper_page.dart)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqres_in/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:reqres_in/src/features/auth/presentation/bloc/login_cubit.dart';
import 'package:reqres_in/src/features/home/presentation/pages/home_page.dart';

// 1. ĐỔI TÊN CLASS
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, AuthState>(
      builder: (context, state) {
        // 2. NẾU THÀNH CÔNG: Vẫn trả về HomePage
        // (Logic này vẫn y hệt AuthWrapperPage)
        if (state is AuthSuccess) {
          return HomePage(userData: state.loginResponse);
        }

        // 3. MẶC ĐỊNH: HIỂN THỊ UI SPLASH SCREEN MỚI
        // (Bao gồm AuthLoading và các state ban đầu)
        // GoRouter sẽ redirect nếu state là Initial/Failure,
        // nhưng trong milli-giây chờ đợi đó, nó sẽ hiển thị UI này.
        return const Scaffold(
          // Bạn có thể dùng màu chính của app
          backgroundColor: Color(0xFF0A4D68), // (Ví dụ: Màu xanh đậm)
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Thêm logo hoặc icon của bạn ở đây
                Icon(
                  Icons.verified_user_outlined,
                  size: 120,
                  color: Colors.white,
                ),
                SizedBox(height: 24),
                Text(
                  'Clean Arch Demo',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 48),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}
