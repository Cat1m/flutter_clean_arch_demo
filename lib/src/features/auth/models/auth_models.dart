import 'package:freezed_annotation/freezed_annotation.dart';

// Import model User là KHÔNG CẦN THIẾT ở đây,
// vì LoginResponse trả về một cấu trúc "phẳng" (flat)
// chứ không lồng một đối tượng User bên trong.

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

// --- REQUEST ---
@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String username, // <-- Đã đổi từ email
    required String password,
    int? expiresInMins, // (Tùy chọn)
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

// --- RESPONSE ---
// API /auth/login của dummyjson trả về một cấu trúc "phẳng"
// bao gồm TẤT CẢ các trường của User CỘNG VỚI 2 token.
@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    // Các trường của User
    required int id,
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String gender,
    required String image,

    // Các trường Token
    required String accessToken, // <-- Đã đổi từ 'token'
    required String refreshToken, // <-- Đã thêm mới
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

@freezed
abstract class RefreshRequest with _$RefreshRequest {
  const factory RefreshRequest({
    /// Refresh token bạn đã lưu từ lúc đăng nhập
    required String refreshToken,

    /// (Tùy chọn) Thời gian hết hạn cho accessToken MỚI (tính bằng phút)
    int? expiresInMins,
  }) = _RefreshRequest;

  factory RefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestFromJson(json);
}

@freezed
abstract class RefreshResponse with _$RefreshResponse {
  const factory RefreshResponse({
    required String accessToken,
    required String refreshToken,
  }) = _RefreshResponse;

  factory RefreshResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshResponseFromJson(json);
}
