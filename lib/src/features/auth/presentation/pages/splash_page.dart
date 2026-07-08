// lib/src/features/auth/presentation/pages/splash_page.dart
// (File cũ là auth_wrapper_page.dart)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqres_in/src/core/ui/ui.dart';
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
        // Dùng đúng màu primary của design system thay vì hex hardcode,
        // để splash luôn khớp brand kể cả khi đổi palette.
        return Scaffold(
          backgroundColor: context.colors.primary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: AppDimens.icXL * 2.5,
                  color: Colors.white,
                ),
                const SizedBox(height: AppDimens.s24),
                Text(
                  'Clean Arch Demo',
                  style: context.text.h1.copyWith(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimens.s48),
                const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}
