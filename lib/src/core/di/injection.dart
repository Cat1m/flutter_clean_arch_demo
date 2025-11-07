// lib/src/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart'; // File này sẽ được tự động sinh ra

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // Tên hàm khởi tạo mặc định
  preferRelativeImports: true, // Dùng import tương đối cho gọn
  asExtension: true, // Sử dụng extension method cho GetIt
)
void configureDependencies() => getIt.init();
