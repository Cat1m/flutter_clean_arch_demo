// lib/core/network/response_envelope.dart

// -----------------------------------------------------------------------------
// 🟢 CONFIG KEY: Trung tâm điều khiển Key của API
// -----------------------------------------------------------------------------
class _Keys {
  // 1. Core Keys
  static const String data = 'data';
  static const String message = 'message';
  static const String status = 'status'; // Hoặc 'code'

  // 2. Pagination Keys (Cấu hình 1 lần tại đây)
  static const String total = 'total'; // Backend trả về tổng số item
  static const String page = 'page'; // Page hiện tại
  static const String limit =
      'per_page'; // Số item trên 1 page (Ví dụ Reqres dùng per_page)
  static const String totalPages = 'total_pages'; // Tổng số trang
}

/// ✉️ ENVELOPE (Phong bì đơn)
/// Cấu trúc: { "data": {...}, "message": "..." }
class Envelope<T> {
  final int? status;
  final String? message;
  final T? data;

  const Envelope({this.status, this.message, this.data});

  // [Như]: Getter check success nhanh
  bool get isSuccess => (status ?? 200) >= 200 && (status ?? 200) < 300;

  factory Envelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return Envelope<T>(
      status: json[_Keys.status] as int?,
      message: json[_Keys.message] as String?,
      // [Như]: Dart 3 Null-aware: Gọn gàng, an toàn
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
    // [Như]: Parse List an toàn tuyệt đối với 1 dòng
    // Cast sang List? trước, sau đó map. Nếu null hoặc sai kiểu thì trả về empty [].
    final rawList = json[_Keys.data] as List?;
    final items = rawList?.map((e) => fromJsonT(e)).toList() ?? <T>[];

    return ListEnvelope<T>(
      status: json[_Keys.status] as int?,
      message: json[_Keys.message] as String?,
      data: items,

      // [Như]: Mapping theo Config Key đã định nghĩa ở trên
      // Dùng ?? 0 để đảm bảo không bao giờ null crash
      total: (json[_Keys.total] as int?) ?? 0,
      page: (json[_Keys.page] as int?) ?? 1,
      limit: (json[_Keys.limit] as int?) ?? 10,
      totalPages: (json[_Keys.totalPages] as int?) ?? 1,
    );
  }
}
