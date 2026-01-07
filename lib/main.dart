import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// Thay đổi đường dẫn import này tùy theo structure thực tế của bạn
import 'package:reqres_in/src/core/di/injection.dart' as di;
import 'package:reqres_in/src/core/widgets/network_snackbar_listener.dart';
import 'package:reqres_in/src/features/auth/presentation/bloc/login_cubit.dart';
// Import Feature Settings (Nơi chứa ThemeCubit)
import 'package:reqres_in/src/shared/theme/theme_cubit.dart';

// ✅ Import Core UI (Barrel file)
import 'src/core/ui/ui.dart';

// ------------------------------

void main() async {
  // 1. Đảm bảo Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Cấu hình DI
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
    // Lấy instance GoRouter
    final router = di.getIt<GoRouter>();

    // 5. ⭐️ Bọc toàn bộ ứng dụng bằng ThemeCubit
    return BlocProvider(
      create: (context) =>
          di.getIt<ThemeCubit>(), // Load saved theme từ local storage
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          // 6. Trả về MaterialApp.router với theme chuẩn Core UI
          return MaterialApp.router(
            title: 'Clean Arch Demo',
            debugShowCheckedModeBanner: false,

            // --- ✅ Tích hợp AppTheme từ Core UI ---
            themeMode: themeMode, // State từ Cubit (System/Light/Dark)
            theme: AppTheme.light(), // Config Light chuẩn
            darkTheme: AppTheme.dark(), // Config Dark chuẩn
            // -------------------------------------

            // 7. Cung cấp cấu hình router
            routerConfig: router,

            // 8. Global UI Wrappers (LoginCubit, Snackbar...)
            builder: (context, child) {
              return MultiBlocProvider(
                providers: [
                  // Inject LoginCubit global để check auth mọi nơi
                  BlocProvider.value(value: di.getIt<LoginCubit>()),
                ],
                // Listener lắng nghe lỗi mạng toàn cục
                child: NetworkSnackbarListener(child: child!),
              );
            },
          );
        },
      ),
    );
  }
}
