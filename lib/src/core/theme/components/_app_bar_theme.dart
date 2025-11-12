// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Định nghĩa theme cho AppBar
class AppAppBarTheme {
  const AppAppBarTheme._();

  static AppBarTheme lightTheme(ColorScheme colors, TextTheme textTheme) {
    return AppBarTheme(
      // Phong cách tối giản: không shadow
      elevation: 0,
      scrolledUnderElevation: 0,

      // Nền AppBar sẽ dùng màu nền (surface),
      // Icon và Tiêu đề sẽ dùng màu primary
      backgroundColor: colors.surface, // (AppColors.white)
      foregroundColor: colors.primary, // (AppColors.primary)
      // Đảm bảo icon (như back button) cũng dùng màu primary
      iconTheme: IconThemeData(color: colors.primary),

      // Đảm bảo các action (vd: icon button) cũng dùng màu primary
      actionsIconTheme: IconThemeData(color: colors.primary),

      // Ghi đè style của tiêu đề
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: colors.primary, // Dùng màu primary
      ),

      // Đảm bảo các icon trên status bar (pin, sóng) có thể đọc được
      systemOverlayStyle: const SystemUiOverlayStyle(
        // Dùng .dark cho nền sáng (hiển thị icon tối)
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  static AppBarTheme darkTheme(ColorScheme colors, TextTheme textTheme) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,

      // Nền AppBar dùng màu surface (tối)
      backgroundColor: colors.surface, // (AppColors.darkSurface)
      // Tiêu đề và icon dùng màu Secondary (Teal) cho nổi bật
      foregroundColor: colors.secondary,
      iconTheme: IconThemeData(color: colors.secondary),
      actionsIconTheme: IconThemeData(color: colors.secondary),

      // Ghi đè style tiêu đề để dùng màu secondary
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: colors.secondary,
      ),

      // Đảm bảo các icon trên status bar (pin, sóng) có thể đọc được
      systemOverlayStyle: const SystemUiOverlayStyle(
        // Dùng .light cho nền tối (hiển thị icon sáng)
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }
}
