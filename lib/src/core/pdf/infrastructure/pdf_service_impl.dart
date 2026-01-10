import 'dart:io';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/i_pdf_service.dart';
import '../domain/pdf_config_model.dart';

@LazySingleton(as: IPdfService)
class PdfServiceImpl implements IPdfService {
  @override
  Future<PdfResult> generatePdf({
    required String fileName,
    required PdfConfigModel config,
    required Future<Uint8List> Function(PdfConfigModel format) builder,
  }) async {
    try {
      // 1. Thực thi builder để lấy dữ liệu bytes
      // Builder này sẽ được cung cấp từ bên ngoài (xem phần Helper bên dưới)
      final bytes = await builder(config);

      // 2. Lấy đường dẫn thư mục tạm ứng dụng
      final dir = await getApplicationDocumentsDirectory();
      // Đảm bảo tên file có đuôi .pdf
      final name = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
      final file = File('${dir.path}/$name');

      // 3. Ghi file
      await file.writeAsBytes(bytes);

      return PdfSuccess(file, bytes);
    } catch (e) {
      return PdfFailure('Không thể tạo file PDF: $e', e);
    }
  }
}
