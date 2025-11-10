import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reqres_in/src/features/auth/models/auth_models.dart';
// 1. Import widget quote mới
import 'package:reqres_in/src/features/quote/widgets/random_quote_widget.dart';

class HomeView extends StatelessWidget {
  // Nhận dữ liệu (giữ nguyên)
  final LoginResponse userData;

  const HomeView({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Toàn bộ UI cũ được giữ nguyên ở đây
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        automaticallyImplyLeading: false,
        actions: [
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

              // 2. Thêm widget quote vào đây
              const SizedBox(height: 48),
              const RandomQuoteWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
