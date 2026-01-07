// lib/core/ui/extensions/context_extension.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

extension ThemeContextX on BuildContext {
  /// Lấy bộ màu hiện tại (Light/Dark)
  /// Usage: context.colors.primary
  AppColors get colors {
    return Theme.of(this).extension<AppColors>() ?? AppColors.light();
  }

  /// Lấy bộ typography
  /// Usage: context.text.h1
  AppTextStyles get text {
    return Theme.of(this).extension<AppTextStyles>() ?? AppTextStyles.main();
  }

  // --- Layout ShortCuts ---
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;

  // Ẩn bàn phím
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}
