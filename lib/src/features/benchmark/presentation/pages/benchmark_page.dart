import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reqres_in/src/core/ui/ui.dart';
import 'package:reqres_in/src/rust/api/benchmark.dart' as rust_benchmark;

const _nOptions = [28, 32, 36, 40];

/// Fibonacci đệ quy thuần bằng Dart — y hệt thuật toán Rust, để so sánh công bằng.
int _fibDart(int n) => n < 2 ? n : _fibDart(n - 1) + _fibDart(n - 2);

class _DartBenchmarkResult {
  const _DartBenchmarkResult(this.result, this.elapsedMicros);

  final int result;
  final int elapsedMicros;
}

/// Chạy trong isolate riêng qua `compute()` để không treo UI thread.
/// Đo thời gian bằng Stopwatch BÊN TRONG isolate, loại trừ overhead spawn isolate.
_DartBenchmarkResult _runDartBenchmark(int n) {
  final stopwatch = Stopwatch()..start();
  final result = _fibDart(n);
  stopwatch.stop();
  return _DartBenchmarkResult(result, stopwatch.elapsedMicroseconds);
}

class BenchmarkPage extends StatefulWidget {
  const BenchmarkPage({super.key});

  @override
  State<BenchmarkPage> createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends State<BenchmarkPage> {
  int _selectedN = _nOptions[1];
  bool _isRunning = false;

  _DartBenchmarkResult? _dartResult;
  rust_benchmark.FibBenchmarkResult? _rustResult;

  Future<void> _runBenchmark() async {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _dartResult = null;
      _rustResult = null;
    });

    // Chạy tuần tự (không song song) để tránh 2 bên tranh CPU làm sai lệch kết quả đo.
    final dartResult = await compute(_runDartBenchmark, _selectedN);
    final rustResult = await rust_benchmark.runFibonacciBenchmark(n: _selectedN);

    if (!mounted) return;
    setState(() {
      _dartResult = dartResult;
      _rustResult = rustResult;
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Benchmark: Dart vs Rust')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.speed, size: AppDimens.icXL, color: context.colors.primary),
              const SizedBox(height: AppDimens.s20),
              Text('So sánh tốc độ tính Fibonacci', style: context.text.h2),
              const SizedBox(height: AppDimens.s8),
              Text(
                'Đệ quy thuần, không nhớ đệm — Dart (isolate) vs Rust (native)',
                style: context.text.caption.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.s8),
              const Wrap(
                spacing: AppDimens.s4,
                alignment: WrapAlignment.center,
                children: [
                  AppBadge(label: 'flutter_rust_bridge'),
                  AppBadge(label: 'compute() isolate'),
                ],
              ),
              const SizedBox(height: AppDimens.s16),
              _buildBuildModeNotice(context),
              const SizedBox(height: AppDimens.s24),
              DropdownButton<int>(
                value: _selectedN,
                items: _nOptions
                    .map((n) => DropdownMenuItem(value: n, child: Text('fib($n)')))
                    .toList(),
                onChanged: _isRunning
                    ? null
                    : (n) => setState(() => _selectedN = n ?? _selectedN),
              ),
              const SizedBox(height: AppDimens.s24),
              _isRunning
                  ? const CircularProgressIndicator()
                  : AppButton(
                      text: 'Chạy Benchmark',
                      icon: Icons.bolt,
                      isExpanded: false,
                      onPressed: _runBenchmark,
                    ),
              const SizedBox(height: AppDimens.s32),
              if (_dartResult != null && _rustResult != null)
                _buildResultCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final dart = _dartResult!;
    final rust = _rustResult!;
    final rustMicros = rust.elapsedMicros.toInt();
    final dartMs = dart.elapsedMicros / 1000;
    final rustMs = rustMicros / 1000;
    final speedup = rustMs == 0 ? 0 : dartMs / rustMs;
    final resultsMatch = dart.result == rust.result.toInt();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultRow(context, 'Dart', dartMs),
          const SizedBox(height: AppDimens.s8),
          _buildResultRow(context, 'Rust', rustMs),
          const Divider(height: AppDimens.s24),
          Text(
            speedup >= 1
                ? '🚀 Rust nhanh hơn ${speedup.toStringAsFixed(1)}x'
                : 'Dart nhanh hơn ${(1 / speedup).toStringAsFixed(1)}x',
            style: context.text.h3,
          ),
          const SizedBox(height: AppDimens.s4),
          Text(
            resultsMatch
                ? '✅ Kết quả khớp: fib($_selectedN) = ${dart.result}'
                : '⚠️ Kết quả KHÔNG khớp: Dart=${dart.result}, Rust=${rust.result}',
            style: context.text.caption,
          ),
        ],
      ),
    );
  }

  // cargokit build Rust ĐÚNG theo profile của Flutter: `flutter run` (debug)
  // → Rust cũng build debug (không tối ưu, có thể CHẬM hơn Dart); chỉ
  // `flutter run --release` mới build Rust ở chế độ tối ưu để so sánh đúng.
  Widget _buildBuildModeNotice(BuildContext context) {
    final message = kReleaseMode
        ? '✅ Đang chạy RELEASE — Rust đã được tối ưu hoá, số liệu phản ánh đúng hiệu năng thật.'
        : '⚠️ Đang chạy DEBUG — Rust build KHÔNG tối ưu, có thể CHẬM hơn Dart. '
              'Chạy "flutter run --release" để thấy Rust nhanh hơn đúng thực tế.';
    final color = kReleaseMode ? context.colors.success : context.colors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s12,
        vertical: AppDimens.s8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.r8),
        border: Border.all(color: color),
      ),
      child: Text(
        message,
        style: context.text.caption.copyWith(color: color),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, String label, double ms) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.text.body1.copyWith(fontWeight: FontWeight.bold)),
        Text('${ms.toStringAsFixed(2)} ms'),
      ],
    );
  }
}
