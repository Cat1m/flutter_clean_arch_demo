import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../domain/pdf_config_model.dart';
import '../infrastructure/pdf_generator_helper.dart';
import 'pdf_text_styles.dart';

class PdfPageTemplate {
  /// Hàm build chính, gọi đến Helper ở tầng Infrastructure
  static Future<Uint8List> generate({
    required PdfConfigModel config,
    required String title,
    required List<pw.Widget> content,
    String? subTitle,
  }) async {
    return PdfGeneratorHelper.buildDocumentBytes(
      config: config,
      content: [
        // Title block (Luôn hiện ở đầu trang 1)
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title.toUpperCase(),
              style: PdfTextStyles.h1.copyWith(color: PdfColors.blue800),
            ),
            if (subTitle != null) ...[
              pw.SizedBox(height: 4),
              pw.Text(subTitle, style: PdfTextStyles.bodySmall),
            ],
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
          ],
        ),
        // Nội dung chính
        ...content,
      ],
      // HEADER chung cho các trang (Logo, Tên công ty)
      header: (context) {
        if (context.pageNumber == 1) {
          return pw.SizedBox(); // Trang 1 đã có Title to
        }
        return pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 8),
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
            ),
          ),
          child: pw.Text(
            title,
            style: PdfTextStyles.bodySmall.copyWith(color: PdfColors.grey500),
          ),
        );
      },
      // FOOTER chung (Số trang)
      footer: (context) {
        return pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Trang ${context.pageNumber} / ${context.pagesCount}',
            style: PdfTextStyles.bodySmall,
          ),
        );
      },
    );
  }
}
