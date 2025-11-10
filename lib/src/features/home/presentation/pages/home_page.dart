import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqres_in/src/core/di/injection.dart';
import 'package:reqres_in/src/features/auth/models/auth_models.dart';
import 'package:reqres_in/src/features/home/presentation/pages/home_view.dart';
import 'package:reqres_in/src/features/quote/cubit/quote_cubit.dart';

class HomePage extends StatelessWidget {
  // 1. Nhận dữ liệu (giữ nguyên)
  final LoginResponse userData;

  const HomePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    // 2. Cung cấp Cubit cho cây widget
    return BlocProvider(
      create: (context) =>
          getIt<QuoteCubit>()..fetchRandomQuote(), // Lấy từ DI và gọi hàm fetch
      child: HomeView(userData: userData), // 3. Trả về "View" (dumb widget)
    );
  }
}
