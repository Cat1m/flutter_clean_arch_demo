// coverage:ignore-file
// This file contains static radius definitions and is not covered by tests.

import 'package:flutter/material.dart';

/// Chứa các giá trị bo góc (BorderRadius) nhất quán.
///
/// Các giá trị này sẽ được đưa vào `AppThemeExtension`.
class AppRadius {
  const AppRadius._(); // Private constructor

  /// 4.0 - Bo góc nhỏ, dùng cho các item nhỏ như chip, tag.
  static const double s = 4.0;
  static final BorderRadius sRadius = BorderRadius.circular(s);

  /// 8.0 - Bo góc mặc định, dùng cho Card, Button.
  static const double m = 8.0;
  static final BorderRadius mRadius = BorderRadius.circular(m);

  /// 12.0 - Bo góc lớn, dùng cho các panel, dialog.
  static const double l = 12.0;
  static final BorderRadius lRadius = BorderRadius.circular(l);

  /// 999.0 - Bo góc "viên thuốc" (pill shape), dùng cho các nút
  /// hoặc component cần bo tròn hoàn toàn.
  static const double full = 999.0;
  static final BorderRadius fullRadius = BorderRadius.circular(full);
}
