import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 1. Thêm import GoRouter
import 'package:reqres_in/src/features/auth/models/auth_models.dart';
// 2. Xóa các import không cần thiết (AuthState, LoginPage, UserPage)
// import 'package:reqres_in/src/features/auth/presentation/bloc/auth_state.dart';
// import 'package:reqres_in/src/features/auth/presentation/bloc/login_cubit.dart';
// import 'package:reqres_in/src/features/auth/presentation/pages/login_page.dart';
// import 'package:reqres_in/src/features/user/presentation/pages/user_page.dart';

class HomePage extends StatelessWidget {
  // 1. Nhận dữ liệu (giữ nguyên)
  final LoginResponse userData;

  const HomePage({super.key, required this.userData});

  // 2. Xóa static helper 'route' (GoRouter đã xử lý)
  // static Route<dynamic> route(LoginResponse userData) { ... }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // 3. Xóa BlocListener (GoRouter redirect đã xử lý logic này)
    // return BlocListener<LoginCubit, AuthState>(
    //   listener: (context, state) {
    //     if (state is AuthInitial) {
    //       Navigator.of(context).pushAndRemoveUntil(...);
    //     }
    //   },
    //   child: Scaffold(

    // Chỉ cần trả về Scaffold
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        automaticallyImplyLeading: false, // Giữ nguyên
        actions: [
          // 4. Nút Profile (Cập nhật)
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Trang cá nhân',
            onPressed: () {
              // Dùng context.push() để điều hướng đến route
              // mà bạn đã định nghĩa trong RouterModule
              context.push('/profile');
            },
          ),

          // 5. Nút Logout (Cập nhật)
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              // Dùng context.push() để "đẩy" route DialogPage
              // mà bạn đã định nghĩa trong RouterModule
              context.push('/logout-confirm');
            },
          ),
        ],
      ),
      // 6. Body (Giữ nguyên)
      // Toàn bộ phần body không thay đổi,
      // vì nó chỉ làm nhiệm vụ hiển thị UI
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(userData.image),
              ),
              const SizedBox(height: 24),
              Text(
                'Chào mừng trở lại,',
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${userData.firstName} ${userData.lastName}',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '@${userData.username}',
                style: textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // ); // Dấu đóng của BlocListener cũ
  }
}
