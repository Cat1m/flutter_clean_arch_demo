// lib/src/core/widgets/session_expired_dialog.dart
import 'package:flutter/material.dart';

/// Hiển thị một dialog thông báo chung,
/// không thể tắt bằng cách bấm ra ngoài (barrierDismissible: false).
///
/// [context]: BuildContext để hiển thị dialog.
/// [title]: Tiêu đề của dialog.
/// [message]: Nội dung thông báo.
/// [onConfirm]: Hàm sẽ được gọi khi người dùng bấm nút "OK".
Future<void> showSessionExpiredDialog({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) async {
  return showDialog<void>(
    context: context,
    // Bắt buộc người dùng phải bấm nút
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(children: <Widget>[Text(message)]),
        ),
        actions: <Widget>[
          TextButton(onPressed: onConfirm, child: const Text('OK')),
        ],
      );
    },
  );
}
