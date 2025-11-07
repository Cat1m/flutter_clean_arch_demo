import 'package:equatable/equatable.dart';

/// Lớp cơ sở cho tất cả các lỗi trong ứng dụng.
/// Kế thừa Equatable để dễ dàng so sánh các instance lỗi.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Lỗi xảy ra từ phía Server (ví dụ: 500 Internal Server Error, 404 Not Found,
/// hoặc lỗi logic nghiệp vụ trả về từ API).
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Lỗi xảy ra khi không có kết nối mạng hoặc timeout.
class ConnectionFailure extends Failure {
  const ConnectionFailure([super.message = 'Không có kết nối Internet']);
}

/// Lỗi xảy ra khi làm việc với Local Data Source (ví dụ: không đọc được cache,
/// lỗi SharedPreferences, lỗi Database cục bộ).
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Lỗi bộ nhớ đệm']);
}

/// Lỗi không xác định hoặc các lỗi ngoại lệ khác không rơi vào các trường hợp trên.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Đã xảy ra lỗi không xác định']);
}
