import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/crypto/rust_crypto_service.dart';
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
  SecureStorageService(this._cryptoService);

  // Tạo một instance singleton cho FlutterSecureStorage
  final _storage = const FlutterSecureStorage(
    // Tùy chọn: Thêm các tùy chọn bảo mật cho Android
    // aOptions: AndroidOptions(
    //   encryptedSharedPreferences: true,
    // ),
  );

  // Mã hoá thêm 1 lớp AES-256-GCM (native, viết bằng Rust) trước khi lưu,
  // để dữ liệu vẫn an toàn ngay cả khi secure storage của OS bị xâm phạm.
  final RustCryptoService _cryptoService;

  // --- User Token ---
  Future<void> saveUserToken(String token) async {
    final encrypted = await _cryptoService.encrypt(token);
    await _storage.write(key: _StorageKeys.userToken, value: encrypted);
  }

  Future<String?> getUserToken() => _readAndDecrypt(_StorageKeys.userToken);

  // --- Refresh Token (Cho tương lai) ---
  Future<void> saveRefreshToken(String token) async {
    final encrypted = await _cryptoService.encrypt(token);
    await _storage.write(key: _StorageKeys.refreshToken, value: encrypted);
  }

  Future<String?> getRefreshToken() =>
      _readAndDecrypt(_StorageKeys.refreshToken);

  Future<void> saveUserData(LoginResponse response) async {
    // Chuyển đối tượng LoginResponse thành JSON string rồi mã hoá
    final jsonString = jsonEncode(response.toJson());
    final encrypted = await _cryptoService.encrypt(jsonString);
    await _storage.write(key: _StorageKeys.userData, value: encrypted);
  }

  Future<LoginResponse?> getUserData() async {
    final jsonString = await _readAndDecrypt(_StorageKeys.userData);
    if (jsonString == null || jsonString.isEmpty) return null;
    // Chuyển JSON string ngược lại thành đối tượng LoginResponse
    return LoginResponse.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  // Đọc giá trị đã mã hoá và giải mã. Nếu đọc/giải mã thất bại (dữ liệu
  // plaintext còn sót lại từ trước khi có tính năng mã hoá, ciphertext của
  // chính flutter_secure_storage bị hỏng do đổi Keystore/cài lại app, v.v.),
  // coi như chưa có dữ liệu và tự dọn key hỏng đó thay vì crash app.
  Future<String?> _readAndDecrypt(String key) async {
    try {
      final encrypted = await _storage.read(key: key);
      if (encrypted == null || encrypted.isEmpty) return null;
      return await _cryptoService.decrypt(encrypted);
    } on Object {
      await _storage.delete(key: key);
      return null;
    }
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
