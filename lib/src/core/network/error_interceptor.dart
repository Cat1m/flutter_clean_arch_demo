// lib/core/network/error_interceptor.dart

import 'package:dio/dio.dart';
import 'package:reqres_in/src/core/network/failures.dart'; // Import lớp Failure của bạn

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 1. Phân tích loại lỗi
    final Failure failure = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const ConnectionFailure(
        'Hết thời gian chờ kết nối',
      ),

      DioExceptionType.connectionError => const ConnectionFailure(
        'Không thể kết nối đến máy chủ',
      ),

      DioExceptionType.badResponse => _handleBadResponse(err.response),

      DioExceptionType.cancel => const UnknownFailure('Yêu cầu đã bị hủy'),

      DioExceptionType.unknown =>
        // Trước đây bạn dùng message mặc định,
        // giờ bạn phải CUNG CẤP message một cách tường minh
        const ConnectionFailure(
          'Không có kết nối Internet. Vui lòng kiểm tra lại.',
        ),

      DioExceptionType.badCertificate => const UnknownFailure(
        'Lỗi chứng chỉ không hợp lệ',
      ), // Xử lý case còn thiếu
    };

    // 2. "Reject" request với một DioException mới
    // Bọc "Failure" của chúng ta vào bên trong trường 'error'
    final newErr = DioException(
      requestOptions: err.requestOptions,
      error: failure, // Đây là mấu chốt!
      type: err.type,
      response: err.response,
    );

    return handler.reject(newErr);
  }

  /// Xử lý các lỗi Bad Response (4xx, 5xx)
  /// Chúng ta sẽ cố gắng lấy message lỗi mà server trả về
  Failure _handleBadResponse(Response? response) {
    String errorMessage = 'Lỗi không xác định từ máy chủ';
    final int? statusCode = response?.statusCode;

    if (response?.data != null && response!.data is Map) {
      // Đây là phần bạn làm trong Repository:
      // Cố gắng parse theo format { "error": "..." }
      errorMessage =
          response.data['error'] ??
          // Hoặc thử format { "message": "..." }
          response.data['message'] ??
          'Lỗi máy chủ ($statusCode)';
    } else if (response?.statusMessage != null &&
        response!.statusMessage!.isNotEmpty) {
      errorMessage = response.statusMessage!;
    }

    return ServerFailure('$errorMessage (Code: $statusCode)');
  }
}
