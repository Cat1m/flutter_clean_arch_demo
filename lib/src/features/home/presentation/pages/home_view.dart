import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reqres_in/src/core/ui/ui.dart';
import 'package:reqres_in/src/features/auth/models/auth_models.dart';
import 'package:reqres_in/src/features/quote/widgets/random_quote_widget.dart';
import 'package:reqres_in/src/shared/theme/theme_cubit.dart';

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final List<String> badges;
  final VoidCallback Function(BuildContext context) buildOnTap;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.badges,
    required this.buildOnTap,
  });
}

/// Trang chủ — mặt tiền của repo showcase: một lưới các feature card
/// dẫn thẳng vào từng kỹ thuật đang được demo (Rust FFI, PDF, bảo mật...),
/// thay vì giấu chúng sau các icon không nhãn trên AppBar.
class HomeView extends StatelessWidget {
  final LoginResponse userData;

  const HomeView({super.key, required this.userData});

  static final List<_FeatureItem> _features = [
    _FeatureItem(
      icon: Icons.person_outline,
      title: 'Hồ sơ chi tiết',
      description: 'Thông tin cá nhân, ví crypto khoá bằng PIN',
      badges: const ['Cubit', 'Either/Failure', 'Argon2'],
      buildOnTap: (context) => () => context.push('/profile'),
    ),
    _FeatureItem(
      icon: Icons.picture_as_pdf_outlined,
      title: 'Xuất PDF',
      description: 'Tạo CV PDF và xem trước bằng Syncfusion',
      badges: const ['pdf', 'Syncfusion'],
      buildOnTap: (context) => () => context.push('/pdf-test'),
    ),
    _FeatureItem(
      icon: Icons.speed,
      title: 'Benchmark Dart vs Rust',
      description: 'So sánh hiệu năng tính Fibonacci: Dart vs Rust FFI',
      badges: const ['flutter_rust_bridge'],
      buildOnTap: (context) => () => context.push('/rust-benchmark'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: _buildAppBarTitle(context),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report_outlined),
              tooltip: 'Debug Error Bus',
              onPressed: () => context.push('/debug-error-bus'),
            ),
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            tooltip: 'Đổi sáng/tối',
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => context.push('/logout-confirm'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Demo gọi API', style: context.text.h3),
              const SizedBox(height: AppDimens.s12),
              const RandomQuoteWidget(),
              const SizedBox(height: AppDimens.s24),
              Text('Các tính năng demo', style: context.text.h3),
              const SizedBox(height: AppDimens.s12),
              _buildFeatureGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  // Dữ liệu user đến từ API demo miễn phí (dummyjson.com), không phải thông
  // tin chính của app — nên chỉ cần gọn nhẹ ở AppBar, không chiếm chỗ trong body.
  Widget _buildAppBarTitle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: context.colors.surface,
          backgroundImage: NetworkImage(userData.image),
          onBackgroundImageError: (_, _) {},
          child: userData.image.isEmpty
              ? const Icon(Icons.person, size: 18)
              : null,
        ),
        const SizedBox(width: AppDimens.s8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chào mừng trở lại',
                style: context.text.caption.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              Text(
                '${userData.firstName} ${userData.lastName}',
                style: context.text.h3.copyWith(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimens.s12,
        mainAxisSpacing: AppDimens.s12,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) =>
          _FeatureCard(feature: _features[index]),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: feature.buildOnTap(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(feature.icon, size: AppDimens.icL, color: context.colors.primary),
          const SizedBox(height: AppDimens.s12),
          Text(feature.title, style: context.text.h3.copyWith(fontSize: 16)),
          const SizedBox(height: AppDimens.s4),
          Expanded(
            child: Text(
              feature.description,
              style: context.text.caption.copyWith(
                color: context.colors.textSecondary,
              ),
              overflow: TextOverflow.fade,
            ),
          ),
          Wrap(
            spacing: AppDimens.s4,
            runSpacing: AppDimens.s4,
            children: feature.badges
                .map((label) => AppBadge(label: label))
                .toList(),
          ),
        ],
      ),
    );
  }
}
