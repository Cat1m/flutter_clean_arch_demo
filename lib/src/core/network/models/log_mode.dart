/// Các chế độ Log của hệ thống
enum LogMode {
  /// Chỉ log ra đúng 1 dòng (Method + URL + Status + Duration)
  oneLine,

  /// Request: Header (Token) + Body
  /// Response: Body (nhưng cắt ngắn giới hạn ký tự)
  short,

  /// Hiển thị full 100% (Headers, Body full, Response full)
  full,
}
