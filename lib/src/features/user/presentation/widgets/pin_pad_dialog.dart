import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reqres_in/src/core/ui/ui.dart';

/// Hiện dialog nhập PIN 6 số, trả về chuỗi PIN đã nhập hoặc `null` nếu huỷ.
Future<String?> showPinPadDialog(
  BuildContext context, {
  required String title,
  String? errorText,
}) {
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: dialogContext.text.h2,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: InputDecoration(
            counterText: '',
            errorText: errorText,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Xác nhận'),
          ),
        ],
      );
    },
  );
}
