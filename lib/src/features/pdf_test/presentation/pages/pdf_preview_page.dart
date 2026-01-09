import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:reqres_in/src/core/pdf/pdf_core_export.dart';

class PdfPreviewPage extends StatelessWidget {
  // Hàm builder để tạo data PDF
  final Future<Uint8List> Function(PdfConfigModel config) builder;
  final String fileName;

  const PdfPreviewPage({
    super.key,
    required this.builder,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fileName)),
      // PdfPreview là widget thần thánh của gói printing
      body: PdfPreview(
        // 1. Tắt bớt các tính năng không cần thiết nếu muốn
        allowPrinting: true,
        allowSharing: true, // ✅ Đã có sẵn nút Share ở đây
        canChangeOrientation: false, // Chặn xoay ngang dọc nếu layout cố định
        canChangePageFormat: false, // Chặn đổi khổ giấy nếu fix cứng A4
        // 2. Tên file khi share/lưu
        pdfFileName: '$fileName.pdf',

        // 3. Hàm build chính
        build: (format) {
          // Map từ format của thư viện sang Model Config của mình
          final config = PdfConfigModel(
            pageFormat: format,
            isPortrait: true, // Hoặc logic check format.width < height
          );

          return builder(config);
        },

        // 4. Loading Widget
        loadingWidget: const Center(child: CircularProgressIndicator()),

        // 5. Xử lý lỗi
        onError: (context, error) => Center(
          child: Text(
            'Lỗi hiển thị PDF: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
