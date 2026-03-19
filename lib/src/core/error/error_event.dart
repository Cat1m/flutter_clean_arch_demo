import 'package:equatable/equatable.dart';

import '../network/failures.dart';
import 'error_severity.dart';

/// Event chứa thông tin error được emit lên Error Bus.
///
/// Immutable, dùng Equatable để so sánh.
/// [source] hữu ích cho debug/history (vd: "ErrorInterceptor", "UserCubit").
class ErrorEvent extends Equatable {
  final Failure failure;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final String? source;

  ErrorEvent({
    required this.failure,
    required this.severity,
    DateTime? timestamp,
    this.source,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [failure, severity, timestamp, source];
}
