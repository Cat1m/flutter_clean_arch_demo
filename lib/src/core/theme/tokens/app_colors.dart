// coverage:ignore-file
// This file contains static color definitions and is not covered by tests.

import 'package:flutter/material.dart';

/// Chứa tất cả các màu sắc cơ bản được sử dụng trong ứng dụng.
///
/// Các giá trị này là "nguyên liệu thô" (raw tokens).
/// Chúng sẽ được "biên soạn" và sử dụng trong file `app_theme.dart`
/// để tạo ra `ColorScheme` và các thuộc tính theme cụ thể.
class AppColors {
  const AppColors._(); // Private constructor to prevent instantiation

  // --- Màu sắc Thương hiệu (Brand Colors) ---
  /// Màu chủ đạo (Primary) của ứng dụng
  /// Dùng cho các thành phần tương tác chính, CTA (Call to action).
  /// Màu: Tím đậm
  static const Color primary = Color(0xFF481267);

  /// Màu phụ (Secondary) của ứng dụng
  /// Dùng cho các điểm nhấn, tab đang hoạt động, hoặc các thành phần
  /// tương tác phụ.
  /// Màu: Xanh Teal
  static const Color secondary = Color(0xFF00BFA5);

  // --- Màu Trung tính (Neutral Colors) ---
  /// Cốt lõi của phong cách tối giản.
  /// Được dùng cho nền, viền, văn bản, và các thành phần không tương tác.

  /// Màu trắng tinh
  static const Color white = Color(0xFFFFFFFF);

  /// Màu đen tuyền
  static const Color black = Color(0xFF000000);

  /// Dùng cho nền sáng (light background) rất nhạt
  static const Color grey50 = Color(0xFFFAFAFA);

  /// Dùng cho nền sáng (light background)
  static const Color grey100 = Color(0xFFF5F5F5);

  /// Dùng cho các đường kẻ/chia (dividers)
  static const Color grey200 = Color(0xFFEEEEEE);

  /// Dùng cho viền (borders) hoặc các trạng thái disabled
  static const Color grey300 = Color(0xFFE0E0E0);

  /// Dùng cho các icon/văn bản có độ tương phản trung bình
  static const Color grey500 = Color(0xFF9E9E9E);

  /// Dùng cho văn bản phụ (secondary text)
  static const Color grey700 = Color(0xFF616161);

  /// Dùng cho văn bản chính (primary text) trên nền sáng
  static const Color grey900 = Color(0xFF212121);

  /// Nền chính của app trong dark mode
  static const Color darkBackground = Color(0xFF121212);

  /// Nền cho các component "nổi" (Card, Dialog) trong dark mode
  static const Color darkSurface = Color(0xFF1E1E1E);

  /// Màu chữ chính (off-white) trên nền tối
  static const Color darkTextPrimary = Color(0xFFE0E0E0);

  // --- Màu sắc Hệ thống (System Colors) ---
  //

  /// Dùng cho các thông báo lỗi, trạng thái error.
  static const Color error = Color(0xFFD32F2F);

  /// Dùng cho các thông báo thành công, trạng thái success.
  static const Color success = Color(0xFF388E3C);

  /// Dùng cho các thông báo cảnh báo, trạng thái warning.
  static const Color warning = Color(0xFFFFA000);

  /// Dùng cho các thông báo thông tin, trạng thái info.
  static const Color info = Color(0xFF1976D2);
}
