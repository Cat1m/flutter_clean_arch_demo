import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reqres_in/src/core/ui/ui.dart';
import 'package:reqres_in/src/features/auth/models/auth_models.dart';
import 'package:reqres_in/src/features/quote/widgets/random_quote_widget.dart';
import 'package:reqres_in/src/shared/theme/theme_cubit.dart';

class HomeView extends StatelessWidget {
  final LoginResponse userData;

  const HomeView({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    // Không cần lấy textTheme thủ công nữa

    return Scaffold(
      appBar: AppBar(
        // title: const Text('Trang chủ'), // Đã setup trong AppTheme
        automaticallyImplyLeading: false,
        actions: [
          // ⭐️ Nút chuyển Theme (Refactor siêu gọn)
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            tooltip: 'Đổi sáng/tối',
            onPressed: () {
              // ✅ Gọi hàm toggleTheme() đã viết sẵn trong Cubit
              context.read<ThemeCubit>().toggleTheme();
            },
          ),

          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Trang cá nhân',
            onPressed: () => context.push('/profile'),
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => context.push('/logout-confirm'),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          // Thêm scroll cho an toàn trên màn hình nhỏ
          // ✅ Dùng AppDimens.s24 thay vì gọi extension dài dòng
          padding: const EdgeInsets.all(AppDimens.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                // Thêm background color phòng khi ảnh lỗi hoặc đang load
                backgroundColor: context.colors.surface,
                backgroundImage: NetworkImage(userData.image),
                // Xử lý lỗi ảnh đơn giản
                onBackgroundImageError: (_, _) {},
                child: userData.image.isEmpty
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),

              // ✅ Dùng AppDimens.s24
              const SizedBox(height: AppDimens.s24),

              Text(
                'Chào mừng trở lại,',
                // ✅ Dùng context.text.h2 (tương đương 24px)
                style: context.text.h2,
              ),

              // ✅ Dùng AppDimens.s8
              const SizedBox(height: AppDimens.s8),

              Text(
                '${userData.firstName} ${userData.lastName}',
                // ✅ Dùng context.text.h1 + Màu Primary
                style: context.text.h1.copyWith(color: context.colors.primary),
                textAlign: TextAlign.center,
              ),

              // ✅ Dùng AppDimens.s8
              const SizedBox(height: AppDimens.s8),

              Text(
                '@${userData.username}',
                // ✅ Dùng context.text.caption (Small text)
                style: context.text.caption.copyWith(
                  fontStyle: FontStyle.italic,
                  fontSize: 14, // Tăng nhẹ size nếu cần
                ),
              ),

              // ✅ Dùng AppDimens.s48
              const SizedBox(height: AppDimens.s48),

              const RandomQuoteWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
