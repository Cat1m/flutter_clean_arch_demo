// lib/core/network/base_response.dart

import 'package:flutter/foundation.dart';

/// 📦 Đại diện cho một cấu trúc "vỏ thư" (Response Envelope) chung
/// mà rất nhiều API backend sử dụng.
///
/// ⚠️ QUAN TRỌNG: Cấu trúc này TÙY THUỘC VÀO DỰ ÁN.
/// Class này PHẢI được tùy chỉnh để khớp với API của dự án thực tế.
///
/// Ví dụ:
/// - Dự án A: { "status": 1, "message": "OK", "data": {...} }
/// - Dự án B: { "success": true, "error_message": null, "result": {...} }
///
/// API `reqres.in` KHÔNG DÙNG cấu trúc này, đây là file MẪU để học tập.
///
/// [T] là kiểu dữ liệu của đối tượng `data` bên trong (ví dụ: UserModel, List<//ProductModel>).
class BaseResponse<T> {
  // Giả sử backend trả về 3 trường này.
  // Hãy đổi tên chúng cho khớp với dự án của bạn (ví dụ: statusCode, msg, result).
  final int? status;
  final String? message;
  final T? data;

  BaseResponse({this.status, this.message, this.data});

  /// Một factory constructor để parse JSON.
  /// Nó cần một hàm [fromJsonT] để biết cách parse cục `data` bên trong.
  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    // [fromJsonT] là một hàm được truyền vào, ví dụ: (json) => LoginResponse.fromJson(json)
    T Function(Object? json)? fromJsonT,
  ) {
    T? parsedData;

    // Chỉ parse cục 'data' nếu nó không null VÀ ta có hàm để parse nó
    if (fromJsonT != null && json['data'] != null) {
      try {
        parsedData = fromJsonT(json['data']);
      } catch (e) {
        // Rất hữu ích để debug khi cấu trúc data trả về bị sai
        if (kDebugMode) {
          print('Lỗi khi parse data T bên trong BaseResponse: $e');
        }
      }
    }

    return BaseResponse<T>(
      status: json['status'] as int?,
      message: json['message'] as String?,
      data: parsedData,
    );
  }

  /// Helper getter để kiểm tra nhanh trạng thái nghiệp vụ.
  /// (Giả sử 1 là thành công, các số khác là lỗi)
  bool get isSuccess => status == 1;
}
