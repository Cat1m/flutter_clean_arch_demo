// lib/core/ui/widgets/app_error_view.dart

import 'package:flutter/material.dart';
import 'package:reqres_in/src/core/network/failures.dart';
import 'package:reqres_in/src/core/ui/ui.dart';
import 'package:reqres_in/src/shared/extensions/failure_extension.dart';

/// Widget hiển thị lỗi chuẩn hoá, tái sử dụng cho mọi feature.
/// Tự động hiện nút "Thử lại" khi [Failure.shouldRetry] là true và có [onRetry].
class AppErrorView extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const AppErrorView({super.key, required this.failure, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(failure.icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: AppDimens.s12),
            Text(
              failure.toDisplayMessage(),
              textAlign: TextAlign.center,
              style: context.text.body1,
            ),
            if (failure.shouldRetry && onRetry != null) ...[
              const SizedBox(height: AppDimens.s16),
              AppButton(
                text: failure.actionText,
                isExpanded: false,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
