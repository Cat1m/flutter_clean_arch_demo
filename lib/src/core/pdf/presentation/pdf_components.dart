import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_text_styles.dart';

class PdfComponents {
  PdfComponents._();

  /// 1. Bảng dữ liệu tiêu chuẩn (Zebra stripe, Header màu xanh)
  static pw.Widget buildTable({
    required List<String> headers,
    required List<List<String>> data,
    List<double>? columnWidths, // Tỷ lệ chiều rộng cột (VD: [1, 3, 1])
  }) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      // Styling
      headerStyle: PdfTextStyles.tableHeader,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
      cellStyle: PdfTextStyles.tableCell,
      cellHeight: 30,
      cellAlignments: {
        // Căn chỉnh mặc định: Cột 0 center, còn lại left (tùy chỉnh nếu cần)
        0: pw.Alignment.center,
      },
      // Kẻ bảng
      border: null, // Bỏ border ngoài
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
    );
  }

  /// 2. Dòng thông tin (Dạng: "Họ tên: Nguyễn Văn A")
  static pw.Widget buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: PdfTextStyles.body.copyWith(color: PdfColors.grey600),
            ),
          ),
          pw.Expanded(child: pw.Text(value, style: PdfTextStyles.bodyBold)),
        ],
      ),
    );
  }

  /// 3. Dòng kẻ phân cách
  static pw.Widget divider() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Divider(color: PdfColors.grey300),
    );
  }
}
