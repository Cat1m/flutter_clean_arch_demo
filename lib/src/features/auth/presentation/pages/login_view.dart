import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/login_cubit.dart';

// ⭐️ 1. Chuyển thành StatefulWidget
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // ⭐️ 2. Tạo FormKey và Controllers
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'emilys');
  final _passwordController = TextEditingController(text: 'emilyspass');
  bool _rememberMe = false; // ⭐️ 3. Thêm state cho checkbox

  @override
  void dispose() {
    // ⭐️ 4. Hủy các controller
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng BlocConsumer để vừa lắng nghe state (hiện thông báo) vừa build lại UI
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<LoginCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Tách riêng hàm _buildBody để code gọn hơn
          // ⭐️ 5. Truyền state vào _buildBody
          return _buildBody(context, state);
        },
      ),
    );
  }

  // ⭐️ 6. Chuyển _buildBody vào trong State
  Widget _buildBody(BuildContext context, AuthState state) {
    // Hiển thị loading đè lên form khi đang đăng nhập
    final bool isLoading = state is AuthLoading;

    // ⭐️ 7. Bọc Form và SingleChildScrollView
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        // Thêm SingleChildScrollView để tránh lỗi pixel khi bàn phím hiện
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
            const SizedBox(height: 40),

            // ⭐️ 8. Dùng TextFormField
            TextFormField(
              controller: _usernameController, // Dùng controller
              decoration: const InputDecoration(
                labelText: 'UserName',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập username';
                }
                return null;
              },
              readOnly: isLoading, // Không cho sửa khi đang loading
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController, // Dùng controller
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                return null;
              },
              readOnly: isLoading, // Không cho sửa khi đang loading
            ),
            const SizedBox(height: 8),

            // ⭐️ 9. Thêm CheckboxListTile
            CheckboxListTile(
              title: const Text('Ghi nhớ đăng nhập'),
              value: _rememberMe,
              onChanged:
                  isLoading // Vô hiệu hóa khi đang loading
                  ? null
                  : (newValue) {
                      setState(() {
                        _rememberMe = newValue ?? false;
                      });
                    },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // ⭐️ 10. Cập nhật ElevatedButton
            ElevatedButton(
              onPressed: isLoading
                  ? null // Vô hiệu hóa nút khi đang loading
                  : () {
                      // 1. Validate form
                      if (_formKey.currentState!.validate()) {
                        // 2. Gọi Cubit với giá trị từ controllers và checkbox
                        context.read<LoginCubit>().login(
                          _usernameController.text,
                          _passwordController.text,
                          _rememberMe,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 18)),
            ),

            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      // Test trường hợp lỗi
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
