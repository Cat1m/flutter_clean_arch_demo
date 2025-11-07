import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqres_in/src/features/auth/models/auth_models.dart';
import 'package:reqres_in/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:reqres_in/src/features/auth/presentation/bloc/login_cubit.dart';
import 'package:reqres_in/src/features/auth/presentation/pages/login_page.dart';

import 'package:reqres_in/src/features/user/presentation/pages/user_page.dart';

class HomePage extends StatelessWidget {
  // 1. Nhận dữ liệu login response
  final LoginResponse userData;

  const HomePage({super.key, required this.userData});

  // 2. (Tùy chọn) Tạo một static helper để gọi route dễ dàng
  static Route<dynamic> route(LoginResponse userData) {
    return MaterialPageRoute(
      builder: (context) => HomePage(userData: userData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<LoginCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          // Khi state là AuthInitial (đã logout), quay về màn Login
          // và xóa tất cả các màn hình trước đó khỏi stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false, // Xóa hết
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trang chủ'),
          // Tự động ẩn nút "Back" để người dùng không quay lại màn Login
          automaticallyImplyLeading: false,
          actions: [
            // 3. NÚT ĐIỀU HƯỚNG MỚI
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: 'Trang cá nhân',
              onPressed: () {
                // 4. Điều hướng đến UserPage
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const UserPage()),
                );
              },
            ),

            // Nút Logout
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Đăng xuất',
              onPressed: () {
                // Gọi hàm logout từ cubit
                // context.read<T>() hoạt động vì ta đã cung cấp
                // cubit ở hàm route()
                context.read<LoginCubit>().logout();
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 3. Hiển thị ảnh đại diện
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(userData.image),
                ),
                const SizedBox(height: 24),

                // 4. Hiển thị lời chào
                Text(
                  'Chào mừng trở lại,',
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${userData.firstName} ${userData.lastName}', //
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '@${userData.username}', //
                  style: textTheme.titleMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
