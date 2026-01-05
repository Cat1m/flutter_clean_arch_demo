import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/features/auth/models/auth_models.dart';

// Định nghĩa các key chúng ta sẽ dùng
// Dùng const giúp tránh lỗi gõ nhầm
class _StorageKeys {
  static const String userToken = 'user_token';
  static const String refreshToken = 'refresh_token';
  static const String userData = 'user_data';
  // Bạn cũng có thể lưu API Key ở đây nếu nó bí mật
}

@lazySingleton
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

  Future<void> saveUserData(LoginResponse response) async {
    // Chuyển đối tượng LoginResponse thành JSON string
    final jsonString = jsonEncode(response.toJson());
    await _storage.write(key: _StorageKeys.userData, value: jsonString);
  }

  Future<LoginResponse?> getUserData() async {
    final jsonString = await _storage.read(key: _StorageKeys.userData);
    if (jsonString != null && jsonString.isNotEmpty) {
      // Chuyển JSON string ngược lại thành đối tượng LoginResponse
      return LoginResponse.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  // --- Xóa Token (Khi logout) ---
  Future<void> clearAllTokens() async {
    // Xóa từng key một
    await _storage.delete(key: _StorageKeys.userToken);
    await _storage.delete(key: _StorageKeys.refreshToken);
    await _storage.delete(key: _StorageKeys.userData);

    // Hoặc xóa tất cả
    // await _storage.deleteAll();
  }
}
