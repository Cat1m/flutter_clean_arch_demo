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

Sau khi thêm fingerprint, còn cần vào **App Check → Apps → Register** app
Android, chọn provider **Play Integrity** (bước riêng, không tự động dù đã
thêm fingerprint ở Project Settings).

### 3.3. Giới hạn đã gặp: sideload không đủ để test Play Integrity thật

Đã làm đúng cả 2 bước ở 3.2 (fingerprint đúng + Register Play Integrity), build
release, cài qua `adb install` — Play Integrity **vẫn sinh token thành công ở
phía máy** (log native `IntegrityService: requestIntegrityToken` không lỗi),
nhưng Firebase App Check backend từ chối với:

```
[firebase_app_check/unknown] Error returned from API. code: 403 body: App attestation failed.
```

Nguyên nhân: Play Integrity cần Google Play "nhận diện" app để verdict hợp lệ.
App cài qua `adb install`/sideload thuần (không qua Play) thường bị đánh giá
"app không được nhận diện" → App Check reject dù token sinh ra không lỗi cú
pháp. Sau vài lần 403 liên tiếp, App Check SDK tự backoff (log thấy
"Too many attempts"), không gọi lại API cho tới khi hết thời gian chờ — không
phải app bị lỗi thêm, chỉ là cơ chế chống rate-limit của SDK.

**Kế hoạch để test Play Integrity thật (làm sau khi có Play Console account):**
1. Đăng ký Google Play Console developer account (phí $25 một lần).
2. Tạo app entry cho `com.example.reqres_in` trên Play Console (chưa cần
   public, có thể để ở trạng thái draft).
3. Dùng 1 trong 2 cách để cài app qua kênh Play (thoả điều kiện Play Integrity
   nhận diện được):
   - **Internal testing track**: upload AAB (`flutter build appbundle
     --release`), thêm tester bằng email, cài qua link Play Store dành cho
     tester.
   - **Internal app sharing**: nhanh hơn, không cần review, upload APK/AAB lấy
     link cài trực tiếp — vẫn đi qua hạ tầng Play nên Play Integrity nhận diện
     được.
4. Cài lại app qua 1 trong 2 link trên (gỡ bản sideload cũ trước để tránh lỗi
   signature mismatch), test lại tính năng dịch quote.
5. Nếu vẫn lỗi, kiểm tra thêm: project Firebase và Play Console phải cùng
   liên kết (Play Console → Setup → App integrity → xác nhận Cloud project
   number khớp với Firebase project).

Code hiện tại (`firebase_ai_translation_service.dart`) đang có tạm 1 dòng
`debugPrint` trong `catch (e)` để lộ lỗi thật ra logcat khi debug — nên xoá đi
khi vấn đề trên đã được xác nhận fix xong, tránh log rò rỉ chi tiết lỗi backend
trong bản release chính thức.

---

## 4. Model & chi phí

Đang dùng `gemini-3.5-flash` (xem `firebase_ai_translation_service.dart`).
Free tier khoảng 10 request/phút, 500 request/ngày tại thời điểm viết doc này
— đủ cho demo, có thể thay đổi theo chính sách Google. Muốn đổi model chỉ cần
sửa 1 dòng `model:` trong `FirebaseAiTranslationService`.
