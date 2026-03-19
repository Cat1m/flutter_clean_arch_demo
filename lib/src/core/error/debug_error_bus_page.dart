import 'package:flutter/material.dart';

import '../di/injection.dart';
import '../network/failures.dart';
import 'error_event.dart';
import 'error_event_service.dart';
import 'error_severity.dart';

/// Trang debug để test Error Bus module.
///
/// Chỉ nên truy cập trong debug mode (kDebugMode).
/// Mỗi nút emit một loại error event khác nhau để verify
/// GlobalErrorListener phản ứng đúng (snackbar/dialog/redirect).
class DebugErrorBusPage extends StatelessWidget {
  const DebugErrorBusPage({super.key});

  ErrorEventService get _errorEventService => getIt<ErrorEventService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Error Bus')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Severity Tests',
            'Mỗi nút emit error với severity khác nhau',
            [
              _TestButton(
                label: 'INFO — Snackbar nhẹ',
                subtitle: 'CacheFailure + info',
                color: Colors.blue,
                onPressed: () => _emit(
                  const CacheFailure('Dùng data cache (demo)'),
                  ErrorSeverity.info,
                  'DebugPage',
                ),
              ),
              _TestButton(
                label: 'WARNING — Snackbar cam',
                subtitle: 'ConnectionFailure + warning',
                color: Colors.orange,
                onPressed: () => _emit(
                  const ConnectionFailure('Mất kết nối tạm thời (demo)'),
                  ErrorSeverity.warning,
                  'DebugPage',
                ),
              ),
              _TestButton(
                label: 'CRITICAL — Dialog',
                subtitle: 'ServerFailure 500 + critical',
                color: Colors.red,
                onPressed: () => _emit(
                  const ServerFailure(
                    'Internal Server Error (demo)',
                    statusCode: 500,
                  ),
                  ErrorSeverity.critical,
                  'DebugPage',
                ),
              ),
              _TestButton(
                label: 'FATAL — Redirect Login',
                subtitle: 'AuthFailure + fatal → redirect /login',
                color: Colors.purple,
                onPressed: () => _emit(
                  AuthFailure.tokenExpired,
                  ErrorSeverity.fatal,
                  'DebugPage',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Dedup Test',
            'Emit 5 ServerFailure liên tiếp — chỉ hiện 1 dialog (dedup 3s)',
            [
              _TestButton(
                label: 'Emit 5x ServerFailure 500',
                subtitle: 'Expect: chỉ 1 dialog (dedup by runtimeType)',
                color: Colors.red.shade800,
                onPressed: () {
                  for (var i = 0; i < 5; i++) {
                    _emit(
                      ServerFailure('Server Error #${i + 1}', statusCode: 500),
                      ErrorSeverity.critical,
                      'DebugPage-Dedup',
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Multi-type Test',
            'Emit 2 loại khác nhau — cả 2 đều hiện (không dedup khác type)',
            [
              _TestButton(
                label: 'ServerFailure + ConnectionFailure',
                subtitle: 'Expect: 1 dialog + 1 snackbar',
                color: Colors.teal,
                onPressed: () {
                  _emit(
                    const ServerFailure('Server 503 (demo)', statusCode: 503),
                    ErrorSeverity.critical,
                    'DebugPage-Multi',
                  );
                  _emit(
                    const ConnectionFailure('Offline (demo)'),
                    ErrorSeverity.warning,
                    'DebugPage-Multi',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _emit(Failure failure, ErrorSeverity severity, String source) {
    _errorEventService.emit(
      ErrorEvent(failure: failure, severity: severity, source: source),
    );
  }

  Widget _buildSection(
    String title,
    String description,
    List<Widget> buttons,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
        )),
        const SizedBox(height: 12),
        ...buttons,
      ],
    );
  }
}

class _TestButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  const _TestButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              )),
              Text(subtitle, style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
