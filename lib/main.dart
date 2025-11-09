// main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reqres_in/src/core/di/injection.dart' as di;
import 'package:reqres_in/src/core/widgets/network_snackbar_listener.dart';
import 'package:reqres_in/src/features/auth/presentation/bloc/login_cubit.dart';

void main() async {
  // 1. Đảm bảo Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Cấu hình DI (quan trọng)
  // Bước này sẽ tạo ra LoginCubit (singleton)
  // VÀ GoRouter (lazySingleton)
  // VÀ liên kết chúng qua refreshListenable
  await di.configureDependencies();

  // 3. Kích hoạt logic auth (quan trọng)
  // Gọi hàm này NGAY LẬP TỨC.
  // GoRouter (đã được tạo ở bước 2) đang lắng nghe.
  // Nó sẽ nhận state (ví dụ: AuthLoading -> AuthInitial)
  // và quyết định route đầu tiên TRƯỚC KHI app kịp hiển thị.
  unawaited(di.getIt<LoginCubit>().checkAuthStatus());

  // 4. Chạy app
  // Không cần BlocProvider bọc ở đây nữa.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy instance GoRouter đã được cấu hình từ getIt
    final router = di.getIt<GoRouter>();

    // 5. Sử dụng MaterialApp.router
    return MaterialApp.router(
      title: 'Clean Arch Demo',
      theme: ThemeData(primarySwatch: Colors.blue),

      // 6. Cung cấp cấu hình router
      routerConfig: router,

      // 7. Cung cấp LoginCubit (singleton) cho cây widget
      // Mục đích: Để các trang con (như LoginPage, SessionExpiredPage)
      // có thể gọi hàm bằng `context.read<LoginCubit>().login()`
      builder: (context, child) {
        // Bọc child trong BlocProvider (như code cũ)
        return BlocProvider.value(
          value: di.getIt<LoginCubit>(),
          // ⭐️ Bọc BlocProvider bằng NetworkSnackbarListener
          child: NetworkSnackbarListener(
            // child! (từ GoRouter) sẽ được truyền vào
            child: child!,
          ),
        );
      },
    );
  }
}
