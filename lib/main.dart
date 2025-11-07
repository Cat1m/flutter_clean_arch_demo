// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqres_in/src/core/di/injection.dart' as di;
import 'package:reqres_in/src/features/auth/presentation/bloc/login_cubit.dart';
import 'package:reqres_in/src/features/auth/presentation/pages/auth_wrapper_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.configureDependencies();

  runApp(
    // ⭐️ CUNG CẤP LOGIN CUBIT CHO TOÀN BỘ ỨNG DỤNG
    BlocProvider(
      // Lấy instance singleton VÀ GỌI HÀM KIỂM TRA NGAY LẬP TỨC
      create: (context) => di.getIt<LoginCubit>()..checkAuthStatus(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Arch Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Truyền repository vào LoginPage
      home: const AuthWrapperPage(),
    );
  }
}
