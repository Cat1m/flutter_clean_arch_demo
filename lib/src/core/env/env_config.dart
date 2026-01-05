// lib/src/core/env/env_config.dart

import 'package:reqres_in/src/core/env/env.dart';
import 'package:reqres_in/src/core/env/env_mode.dart';

class EnvConfig {
  // 🔧 CONFIG: Đổi môi trường tại đây
  static const EnvMode mode = EnvMode.prod;

  // Map URL tương ứng với từng Mode
  static const Map<EnvMode, String> _urls = {
    EnvMode.dev: 'https://dev-api.reqres.in', // Ví dụ
    EnvMode.localAndroid: 'http://10.0.2.2:8080',
    EnvMode.localIos: 'http://localhost:8080',
    EnvMode.ngrok: 'https://your-ngrok-id.ngrok-free.app',
  };

  /// Logic chọn URL:
  /// - Nếu là Prod: Lấy từ file .env (Bảo mật)
  /// - Nếu là Dev/Local: Lấy từ Map cấu hình bên trên
  static String get baseUrl {
    if (mode == EnvMode.prod) {
      return Env.baseUrl; // Lấy từ Envied
    }
    // Trả về URL test, nếu không có thì fallback về Prod
    return _urls[mode] ?? Env.baseUrl;
  }
}
