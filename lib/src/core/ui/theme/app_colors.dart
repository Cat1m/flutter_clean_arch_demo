// lib/core/ui/theme/app_colors.dart

// ignore_for_file: unused_field

import 'package:flutter/material.dart';

// 1. Palette: Bảng màu thô (Chỉ dùng nội bộ file này)
class _Palette {
  // Brand Colors
  static const primary = Color(0xFF6200EE);
  static const secondary = Color(0xFF03DAC6);

  // Status Colors
  static const error = Color(0xFFB00020);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const info = Color(0xFF2196F3);

  // Neutral Colors
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const gray100 = Color(0xFFF5F5F5);
  static const gray300 = Color(0xFFE0E0E0);
  static const gray800 = Color(0xFF424242);
  static const gray900 = Color(0xFF212121);
}

// 2. AppColors: Định nghĩa ngữ nghĩa (Dùng cái này ở UI)
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color error;
  final Color success;
  final Color border; // Dùng cho viền ô input, card

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
    required this.success,
    required this.border,
  });

  // Theme Light Mặc Định
  factory AppColors.light() {
    return const AppColors(
      primary: _Palette.primary,
      secondary: _Palette.secondary,
      background: _Palette.gray100,
      surface: _Palette.white,
      textPrimary: _Palette.gray900,
      textSecondary: _Palette.gray800,
      error: _Palette.error,
      success: _Palette.success,
      border: _Palette.gray300,
    );
  }

  // Theme Dark Mặc Định
  factory AppColors.dark() {
    return const AppColors(
      primary: _Palette.secondary, // Đảo màu primary
      secondary: _Palette.primary,
      background: _Palette.gray900, // Nền tối
      surface: _Palette.gray800, // Card nổi trên nền tối
      textPrimary: _Palette.white,
      textSecondary: _Palette.gray300,
      error: Color(0xFFCF6679), // Error màu nhạt hơn cho dễ đọc trên nền đen
      success: Color(0xFF81C784),
      border: _Palette.gray800,
    );
  }

  // Bắt buộc phải override 2 hàm này để Flutter hiểu cách copy và animation
  @override
  ThemeExtension<AppColors> copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? error,
    Color? success,
    Color? border,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      error: error ?? this.error,
      success: success ?? this.success,
      border: border ?? this.border,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}
