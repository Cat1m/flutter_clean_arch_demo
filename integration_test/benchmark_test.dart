import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reqres_in/src/rust/api/benchmark.dart';
import 'package:reqres_in/src/rust/frb_generated.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => RustLib.init());

  group('runFibonacciBenchmark', () {
    test('fib(10) trả về đúng kết quả 55 qua FFI', () async {
      final benchmark = await runFibonacciBenchmark(n: 10);

      expect(benchmark.result.toInt(), equals(55));
      expect(benchmark.elapsedMicros.toInt(), greaterThanOrEqualTo(0));
    });
  });
}
