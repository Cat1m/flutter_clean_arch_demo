import 'dart:io';
import 'dart:typed_data';
import 'pdf_config_model.dart';

// Định nghĩa các trạng thái trả về khi xuất PDF
sealed class PdfResult {}

class PdfSuccess implements PdfResult {
  final File file;
  final Uint8List bytes;
  PdfSuccess(this.file, this.bytes);
}

class PdfFailure implements PdfResult {
  final String message;
  final Object? error;
  PdfFailure(this.message, [this.error]);
}

// Interface chính cho PDF Service
abstract interface class IPdfService {
  // Hàm tạo PDF từ danh sách widget (được cung cấp bởi gói pdf)
  Future<PdfResult> generatePdf({
    required String fileName,
    required PdfConfigModel config,
    required Future<Uint8List> Function(PdfConfigModel format) builder,
  });
}
