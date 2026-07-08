import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/logging/app_logger.dart';
import 'package:reqres_in/src/rust/api/crypto.dart' as rust_crypto;

const _tag = 'RustCryptoService';

// Key lưu khoá master AES, tách riêng khỏi SecureStorageService
// để tránh phụ thuộc vòng (SecureStorageService sẽ dùng service này).
class _CryptoStorageKeys {
  static const String encryptionKey = 'local_encryption_key';
}

/// Mã hoá/giải mã dữ liệu bằng AES-256-GCM (thực thi native ở Rust qua
/// flutter_rust_bridge). Khoá master được sinh ngẫu nhiên một lần rồi lưu
/// trong secure storage của hệ điều hành.
@lazySingleton
class RustCryptoService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
  );
  String? _cachedKey;

  Future<String> _getOrCreateKey() async {
    final cached = _cachedKey;
    if (cached != null) return cached;

    String? key;
    try {
      key = await _storage.read(key: _CryptoStorageKeys.encryptionKey);
    } on Object catch (e) {
      // Ciphertext của flutter_secure_storage bị hỏng (đổi Keystore, cài lại
      // app, v.v.) — coi như chưa từng có khoá, sinh khoá mới thay vì crash.
      AppLogger.warning(
        '⚠️ Đọc khoá master thất bại, sẽ sinh khoá mới: $e',
        tag: _tag,
      );
      key = null;
    }
    if (key == null) {
      AppLogger.info('🔑 Chưa có khoá master, sinh khoá AES-256 mới', tag: _tag);
      key = rust_crypto.generateKey();
      await _storage.write(
        key: _CryptoStorageKeys.encryptionKey,
        value: key,
      );
    } else {
      AppLogger.debug('🔑 Dùng khoá master đã lưu', tag: _tag);
    }
    _cachedKey = key;
    return key;
  }

  Future<String> encrypt(String plaintext) async {
    final key = await _getOrCreateKey();
    final encrypted = rust_crypto.encrypt(keyB64: key, plaintext: plaintext);
    AppLogger.debug(
      '🔒 Encrypt ${plaintext.length} ký tự → payload ${encrypted.length} ký tự',
      tag: _tag,
    );
    return encrypted;
  }

  Future<String> decrypt(String payload) async {
    final key = await _getOrCreateKey();
    final decrypted = rust_crypto.decrypt(keyB64: key, payloadB64: payload);
    AppLogger.debug('🔓 Decrypt thành công (${decrypted.length} ký tự)', tag: _tag);
    return decrypted;
  }
}
