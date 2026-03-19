import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

        final event = state.event;
        final failure = event.failure;

        switch (event.severity) {
          case ErrorSeverity.info:
          case ErrorSeverity.warning:
            _showSnackbar(context, failure, event.severity);
          case ErrorSeverity.critical:
            _showDialog(context, failure);
          case ErrorSeverity.fatal:
            _handleFatal(context, failure);
        }

        // Reset state sau khi đã xử lý
        errorCubit.dismiss();
      },
      child: child,
    );
  }

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

  void _showDialog(BuildContext context, Failure failure) {
    showDialog<void>(
      context: context,
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

  void _handleFatal(BuildContext context, Failure failure) {
    if (failure is AuthFailure) {
      // Session expired → redirect login
      GoRouter.of(context).go('/login');
    } else {
      // Các fatal khác → show dialog rồi để user tự xử lý
      _showDialog(context, failure);
    }
  }
}
