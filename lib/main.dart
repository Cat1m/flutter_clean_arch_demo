// main.dart
import 'package:flutter/material.dart';
import 'package:reqres_in/src/core/di/injection.dart' as di;
import 'package:reqres_in/src/features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  di.configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Arch Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Truyền repository vào LoginPage
      home: const LoginPage(),
    );
  }
}
