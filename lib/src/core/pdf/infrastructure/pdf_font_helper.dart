import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfFontHelper {
  PdfFontHelper._();
  static final PdfFontHelper instance = PdfFontHelper._();

  // --- CẤU HÌNH ĐƯỜNG DẪN FONT ---
  static const _kPathRegular = 'assets/fonts/Roboto-Regular.ttf';
  static const _kPathBold = 'assets/fonts/Roboto-Bold.ttf';
  static const _kPathItalic = 'assets/fonts/Roboto-Italic.ttf';

  pw.Font? _regularFont;
  pw.Font? _boldFont;
  pw.Font? _italicFont;

  // Biến khóa để tránh Race Condition (Lỗi font lần đầu)
  Future<void>? _pendingInitFuture;

  /// Hàm khởi tạo an toàn (Safe Init)
  Future<void> init() async {
    // 1. Nếu đủ 3 font rồi thì return luôn
    if (_regularFont != null && _boldFont != null && _italicFont != null) {
      return;
    }

    // 2. Nếu đang chạy dở, bắt các request sau phải chờ chung
    if (_pendingInitFuture != null) {
      return _pendingInitFuture;
    }

    // 3. Tạo khóa và chạy
    _pendingInitFuture = _initImpl();

    // 4. Đợi xong
    await _pendingInitFuture;

    // 5. Xóa khóa
    _pendingInitFuture = null;
  }

  // Logic tải thực tế
  Future<void> _initImpl() async {
    try {
      // Tải song song cả 3 font cùng lúc cho nhanh
      await Future.wait([
        _loadRegular(),
        _loadBold(),
        _loadItalic(), // ✅ Đã thêm lại
      ]);
    } catch (e) {
      if (kDebugMode) print('PDF Font Error: $e');
    }
  }

  // --- Các hàm tải chi tiết (Có Backup Online) ---

  Future<void> _loadRegular() async {
    try {
      final data = await rootBundle.load(_kPathRegular);
      _regularFont = pw.Font.ttf(data);
    } catch (_) {
      _regularFont = await PdfGoogleFonts.robotoRegular();
    }
  }

  Future<void> _loadBold() async {
    try {
      final data = await rootBundle.load(_kPathBold);
      _boldFont = pw.Font.ttf(data);
    } catch (_) {
      _boldFont = await PdfGoogleFonts.robotoBold();
    }
  }

  Future<void> _loadItalic() async {
    try {
      final data = await rootBundle.load(_kPathItalic);
      _italicFont = pw.Font.ttf(data);
    } catch (_) {
      // Backup Italic Online
      _italicFont = await PdfGoogleFonts.robotoItalic();
    }
  }

  // --- Getters an toàn ---

  pw.Font get regularFont => _regularFont ?? pw.Font.courier();

  pw.Font get boldFont => _boldFont ?? _regularFont ?? pw.Font.courierBold();

  // Fallback: Italic -> Regular -> CourierOblique
  pw.Font get italicFont =>
      _italicFont ?? _regularFont ?? pw.Font.courierOblique();
}
