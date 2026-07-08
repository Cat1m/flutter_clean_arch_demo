import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reqres_in/src/core/crypto/rust_crypto_service.dart';
import 'package:reqres_in/src/core/storage/secure_storage_service.dart';
import 'package:reqres_in/src/rust/frb_generated.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => RustLib.init());

  group('RustCryptoService', () {
    test('encrypt rồi decrypt trả về đúng plaintext gốc', () async {
      final service = RustCryptoService();
      const plaintext = 'super secret token 123 - xin chào';

      final encrypted = await service.encrypt(plaintext);
      expect(encrypted, isNot(equals(plaintext)));

      final decrypted = await service.decrypt(encrypted);
      expect(decrypted, equals(plaintext));
    });
  });

  group('SecureStorageService (được mã hoá bằng Rust)', () {
    test('saveUserToken/getUserToken round-trip đúng giá trị gốc', () async {
      final storage = SecureStorageService(RustCryptoService());
      const token = 'jwt.token.value';

      await storage.saveUserToken(token);
      final result = await storage.getUserToken();

      expect(result, equals(token));

      await storage.clearAllTokens();
    });

    test('dữ liệu plaintext cũ (trước khi có mã hoá) không làm crash, '
        'tự dọn và trả về null', () async {
      const storageKey = 'user_token';
      const legacyJwt = 'header.payload.signature';

      // Ghi thẳng giá trị plaintext (giả lập dữ liệu lưu từ trước khi có
      // RustCryptoService), bỏ qua lớp mã hoá.
      const rawStorage = FlutterSecureStorage();
      await rawStorage.write(key: storageKey, value: legacyJwt);

      final storage = SecureStorageService(RustCryptoService());
      final result = await storage.getUserToken();

      expect(result, isNull);
      expect(await rawStorage.read(key: storageKey), isNull);
    });
  });
}
