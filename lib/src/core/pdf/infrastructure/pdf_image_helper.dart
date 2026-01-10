import 'dart:async';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // Cần import http để tải ảnh mạng
import 'package:pdf/widgets.dart' as pw;

class PdfImageHelper {
  PdfImageHelper._();

  /// Load ảnh từ Assets (Local)
  static Future<pw.MemoryImage> loadAssetImage(String path) async {
    final data = await rootBundle.load(path);
    return pw.MemoryImage(data.buffer.asUint8List());
  }

  /// Load ảnh từ Network (URL)
  /// Trả về null nếu lỗi tải ảnh (để UI xử lý placeholder)
  static Future<pw.MemoryImage?> loadNetworkImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      }
      return null;
    } catch (e) {
      // Log lỗi nếu cần
      return null;
    }
  }
}
