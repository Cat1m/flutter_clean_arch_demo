import 'package:retrofit/retrofit.dart';

/// Định nghĩa các loại xác thực cho API
enum AuthType {
  userToken, // Cần Bearer Token
  apiKey, // Cần API Key
  none, // Không cần gì (Public)
}

// Annotations dùng trong ApiService
const userToken = Extra({'auth_type': AuthType.userToken});
const apiKey = Extra({'auth_type': AuthType.apiKey});
const noAuth = Extra({'auth_type': AuthType.none});
