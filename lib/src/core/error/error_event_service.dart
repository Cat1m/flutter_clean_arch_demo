import 'dart:async';

import 'package:injectable/injectable.dart';

import 'error_event.dart';

/// Singleton stream broadcast bus cho error events toàn app.
///
/// Bất kỳ layer nào (Interceptor, Cubit, Repository) đều có thể
/// emit [ErrorEvent] lên bus này. [ErrorCubit] listen và xử lý.
@lazySingleton
class ErrorEventService {
  final StreamController<ErrorEvent> _controller =
      StreamController<ErrorEvent>.broadcast();

  /// Stream để [ErrorCubit] subscribe.
  Stream<ErrorEvent> get errorStream => _controller.stream;

  /// Emit một error event lên bus.
  void emit(ErrorEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  @disposeMethod
  void dispose() {
    _controller.close();
  }
}
