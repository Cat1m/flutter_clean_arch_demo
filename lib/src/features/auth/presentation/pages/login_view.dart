import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ⭐️ Dọn dẹp: Import AppThemeExtension
import 'package:reqres_in/src/core/theme/extensions/app_theme_extensions.dart';
import 'package:reqres_in/src/shared/extensions/failure_extension.dart';
import '../bloc/auth_state.dart';
import '../bloc/login_cubit.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  // Giữ nguyên controller
  final _usernameController = TextEditingController(text: 'emilys');
  final _passwordController = TextEditingController(text: 'emilyspass');
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<LoginCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                // ✅ Hiển thị Icon và Message từ FailureExtension
                content: Row(
                  children: [
                    Text(state.failure.icon), // Hiển thị icon (📡, 🔐, ⚠️)
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        // Sửa lỗi: Gọi hàm toDisplayMessage() thay vì getter
                        state.failure.toDisplayMessage(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior:
                    SnackBarBehavior.floating, // Khuyến nghị: floating đẹp hơn
                // ✅ Thêm Action Button dựa trên loại lỗi (Thử lại / Đóng)
                action: SnackBarAction(
                  label: state.failure.actionText.toUpperCase(),
                  textColor: Theme.of(context).colorScheme.onError,
                  onPressed: () {
                    // Xử lý logic retry nếu cần (dựa trên state.failure.shouldRetry)
                    if (state.failure.shouldRetry) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      // Gọi lại hàm login hoặc refresh logic tại đây
                    }
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AuthState state) {
    final bool isLoading = state is AuthLoading;
    // ⭐️ Dọn dẹp: Lấy textTheme và theme extension
    final textTheme = Theme.of(context).textTheme;
    final spacing = Theme.of(context).extension<AppThemeExtension>()!.spacing;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        // ⭐️ Dọn dẹp: Dùng token spacing xl (24.0)
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              // ⭐️ Dọn dẹp: Dùng màu primary
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 40), // (Tạm giữ 40px)

            TextFormField(
              controller: _usernameController,
              // ⭐️ Dọn dẹp: Để AppTheme.inputDecorationTheme tự xử lý!
              // Không cần 'border: OutlineInputBorder()' nữa.
              decoration: const InputDecoration(
                labelText: 'UserName',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập username';
                }
                return null;
              },
              readOnly: isLoading,
            ),
            // ⭐️ Dọn dẹp: Dùng token spacing m (16.0)
            SizedBox(height: spacing.m),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              // ⭐️ Dọn dẹp: Để AppTheme.inputDecorationTheme tự xử lý!
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: Icon(Icons.key),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                return null;
              },
              readOnly: isLoading,
            ),
            // ⭐️ Dọn dẹp: Dùng token spacing xs (8.0)
            SizedBox(height: spacing.xs),

            CheckboxListTile(
              // ⭐️ Dọn dẹp: Dùng style từ theme
              title: Text('Ghi nhớ đăng nhập', style: textTheme.bodyLarge),
              value: _rememberMe,
              onChanged: isLoading
                  ? null
                  : (newValue) {
                      setState(() {
                        _rememberMe = newValue ?? false;
                      });
                    },
              // ⭐️ Dọn dẹp: Dùng màu primary (tự động)
              // activeColor: Theme.of(context).colorScheme.primary,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            // ⭐️ Dọn dẹp: Dùng token spacing m (16.0)
            SizedBox(height: spacing.m),

            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        context.read<LoginCubit>().login(
                          _usernameController.text,
                          _passwordController.text,
                          _rememberMe,
                        );
                      }
                    },
              // ⭐️ Dọn dẹp: Xóa 'style'
              // AppTheme.elevatedButtonTheme sẽ tự động
              // áp dụng padding, bo góc (radius.full) và textStyle.
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        // ⭐️ Dọn dẹp: Dùng màu onPrimary
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  // ⭐️ Dọn dẹp: Xóa 'style'. Nút sẽ tự
                  // dùng 'labelLarge' từ theme.
                  : const Text('ĐĂNG NHẬP'),
            ),

            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      context.read<LoginCubit>().login(
                        'eve.holt@reqres.in',
                        '', // Lỗi thiếu pass
                        false,
                      );
                    },
              // ⭐️ Dọn dẹp: Không cần style
              // AppTheme.textButtonTheme sẽ tự động đổi màu chữ
              child: const Text('Test Đăng nhập lỗi'),
            ),
          ],
        ),
      ),
    );
  }
}
