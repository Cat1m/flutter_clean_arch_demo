// lib/core/ui/widgets/app_empty_view.dart

import 'package:flutter/material.dart';
import 'package:reqres_in/src/core/ui/ui.dart';

/// Widget hiển thị trạng thái "không có dữ liệu", tái sử dụng cho mọi feature.
class AppEmptyView extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const AppEmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: context.colors.textSecondary),
            const SizedBox(height: AppDimens.s12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.text.body1.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppDimens.s16),
              AppButton(
                text: actionText!,
                isExpanded: false,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
