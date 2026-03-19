import 'package:equatable/equatable.dart';

import 'error_event.dart';

/// State của [ErrorCubit].
///
/// - [ErrorIdle]: Không có error (initial + sau dismiss)
/// - [ErrorReceived]: Có error mới cần UI xử lý
sealed class ErrorState extends Equatable {
  const ErrorState();

  @override
  List<Object?> get props => [];
}

/// Không có error nào đang active.
class ErrorIdle extends ErrorState {
  const ErrorIdle();
}

/// Có error mới, UI cần phản ứng theo [event.severity].
class ErrorReceived extends ErrorState {
  final ErrorEvent event;

  const ErrorReceived(this.event);

  @override
  List<Object?> get props => [event];
}
