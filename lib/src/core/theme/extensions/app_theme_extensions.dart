// coverage:ignore-file
// This file contains the definition of AppThemeExtension.
// It requires manual implementation of lerp and copyWith.

import 'package:flutter/material.dart';

/// Lớp `ThemeExtension` tùy chỉnh để chứa các "design token"
/// không được hỗ trợ bởi `ThemeData` mặc định.
///
/// Bao gồm Spacing, Radius, và Shadows.
///
/// Cách sử dụng:
/// `Theme.of(context).extension<AppThemeExtension>()!.spacing.m`
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.spacing,
    required this.radius,
    required this.shadows,
  });

  /// Các giá trị khoảng cách (spacing)
  final AppSpacingData spacing;

  /// Các giá trị bo góc (radius)
  final AppRadiusData radius;

  /// Các giá trị đổ bóng (shadows)
  final AppShadowsData shadows;

  /// Tạo một bản sao của extension này với các giá trị được
  /// cung cấp (nếu có).
  @override
  ThemeExtension<AppThemeExtension> copyWith({
    AppSpacingData? spacing,
    AppRadiusData? radius,
    AppShadowsData? shadows,
  }) {
    return AppThemeExtension(
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      shadows: shadows ?? this.shadows,
    );
  }

  /// "Hòa trộn" (interpolate) giữa hai theme.
  /// Cần thiết khi chuyển đổi theme (ví dụ: Light -> Dark).
  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }

    // Vì các giá trị token (spacing, radius, shadow) là không đổi
    // giữa light/dark, chúng ta chỉ cần trả về một trong hai.
    // Nếu chúng ta muốn hỗ trợ
    // spacing khác nhau cho light/dark, chúng ta sẽ cần 'lerp'
    // các giá trị bên trong.
    return t < 0.5 ? this : other;
  }
}

// --- CÁC LỚP DATA CHỨA TOKEN ---
// Chúng ta tạo các lớp immutable nhỏ để nhóm các token lại
// cho dễ quản lý và truy cập (vd: extension.spacing.m)

/// Lớp data chứa các giá trị spacing
@immutable
class AppSpacingData {
  const AppSpacingData({
    required this.xxs,
    required this.xs,
    required this.s,
    required this.m,
    required this.l,
    required this.xl,
    required this.xxl,
  });

  final double xxs; // 4.0
  final double xs; // 8.0
  final double s; // 12.0
  final double m; // 16.0
  final double l; // 20.0
  final double xl; // 24.0
  final double xxl; // 32.0
}

/// Lớp data chứa các giá trị bo góc
@immutable
class AppRadiusData {
  const AppRadiusData({
    required this.s,
    required this.m,
    required this.l,
    required this.full,
  });

  final BorderRadius s; // 4.0
  final BorderRadius m; // 8.0
  final BorderRadius l; // 12.0
  final BorderRadius full; // 999.0
}

/// Lớp data chứa các giá trị đổ bóng
@immutable
class AppShadowsData {
  const AppShadowsData({
    required this.low,
    required this.medium,
    required this.high,
  });

  final List<BoxShadow> low;
  final List<BoxShadow> medium;
  final List<BoxShadow> high;
}
