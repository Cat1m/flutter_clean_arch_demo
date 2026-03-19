import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'error_event.dart';
import 'error_event_service.dart';
import 'error_state.dart';

/// Singleton cubit quản lý error state toàn app.
///
/// Listen [ErrorEventService.errorStream], áp dụng dedup theo
/// `failure.runtimeType` trong [dedupWindow], rồi emit [ErrorState].
@lazySingleton
class ErrorCubit extends Cubit<ErrorState> {
  final ErrorEventService _errorEventService;
  late final StreamSubscription<ErrorEvent> _subscription;

  /// Map lưu timestamp emit gần nhất theo failure runtimeType.
  /// Dùng cho dedup: cùng loại failure trong [dedupWindow] → bỏ qua.
  final Map<Type, DateTime> _dedupMap = {};

  /// Khoảng thời gian dedup. Mặc định 3 giây.
  final Duration dedupWindow;

  ErrorCubit(
    this._errorEventService, {
    this.dedupWindow = const Duration(seconds: 3),
  }) : super(const ErrorIdle()) {
    _subscription = _errorEventService.errorStream.listen(_onErrorEvent);
  }

  void _onErrorEvent(ErrorEvent event) {
    final failureType = event.failure.runtimeType;
    final now = DateTime.now();

    // Dedup: cùng runtimeType trong dedupWindow → bỏ qua
    final lastEmit = _dedupMap[failureType];
    if (lastEmit != null && now.difference(lastEmit) < dedupWindow) {
      return;
    }

    _dedupMap[failureType] = now;
    emit(ErrorReceived(event));
  }

  /// UI gọi sau khi đã show error (snackbar/dialog) để reset state.
  void dismiss() => emit(const ErrorIdle());

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
