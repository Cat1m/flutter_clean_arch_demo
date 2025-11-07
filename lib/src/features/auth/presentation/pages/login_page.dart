import 'package:flutter/material.dart';
import 'package:reqres_in/src/features/auth/presentation/pages/login_view.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐️ KHÔNG CẦN BlocProvider.value Ở ĐÂY NỮA
    // Chỉ cần trả về LoginView vì Cubit đã có sẵn từ context
    return const LoginView();
  }
}
