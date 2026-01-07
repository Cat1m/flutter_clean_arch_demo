import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqres_in/src/core/ui/ui.dart';
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
      // AppBar tự động ăn theo Theme config trong AppTheme
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<LoginCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            // Ẩn phím khi có lỗi để user nhìn thấy SnackBar rõ hơn
            context.hideKeyboard();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                // ✅ Dùng AppDimens cho padding/margin
                content: Row(
                  children: [
                    Text(state.failure.icon),
                    const SizedBox(width: AppDimens.s12),
                    Expanded(
                      child: Text(
                        state.failure.toDisplayMessage(),
                        // Text trên nền Error thường là màu trắng/sáng
                        style: context.text.body2.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                // ✅ Dùng context.colors.error từ Core UI
                backgroundColor: context.colors.error,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: state.failure.actionText.toUpperCase(),
                  textColor: Colors.white,
                  onPressed: () {
                    if (state.failure.shouldRetry) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      // Logic retry
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

    // ❌ ĐÃ XÓA: final spacing = ...
    // Giờ chúng ta dùng AppDimens và context extension trực tiếp

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        // ✅ Dùng AppDimens.s24 (tương đương xl cũ)
        padding: const EdgeInsets.all(AppDimens.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80, // Có thể thay bằng AppDimens.s64 * 1.5 nếu muốn strict
              // ✅ Dùng context.colors.primary
              color: context.colors.primary,
            ),

            // ✅ Dùng AppDimens thay số chết 40
            const SizedBox(height: AppDimens.s32),

            AppTextField(
              controller: _usernameController,
              label: 'UserName',
              prefixIcon: Icons.person_outline,
              readOnly: isLoading,
              validator: (v) => v!.isEmpty ? 'Nhập user' : null,
            ),

            // ✅ Dùng AppDimens.s16
            const SizedBox(height: AppDimens.s16),

            AppTextField(
              controller: _passwordController,
              label: 'Mật khẩu',
              prefixIcon: Icons.key,
              isPassword: true,
              readOnly: isLoading,
              validator: (v) => v!.isEmpty ? 'Nhập pass' : null,
            ),

            // ✅ Dùng AppDimens.s8
            const SizedBox(height: AppDimens.s8),

            CheckboxListTile(
              // ✅ Dùng context.text.body1
              title: Text('Ghi nhớ đăng nhập', style: context.text.body1),
              value: _rememberMe,
              onChanged: isLoading
                  ? null
                  : (newValue) {
                      setState(() {
                        _rememberMe = newValue ?? false;
                      });
                    },
              // Checkbox mặc định ăn theo ColorScheme của Theme nên không cần set color thủ công
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            // ✅ Dùng AppDimens.s24 cho khoảng cách lớn hơn chút trước nút bấm
            const SizedBox(height: AppDimens.s24),

            AppButton(
              text: 'ĐĂNG NHẬP',
              isLoading: isLoading,
              onPressed: () {
                context.hideKeyboard();
                if (_formKey.currentState!.validate()) {
                  context.hideKeyboard();
                  if (_formKey.currentState!.validate()) {
                    context.read<LoginCubit>().login(
                      _usernameController.text,
                      _passwordController.text,
                      _rememberMe,
                    );
                  }
                }
              },
            ),

            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      context.hideKeyboard();
                      context.read<LoginCubit>().login(
                        'eve.holt@reqres.in',
                        '',
                        false,
                      );
                    },
              child: const Text('Test Đăng nhập lỗi'),
            ),
          ],
        ),
      ),
    );
  }
}
