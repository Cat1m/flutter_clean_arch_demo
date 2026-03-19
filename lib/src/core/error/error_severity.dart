/// Mức độ nghiêm trọng của error, quyết định cách UI phản ứng.
enum ErrorSeverity {
  /// Log only, snackbar nhẹ (cache miss, dùng data cũ)
  info,

  /// Snackbar thông thường (mất mạng tạm thời)
  warning,

  /// Dialog bắt buộc acknowledge (server 500)
  critical,

  /// Redirect / force action (session expired → login)
  fatal,
}
