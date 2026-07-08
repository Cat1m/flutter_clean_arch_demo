# AI Core Module

Module tích hợp AI (Gemini) qua **Firebase AI Logic**, dùng cho demo dịch quote
(EN → VI) ở trang chủ. Không lộ API key phía client — Firebase quản lý xác
thực/quota ở backend, thay vì app tự cầm 1 API key như gọi REST trực tiếp.

---

## 1. Kiến trúc

- `translation_service.dart` — interface `TranslationService` (1 method
  `translate({text, targetLanguage})`, trả `Either<Failure, String>`).
- `translation_prompt.dart` — hàm dựng prompt dùng chung, để dễ đổi cách hỏi
  model mà không phải sửa nhiều chỗ.
- `firebase_ai_translation_service.dart` — hiện thực duy nhất, gọi qua
  `firebase_ai` package. `@LazySingleton(as: TranslationService)` nên đây là
  bản được inject bất cứ đâu cần `TranslationService` (vd `QuoteCubit`).

Muốn dùng ở feature khác: inject `TranslationService` qua constructor (DI tự
wire), không cần biết tới `FirebaseAiTranslationService` hay `firebase_ai`.

---

## 2. Setup Firebase (làm 1 lần cho project)

### 2.1. Cài công cụ
```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```
Trên Windows, đảm bảo thư mục pub-cache `bin` (vd `<PUB_CACHE>\bin`) có trong
PATH để lệnh `flutterfire` chạy được.

### 2.2. Tạo Firebase project + bật AI Logic
1. https://console.firebase.google.com → **Add project** (gói Spark miễn phí là đủ).
2. Trong project: **Build → AI Logic → Get started** → chọn backend
   **"Gemini Developer API"** (dùng chung hạn mức free với Google AI Studio).
   **Không chọn "Vertex AI Gemini API"** — backend đó bắt buộc bật billing GCP.
3. Có thể bật thêm **AI monitoring** (optional, miễn phí trong hạn mức) để xem
   latency/token usage/lỗi của các lệnh gọi ngay trong Firebase Console.

### 2.3. Kết nối Flutter project
```bash
flutterfire configure
```
Chọn project vừa tạo, chọn platform cần dùng (tối thiểu `android`). Lệnh này
tự sinh `lib/firebase_options.dart`, `android/app/google-services.json`, và
patch Gradle — **không sửa tay** các file này.

---

## 3. App Check (bắt buộc, không phải tuỳ chọn)

Firebase AI Logic mặc định bật **App Check enforcement** — request không có
token hợp lệ sẽ bị từ chối với lỗi `Firebase App Check token is invalid`. Đây
chính là cơ chế đứng sau lý do "không cần lộ API key" ở trên: chỉ app đã được
xác minh mới gọi được, không phải bất kỳ ai cầm được config Firebase.

Code đã kích hoạt sẵn ở `lib/main.dart`:
```dart
await FirebaseAppCheck.instance.activate(
  providerAndroid: kDebugMode
      ? const AndroidDebugProvider()
      : const AndroidPlayIntegrityProvider(),
  providerApple: kDebugMode
      ? const AppleDebugProvider()
      : const AppleAppAttestProvider(),
);
```

### 3.1. Chạy debug (`flutter run`)
Lần đầu chạy, logcat/console sẽ in ra 1 dòng dạng:
```
D/...DebugAppCheckProvider(...): Enter this debug secret into the allow list
in the Firebase Console for your project: <uuid>
```
Copy đúng `<uuid>` đó → Firebase Console → **App Check → Manage debug tokens**
→ **Add debug token** → dán vào → **Save**. Tên token đặt gì cũng được, chỉ
giá trị (UUID) mới cần khớp. Làm 1 lần cho mỗi máy/thiết bị dev.

### 3.2. Build release
Token debug ở trên **không dùng được cho release** — code tự chuyển sang
`AndroidPlayIntegrityProvider`/`AppleAppAttestProvider`. Để chạy được, cần
thêm ở Firebase Console: **Project Settings → app Android → Add fingerprint**
→ dán **SHA-256** của keystore dùng để ký bản release. Thiếu bước này sẽ gặp
lại đúng lỗi App Check token invalid, nhưng vì lý do khác (thiếu fingerprint).

---

## 4. Model & chi phí

Đang dùng `gemini-3.5-flash` (xem `firebase_ai_translation_service.dart`).
Free tier khoảng 10 request/phút, 500 request/ngày tại thời điểm viết doc này
— đủ cho demo, có thể thay đổi theo chính sách Google. Muốn đổi model chỉ cần
sửa 1 dòng `model:` trong `FirebaseAiTranslationService`.
