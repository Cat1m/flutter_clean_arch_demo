// lib/core/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart'; // Đây là file sẽ được sinh ra

@Envied(path: '.env') // Chỉ định đường dẫn tới file .env
abstract class Env {
  // 1. Base URL (Không cần làm rối vì nó thường công khai)
  @EnviedField(varName: 'BASE_URL', obfuscate: true)
  static final String baseUrl = _Env.baseUrl;

  // 1. Base URL (Không cần làm rối vì nó thường công khai)
  @EnviedField(varName: 'FILE_SERVER', obfuscate: true)
  static final String fileServer = _Env.fileServer;

  // 2. API Key (Làm rối để tăng bảo mật)
  // Lưu ý: Khi dùng obfuscate=true, phải dùng 'final' thay vì 'const'
  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static final String apiKey = _Env.apiKey;
}
//* dùng để gen code
//dart run build_runner build --delete-conflicting-outputs
//* đổi giá trị thì nhớ dùng dòng này trước rồi mới chạy dòng trên
//dart run build_runner clean