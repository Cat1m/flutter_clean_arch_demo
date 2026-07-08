import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/logging/app_logger.dart';
import 'package:reqres_in/src/rust/api/crypto.dart' as rust_crypto;
import 'package:reqres_in/src/rust/api/kdf.dart' as rust_kdf;

const _tag = 'PinLockService';

class _PinStorageKeys {
  static const String salt = 'pin_kdf_salt';
  static const String protectedWallet = 'pin_protected_wallet';
}

/// Khoá 1 giá trị nhạy cảm bằng PIN 6 số: khoá AES dùng để mã hoá/giải mã
/// KHÔNG được lưu ở đâu cả, mà được derive lại từ PIN mỗi lần cần dùng (qua
/// Argon2id chạy native ở Rust) — nhập sai PIN thì derive ra khoá sai, AES-GCM
/// tự phát hiện qua auth tag nên thử giải mã thất bại chính là "PIN sai".
@lazySingleton
class PinLockService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
  );

  Future<bool> get isPinSet async {
    final salt = await _storage.read(key: _PinStorageKeys.salt);
    return salt != null;
  }

  Future<void> setPinAndProtect(String pin, String plaintext) async {
    AppLogger.info('🆕 Đặt PIN mới, sinh salt + derive khoá (Argon2)', tag: _tag);
    final salt = rust_kdf.generateSalt();
    final key = await rust_kdf.deriveKey(pin: pin, saltB64: salt);
    final encrypted = rust_crypto.encrypt(keyB64: key, plaintext: plaintext);

    await _storage.write(key: _PinStorageKeys.salt, value: salt);
    await _storage.write(
      key: _PinStorageKeys.protectedWallet,
      value: encrypted,
    );
    AppLogger.info('✅ Đã lưu salt + dữ liệu được PIN bảo vệ', tag: _tag);
  }

  Future<String?> verifyPinAndReveal(String pin) async {
    final salt = await _storage.read(key: _PinStorageKeys.salt);
    final encrypted = await _storage.read(
      key: _PinStorageKeys.protectedWallet,
    );
    if (salt == null || encrypted == null) {
      AppLogger.warning('⚠️ Chưa set PIN, không có gì để xác thực', tag: _tag);
      return null;
    }

    AppLogger.debug('🔑 Derive khoá từ PIN vừa nhập (Argon2)...', tag: _tag);
    try {
      final key = await rust_kdf.deriveKey(pin: pin, saltB64: salt);
      final revealed = rust_crypto.decrypt(keyB64: key, payloadB64: encrypted);
      AppLogger.info('✅ PIN đúng, đã giải mã dữ liệu', tag: _tag);
      return revealed;
    } on Object {
      // PIN sai → khoá derive sai → AES-GCM auth tag không khớp.
      AppLogger.warning('❌ Sai PIN (auth tag không khớp)', tag: _tag);
      return null;
    }
  }

  Future<void> resetPin() async {
    AppLogger.info('🧹 Reset PIN — xoá salt + dữ liệu đã bảo vệ', tag: _tag);
    await _storage.delete(key: _PinStorageKeys.salt);
    await _storage.delete(key: _PinStorageKeys.protectedWallet);
  }
}
