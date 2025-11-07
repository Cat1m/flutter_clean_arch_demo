Chắc chắn rồi ạ\! Đây là một ghi chú rất quan trọng cần thêm vào `README` để đảm bảo tính linh hoạt của network layer.

Tôi sẽ thêm một **Mục 2** mới vào `NETWORK_README.md` để giải thích về việc này và đẩy các mục khác xuống.

-----

### updated/NETWORK\_README.md

Đây là nội dung file `README` được cập nhật, với **Mục 2** mới được thêm vào.

````markdown
# 📖 Ghi chú về Network Layer (Lớp Mạng)

Thư mục này chứa toàn bộ logic cốt lõi để giao tiếp với API bên ngoài.

## 1. Các thành phần chính

* **`dio_client.dart`**: Khởi tạo và cấu hình instance `Dio` duy nhất. Đây là nơi set `baseUrl`, `timeout`, và thêm các `Interceptors`.
* **`api_service.dart`**: Interface của **Retrofit**. Nơi định nghĩa TẤT CẢ các endpoints.
* **`base_response.dart`**: Khuôn mẫu (template) cho các API trả về "vỏ thư" (envelope).
* **`error_interceptor.dart`**: (Tùy chọn) Interceptor để tự động bắt `DioException` và chuyển đổi chúng thành các `Failure` (như `ConnectionFailure`, `ServerFailure`).
* **`token_interceptor.dart`**: (Tùy chọn) Interceptor để tự động làm mới (refresh) `AccessToken` khi hết hạn.

---

## 2. ⚙️ Xử lý Content-Type (JSON, Upload File...)

Trong `dio_client.dart`, chúng ta thường set `contentType: 'application/json'` làm **giá trị mặc định** cho toàn bộ ứng dụng.

Tuy nhiên, sẽ có lúc bạn cần ghi đè (override) giá trị này cho các API đặc biệt. `Retrofit` cho phép bạn làm điều này rất dễ dàng ngay tại file `api_service.dart`.

### Trường hợp 1: Upload File (Phổ biến nhất)

Khi upload file, bạn phải dùng `Content-Type: multipart/form-data`. `Retrofit` sẽ tự động làm việc này khi bạn dùng `@MultiPart` và `@Part`.

```dart
// trong api_service.dart
@POST('/users/upload-avatar')
@userAuth // (Giả sử API này cần token user)
@MultiPart // <-- Tự động đổi Content-Type thành 'multipart/form-data'
Future<void> uploadAvatar(
  @Part(name: 'avatar') File avatarFile, // <-- File
  @Part(name: 'user_id') String userId, // <-- Dữ liệu đi kèm
);
````

### Trường hợp 2: Gửi Form (Ít phổ biến hơn)

Nếu backend yêu cầu `Content-Type: application/x-www-form-urlencoded` (giống form web cũ), bạn có thể dùng `@Headers`.

```dart
// trong api_service.dart
@POST('/submit-legacy-form')
@userAuth
@Headers({ // <-- Ghi đè header tại đây
  'Content-Type': 'application/x-www-form-urlencoded',
})
Future<void> submitLegacyForm(
  @Body() Map<String, String> formBody,
);
```

**Kết luận:** `BaseOptions` trong `DioClient` là "luật chung" (default), còn các annotation `@` trong `ApiService` là "luật riêng" (override), có độ ưu tiên cao hơn.

-----

## 3\. ⚠️ QUAN TRỌNG: Khái niệm "Vỏ Thư" (`BaseResponse`)

Hầu hết các dự án backend chuyên nghiệp KHÔNG trả về dữ liệu thô. Thay vào đó, họ trả về một cấu trúc "vỏ thư" (Response Envelope) chung.

File `base_response.dart` là một **KHUÔN MẪU** cho cấu trúc đó.

### Vấn đề: Mỗi dự án mỗi khác\!

Cấu trúc "vỏ thư" **HOÀN TOÀN TÙY THUỘC VÀO DỰ ÁN**.

  * **Dự án A (giống template):**
    ```json
    {
      "status": 1,
      "message": "Đăng nhập thành công",
      "data": { "token": "..." }
    }
    ```
  * **Dự án B (khác):**
    ```json
    {
      "success": true,
      "error_code": null,
      "result": { "token": "..." }
    }
    ```

### Checklist cho Dự án MỚI:

1.  **Hỏi Backend:** Cấu trúc "vỏ thư" chung là gì?
2.  **Sửa `base_response.dart`:** Đổi tên trường, kiểu dữ liệu, và logic `isSuccess` cho khớp.
3.  **Sửa `api_service.dart`:** Đảm bảo các hàm trả về `Future<BaseResponse<YourModel>>`.
4.  **Sửa `Repository`:** Xử lý lỗi 2 tầng: `try...on DioException` (hoặc dùng `ErrorInterceptor`) VÀ `if (baseResponse.isSuccess)`.

-----

## 4\. (Nâng cao) TùY CHỌN: Xử lý Refresh Token tự động

Đây là một "Security Pattern" (mẫu bảo mật).

### Vấn đề:

  * Khi đăng nhập, backend chuyên nghiệp sẽ trả về 2 token:
    1.  `AccessToken` (Vé xem phim): Hạn ngắn (ví dụ: 15 phút).
    2.  `RefreshToken` (Thẻ thành viên): Hạn dài (ví dụ: 30 ngày).
  * Khi `AccessToken` hết hạn, API sẽ trả về **lỗi 401 Unauthorized**.

### Giải pháp: "Người Trợ Lý Thông Minh" (`TokenInterceptor`)

Chúng ta tạo một `QueuedInterceptor` để:

1.  Bắt lỗi 401.
2.  **"Khóa" (Lock)** Dio lại (tạm dừng các request khác).
3.  Tự mình gọi API `/refresh-token` (dùng `RefreshToken`).
4.  **Nếu thành công:** Lấy `AccessToken` mới, lưu lại, và "Mở khóa" (Unlock) Dio.
5.  **"Thử lại" (Retry)** request vừa thất bại.
6.  **Nếu thất bại** (ví dụ: `RefreshToken` cũng hết hạn): Đăng xuất người dùng.

### Checklist để áp dụng:

1.  **Hỏi Backend:** API có cơ chế Refresh Token không?
2.  **Nếu có:**
      * Lấy file `token_interceptor.dart` (code mẫu).
      * Thêm `TokenInterceptor` vào `dio_client.dart` (sau `AuthInterceptor`, trước `ErrorInterceptor`).

-----

## 5\. 💡 Lưu ý cho dự án này (`reqres.in`)

API `reqres.in` được dùng trong dự án học tập này **KHÔNG SỬ DỤNG** cả `BaseResponse` lẫn `Refresh Token`.

  * Nó trả về dữ liệu thô (raw data).
  * Nó chỉ trả về 1 `token` duy nhất.
  * Vì vậy, các file `base_response.dart`, `error_interceptor.dart`, `token_interceptor.dart` và ghi chú này chỉ mang tính chất tham khảo cho các dự án thực tế trong tương lai.

<!-- end list -->

```
```