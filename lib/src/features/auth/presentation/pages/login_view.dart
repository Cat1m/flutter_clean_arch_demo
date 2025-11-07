import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/login_cubit.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng BlocConsumer để vừa lắng nghe state (hiện thông báo) vừa build lại UI
    return Scaffold(
      appBar: AppBar(title: const Text('Login (Page-View Pattern)')),
      body: BlocConsumer<LoginCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đăng nhập thành công! Token: ${state.token}'),
                backgroundColor: Colors.green,
              ),
            );
            // Điều hướng ở đây nếu cần: Navigator.pushReplacementNamed(...)
          }
        },
        builder: (context, state) {
          // Tách riêng hàm _buildBody để code gọn hơn
          return _buildBody(context, state);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AuthState state) {
    if (state is AuthLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
          const SizedBox(height: 40),

          // Các text field (Trong thực tế nên tách thành widget riêng nếu phức tạp)
          TextField(
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            // Để đơn giản ta dùng hardcode, dự án thật dùng Controller
            controller: TextEditingController(text: 'eve.holt@reqres.in'),
          ),
          const SizedBox(height: 16),
          TextField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mật khẩu',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.key),
            ),
            controller: TextEditingController(text: 'cityslicka'),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              // Gọi Cubit từ context
              context.read<LoginCubit>().login(
                'eve.holt@reqres.in',
                'cityslicka',
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 18)),
          ),

          TextButton(
            onPressed: () {
              // Test trường hợp lỗi
              context.read<LoginCubit>().login('eve.holt@reqres.in', '');
            },
            child: const Text('Test Đăng nhập lỗi'),
          ),
        ],
      ),
    );
  }
}
