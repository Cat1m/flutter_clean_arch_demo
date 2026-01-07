// lib/core/ui/widgets/app_text_field.dart

import 'package:flutter/material.dart';
import '../ui.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autoFocusOut;

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.isPassword = false,
    this.validator,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.autoFocusOut = true,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    // Nếu không phải password thì luôn hiện text
    _obscureText = widget.isPassword;
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      validator: widget.validator,
      readOnly: widget.readOnly,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,

      // Style Text nhập vào
      style: context.text.body1.copyWith(color: context.colors.textPrimary),
      onTapOutside: widget.autoFocusOut
          ? (event) => FocusManager.instance.primaryFocus?.unfocus()
          : null,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,

        // Icon bên trái
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: AppDimens.icM)
            : null,

        // Icon mắt thần (chỉ hiện khi là password)
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: AppDimens.icM,
                ),
                onPressed: _toggleVisibility,
              )
            : null,

        // --- BORDER STYLES (Quy hoạch 1 chỗ) ---
        // 1. Trạng thái bình thường
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.r8),
          borderSide: BorderSide(color: context.colors.border),
        ),

        // 2. Trạng thái Focus (đang nhập)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.r8),
          borderSide: BorderSide(color: context.colors.primary, width: 2),
        ),

        // 3. Trạng thái Lỗi
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.r8),
          borderSide: BorderSide(color: context.colors.error),
        ),

        // 4. Trạng thái Lỗi + Focus
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.r8),
          borderSide: BorderSide(color: context.colors.error, width: 2),
        ),

        // Padding nội dung
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s16,
          vertical: AppDimens.s16,
        ),
      ),
    );
  }
}
