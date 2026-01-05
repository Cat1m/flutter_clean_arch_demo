// -----------------------------------------------------------------------------
// 🟢 CONFIG KEY: Chỉ cần sửa ở đây khi sang Project mới
// -----------------------------------------------------------------------------
class _Keys {
  static const String data = 'data';
  static const String message = 'message';
  static const String status = 'status'; // Hoặc 'code', 'errorCode'
}

/// ✉️ ENVELOPE (Phong bì)
/// Dùng cho cấu trúc response dạng object: { "status": 200, "data": {...} }
class Envelope<T> {
  final int? status;
  final String? message;
  final T? data;

  Envelope({this.status, this.message, this.data});

  /// Kiểm tra nhanh status (Tùy logic Backend)
  bool get isSuccess => status == 200 || status == 201 || status == 1;

  factory Envelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return Envelope<T>(
      status: json[_Keys.status] as int?,
      message: json[_Keys.message] as String?,
      // Logic an toàn: Nếu 'data' null thì trả về null
      data: (json[_Keys.data] != null) ? fromJsonT(json[_Keys.data]) : null,
    );
  }
}

/// ✉️ LIST ENVELOPE (Phong bì chứa Danh sách)
/// Dùng cho cấu trúc response dạng list: { "data": [...], "total": 100 }
class ListEnvelope<T> {
  final int? status;
  final String? message;
  final List<T> data;

  // Các trường phân trang (Pagination)
  final int total;
  final int page;
  final int limit;

  ListEnvelope({
    this.status,
    this.message,
    this.data = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 10,
  });

  factory ListEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final rawData = json[_Keys.data];

    List<T> items = [];
    if (rawData is List) {
      items = rawData.map((e) => fromJsonT(e)).toList();
    }

    return ListEnvelope<T>(
      status: json[_Keys.status] as int?,
      message: json[_Keys.message] as String?,
      data: items,
      // Mapping các trường phân trang linh hoạt
      total: (json['total'] ?? json['totalCount'] ?? 0) as int,
      page: (json['page'] ?? 1) as int,
      limit: (json['limit'] ?? json['pageSize'] ?? 10) as int,
    );
  }
}
