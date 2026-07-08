// lib/core/ui/widgets/app_card.dart

import 'package:flutter/material.dart';
import 'package:reqres_in/src/core/ui/ui.dart';

/// Card chuẩn hoá dùng chung cho mọi feature (vd feature showcase, thông tin).
/// Bọc [Card] mặc định của theme, chỉ thêm padding + onTap tuỳ chọn.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppDimens.s16),
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.r12),
        child: Padding(padding: padding, child: child),
      ),
    );
    return card;
  }
}
