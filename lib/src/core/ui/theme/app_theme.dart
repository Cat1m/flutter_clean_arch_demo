// lib/core/ui/theme/app_theme.dart

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_text_styles.dart';

class AppTheme {
  // 1. Light Theme
  static ThemeData light() {
    final colors = AppColors.light();
    final text = AppTextStyles.main();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Map Extension vào Theme
      extensions: [colors, text],

      // Config Material Widget mặc định theo AppColors
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primary,

      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.surface,
      ),

      // 1. Checkbox & Radio (Tự động ăn theo màu Primary/Error)
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.primary;
          return null; // Mặc định
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.r4),
        ),
      ),

      // 2. Card (Card mặc định trong app)
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.r12),
        ),
        margin: EdgeInsets.zero,
      ),

      // 3. Dialog & BottomSheet
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.r16),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.r16),
          ),
        ),
      ),

      // 4. Divider (Đường kẻ mờ)
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // 2. Dark Theme
  static ThemeData dark() {
    final colors = AppColors.dark();
    final text = AppTextStyles.main();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: [colors, text],

      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primary,

      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.surface,
      ),
    );
  }
}
