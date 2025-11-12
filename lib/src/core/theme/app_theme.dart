// coverage:ignore-file
import 'package:flutter/material.dart';

// Import 1 dòng cho TẤT CẢ components (Cấp 2)
// Sửa lỗi 'directives_ordering': 'components' đứng trước 'tokens'
import 'components/components.dart';
// Import 1 dòng cho extension
import 'extensions/app_theme_extensions.dart';
// Import 1 dòng cho TẤT CẢ tokens (Cấp 1)
import 'tokens/tokens.dart';

// Xóa 'unused_import' của google_fonts

/// "Nhà máy" lắp ráp theme chính của ứng dụng.
/// Kết hợp Tokens (Cấp 1) và Component Styles (Cấp 2)
class AppTheme {
  const AppTheme._();

  // --- Định nghĩa các data token Cấp 1 ---
  // Sửa lỗi 'prefer_const_constructors': Thêm 'const'
  static const _spacing = AppSpacingData(
    xxs: AppSpacing.xxs,
    xs: AppSpacing.xs,
    s: AppSpacing.s,
    m: AppSpacing.m,
    l: AppSpacing.l,
    xl: AppSpacing.xl,
    xxl: AppSpacing.xxl,
  );

  static final _radius = AppRadiusData(
    s: AppRadius.sRadius,
    m: AppRadius.mRadius,
    l: AppRadius.lRadius,
    full: AppRadius.fullRadius,
  );

  static final _shadows = AppShadowsData(
    low: AppShadows.low,
    medium: AppShadows.medium,
    high: AppShadows.high,
  );

  static final _lightTextTheme = AppTypography.textTheme;

  // Sửa lỗi 'prefer_const_constructors': Thêm 'const'
  static const _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    error: AppColors.error,

    // Sửa lỗi 'deprecated_member_use': Xóa 'background'
    // background: AppColors.grey100,
    surface: AppColors.white, // Nền Card, Dialog, TextField
    onPrimary: AppColors.white, // Chữ trên nền primary
    onSecondary: AppColors.white, // Chữ trên nền secondary
    onSurface: AppColors.grey900, // Chữ chính
    onError: AppColors.white, // Chữ trên nền error
    // Sửa lỗi 'deprecated_member_use': Xóa 'onBackground'
    // onBackground: AppColors.grey900,
  );

  // --- NHÀ MÁY LIGHT THEME ---
  static ThemeData get lightTheme {
    return ThemeData.light(useMaterial3: true).copyWith(
      // 1. GÁN CẤP 1 (Tokens, Extensions)
      colorScheme: _lightColorScheme,
      textTheme: _lightTextTheme,

      // Sửa lỗi 'deprecated_member_use':
      // Set 'scaffoldBackgroundColor' trực tiếp thay vì
      // dùng 'colorScheme.background' (đã bị deprecated)
      scaffoldBackgroundColor: AppColors.grey100,

      extensions: [
        AppThemeExtension(
          spacing: _spacing,
          radius: _radius,
          shadows: _shadows,
        ),
      ],

      // 2. GÁN CẤP 2 (Components) - Gọi từ các file đã import
      appBarTheme: AppAppBarTheme.lightTheme(
        _lightColorScheme,
        _lightTextTheme,
      ),
      elevatedButtonTheme: AppButtonThemes.elevatedButtonTheme(
        colors: _lightColorScheme,
        textTheme: _lightTextTheme,
        radius: _radius,
        spacing: _spacing,
      ),
      textButtonTheme: AppButtonThemes.textButtonTheme(
        colors: _lightColorScheme,
        textTheme: _lightTextTheme,
      ),
      outlinedButtonTheme: AppButtonThemes.outlinedButtonTheme(
        colors: _lightColorScheme,
        textTheme: _lightTextTheme,
        radius: _radius,
        spacing: _spacing,
      ),

      // Sửa lỗi 'argument_type_not_assignable':
      // Hàm AppCardTheme.theme() giờ trả về CardThemeData
      cardTheme: AppCardTheme.theme(colors: _lightColorScheme, radius: _radius),
      inputDecorationTheme: AppInputDecorationTheme.theme(
        colors: _lightColorScheme,
        textTheme: _lightTextTheme,
        radius: _radius,
      ),

      // Sửa lỗi 'argument_type_not_assignable':
      // Hàm AppDialogTheme.theme() giờ trả về DialogThemeData
      dialogTheme: AppDialogTheme.theme(
        colors: _lightColorScheme,
        textTheme: _lightTextTheme,
        radius: _radius,
      ),
    );
  }

  // --- Cấu hình cho Dark Theme (Thêm mới) ---
  static final _darkTextTheme = AppTypography.darkTextTheme;
  static const _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    error: AppColors.error,
    surface: AppColors.darkSurface, // Nền Card, Dialog
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    onSurface: AppColors.darkTextPrimary, // Chữ chính (sáng)
    onError: AppColors.white,
  );

  // --- NHÀ MÁY DARK THEME (Thêm mới) ---
  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: true).copyWith(
      // 1. GÁN CẤP 1 (Tokens, Extensions)
      colorScheme: _darkColorScheme,
      textTheme: _darkTextTheme,
      scaffoldBackgroundColor: AppColors.darkBackground, // Nền app tối
      extensions: [
        AppThemeExtension(
          spacing: _spacing,
          radius: _radius,
          shadows: _shadows,
        ),
      ],

      // 2. GÁN CẤP 2 (Components)
      // Các hàm component theme này sẽ tự động
      // nhận ColorScheme tối và hoạt động
      appBarTheme: AppAppBarTheme.darkTheme(
        // <-- Dùng darkTheme
        _darkColorScheme,
        _darkTextTheme,
      ),
      elevatedButtonTheme: AppButtonThemes.elevatedButtonTheme(
        colors: _darkColorScheme,
        textTheme: _darkTextTheme,
        radius: _radius,
        spacing: _spacing,
      ),
      textButtonTheme: AppButtonThemes.textButtonTheme(
        colors: _darkColorScheme,
        textTheme: _darkTextTheme,
      ),
      outlinedButtonTheme: AppButtonThemes.outlinedButtonTheme(
        colors: _darkColorScheme,
        textTheme: _darkTextTheme,
        radius: _radius,
        spacing: _spacing,
      ),
      cardTheme: AppCardTheme.theme(colors: _darkColorScheme, radius: _radius),
      inputDecorationTheme: AppInputDecorationTheme.theme(
        colors: _darkColorScheme,
        textTheme: _darkTextTheme,
        radius: _radius,
      ),
      dialogTheme: AppDialogTheme.theme(
        colors: _darkColorScheme,
        textTheme: _darkTextTheme,
        radius: _radius,
      ),
    );
  }
}
