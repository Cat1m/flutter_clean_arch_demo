// coverage:ignore-file
import 'package:flutter/material.dart';
import '../extensions/app_theme_extensions.dart';
import '../tokens/tokens.dart';

/// Định nghĩa theme cho Card
class AppCardTheme {
  const AppCardTheme._();

  static CardThemeData theme({
    required ColorScheme colors,
    required AppRadiusData radius,
  }) {
    return CardThemeData(
      elevation: 0, // Tắt shadow mặc định
      clipBehavior: Clip.antiAlias, // Giúp bo góc hoạt động tốt
      color: colors.surface, // (AppColors.white)
      shape: RoundedRectangleBorder(
        borderRadius: radius.l, // Bo góc 12.0
        side: const BorderSide(
          color: AppColors.grey200, // Thêm 1 viền xám nhạt
          width: 1.0,
        ),
      ),
    );
  }

  // Ghi chú: Nếu muốn dùng shadow, hãy bọc Card trong
  // Container(decoration: BoxDecoration(shadows: shadows.low))
}
