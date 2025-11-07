// lib/src/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqres_in/src/features/auth/presentation/pages/login_view.dart';
import '../../../../core/di/injection.dart';
import '../bloc/login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // MA THUẬT Ở ĐÂY:
      // Thay vì nhận từ constructor, ta gọi getIt<AuthRepository>()
      // GetIt sẽ tự động tìm instance đã đăng ký và trả về.
      create: (context) => getIt<LoginCubit>(),
      child: const LoginView(),
    );
  }
}
