import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Cần gói printing cho Google Fonts

class PdfFontHelper {
  PdfFontHelper._();
  static final PdfFontHelper instance = PdfFontHelper._();

  // --- CẤU HÌNH ĐƯỜNG DẪN FONT (Độc lập với FlutterGen) ---
  // Khi sang project mới, chỉ cần đảm bảo có file này trong assets
  // hoặc sửa đường dẫn tại đây.
  static const _kPathRegular = 'assets/fonts/Roboto-Regular.ttf';
  static const _kPathBold = 'assets/fonts/Roboto-Bold.ttf';
  static const _kPathItalic = 'assets/fonts/Roboto-Italic.ttf';

  pw.Font? _regularFont;
  pw.Font? _boldFont;
  pw.Font? _italicFont;

  /// Hàm khởi tạo: Asset -> Network -> Fallback
  Future<void> init() async {
    if (_regularFont != null) return;

    // 1. Load Regular (Quan trọng nhất)
    try {
      _regularFont = await _loadFontAsset(_kPathRegular);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ PDF: Lỗi load Asset Regular ($_kPathRegular). Thử Online...');
      }
      try {
        _regularFont = await PdfGoogleFonts.robotoRegular();
      } catch (_) {}
    }

    // 2. Load Bold
    try {
      _boldFont = await _loadFontAsset(_kPathBold);
    } catch (e) {
      if (kDebugMode) print('⚠️ PDF: Lỗi load Asset Bold. Thử Online...');
      try {
        _boldFont = await PdfGoogleFonts.robotoBold();
      } catch (_) {}
    }

    // 3. Load Italic (Nếu cần)
    try {
      _italicFont = await _loadFontAsset(_kPathItalic);
    } catch (e) {
      // Không quan trọng lắm, có thể bỏ qua backup
    }
  }

  Future<pw.Font> _loadFontAsset(String path) async {
    final data = await rootBundle.load(path);
    return pw.Font.ttf(data);
  }

  // --- Getters ---
  pw.Font get regularFont => _regularFont ?? pw.Font.courier();

  // Fallback dây chuyền: Bold -> Regular -> CourierBold
  pw.Font get boldFont => _boldFont ?? _regularFont ?? pw.Font.courierBold();

  // Fallback dây chuyền: Italic -> Regular -> CourierOblique
  pw.Font get italicFont =>
      _italicFont ?? _regularFont ?? pw.Font.courierOblique();
}
