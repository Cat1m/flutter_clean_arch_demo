import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../domain/pdf_config_model.dart';
import 'pdf_font_helper.dart';

/// Helper chuyên biệt để tạo cấu trúc Document chuẩn
class PdfGeneratorHelper {
  /// Hàm core tạo Document Bytes
  /// Hỗ trợ tự động MultiPage và Font Tiếng Việt
  static Future<Uint8List> buildDocumentBytes({
    required PdfConfigModel config,
    required List<pw.Widget> content, // Nội dung PDF
    bool isMultiPage = true, // Cờ bật tắt chế độ nhiều trang
    pw.Widget Function(pw.Context)? header,
    pw.Widget Function(pw.Context)? footer,
  }) async {
    // 1. Đảm bảo font đã được load
    await PdfFontHelper.instance.init();

    // 2. Tạo Document với Theme hỗ trợ Tiếng Việt
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: PdfFontHelper.instance.regularFont,
        bold: PdfFontHelper.instance.boldFont,
        italic: PdfFontHelper.instance.italicFont,
      ),
    );

    // 3. Xử lý OnePage vs MultiPage
    if (isMultiPage) {
      // MultiPage: Tự động ngắt trang khi nội dung dài
      // Limit note: Nếu content quá lớn (>50 trang ảnh), nên chia nhỏ content
      // thành nhiều file PDF hoặc dùng isolate (nhưng cấu hình phức tạp hơn).
      pdf.addPage(
        pw.MultiPage(
          pageFormat: config.pageFormat.copyWith(
            marginTop: config.margin,
            marginBottom: config.margin,
            marginLeft: config.margin,
            marginRight: config.margin,
          ),
          orientation: config.isPortrait
              ? pw.PageOrientation.portrait
              : pw.PageOrientation.landscape,
          header: header,
          footer: footer,
          build: (context) => content,
        ),
      );
    } else {
      // OnePage: Dùng cho các đơn từ cố định, không nhảy trang
      pdf.addPage(
        pw.Page(
          pageFormat: config.pageFormat,
          build: (context) =>
              pw.Center(child: content.first), // Chỉ lấy widget đầu tiên
        ),
      );
    }

    return pdf.save();
  }
}
