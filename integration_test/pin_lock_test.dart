import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reqres_in/src/core/crypto/pin_lock_service.dart';
import 'package:reqres_in/src/rust/frb_generated.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => RustLib.init());

  group('PinLockService', () {
    test('chưa set PIN thì isPinSet = false', () async {
      final service = PinLockService();
      await service.resetPin();

      expect(await service.isPinSet, isFalse);
    });

    test('setPinAndProtect rồi verifyPinAndReveal đúng PIN trả về plaintext gốc', () async {
      final service = PinLockService();
      const pin = '135790';
      const walletValue = '0xABCDEF1234567890';

      await service.setPinAndProtect(pin, walletValue);
      expect(await service.isPinSet, isTrue);

      final revealed = await service.verifyPinAndReveal(pin);
      expect(revealed, equals(walletValue));

      await service.resetPin();
    });

    test('verifyPinAndReveal với PIN sai trả về null, không crash', () async {
      final service = PinLockService();
      const correctPin = '111111';
      const wrongPin = '222222';

      await service.setPinAndProtect(correctPin, 'giá trị bí mật');

      final revealed = await service.verifyPinAndReveal(wrongPin);
      expect(revealed, isNull);

      await service.resetPin();
    });

    test('sau resetPin, isPinSet lại về false', () async {
      final service = PinLockService();
      await service.setPinAndProtect('123123', 'tạm thời');
      expect(await service.isPinSet, isTrue);

      await service.resetPin();
      expect(await service.isPinSet, isFalse);
    });
  });
}
