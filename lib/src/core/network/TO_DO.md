# 📋 Checklist Di chuyển Network Layer
---

## 1. 📦 Dependencies (pubspec.yaml)

Việc đầu tiên là đảm bảo project mới có đủ "nguyên liệu".

* [ ] **Copy `dependencies`:**
    * `dio`: Lõi của network.
    * `retrofit`: Để tạo `ApiService`.
    * `json_annotation`: Để tạo Model.
    * `dartz`: Để xử lý `Either<Failure, Success>`.
    * `get_it`: Để DI (Dependency Injection).
    * `injectable`: Để DI (Code gen).
    * `pretty_dio_logger`: (Tuỳ chọn) Để log request.
    * `flutter_secure_storage`: (Hoặc BẤT KỲ thư viện lưu trữ nào bạn chọn).
* [ ] **Copy `dev_dependencies`:**
    * `build_runner`: Công cụ sinh code.
    * `retrofit_generator`: Trình sinh code của Retrofit.
    * `json_serializable`: Trình sinh code của Model.
    * `injectable_generator`: Trình sinh code của DI.

---

## 2. 🌍 Cấu hình Môi trường (Environment)

Đây là nơi bạn định nghĩa các "hằng số" của project mới.

* [ ] **Kiểm tra file `Env`:** Project mới lưu `baseUrl` ở đâu?
    * Nếu chưa có, hãy tạo file `env.dart`.
* [ ] **Cập nhật `baseUrl`:** Lấy `baseUrl` (Production) của project mới.
* [ ] **Cập nhật `apiKey`:** Lấy `apiKey` (nếu có) của project mới.
* [ ] **Cập nhật các `baseUrl` khác:** Project mới có dùng server file riêng không? (Nếu có, cập nhật `Env.fileServer` cho `FileUploadService`).
* [ ] **Cập nhật `_urlDev`:** Trong `dio_client.dart`, cập nhật URL `ngrok` hoặc `localhost` của project mới.

---

## 3. 📦 "Vỏ Thư" (BaseResponse)

Đây là bước **quan trọng nhất** và gần như chắc chắn sẽ thay đổi.

* [ ] **Hỏi Backend:** Cấu trúc "vỏ thư" (response envelope) chung của project này là gì?
    * Ví dụ 1: `{ "status": 1, "message": "OK", "data": {...} }`
    * Ví dụ 2: `{ "success": true, "error_code": null, "result": {...} }`
* [ ] **Sửa `base_response.dart`:**
    * Đổi tên các trường (field) cho khớp (ví dụ: `status` -> `success`).
    * Đổi kiểu dữ liệu nếu cần (ví dụ: `status` là `int` hay `bool`?).
* [ ] **Sửa `isSuccess` getter:** Cập nhật logic `isSuccess` để khớp với project mới (ví dụ: `bool get isSuccess => success == true;`).

---

## 4. ⚙️ Lõi Dio & Interceptors

Đây là "bộ não" của network layer.

* [ ] **Copy `dio_client.dart`:** File này gần như không cần sửa, vì nó chỉ "lắp ráp" các Interceptor.
* [ ] **Copy `failures.dart`:** File này không cần sửa.
* [ ] **Copy `auth_interceptor.dart`:**
    * Kiểm tra `AuthType`: Project mới có dùng nhiều loại xác thực (ví dụ: `userToken` vs `apiKey`) không? Nếu không, hãy đơn giản hóa nó.
* [ ] **Kiểm tra `error_interceptor.dart`:**
    * **Hỏi Backend:** Khi có lỗi (400, 500), JSON lỗi trả về có dạng gì?
    * **Sửa `_handleBadResponse`:** Cập nhật logic để parse đúng message lỗi (ví dụ: `response.data['error']` hay `response.data['message']` hay `response.data['errors'][0]`).
* [ ] **Kiểm tra `token_interceptor.dart`:**
    * **Hỏi Backend:** Project này có cơ chế Refresh Token không?
    * Nếu có: Cập nhật đường dẫn (path) và body của API refresh token cho đúng.
    * Nếu không: Xóa `TokenInterceptor` khỏi `dio_client.dart`.

---

## 5. 💾 Lớp Lưu trữ (Storage)

Cách bạn lưu token và dữ liệu local.

* [ ] **Copy `secure_storage_service.dart`:** (Hoặc file tương tự).
* [ ] **Kiểm tra các hàm:** Project mới có cần lưu `refreshToken` và `userData` không? Hay chỉ cần `userToken`? Thêm/bớt các hàm `save...` và `get...` cho phù hợp.
* [ ] **Đảm bảo DI:** Đảm bảo bạn đã đăng ký (`register`) implementation của service này với `get_it`.

---

## 6. 🔌 Định nghĩa API (API Services)

Đây là phần "việc tay chân" nhiều nhất.

* [ ] **XÓA SẠCH** nội dung `api_service.dart` (giữ lại `factory` và `@RestApi`).
* [ ] **XÓA SẠCH** các file Model cũ (ví dụ: `user_model.dart`).
* [ ] **TẠO MỚI** các file Model cho project mới, dùng `@JsonSerializable`.
* [ ] **ĐỊNH NGHĨA LẠI** các endpoints mới trong `api_service.dart` (dùng `@GET`, `@POST`, `@Body`, ...).
    * Đừng quên dùng các "nhãn" (`@userToken`, `@noAuth`) để `AuthInterceptor` hoạt động.
* [ ] **Copy `file_upload_service.dart`:** (Nếu project mới có cần upload-chunk).
    * **Sửa `_uploadUrl` và `_completeUrl`** (trong file service) để khớp với project mới.
    * **Sửa logic `FormData`** nếu backend mới yêu cầu các trường (field) khác.

---

## 7. 🚀 Hoàn tất và Sử dụng

* [ ] **Chạy Build Runner:**
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
* [ ] **Đăng ký DI:** Mở file `injection.dart` (hoặc file DI của bạn) và đăng ký:
    * `DioClient` (singleton)
    * `ApiService` (singleton, phụ thuộc `DioClient`)
    * `FileUploadService` (singleton, phụ thuộc `DioClient`)
    * `SecureStorageService` (singleton)
* [ ] **Kiểm tra Repository:** Khi inject `ApiService` vào `Repository`, đảm bảo bạn sử dụng block `try...catch` chuẩn để "hứng" các `Failure` mà `ErrorInterceptor` đã tạo:

    ```dart
    try {
      final result = await _apiService.someApi(...);
      return Right(result);
    } on DioException catch (e) {
      // Tin tưởng Interceptor, chỉ cần lấy e.error ra
      if (e.error is Failure) {
        return Left(e.error as Failure);
      }
      // Fallback
      return Left(UnknownFailure(e.message ?? 'Lỗi Dio không xác định'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
    ```

---