import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../infrastructure/pdf_font_helper.dart';

class PdfTextStyles {
  PdfTextStyles._();

  // Helper để lấy font nhanh
  static pw.Font get _regular => PdfFontHelper.instance.regularFont;
  static pw.Font get _bold => PdfFontHelper.instance.boldFont;
  // ignore: unused_element
  static pw.Font get _italic => PdfFontHelper.instance.italicFont;

  // --- HEADINGS ---
  static pw.TextStyle get h1 =>
      pw.TextStyle(font: _bold, fontSize: 24, color: PdfColors.black);

  static pw.TextStyle get h2 =>
      pw.TextStyle(font: _bold, fontSize: 18, color: PdfColors.black);

  static pw.TextStyle get h3 =>
      pw.TextStyle(font: _bold, fontSize: 14, color: PdfColors.grey800);

  // --- BODY ---
  static pw.TextStyle get body =>
      pw.TextStyle(font: _regular, fontSize: 12, color: PdfColors.black);

  static pw.TextStyle get bodyBold => body.copyWith(font: _bold);

  static pw.TextStyle get bodySmall =>
      body.copyWith(fontSize: 10, color: PdfColors.grey700);

  // --- TABLE STYLES ---
  static pw.TextStyle get tableHeader =>
      bodyBold.copyWith(color: PdfColors.white);
  static pw.TextStyle get tableCell => body;
}
