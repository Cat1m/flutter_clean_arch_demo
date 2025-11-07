import 'package:equatable/equatable.dart';
import 'package:reqres_in/src/features/user/models/user_model.dart';

// 1. Dùng 'sealed class' làm lớp cơ sở
// Nó buộc tất cả các state con phải được định nghĩa trong cùng 1 file
sealed class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

// 2. Các state con dùng 'final class'
// (Hoặc 'class' nếu bạn muốn nó có thể được kế thừa)

/// Trạng thái ban đầu, chưa làm gì cả
final class UserInitial extends UserState {}

/// Trạng thái đang tải dữ liệu (ví dụ: gọi API getMe)
final class UserLoading extends UserState {}

/// Trạng thái tải thành công, chứa dữ liệu User
final class UserSuccess extends UserState {
  final User user;

  const UserSuccess(this.user);

  @override
  List<Object> get props => [user];
}

/// Trạng thái tải thất bại, chứa thông báo lỗi
final class UserFailure extends UserState {
  final String message;

  const UserFailure(this.message);

  @override
  List<Object> get props => [message];
}
