# Logging module

## Hiện trạng
`AppLogger` (`app_logger.dart`) là structured logging tĩnh, thay cho `print()` rải rác
khắp code. Dùng `dart:developer.log` — cùng cơ chế với `LoggerInterceptor`
(`core/network/logger_interceptor.dart`, log HTTP request/response, không đụng tới
trong lần refactor này).

```dart
AppLogger.debug('...', tag: 'FeatureX');
AppLogger.info('...', tag: 'FeatureX');
AppLogger.warning('...', tag: 'FeatureX');
AppLogger.error('...', tag: 'FeatureX', error: e, stackTrace: st);
```

**Giới hạn hiện tại (chủ ý, vì đây là demo project chưa release):**
- Chỉ log khi `kDebugMode` — build release không log gì cả.
- Không gửi đi đâu cả (không crash reporting, không analytics). Log chỉ thấy được
  khi bạn đang chạy `flutter run`/DevTools trên máy dev.
- Tách biệt với `ErrorEventService`/`ErrorCubit` (`core/error/`) — đó là error bus
  cho **UI** (Snackbar/Dialog hiện cho user), còn `AppLogger` là log cho **dev**.

## Khi nào cần nâng cấp
Khi project chuẩn bị release thật (có user ngoài máy bạn), cần biết app crash ở
đâu mà không phải chờ user tự report → nối `AppLogger` với 1 service crash
reporting. Chỉ cần sửa **một chỗ** — `AppLogger._log()` — không phải sờ lại từng
call site đã dùng `AppLogger.debug/info/warning/error(...)`.

### Option A — Sentry (khuyến nghị nếu muốn setup nhanh, không cần Firebase project)
1. `flutter pub add sentry_flutter`
2. Tạo project trên sentry.io → lấy DSN.
3. Trong `main.dart`, bọc `runApp` bằng `SentryFlutter.init`:
   ```dart
   await SentryFlutter.init(
     (options) => options.dsn = 'YOUR_DSN',
     appRunner: () => runApp(const MyApp()),
   );
   ```
4. Trong `AppLogger._log()`, trước dòng `if (!kDebugMode) return;`, thêm:
   ```dart
   if (level >= 900) {
     // warning/error → breadcrumb + report lên Sentry cả ở release
     Sentry.addBreadcrumb(Breadcrumb(message: message, category: tag));
     if (error != null) {
       unawaited(Sentry.captureException(error, stackTrace: stackTrace));
     }
   }
   ```
5. Nên thêm `Env` mới cho DSN (theo pattern `core/env/env.dart` hiện có, dùng
   `envied`) — đừng hardcode DSN trong code.

### Option B — Firebase Crashlytics (nếu đã/sẽ dùng Firebase cho việc khác)
1. `flutter pub add firebase_core firebase_crashlytics`, chạy `flutterfire configure`
   (cần Firebase project — sinh `firebase_options.dart`, `google-services.json`).
2. Trong `main.dart`:
   ```dart
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
   PlatformDispatcher.instance.onError = (error, stack) {
     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
     return true;
   };
   ```
3. Trong `AppLogger._log()`, tương tự Option A nhưng gọi
   `FirebaseCrashlytics.instance.log(message)` và
   `FirebaseCrashlytics.instance.recordError(error, stackTrace)`.

### Cả 2 option đều cần thêm
- Bắt **uncaught error** ở tầng ngoài cùng (không đi qua `AppLogger` vì đó là lỗi
  chưa được code nào catch): wrap `main()` bằng `runZonedGuarded` (Sentry tự làm
  việc này qua `SentryFlutter.init`; Crashlytics cần set `FlutterError.onError` +
  `PlatformDispatcher.instance.onError` như trên).
- Cân nhắc forward luôn `ErrorEventService`'s fatal events (`core/error/`) sang
  service crash reporting để có thêm context nghiệp vụ (không chỉ crash cấp
  Flutter mà cả `Failure` đã được app tự bắt) — hook vào `ErrorEventService.emit()`
  hoặc `ErrorCubit._onErrorEvent()`.
- Test kỹ: build **release** thử (`flutter run --release` hoặc build apk) để chắc
  log/crash report thật sự gửi đi được ở ngoài debug mode, vì `AppLogger.debug/info`
  vẫn chỉ chạy khi `kDebugMode` — muốn breadcrumb ở release thì phải sửa điều kiện
  đó cho phù hợp (ví dụ tách riêng "chỉ log console khi debug" khỏi "luôn báo lỗi
  cho crash service kể cả release").
