// coverage:ignore-file
// This file contains static text style definitions and is not covered by tests.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart'; // Import file màu sắc của chúng ta

/// Chứa tất cả các kiểu chữ (Text Styles) cơ bản cho ứng dụng.
///
/// Các kiểu chữ này sử dụng font 'Roboto' từ google_fonts
/// và sử dụng các màu cơ bản từ `AppColors`.
///
/// Chúng sẽ được "biên soạn" và sử dụng trong file `app_theme.dart`
/// để tạo ra `TextTheme` hoàn chỉnh cho ứng dụng.
class AppTypography {
  const AppTypography._(); // Private constructor

  /// Màu văn bản chính, dùng cho nội dung, tiêu đề phụ.
  /// Thường là màu tối nhất trên nền sáng.
  static const Color _primaryTextColor = AppColors.grey900;

  /// Màu văn bản phụ, dùng cho mô tả, chú thích, hint text.
  static const Color _secondaryTextColor = AppColors.grey700;

  /// Kiểu chữ cơ bản (base) sử dụng font Roboto.
  /// Các kiểu chữ khác sẽ kế thừa từ đây.
  static final TextStyle _base = GoogleFonts.roboto(
    color: _primaryTextColor,
    fontWeight: FontWeight.w400,
  );

  static const Color _lightPrimaryTextColor = AppColors.grey900;
  static const Color _lightSecondaryTextColor = AppColors.grey700;
  static final TextStyle _lightBase = GoogleFonts.roboto(
    color: _lightPrimaryTextColor,
    fontWeight: FontWeight.w400,
  );

  // --- CÁC KIỂU CHỮ CHO TIÊU ĐỀ (DISPLAY & HEADLINE) ---
  //

  /// Dùng cho các tiêu đề rất lớn (ví dụ: màn hình splash, số liệu lớn)
  static final TextStyle displayLarge = _base.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
  );

  /// Dùng cho tiêu đề chính của màn hình (Screen Title)
  /// Đây là nơi chúng ta "phá cách" bằng màu Primary!
  static final TextStyle headlineLarge = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.primary, // <-- Phá cách ở đây
  );

  /// Dùng cho tiêu đề của các mục (Section Title)
  static final TextStyle headlineMedium = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  /// Dùng cho tiêu đề phụ
  static final TextStyle headlineSmall = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  // --- CÁC KIỂU CHỮ CHO NỘI DUNG (BODY & LABEL) ---

  /// Dùng cho văn bản nội dung chính, quan trọng
  static final TextStyle bodyLarge = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  /// Kiểu chữ mặc định cho hầu hết văn bản nội dung
  static final TextStyle bodyMedium = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  /// Dùng cho văn bản nội dung phụ, mô tả nhỏ
  static final TextStyle bodySmall = _lightBase.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: _lightSecondaryTextColor, // Màu chữ phụ
  );

  /// Dùng cho các nút bấm (Buttons)
  static final TextStyle labelLarge = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Chữ in hoa/đậm hơn cho nút
    letterSpacing: 0.1,
  );

  /// Dùng cho các nhãn nhỏ (ví dụ: chú thích icon)
  static final TextStyle labelMedium = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: _secondaryTextColor,
  );

  /// Dùng cho các văn bản rất nhỏ, caption, hint text
  static final TextStyle caption = _lightBase.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: _lightSecondaryTextColor,
  );

  /// Tạo một TextTheme hoàn chỉnh để sử dụng trong ThemeData
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall, // <--- Gán bodySmall
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: caption, // <--- Sửa lỗi: 'caption' được gán cho 'labelSmall'
    // Chúng ta không định nghĩa các kiểu title (titleLarge, titleMedium, titleSmall)
    // và các kiểu display (displayMedium, displaySmall) trong phác thảo
    // nên chúng sẽ là null, Flutter sẽ dùng giá trị mặc định.
    // Điều này là ổn vì chúng ta đang tập trung vào các kiểu chính.
  );

  // --- Cấu hình cho Dark Theme (Thêm mới) ---
  static const Color _darkPrimaryTextColor = AppColors.darkTextPrimary;
  static const Color _darkSecondaryTextColor = AppColors.grey500;
  // ignore: unused_field
  static final TextStyle _darkBase = GoogleFonts.roboto(
    color: _darkPrimaryTextColor,
    fontWeight: FontWeight.w400,
  );

  static TextTheme get darkTextTheme => TextTheme(
    // Dùng lại các style, chỉ thay đổi base
    displayLarge: displayLarge.copyWith(color: _darkPrimaryTextColor),
    // "Phá cách" cho Dark Mode: Dùng màu Teal
    headlineLarge: headlineLarge.copyWith(color: AppColors.secondary),
    headlineMedium: headlineMedium.copyWith(color: _darkPrimaryTextColor),
    headlineSmall: headlineSmall.copyWith(color: _darkPrimaryTextColor),
    bodyLarge: bodyLarge.copyWith(color: _darkPrimaryTextColor),
    bodyMedium: bodyMedium.copyWith(color: _darkPrimaryTextColor),
    bodySmall: bodySmall.copyWith(color: _darkSecondaryTextColor),
    labelLarge: labelLarge.copyWith(color: _darkPrimaryTextColor),
    labelMedium: labelMedium.copyWith(color: _darkSecondaryTextColor),
    labelSmall: caption.copyWith(color: _darkSecondaryTextColor),
  );
}
