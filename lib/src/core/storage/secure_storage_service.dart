import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Định nghĩa các key chúng ta sẽ dùng
// Dùng const giúp tránh lỗi gõ nhầm
class _StorageKeys {
  static const String userToken = 'user_token';
  static const String refreshToken = 'refresh_token';
  // Bạn cũng có thể lưu API Key ở đây nếu nó bí mật
}

class SecureStorageService {
  // Tạo một instance singleton cho FlutterSecureStorage
  final _storage = const FlutterSecureStorage(
    // Tùy chọn: Thêm các tùy chọn bảo mật cho Android
    // aOptions: AndroidOptions(
    //   encryptedSharedPreferences: true,
    // ),
  );

  // --- User Token ---
  Future<void> saveUserToken(String token) async {
    await _storage.write(key: _StorageKeys.userToken, value: token);
  }

  Future<String?> getUserToken() async {
    return _storage.read(key: _StorageKeys.userToken);
  }

  // --- Refresh Token (Cho tương lai) ---
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _StorageKeys.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _StorageKeys.refreshToken);
  }

  // --- Xóa Token (Khi logout) ---
  Future<void> clearAllTokens() async {
    // Xóa từng key một
    await _storage.delete(key: _StorageKeys.userToken);
    await _storage.delete(key: _StorageKeys.refreshToken);

    // Hoặc xóa tất cả
    // await _storage.deleteAll();
  }
}
