import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqres_in/src/features/auth/presentation/bloc/login_cubit.dart';

class SessionExpiredPage extends StatelessWidget {
  const SessionExpiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Trang này được cung cấp LoginCubit thông qua
    // BlocProvider.value trong main.dart's builder
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Phiên đăng nhập hết hạn',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Phiên đăng nhập đã hết hạn hoặc có lỗi xảy ra.\nVui lòng đăng nhập lại.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                child: const Text('Về màn hình Đăng nhập'),
                onPressed: () {
                  // --- CẬP NHẬT COMMENT ---
                  // Khi bấm nút, gọi hàm logout() từ cubit.
                  // Cubit sẽ emit AuthInitial, và GoRouter
                  // (đang lắng nghe) sẽ tự động điều hướng
                  // app về route '/login'.
                  context.read<LoginCubit>().logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
