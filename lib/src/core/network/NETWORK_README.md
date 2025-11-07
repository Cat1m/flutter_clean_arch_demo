# 📖 Ghi chú về Network Layer (Lớp Mạng)

Thư mục này chứa toàn bộ logic cốt lõi để giao tiếp với API bên ngoài.

## 1. Các thành phần chính

* **`dio_client.dart`**: Khởi tạo và cấu hình instance `Dio` duy nhất cho toàn ứng dụng. Đây là nơi để set `baseUrl` (từ file `Env`), `connectTimeout`, và quan trọng nhất là thêm các `Interceptors` (như Log, chèn API Key, chèn Access Token...).
* **`api_service.dart`**: Interface của **Retrofit**. Nơi định nghĩa TẤT CẢ các endpoints của ứng dụng (ví dụ: `@POST('/login')`).
* **`base_response.dart`**: Một file khuôn mẫu (template) cực kỳ quan trọng cho các dự án thực tế.

---

## 2. ⚠️ QUAN TRỌNG: Khái niệm "Vỏ Thư" (`BaseResponse`)

Hầu hết các dự án backend chuyên nghiệp KHÔNG trả về dữ liệu thô. Thay vào đó, họ trả về một cấu trúc "vỏ thư" (Response Envelope) chung.

File `base_response.dart` trong thư mục này là một **KHUÔN MẪU** cho cấu trúc đó.

### Vấn đề: Mỗi dự án mỗi khác!

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

###  Checklist cho Dự án MỚI:

Khi bắt đầu một dự án mới, hãy làm theo các bước sau:

1.  **Hỏi Backend (hoặc xem Postman):** Cấu trúc "vỏ thư" chung của họ là gì?
2.  **Sửa `base_response.dart`:**
    * Đổi tên các trường `status`, `message`, `data` cho khớp với API thật.
    * Đổi kiểu dữ liệu nếu cần (ví dụ `status` có thể là `String "OK"` thay vì `int 1`).
    * Cập nhật lại `factory BaseResponse.fromJson` để parse đúng các key đó.
    * Cập nhật `getter isSuccess` cho đúng (ví dụ: `status == "OK"`).
3.  **Sửa `api_service.dart` (Retrofit):** Đảm bảo các hàm của bạn trả về `Future<BaseResponse<YourModel>>`.
4.  **Sửa `Repository` (Quan trọng nhất):**
    * Luôn xử lý lỗi theo 2 tầng:
    * **Tầng 1 (Kỹ thuật):** Dùng `try...on DioException catch (e)` để bắt lỗi HTTP (404, 500, mất mạng).
    * **Tầng 2 (Nghiệp vụ):** Kiểm tra `if (baseResponse.isSuccess)` để bắt lỗi logic (sai mật khẩu, tài khoản bị khóa...).

---

## 3. 💡 Lưu ý cho dự án này (`reqres.in`)

API `reqres.in` được dùng trong dự án học tập này **KHÔNG SỬ DỤNG** `BaseResponse`.

* Nó trả về dữ liệu thô (raw data) trực tiếp.
* Ví dụ: `POST /login` trả về thẳng `{ "token": "..." }`.
* Vì vậy, trong `AuthRepositoryImpl` của dự án này, chúng ta đã **đơn giản hóa** logic, chỉ cần `try-catch DioException` là đủ.
* File `base_response.dart` và ghi chú này chỉ mang tính chất tham khảo cho tương lai.