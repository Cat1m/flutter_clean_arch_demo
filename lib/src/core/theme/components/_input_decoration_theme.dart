// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:reqres_in/src/core/theme/extensions/app_theme_extensions.dart';
import '../tokens/tokens.dart';

/// Định nghĩa theme cho InputDecoration (TextFields)
class AppInputDecorationTheme {
  const AppInputDecorationTheme._();

  static InputDecorationTheme theme({
    required ColorScheme colors,
    required TextTheme textTheme,
    required AppRadiusData radius,
  }) {
    // Viền mặc định
    final defaultBorder = OutlineInputBorder(
      borderRadius: radius.m, // Bo góc 8.0
      borderSide: const BorderSide(color: AppColors.grey300, width: 1.0),
    );

    // Viền khi focus
    final focusedBorder = OutlineInputBorder(
      borderRadius: radius.m,
      borderSide: BorderSide(color: colors.primary, width: 2.0),
    );

    // Viền khi lỗi
    final errorBorder = OutlineInputBorder(
      borderRadius: radius.m,
      borderSide: BorderSide(color: colors.error, width: 2.0),
    );

    return InputDecorationTheme(
      // Style cho hint text
      hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
      // Style cho label
      labelStyle: textTheme.bodyLarge?.copyWith(color: AppColors.grey700),
      // Style cho text khi gõ
      floatingLabelStyle: textTheme.bodyLarge?.copyWith(color: colors.primary),

      // Viền
      border: defaultBorder,
      enabledBorder: defaultBorder,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder, // Giữ nguyên viền lỗi khi focus
      // Nền
      filled: true,
      fillColor: colors.surface, // (AppColors.white)
      // Căn chỉnh nội dung
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 16.0,
      ),
    );
  }
}
