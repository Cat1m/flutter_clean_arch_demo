// lib/src/core/services/auth_event_service.dart
import 'dart:async';

import 'package:injectable/injectable.dart';

/// Một service singleton (LazySingleton) hoạt động như một cầu nối.
///
/// Vai trò: Cho phép các tầng sâu (như Interceptor) gửi thông báo
/// lên tầng Presentation (như Cubit) mà không bị phụ thuộc lẫn nhau.
@lazySingleton
class AuthEventService {
  // 1. Tạo một StreamController.
  // Chúng ta dùng `broadcast` để nhiều nơi có thể lắng nghe (nếu cần).
  final StreamController<void> _controller = StreamController.broadcast();

  // 2. Tạo một Stream public để bên ngoài (Cubit) lắng nghe
  Stream<void> get onSessionExpired => _controller.stream;

  /// 3. Hàm để Interceptor gọi khi refresh token thất bại
  void notifySessionExpired() {
    _controller.add(null);
  }

  // 4. Đừng quên đóng controller khi không cần nữa
  // (Trong trường hợp singleton thì nó sẽ sống suốt app)
  void dispose() {
    _controller.close();
  }
}
