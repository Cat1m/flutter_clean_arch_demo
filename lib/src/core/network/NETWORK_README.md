# 🌐 Core Network Module

Module quản lý kết nối mạng, xử lý API và lỗi tập trung cho ứng dụng Flutter.
Được thiết kế theo kiến trúc **Clean Architecture** và tách biệt hoàn toàn Logic Auth.

## 📂 Cấu trúc thư mục

```text
lib/src/core/network/
├── models/
│   ├── auth_type.dart          # Enum định nghĩa loại xác thực (UserToken, ApiKey, None)
│   └── response_envelope.dart  # Wrapper phản hồi chuẩn (Envelope Pattern)
├── clients/
│   └── dio_client.dart         # Cấu hình Dio (Timeout, Interceptors, Logger)
├── interceptors/
│   └── error_interceptor.dart  # Chuyển đổi DioException -> App Failure
├── services/
│   └── file_upload_service.dart # Service upload file (có chia Chunk)
├── api_service.dart            # Định nghĩa toàn bộ Endpoint (Retrofit)
└── failures.dart               # Các class lỗi Domain (ServerFailure, CacheFailure...)
🛠️ Thành phần Core (Ít thay đổi)
Đây là các file xương sống, có thể tái sử dụng 100% qua các dự án khác mà không cần sửa logic.

dio_client.dart:

Đóng vai trò Factory tạo ra instance Dio.

Là nơi "cắm" (plug) các Interceptor từ bên ngoài vào (như Auth, Token).

Note: Logger hiện tại đang được cấu hình cứng ở đây (PrettyDioLogger).

error_interceptor.dart:

Bắt mọi lỗi từ Dio.

Phân loại lỗi (Timeout, No Internet, Bad Response).

Bọc lỗi vào Failure object để tầng UI dễ xử lý.

failures.dart:

Định nghĩa các lỗi nghiệp vụ chung. Dùng Equatable để dễ so sánh.

auth_type.dart:

Định nghĩa các Annotation (@userToken, @noAuth) dùng trong Retrofit.

⚙️ Thành phần Tùy biến (Theo dự án)
Các file này phụ thuộc vào Backend cụ thể của từng dự án. Cần review khi copy sang project mới.

response_envelope.dart (Quan trọng):

Định nghĩa cấu trúc JSON trả về.

Ví dụ: Backend trả { "data": ..., "err_code": 0 } thì phải sửa file này để map đúng key.

api_service.dart:

Chứa danh sách các API endpoints.

Hiện tại đang quản lý Tập trung (Centralized).

Scaling: Nếu file này quá lớn (>300 dòng), hãy tách thành AuthClient, UserClient và đặt vào folder Feature tương ứng.

file_upload_service.dart:

Logic upload file. Cần kiểm tra lại URL upload và logic Chunking nếu Server thay đổi.

🚀 Cách sử dụng (Setup)
Cài đặt dependencies: Chạy script setup (nếu có) hoặc đảm bảo pubspec.yaml có: dio, retrofit, json_annotation...

Dependency Injection: Module này cần được cung cấp Interceptor từ module Auth. Xem file core/di/register_module.dart để biết cách inject.

Gọi API:

Dart

// Repository Layer
final response = await _apiService.login(request);
📝 Notes
Logger: Hiện tại PrettyDioLogger đang nằm trong DioClient. Nếu muốn customize log sâu hơn, nên tách ra thành LoggerInterceptor riêng.