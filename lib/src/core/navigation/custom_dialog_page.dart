// lib/src/core/navigation/custom_dialog_page.dart

import 'package:flutter/material.dart';

/// Một class Page tùy chỉnh để hiển thị một dialog như một route.
/// GoRouter sẽ dùng class này trong `pageBuilder`.
class CustomDialogPage<T> extends Page<T> {
  final Widget child;
  final bool barrierDismissible;
  final String? barrierLabel;
  final Color barrierColor;

  const CustomDialogPage({
    required this.child,
    this.barrierDismissible = true,
    this.barrierLabel,
    this.barrierColor = Colors.black54,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    // Trả về một DialogRoute
    return DialogRoute<T>(
      context: context,
      settings: this,
      builder: (context) => child, // Widget con chính là Dialog
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
    );
  }
}
