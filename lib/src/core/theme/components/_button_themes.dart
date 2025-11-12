import 'package:flutter/material.dart';
import '../extensions/app_theme_extensions.dart'; // <-- Import extension

/// Định nghĩa theme cho các loại Button
class AppButtonThemes {
  const AppButtonThemes._();

  /// Theme cho ElevatedButton
  static ElevatedButtonThemeData elevatedButtonTheme({
    required ColorScheme colors,
    required TextTheme textTheme,
    required AppRadiusData radius,
    required AppSpacingData spacing,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary, // Nền tím
        foregroundColor: colors.onPrimary, // Chữ trắng
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: radius.full), // Bo tròn
        padding: EdgeInsets.symmetric(
          vertical: spacing.s, // 12.0
          horizontal: spacing.xl, // 24.0
        ),
        elevation: 0, // Tối giản, không shadow
      ),
    );
  }

  /// Theme cho TextButton
  static TextButtonThemeData textButtonTheme({
    required ColorScheme colors,
    required TextTheme textTheme,
  }) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary, // Chữ màu tím
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Bo nhẹ cho vùng nhấn
        ),
      ),
    );
  }

  /// Theme cho OutlinedButton
  static OutlinedButtonThemeData outlinedButtonTheme({
    required ColorScheme colors,
    required TextTheme textTheme,
    required AppRadiusData radius,
    required AppSpacingData spacing,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary, // Chữ tím
        side: BorderSide(color: colors.primary, width: 1.5), // Viền tím
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: radius.full), // Bo tròn
        padding: EdgeInsets.symmetric(
          vertical: spacing.s, // 12.0
          horizontal: spacing.xl, // 24.0
        ),
      ),
    );
  }
}
