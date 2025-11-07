
-----

# Nguyên tắc DI với `injectable`

Đây là bản tóm tắt nhanh các quy tắc sử dụng `@injectable`, `@lazySingleton`, và `@module` trong `injectable` để quản lý Dependency Injection (DI) hiệu quả.

## 1\. `@injectable`: Dùng cho BLoC/Cubit

Quy tắc chính là **"Tạo mới mỗi lần gọi"** (Factory).

  * **Sử dụng cho:** Các class thuộc lớp Presentation (BLoC, Cubit, ViewModel...).
  * **Tại sao:** Vì các class này chứa **State**. Chúng ta cần một state "sạch" (fresh instance) mỗi khi một màn hình mới được mở.
  * **Cách dùng:** Đặt ngay trên class.

<!-- end list -->

```dart
@injectable
class LoginCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  
  LoginCubit(this._repository) : super(AuthInitial());
  // ...
}
```

## 2\. `@lazySingleton`: Dùng cho Repository, Service, Client

Quy tắc chính là **"Dùng chung một instance cho toàn app"** (Singleton).

  * **Sử dụng cho:** Các class thuộc lớp Data hoặc Core (Repository, ApiService, DioClient, SharedPreferences...).
  * **Tại sao:** Các class này **không chứa state** mà chỉ cung cấp dịch vụ (như gọi API, truy cập database). Chỉ cần tạo 1 lần và tái sử dụng ở mọi nơi để tiết kiệm bộ nhớ.
  * **Cách dùng:** Đặt ngay trên class implementation.
  * **Mẹo:** Luôn dùng `as:` để đăng ký với kiểu Abstract (Interface).

<!-- end list -->

```dart
@lazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  
  AuthRepositoryImpl(this._apiService);
  // ...
}
```

## 3\. `@module`: Dùng cho Thư viện bên thứ 3

Quy tắc chính là **"Đăng ký hộ những class không phải của mình"**.

  * **Sử dụng cho:** Các class bạn không thể sửa code để thêm annotation vào được (ví dụ: `Dio`, `SharedPreferences`, hoặc class từ thư viện khác) hoặc các class được sinh ra (như `ApiService` của Retrofit).
  * **Tại sao:** Để báo cho `injectable` biết cách khởi tạo chúng.
  * **Cách dùng:**
    1.  Tạo một `abstract class` và đánh dấu nó là `@module`.
    2.  Bên trong, tạo các *getter* hoặc *method* trả về instance bạn muốn đăng ký.
    3.  Sử dụng `@lazySingleton` hoặc `@injectable` trên các *getter/method* đó.

<!-- end list -->

```dart
@module
abstract class RegisterModule {
  // Đăng ký Dio (thư viện ngoài)
  @lazySingleton
  Dio get dio => DioClient().dio;

  // Đăng ký ApiService (code-gen của Retrofit)
  @lazySingleton
  ApiService getApiService(Dio dio) => ApiService(dio);
}
```