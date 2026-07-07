// lib/core/logging/app_logger.dart

import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

/// Structured logging utility dùng `dart:developer.log` (giống
/// `LoggerInterceptor` cho HTTP traffic) thay cho `print()` rải rác.
///
/// Chỉ log khi [kDebugMode]. Khi cần crash reporting thật (Sentry/Crashlytics),
/// gửi [error]/[stackTrace] cho service đó ngay trong [_log] trước dòng
/// `if (!kDebugMode) return;`.
class AppLogger {
  AppLogger._();

  static void debug(String message, {String? tag}) =>
      _log(message, tag: tag, level: 500);

  static void info(String message, {String? tag}) =>
      _log(message, tag: tag, level: 800);

  static void warning(String message, {String? tag}) =>
      _log(message, tag: tag, level: 900);

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) => _log(
    message,
    tag: tag,
    level: 1000,
    error: error,
    stackTrace: stackTrace,
  );

  static void _log(
    String message, {
    String? tag,
    required int level,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;
    dev.log(
      message,
      name: tag ?? 'App',
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
