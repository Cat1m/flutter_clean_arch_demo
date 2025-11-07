import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqres_in/src/core/di/injection.dart';
import 'package:reqres_in/src/features/user/presentation/bloc/user_cubit.dart';
import 'package:reqres_in/src/features/user/presentation/pages/user_view.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // 1. Dùng getIt để tạo một instance UserCubit mới
      create: (context) => getIt<UserCubit>(),
      // 2. Widget con là UserView
      child: const UserView(),
    );
  }
}
