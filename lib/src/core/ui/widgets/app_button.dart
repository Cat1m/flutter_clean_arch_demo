// lib/core/ui/widgets/app_button.dart

import 'package:flutter/material.dart';
import '../ui.dart'; // Import Core UI

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded; // Có full width hay không?
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Logic: Nếu đang loading hoặc onPressed null -> Disable button
    final isEnabled = !isLoading && onPressed != null;

    final content = ElevatedButton(
      onPressed: isEnabled ? onPressed : null, // Tự động disable style
      style: ElevatedButton.styleFrom(
        // Quy định chiều cao chuẩn (ví dụ 48px)
        minimumSize: Size(isExpanded ? double.infinity : 0, AppDimens.s48),
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.s24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.r8),
        ),
        // Màu sắc sẽ tự ăn theo Theme, nhưng nếu muốn hardcode theo design system:
        // backgroundColor: context.colors.primary,
        // foregroundColor: context.colors.surface,
      ),
      child: isLoading
          ? SizedBox(
              height: AppDimens.s24,
              width: AppDimens.s24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color:
                    context.colors.surface, // Màu spinner nổi trên nền button
              ),
            )
          : _buildChild(context),
    );

    return content;
  }

  Widget _buildChild(BuildContext context) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppDimens.icS),
          const SizedBox(width: AppDimens.s8),
          Text(text, style: context.text.button),
        ],
      );
    }
    return Text(text, style: context.text.button);
  }
}
