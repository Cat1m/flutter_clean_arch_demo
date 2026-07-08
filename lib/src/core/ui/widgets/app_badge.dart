// lib/core/ui/widgets/app_badge.dart

import 'package:flutter/material.dart';
import 'package:reqres_in/src/core/ui/ui.dart';

/// Badge nhỏ dùng để gắn tag công nghệ lên feature card (vd "Rust FFI",
/// "Argon2", "AES-256-GCM").
class AppBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const AppBadge({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? context.colors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimens.rCircle),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: context.text.caption.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
