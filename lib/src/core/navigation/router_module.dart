// lib/src/core/navigation/router_module.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/di/injection.dart'; // Để dùng getIt
import 'package:reqres_in/src/core/navigation/custom_dialog_page.dart';
import 'package:reqres_in/src/core/navigation/stream_listenable.dart';
import 'package:reqres_in/src/features/auth/models/auth_models.dart';
import 'package:reqres_in/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:reqres_in/src/features/auth/presentation/bloc/login_cubit.dart';
import 'package:reqres_in/src/features/auth/presentation/pages/login_page.dart';
import 'package:reqres_in/src/features/auth/presentation/pages/session_expired_page.dart';
// Import tất cả các trang bạn cần cho route
import 'package:reqres_in/src/features/auth/presentation/pages/splash_page.dart';
import 'package:reqres_in/src/features/home/presentation/pages/home_page.dart';
import 'package:reqres_in/src/features/user/presentation/pages/user_page.dart';

// (Bạn cũng cần import LoginResponse nếu dùng state.extra cho HomePage)
// import 'package:reqres_in/src/features/auth/models/auth_models.dart';

@module // 1. Đánh dấu đây là một Module
abstract class RouterModule {
  // 2. Định nghĩa @lazySingleton cho GoRouter
  @lazySingleton
  GoRouter get router {
    // 3. Lấy LoginCubit (phải là singleton)
    final loginCubit = getIt<LoginCubit>();

    return GoRouter(
      // 4. Lắng nghe Cubit
      refreshListenable: StreamListenable(loginCubit.stream),

      // 5. Khai báo các route (đường dẫn)
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashPage()),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/session-expired',
          builder: (context, state) => const SessionExpiredPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const UserPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            // Ví dụ nhận data khi chuyển trang
            final userData = state.extra as LoginResponse;
            return HomePage(userData: userData);
          },
        ),
        GoRoute(
          path: '/logout-confirm',
          pageBuilder: (context, state) {
            // 1. Thay thế "DialogPage" bằng "CustomDialogPage"
            return CustomDialogPage(
              barrierDismissible: false,
              // 2. "child" của nó chính là AlertDialog
              child: AlertDialog(
                title: const Text('Xác nhận Đăng xuất'),
                content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                actions: [
                  TextButton(
                    child: const Text('Hủy'),
                    onPressed: () {
                      context.pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Đăng xuất'),
                    onPressed: () {
                      context.pop();
                      loginCubit.logout();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],

      // 6. Logic tự động điều hướng
      redirect: (context, state) {
        final authState = loginCubit.state;
        final location = state.matchedLocation;

        // 1. Nếu state là Hết hạn
        // (Kiểm tra này nên được ưu tiên)
        if (authState is AuthSessionExpired) {
          // Nếu CHƯA ở trang lỗi, thì đi đến trang lỗi
          return (location == '/session-expired') ? null : '/session-expired';
        }

        // 2. Nếu state là Chưa đăng nhập (Initial hoặc Failure)
        final isUnauthenticated =
            authState is AuthInitial || authState is AuthFailure;
        if (isUnauthenticated) {
          // Chỉ cho phép ở /login.
          // Nếu đang ở BẤT CỨ ĐÂU KHÁC (kể cả /session-expired),
          // thì phải chuyển về /login.
          return (location == '/login') ? null : '/login';
        }

        // 3. Nếu state là Đã đăng nhập
        if (authState is AuthSuccess) {
          // Nếu đang ở trang login hoặc lỗi, đá về trang chủ
          if (location == '/login' || location == '/session-expired') {
            return '/';
          }
        }

        // 4. Mặc định (ví dụ: AuthLoading), không làm gì cả
        return null;
      },
    );
  }
}
