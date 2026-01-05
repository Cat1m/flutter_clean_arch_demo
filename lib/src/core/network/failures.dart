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
}

// 1. Lỗi Server (API trả về lỗi hoặc 500)
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode, super.errorCode});
}

// 2. Lỗi mạng (Timeout, No Internet)
class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);
}

// 3. Lỗi Cache (Local DB)
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// 4. Lỗi Authentication (Token hết hạn, sai pass...)
// -> Tách riêng ra để dễ handle logout ở UI
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// 5. Lỗi không xác định
class UnknownFailure extends Failure {
  final Object? errorObject; // Lưu lại object lỗi gốc để debug nếu cần
  const UnknownFailure(super.message, {this.errorObject});
}
