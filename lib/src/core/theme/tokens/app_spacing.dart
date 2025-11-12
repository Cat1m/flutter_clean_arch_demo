// coverage:ignore-file
// This file contains static spacing definitions and is not covered by tests.

import 'package:flutter/material.dart';

/// Chứa các giá trị khoảng cách (spacing) và padding nhất quán.
///
/// Chúng ta dùng hệ thống 8-point grid (hầu hết các giá trị là
/// bội số của 4 hoặc 8) để đảm bảo sự nhất quán về thị giác.
///
/// Các giá trị này sẽ được đưa vào `AppThemeExtension`.
class AppSpacing {
  const AppSpacing._(); // Private constructor

  /// 4.0 - Khoảng cách rất nhỏ, dùng cho các icon sát nhau.
  static const double xxs = 4.0;

  /// 8.0 - Khoảng cách nhỏ, dùng cho padding bên trong các component nhỏ.
  static const double xs = 8.0;

  /// 12.0 - Dùng cho các component có kích thước vừa.
  static const double s = 12.0;

  /// 16.0 - Khoảng cách mặc định, dùng cho padding/margin chính.
  static const double m = 16.0;

  /// 20.0
  static const double l = 20.0;

  /// 24.0 - Khoảng cách lớn, dùng để ngăn cách các section.
  static const double xl = 24.0;

  /// 32.0 - Khoảng cách rất lớn.
  static const double xxl = 32.0;

  // --- Các giá trị padding/margin cụ thể (EdgeInsets) ---
  //

  /// EdgeInsets.all(16.0)
  static const EdgeInsets allM = EdgeInsets.all(m);

  /// EdgeInsets.all(8.0)
  static const EdgeInsets allS = EdgeInsets.all(xs);

  /// EdgeInsets.symmetric(horizontal: 16.0)
  static const EdgeInsets horizontalM = EdgeInsets.symmetric(horizontal: m);

  /// EdgeInsets.symmetric(vertical: 16.0)
  static const EdgeInsets verticalM = EdgeInsets.symmetric(vertical: m);

  /// EdgeInsets.symmetric(horizontal: 8.0)
  static const EdgeInsets horizontalS = EdgeInsets.symmetric(horizontal: xs);

  /// EdgeInsets.symmetric(vertical: 8.0)
  static const EdgeInsets verticalS = EdgeInsets.symmetric(vertical: xs);
}
