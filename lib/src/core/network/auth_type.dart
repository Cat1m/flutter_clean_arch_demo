// lib/core/network/auth_type.dart
import 'package:retrofit/retrofit.dart';

// 1. Định nghĩa các loại xác thực
enum AuthType {
  /// Cần "vé chơi trò chơi" (Token của User)
  userToken,

  /// Chỉ cần "vé vào cổng" (API Key)
  apiKey,

  /// Không cần gì cả (ví dụ: API Login, Register)
  none,
}

// 2. Tạo các "nhãn" (annotations)
// Đây là hằng số, sẽ được dùng trong api_service.dart
const userToken = Extra({'auth_type': AuthType.userToken});
const apiKey = Extra({'auth_type': AuthType.apiKey});
const noAuth = Extra({'auth_type': AuthType.none});
