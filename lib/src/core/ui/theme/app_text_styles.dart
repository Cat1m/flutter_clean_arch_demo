// lib/core/ui/theme/app_text_styles.dart

import 'package:flutter/material.dart';

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

  // Base Style (Ví dụ dùng Roboto)
  // Sau này muốn đổi font cả app thì sửa đúng 1 dòng này là xong
  static const _baseStyle = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    height: 1.5, // Line height dễ đọc
    leadingDistribution: TextLeadingDistribution.even,
  );

  factory AppTextStyles.main() {
    return AppTextStyles(
      h1: _baseStyle.copyWith(fontSize: 32, fontWeight: FontWeight.bold),
      h2: _baseStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
      h3: _baseStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      body1: _baseStyle.copyWith(fontSize: 16), // Normal text
      body2: _baseStyle.copyWith(fontSize: 14), // Small text
      caption: _baseStyle.copyWith(fontSize: 12, color: Colors.grey),
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
