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

  // ✅ 1. CHÈN LINK (Clickable)
  static pw.Widget buildLink({
    required String text,
    required String url,
    pw.TextStyle? style,
  }) {
    return pw.UrlLink(
      destination: url,
      child: pw.Text(
        text,
        style:
            style ??
            PdfTextStyles.body.copyWith(
              color: PdfColors.blue,
              decoration: pw.TextDecoration.underline,
            ),
      ),
    );
  }

  // ✅ 2. CHÈN QR CODE
  static pw.Widget buildQRCode({required String data, double size = 60}) {
    return pw.BarcodeWidget(
      data: data,
      barcode: pw.Barcode.qrCode(),
      width: size,
      height: size,
      drawText: false, // Không hiện text bên dưới mã
      color: PdfColors.black,
    );
  }

  // 1. Định nghĩa SVG String (Hình người mặc định)
  // Đây là vector path chuẩn của icon Person trong Material Design
  static const String _kProfileSvg =
      '<svg viewBox="0 0 24 24"><path fill="#9E9E9E" d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>';

  // 2. Định nghĩa SVG String (Hình cảnh báo lỗi - Dấu chấm than)
  static const String _kErrorSvg =
      '<svg viewBox="0 0 24 24"><path fill="#EF5350" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg>';

  // ✅ Hàm tạo Placeholder Avatar (Có icon)
  static pw.Widget buildAvatarPlaceholder({bool isError = false}) {
    return pw.Container(
      color: PdfColors.grey200,
      child: pw.Center(
        child: pw.SvgImage(
          svg: isError ? _kErrorSvg : _kProfileSvg,
          width: 40, // Kích thước icon bên trong
          height: 40,
        ),
      ),
    );
  }
}
