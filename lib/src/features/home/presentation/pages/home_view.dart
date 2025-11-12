import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // <-- Thêm import
import 'package:go_router/go_router.dart';
import 'package:reqres_in/src/core/theme/extensions/app_theme_extensions.dart';
import 'package:reqres_in/src/core/theme/theme_manager/theme_cubit.dart';
import 'package:reqres_in/src/features/auth/models/auth_models.dart';
import 'package:reqres_in/src/features/quote/widgets/random_quote_widget.dart';

class HomeView extends StatelessWidget {
  final LoginResponse userData;

  const HomeView({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    // Lấy TextTheme TỪ AppTheme (giờ đã nhất quán)
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        // title: const Text('Trang chủ'), (Đã có trong AppAppBarTheme)
        automaticallyImplyLeading: false,
        actions: [
          // ⭐️ Nút chuyển Theme (Thêm mới)
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            tooltip: 'Đổi sáng/tối',
            onPressed: () {
              // 1. Lấy cubit
              final cubit = context.read<ThemeCubit>();
              // 2. Lấy state hiện tại
              final currentMode = cubit.state;
              // 3. Chuyển đổi (ví dụ đơn giản)
              final newMode = currentMode == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
              // 4. Gọi hàm
              cubit.setThemeMode(newMode);
            },
          ),
          // Nút Profile
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Trang cá nhân',
            onPressed: () {
              context.push('/profile');
            },
          ),
          // Nút Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              context.push('/logout-confirm');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          // ⭐️ Dọn dẹp: Dùng token spacing từ ThemeExtension
          padding: EdgeInsets.all(
            Theme.of(
              context,
            ).extension<AppThemeExtension>()!.spacing.xl, // 24.0
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(userData.image),
              ),
              // ⭐️ Dọn dẹp: Dùng token spacing
              SizedBox(
                height: Theme.of(
                  context,
                ).extension<AppThemeExtension>()!.spacing.xl, // 24.0
              ),
              Text(
                'Chào mừng trở lại,',
                // ⭐️ Dọn dẹp: Dùng style từ AppTheme
                // headlineSmall (24px, grey900)
                style: textTheme.headlineSmall,
              ),
              // ⭐️ Dọn dẹp: Dùng token spacing
              SizedBox(
                height: Theme.of(
                  context,
                ).extension<AppThemeExtension>()!.spacing.xs, // 8.0
              ),
              Text(
                '${userData.firstName} ${userData.lastName}',
                // ⭐️ Dọn dẹp: Dùng style từ AppTheme
                // headlineLarge (32px, primary color)
                style: textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              // ⭐️ Dọn dẹp: Dùng token spacing
              SizedBox(
                height: Theme.of(
                  context,
                ).extension<AppThemeExtension>()!.spacing.xs, // 8.0
              ),
              Text(
                '@${userData.username}',
                // ⭐️ Dọn dẹp: Dùng style từ AppTheme
                // bodySmall (12px, grey700)
                style: textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),

              // 2. Thêm widget quote
              // ⭐️ Dọn dẹp: Dùng token spacing
              const SizedBox(height: 48), // (Tạm giữ 48px)
              const RandomQuoteWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
