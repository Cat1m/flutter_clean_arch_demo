// coverage:ignore-file
// This file contains static shadow definitions and is not covered by tests.

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Chứa các giá trị đổ bóng (BoxShadow) nhất quán.
///
/// Các giá trị này sẽ được đưa vào `AppThemeExtension`.
class AppShadows {
  const AppShadows._(); // Private constructor

  /// Màu đổ bóng cơ bản, rất nhạt
  static final Color _shadowColor = AppColors.black.withValues(alpha: .1);

  /// Đổ bóng nhẹ, dùng cho các component "nổi" nhẹ (như Card)
  static final List<BoxShadow> low = [
    BoxShadow(color: _shadowColor, blurRadius: 8.0, offset: const Offset(0, 2)),
  ];

  /// Đổ bóng vừa, dùng cho các component "nổi" rõ (như Dialog, Modal)
  static final List<BoxShadow> medium = [
    BoxShadow(
      color: _shadowColor,
      blurRadius: 12.0,
      offset: const Offset(0, 4),
    ),
  ];

  /// Đổ bóng cao, dùng cho các yếu tố "nổi" cao nhất (như thanh điều hướng
  /// khi cuộn)
  static final List<BoxShadow> high = [
    BoxShadow(
      color: _shadowColor,
      blurRadius: 24.0,
      offset: const Offset(0, 8),
    ),
  ];
}
