// lib/core/network/response_envelope.dart

// -----------------------------------------------------------------------------
// 🟢 CONFIG KEY: Trung tâm điều khiển Key của API
// -----------------------------------------------------------------------------
class _Keys {
  // 1. Core Keys
  static const String data = 'data';
  static const String message = 'message';
  static const String status = 'status'; // Hoặc 'code'

  // 2. Pagination Keys
  static const String total = 'total';
  static const String page = 'page';
  static const String limit = 'per_page';
  static const String totalPages = 'total_pages';
}

/// ✉️ ENVELOPE (Phong bì đơn)
/// Cấu trúc: { "data": {...}, "message": "..." }
class Envelope<T> {
  final int? status;
  final String? message;
  final T? data;

  const Envelope({this.status, this.message, this.data});

  // Getter check success — null status = không xác định, không mặc định success
  bool get isSuccess => status != null && status! >= 200 && status! < 300;

  factory Envelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return Envelope<T>(
      status: json[_Keys.status] as int?,
      message: json[_Keys.message] as String?,
      // ✅ Dart 3 Pattern Matching: Xử lý null safety cực gọn
      data: switch (json[_Keys.data]) {
        null => null,
        final Object data => fromJsonT(data),
      },
    );
  }
}

/// ✉️ LIST ENVELOPE (Phong bì danh sách)
/// Cấu trúc: { "data": [...], "page": 1, ... }
class ListEnvelope<T> {
  final int? status;
  final String? message;
  final List<T> data;

  // Metadata phân trang
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ListEnvelope({
    this.status,
    this.message,
    this.data = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.totalPages = 1,
  });

  factory ListEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    // ✅ REFACTOR SAFETY: Dùng Pattern Matching để cast an toàn tuyệt đối.
    // Nếu json['data'] là List -> map nó.
    // Nếu là null hoặc bất cứ kiểu gì khác (Map, String...) -> trả về rỗng [].
    final items = switch (json[_Keys.data]) {
      final List<dynamic> list => list.map((e) => fromJsonT(e)).toList(),
      _ => <T>[],
    };

    return ListEnvelope<T>(
      status: json[_Keys.status] as int?,
      message: json[_Keys.message] as String?,
      data: items,

      // Metadata keys
      total: (json[_Keys.total] as int?) ?? 0,
      page: (json[_Keys.page] as int?) ?? 1,
      limit: (json[_Keys.limit] as int?) ?? 10,
      totalPages: (json[_Keys.totalPages] as int?) ?? 1,
    );
  }
}
