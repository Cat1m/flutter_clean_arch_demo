// lib/core/network/failures.dart

import 'package:equatable/equatable.dart';

/// Dart sẽ biết chính xác có bao nhiêu loại lỗi trong hệ thống.
sealed class Failure extends Equatable {
  final String message;
  final int? statusCode; // HTTP Status Code (400, 401, 500...)
  final String?
  errorCode; // Mã lỗi nghiệp vụ (ví dụ: "USER_LOCKED", "OTP_INVALID")

  const Failure(this.message, {this.statusCode, this.errorCode});

  @override
  List<Object?> get props => [message, statusCode, errorCode];

  // ✅ Helper method để check loại lỗi nhanh
  bool get isServerError => this is ServerFailure;
  bool get isNetworkError => this is ConnectionFailure;
  bool get isAuthError => this is AuthFailure;
  bool get isCacheError => this is CacheFailure;
  bool get isUnknownError => this is UnknownFailure;

  // ✅ Copy with cho flexibility
  Failure copyWith({String? message, int? statusCode, String? errorCode});
}

// 1. Lỗi Server (API trả về lỗi hoặc 500)
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode, super.errorCode});

  @override
  ServerFailure copyWith({
    String? message,
    int? statusCode,
    String? errorCode,
  }) {
    return ServerFailure(
      message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  // ✅ Helper để check loại server error
  bool get isBadRequest => statusCode == 400;
  bool get isNotFound => statusCode == 404;
  bool get isInternalServerError => statusCode == 500;
  bool get isServiceUnavailable => statusCode == 503;
}

// 2. Lỗi mạng (Timeout, No Internet)
class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);

  @override
  ConnectionFailure copyWith({
    String? message,
    int? statusCode,
    String? errorCode,
  }) {
    return ConnectionFailure(message ?? this.message);
  }

  // ✅ Predefined connection failures
  static const timeout = ConnectionFailure('Connection Timeout');
  static const noInternet = ConnectionFailure('No Internet Connection');
}

// 3. Lỗi Cache (Local DB)
class CacheFailure extends Failure {
  const CacheFailure(super.message);

  @override
  CacheFailure copyWith({String? message, int? statusCode, String? errorCode}) {
    return CacheFailure(message ?? this.message);
  }

  // ✅ Predefined cache failures
  static const notFound = CacheFailure('Data not found in cache');
  static const corrupted = CacheFailure('Cached data is corrupted');
  static const expired = CacheFailure('Cached data has expired');
}

// 4. Lỗi Authentication (Token hết hạn, sai pass...)
// -> Tách riêng ra để dễ handle logout ở UI
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.statusCode});

  @override
  AuthFailure copyWith({String? message, int? statusCode, String? errorCode}) {
    return AuthFailure(
      message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
    );
  }

  // ✅ Predefined auth failures
  static const unauthorized = AuthFailure('Unauthorized', statusCode: 401);
  static const forbidden = AuthFailure('Forbidden', statusCode: 403);
  static const tokenExpired = AuthFailure('Token expired', statusCode: 401);
  static const invalidCredentials = AuthFailure('Invalid credentials');
}

// 5. Lỗi không xác định
class UnknownFailure extends Failure {
  final Object? errorObject; // Lưu lại object lỗi gốc để debug nếu cần

  const UnknownFailure(super.message, {this.errorObject});

  @override
  UnknownFailure copyWith({
    String? message,
    int? statusCode,
    String? errorCode,
    Object? errorObject,
  }) {
    return UnknownFailure(
      message ?? this.message,
      errorObject: errorObject ?? this.errorObject,
    );
  }

  @override
  List<Object?> get props => [...super.props, errorObject];
}

// ✅ Extension để dễ dàng chuyển đổi sang user-friendly message
extension FailureExtension on Failure {
  /// Lấy message hiển thị cho user (có thể localize)
  String toDisplayMessage() {
    return switch (this) {
      ConnectionFailure() => 'Không có kết nối mạng. Vui lòng thử lại.',
      AuthFailure() => 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      ServerFailure(statusCode: 400) => 'Dữ liệu không hợp lệ.',
      ServerFailure(statusCode: 404) => 'Không tìm thấy dữ liệu.',
      ServerFailure(statusCode: 500) => 'Lỗi máy chủ. Vui lòng thử lại sau.',
      ServerFailure(message: final msg) => msg,
      CacheFailure() => 'Lỗi đọc dữ liệu cục bộ.',
      UnknownFailure() => 'Có lỗi xảy ra. Vui lòng thử lại.',
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
    return this is AuthFailure;
  }
}
