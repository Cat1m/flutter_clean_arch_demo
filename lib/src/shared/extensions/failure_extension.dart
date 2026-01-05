// lib/shared/extensions/failure_extension.dart

import 'package:reqres_in/src/core/network/failures.dart';

extension FailureDisplay on Failure {
  /// Thông báo thân thiện cho người dùng (Tiếng Việt)
  String get uiMessage {
    return switch (this) {
      // 1. Lỗi mạng
      ConnectionFailure() =>
        'Không có kết nối Internet. Vui lòng kiểm tra lại đường truyền.',

      // 2. Lỗi Server
      ServerFailure(statusCode: final code, message: final msg) =>
        _handleServerMessage(code, msg),

      // 3. Lỗi Auth (Thường UI sẽ tự navigate về Login, nhưng vẫn cần text fallback)
      AuthFailure() => 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',

      // 4. Lỗi Cache
      CacheFailure() => 'Không thể tải dữ liệu đã lưu.',

      // 5. Lỗi lạ
      UnknownFailure() =>
        'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại sau.',
    };
  }

  /// Logic riêng để xử lý thông báo lỗi từ Server
  String _handleServerMessage(int? code, String serverMsg) {
    // Nếu là lỗi 500+ (Lỗi hệ thống), không nên hiện raw message của dev cho user xem
    if (code != null && code >= 500) {
      return 'Máy chủ đang bảo trì. Vui lòng thử lại sau ($code).';
    }

    // Nếu là lỗi 400 (Bad Request), thường chứa message validation (Ví dụ: "Email sai định dạng")
    // Thì ưu tiên hiển thị message của server trả về
    if (code != null && code >= 400 && code < 500) {
      return serverMsg.isNotEmpty ? serverMsg : 'Yêu cầu không hợp lệ.';
    }

    // Mặc định
    return serverMsg.isNotEmpty ? serverMsg : 'Lỗi máy chủ ($code)';
  }
}
