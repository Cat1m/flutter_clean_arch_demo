// coverage:ignore-file
import 'package:flutter/material.dart';
import '../extensions/app_theme_extensions.dart';

/// Định nghĩa theme cho Dialog
class AppDialogTheme {
  const AppDialogTheme._();

  static DialogThemeData theme({
    required ColorScheme colors,
    required TextTheme textTheme,
    required AppRadiusData radius,
  }) {
    return DialogThemeData(
      backgroundColor: colors.surface,
      elevation: 0, // Tắt shadow mặc định
      shape: RoundedRectangleBorder(
        borderRadius: radius.l, // Bo góc 12.0
      ),
      titleTextStyle: textTheme.headlineSmall, // Dùng style tiêu đề
      contentTextStyle: textTheme.bodyMedium, // Dùng style nội dung
    );
  }
}
