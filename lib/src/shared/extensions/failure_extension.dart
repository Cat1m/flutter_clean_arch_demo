// lib/src/shared/extensions/failure_extension.dart

import 'package:reqres_in/src/core/network/failures.dart';

/// ✅ Extension để chuyển đổi Failure thành message hiển thị cho user
///
/// Đặt ở Shared layer vì:
/// - Chứa presentation logic (UI messages)
/// - Có thể localize dễ dàng
/// - Không làm "ô nhiễm" Core network module
extension FailureExtension on Failure {
  /// Lấy message hiển thị cho user (tiếng Việt)
  ///
  /// TODO: Tích hợp với i18n package để support đa ngôn ngữ
  String toDisplayMessage() {
    return switch (this) {
      // Connection Failures
      ConnectionFailure(message: final msg) => _mapConnectionError(msg),

      // Auth Failures
      AuthFailure(statusCode: 401) =>
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      AuthFailure(statusCode: 403) =>
        'Bạn không có quyền truy cập tài nguyên này.',
      AuthFailure() => 'Lỗi xác thực. Vui lòng đăng nhập lại.',

      // Server Failures
      ServerFailure(statusCode: 400, message: final msg) =>
        'Dữ liệu không hợp lệ: $msg',
      ServerFailure(statusCode: 404) => 'Không tìm thấy dữ liệu yêu cầu.',
      ServerFailure(statusCode: 422, message: final msg) =>
        'Dữ liệu không đúng định dạng: $msg',
      ServerFailure(statusCode: 429) =>
        'Quá nhiều yêu cầu. Vui lòng thử lại sau.',
      ServerFailure(statusCode: 500) => 'Lỗi máy chủ. Vui lòng thử lại sau.',
      ServerFailure(statusCode: 502) =>
        'Máy chủ đang bảo trì. Vui lòng thử lại sau.',
      ServerFailure(statusCode: 503) => 'Dịch vụ tạm thời không khả dụng.',
      ServerFailure(message: final msg) => msg,

      // Certificate Failures
      CertificateFailure() =>
        'Kết nối không an toàn. Chứng chỉ bảo mật không hợp lệ.',

      // Cache Failures
      CacheFailure(message: final msg) => 'Lỗi đọc dữ liệu cục bộ: $msg',

      // Unknown Failures
      UnknownFailure() => 'Có lỗi không xác định xảy ra. Vui lòng thử lại.',
    };
  }

  /// Map connection error messages
  String _mapConnectionError(String message) {
    if (message.toLowerCase().contains('timeout')) {
      return 'Kết nối quá chậm. Vui lòng kiểm tra mạng và thử lại.';
    }
    if (message.toLowerCase().contains('no internet')) {
      return 'Không có kết nối mạng. Vui lòng kiểm tra và thử lại.';
    }
    return 'Lỗi kết nối. Vui lòng thử lại.';
  }

  /// Lấy message ngắn gọn cho Toast/Snackbar
  String toShortMessage() {
    return switch (this) {
      ConnectionFailure() => 'Không có kết nối mạng',
      CertificateFailure() => 'Chứng chỉ không hợp lệ',
      AuthFailure() => 'Phiên đăng nhập hết hạn',
      ServerFailure(statusCode: 404) => 'Không tìm thấy',
      ServerFailure(statusCode: 500) => 'Lỗi máy chủ',
      ServerFailure() => 'Lỗi từ máy chủ',
      CacheFailure() => 'Lỗi dữ liệu cục bộ',
      UnknownFailure() => 'Có lỗi xảy ra',
    };
  }

  /// Lấy title cho Dialog
  String toDialogTitle() {
    return switch (this) {
      ConnectionFailure() => 'Lỗi kết nối',
      CertificateFailure() => 'Lỗi chứng chỉ',
      AuthFailure() => 'Lỗi xác thực',
      ServerFailure() => 'Lỗi máy chủ',
      CacheFailure() => 'Lỗi dữ liệu',
      UnknownFailure() => 'Lỗi',
    };
  }

  /// Có nên retry request này không?
  bool get shouldRetry {
    return switch (this) {
      ConnectionFailure() => true,
      ServerFailure(statusCode: final code) when code != null && code >= 500 =>
        true,
      _ => false,
    };
  }

  /// Có nên logout user không?
  bool get shouldLogout {
    return switch (this) {
      AuthFailure(statusCode: 401) => true,
      AuthFailure(statusCode: 403) => false, // 403 không logout
      AuthFailure() => true,
      _ => false,
    };
  }

  /// Có nên show dialog không? (thay vì toast)
  bool get shouldShowDialog {
    return switch (this) {
      AuthFailure() => true,
      ServerFailure(statusCode: final code) when code != null && code >= 500 =>
        true,
      UnknownFailure() => true,
      _ => false,
    };
  }

  /// Icon phù hợp cho error (dùng cho UI)
  String get icon {
    return switch (this) {
      ConnectionFailure() => '📡',
      CertificateFailure() => '🔒',
      AuthFailure() => '🔐',
      ServerFailure() => '⚠️',
      CacheFailure() => '💾',
      UnknownFailure() => '❌',
    };
  }

  /// Action text phù hợp
  String get actionText {
    return switch (this) {
      _ when shouldRetry => 'Thử lại',
      _ when shouldLogout => 'Đăng nhập lại',
      _ => 'Đóng',
    };
  }
}

/// ✅ Extension cho việc log/debug
extension FailureDebugExtension on Failure {
  /// Format đẹp cho log
  String toLogString() {
    final buffer = StringBuffer();
    buffer.writeln('$runtimeType: $message');

    if (statusCode != null) {
      buffer.writeln('  Status Code: $statusCode');
    }

    if (errorCode != null) {
      buffer.writeln('  Error Code: $errorCode');
    }

    if (this is UnknownFailure) {
      final unknown = this as UnknownFailure;
      if (unknown.errorObject != null) {
        buffer.writeln('  Error Object: ${unknown.errorObject}');
      }
    }

    return buffer.toString();
  }

  /// Tạo Map để gửi lên Analytics/Crashlytics
  Map<String, dynamic> toAnalyticsMap() {
    return {
      'error_type': runtimeType.toString(),
      'message': message,
      if (statusCode != null) 'status_code': statusCode,
      if (errorCode != null) 'error_code': errorCode,
      'should_retry': shouldRetry,
      'should_logout': shouldLogout,
    };
  }
}
