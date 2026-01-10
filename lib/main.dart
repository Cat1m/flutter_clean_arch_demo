import 'dart:async'; // Để dùng unawaited

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// ✅ Gom nhóm import Core
import 'package:reqres_in/src/core/di/injection.dart'; // Bỏ alias 'as di' nếu không bị trùng tên
import 'package:reqres_in/src/core/pdf/infrastructure/pdf_font_helper.dart';
import 'package:reqres_in/src/core/ui/ui.dart';
import 'package:reqres_in/src/core/widgets/network_snackbar_listener.dart';

// ✅ Gom nhóm import Feature
import 'package:reqres_in/src/features/auth/presentation/bloc/login_cubit.dart';
import 'package:reqres_in/src/shared/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Cấu hình DI (Blocking - Bắt buộc chờ vì các màn hình sau cần nó)
  await configureDependencies();

  // 2. Fire & Forget (Non-blocking - Chạy ngầm song song)
  // Check Auth và Load Font chạy đua với nhau và đua với cả runApp
  unawaited(getIt<LoginCubit>().checkAuthStatus());
  unawaited(getIt<PdfFontHelper>().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng getIt trực tiếp cho gọn
    final router = getIt<GoRouter>();

    return BlocProvider(
      create: (context) => getIt<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Clean Arch Demo',
            debugShowCheckedModeBanner: false,

            // Theme config
            themeMode: themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),

            // Router config
            routerConfig: router,

            // Global Wrappers
            builder: (context, child) {
              return MultiBlocProvider(
                providers: [BlocProvider.value(value: getIt<LoginCubit>())],
                child: NetworkSnackbarListener(child: child!),
              );
            },
          );
        },
      ),
    );
  }
}
