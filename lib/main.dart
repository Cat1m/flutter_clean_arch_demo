import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reqres_in/src/core/di/injection.dart' as di;
// --- Thêm import cho Theme ---
import 'package:reqres_in/src/core/theme/app_theme.dart';
import 'package:reqres_in/src/core/theme/theme_manager/theme_cubit.dart';
import 'package:reqres_in/src/core/widgets/network_snackbar_listener.dart';
import 'package:reqres_in/src/features/auth/presentation/bloc/login_cubit.dart';

// ------------------------------

void main() async {
  // 1. Đảm bảo Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Cấu hình DI
  // (Sẽ tự động đăng ký 'ThemeCubit' của bạn vì nó có @lazySingleton)
  await di.configureDependencies();

  // 3. Kích hoạt logic auth
  unawaited(di.getIt<LoginCubit>().checkAuthStatus());

  // 4. Chạy app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy instance GoRouter (giữ nguyên)
    final router = di.getIt<GoRouter>();

    // 5. ⭐️ Bọc toàn bộ ứng dụng bằng ThemeCubit
    return BlocProvider(
      create: (context) => di.getIt<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          // 6. Trả về MaterialApp.router với theme đã được cấu hình
          return MaterialApp.router(
            title: 'Clean Arch Demo',

            // --- Tích hợp AppTheme ---
            themeMode: themeMode, // <-- Lấy state từ Cubit
            theme: AppTheme.lightTheme, // <-- Áp dụng Light Theme
            // Tạm thời dùng lightTheme cho cả hai để test
            darkTheme: AppTheme.darkTheme,
            // --------------------------

            // 7. Cung cấp cấu hình router (giữ nguyên)
            routerConfig: router,

            // 8. Cung cấp LoginCubit (giữ nguyên)
            builder: (context, child) {
              return BlocProvider.value(
                value: di.getIt<LoginCubit>(),
                child: NetworkSnackbarListener(child: child!),
              );
            },
          );
        },
      ),
    );
  }
}
