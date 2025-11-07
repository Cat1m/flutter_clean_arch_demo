import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqres_in/src/features/home/presentation/pages/home_page.dart';
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
            // 2. THAY ĐỔI TẠI ĐÂY
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  // Dùng firstName cho lời chào
                  'Đăng nhập thành công! Xin chào ${state.loginResponse.firstName}!',
                ),
                backgroundColor: Colors.green,
              ),
            );
            // 3. ĐIỀU HƯỚNG TỚI HOME
            // Dùng pushReplacement để người dùng không thể "Back" về màn Login
            Navigator.of(context).pushReplacement(
              // Gọi static helper 'route' ta đã tạo
              HomePage.route(state.loginResponse),
            );
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
              labelText: 'UserName',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            // Để đơn giản ta dùng hardcode, dự án thật dùng Controller
            controller: TextEditingController(text: 'emilys'),
          ),
          const SizedBox(height: 16),
          TextField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mật khẩu',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.key),
            ),
            controller: TextEditingController(text: 'emilyspass'),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              // Gọi Cubit từ context
              context.read<LoginCubit>().login('emilys', 'emilyspass');
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
