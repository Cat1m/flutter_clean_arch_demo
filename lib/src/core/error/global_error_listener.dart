import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../navigation/router_module.dart';
import '../network/failures.dart';
import 'error_cubit.dart';
import 'error_severity.dart';
import 'error_state.dart';

/// Widget bọc child trong [BlocListener<ErrorCubit>].
///
/// Đặt trong `MaterialApp.builder` để react toàn cục với error events.
/// Map [ErrorSeverity] → UI action:
/// - info/warning → Snackbar
/// - critical → Dialog
/// - fatal → Redirect (AuthFailure → login, khác → error page)
///
/// Vì widget này nằm **trên** Navigator trong widget tree
/// (MaterialApp.builder), nên dùng [rootNavigatorKey] để lấy
/// context bên dưới Navigator cho showDialog/GoRouter.
class GlobalErrorListener extends StatelessWidget {
  final ErrorCubit errorCubit;
  final Widget child;

  const GlobalErrorListener({
    super.key,
    required this.errorCubit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ErrorCubit, ErrorState>(
      bloc: errorCubit,
      listener: (context, state) {
        if (state is! ErrorReceived) return;

        // Lấy context từ Navigator (bên dưới MaterialApp)
        // thay vì context của BlocListener (bên trên Navigator).
        final navContext = rootNavigatorKey.currentContext;
        if (navContext == null) return;

        final event = state.event;
        final failure = event.failure;

        switch (event.severity) {
          case ErrorSeverity.info:
          case ErrorSeverity.warning:
            _showSnackbar(context, failure, event.severity);
          case ErrorSeverity.critical:
            _showDialog(navContext, failure);
          case ErrorSeverity.fatal:
            _handleFatal(navContext, failure);
        }

        // Reset state sau khi đã xử lý
        errorCubit.dismiss();
      },
      child: child,
    );
  }

  /// Snackbar dùng [ScaffoldMessenger] — context của MaterialApp.builder
  /// là OK vì ScaffoldMessenger nằm ở tầng MaterialApp.
  void _showSnackbar(
    BuildContext context,
    Failure failure,
    ErrorSeverity severity,
  ) {
    final isWarning = severity == ErrorSeverity.warning;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            failure.message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: isWarning ? Colors.orange.shade700 : Colors.blue,
          duration: Duration(seconds: isWarning ? 4 : 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  /// Dialog cần [navContext] — context bên dưới Navigator.
  void _showDialog(BuildContext navContext, Failure failure) {
    showDialog<void>(
      context: navContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Lỗi hệ thống'),
          content: Text(failure.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Đã hiểu'),
            ),
          ],
        );
      },
    );
  }

  void _handleFatal(BuildContext navContext, Failure failure) {
    if (failure is AuthFailure) {
      // Session expired → redirect login
      GoRouter.of(navContext).go('/login');
    } else {
      // Các fatal khác → show dialog
      _showDialog(navContext, failure);
    }
  }
}
