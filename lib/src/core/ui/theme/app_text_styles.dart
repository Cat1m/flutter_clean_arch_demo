// lib/core/ui/theme/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle body1;
  final TextStyle body2;
  final TextStyle caption;
  final TextStyle button;

  const AppTextStyles({
    required this.h1,
    required this.h2,
    required this.h3,
    required this.body1,
    required this.body2,
    required this.caption,
    required this.button,
  });

  // Base Style dùng google_fonts (tự tải/cache font, không cần khai báo
  // asset trong pubspec.yaml). Sau này muốn đổi font cả app thì sửa
  // đúng dòng GoogleFonts.roboto(...) này là xong.
  static final _baseStyle = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    height: 1.5, // Line height dễ đọc
  ).copyWith(leadingDistribution: TextLeadingDistribution.even);

  factory AppTextStyles.main() {
    return AppTextStyles(
      h1: _baseStyle.copyWith(fontSize: 32, fontWeight: FontWeight.bold),
      h2: _baseStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
      h3: _baseStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      body1: _baseStyle.copyWith(fontSize: 16), // Normal text
      body2: _baseStyle.copyWith(fontSize: 14), // Small text
      // Không hardcode màu ở đây — để caller override bằng
      // context.colors.textSecondary khi cần màu mờ, tránh vỡ dark mode.
      caption: _baseStyle.copyWith(fontSize: 12),
      button: _baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  @override
  ThemeExtension<AppTextStyles> copyWith() => this;

  @override
  ThemeExtension<AppTextStyles> lerp(
    ThemeExtension<AppTextStyles>? other,
    double t,
  ) {
    if (other is! AppTextStyles) return this;
    return AppTextStyles(
      h1: TextStyle.lerp(h1, other.h1, t)!,
      h2: TextStyle.lerp(h2, other.h2, t)!,
      h3: TextStyle.lerp(h3, other.h3, t)!,
      body1: TextStyle.lerp(body1, other.body1, t)!,
      body2: TextStyle.lerp(body2, other.body2, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
    );
  }
}
