# ADR: Core Error Bus Module

**Ngày**: 2026-03-19
**Trạng thái**: Đã phê duyệt
**Luồng**: LUỒNG B — Đánh giá ý tưởng người dùng

---

## 1. Bối Cảnh (Context)

Hiện tại app xử lý error theo 3 kênh riêng biệt:
- **Per-cubit error handling**: Mỗi cubit tự `fold()` Either → emit error state riêng (`AuthFailure`, `QuoteError`, `UserFailure`)
- **AuthEventService**: Singleton stream broadcast cho session expiry → `LoginCubit` listen → GoRouter redirect
- **NetworkSnackbarListener**: StatefulWidget listen `NetworkService.isOnlineStream` → show snackbar

**Vấn đề**:
- Không có nơi tập trung để handle **cross-cutting errors** (server 500, mất mạng, session expired)
- 3 kênh error khác nhau → fragmented, khó debug, khó mở rộng
- Không có error history để debug bên cạnh Firebase Crashlytics
- Khi 5 cubit cùng fail (ví dụ offline), user bị flood 5 error cùng lúc

**Mục tiêu**: Tạo module `core/error/` hoạt động như Error Event Bus toàn app, thống nhất error handling.

## 2. Yêu Cầu Đã Làm Rõ

- **Phạm vi Lần 1** (session này): Tạo `core/error/` module hoàn chỉnh, chạy song song với code cũ. KHÔNG refactor `AuthEventService`, `NetworkSnackbarListener` trong lần này.
- **Phạm vi Lần 2** (session riêng): Refactor xóa `AuthEventService` + `NetworkSnackbarListener`, update `LoginCubit`, `TokenInterceptor`, `ErrorInterceptor`, `main.dart`.
- **Người tiêu thụ**:
  - **Auto**: `ErrorInterceptor` emit trực tiếp cho cross-cutting errors (ConnectionFailure, AuthFailure, ServerFailure 500/503)
  - **Opt-in**: Bất kỳ cubit/repository nào muốn delegate error lên Bus
- **Ranh giới error**:
  - **Global (Bus handle)**: Cross-cutting errors không thuộc feature nào — mất mạng, session expired, server 500/503, maintenance
  - **Local (cubit tự handle)**: Business logic errors — sai password, user not found, validation fail
  - **Opt-in**: Developer tự quyết định emit lên Bus từ cubit/repo cho các case đặc biệt
- **UI reaction**: ErrorCubit chỉ broadcast event (kèm severity). Một global `BlocListener<ErrorCubit>` trong `MaterialApp.builder` tự map severity → UI action (snackbar/dialog/redirect)
- **Dedup**: Cùng loại Failure (by `runtimeType`) trong time window N giây → chỉ emit 1 lần
- **Edge cases**:
  - 5 cubit cùng fail khi offline → dedup chỉ show 1 ConnectionFailure
  - Error event đến khi app ở background → ErrorCubit giữ state, UI show khi resume
  - AuthFailure từ Interceptor + ErrorBus đồng thời → Lần 1 chạy song song, Lần 2 migrate
- **Mục tiêu mở rộng tương lai**: Error history (log lại các error đã xảy ra) để debug bổ sung cho Firebase Crashlytics
- **Team context**: 3 thành viên, không thể ép convention "tất cả error qua Bus" → hybrid auto + opt-in

## 3. Ý Tưởng Ban Đầu của Người Dùng

Tạo `core/error/` module kết hợp Stream-based event bus + Cubit:
1. `ErrorEventService` (singleton stream broadcast) — bất kỳ layer nào emit `ErrorEvent`
2. `ErrorCubit` (global singleton) — listen stream, manage state, dedup/throttle
3. UI react toàn cục qua `BlocListener`
4. Tích hợp Failure hierarchy có sẵn + severity levels
5. Thay thế hoàn toàn `AuthEventService` + `NetworkSnackbarListener` (trong Lần 2)

**Đánh giá Phase 1.5**: Phù hợp có điều kiện → sau khi làm rõ ranh giới local/global error và scope triển khai 2 giai đoạn → **Phù hợp hoàn toàn**.

## 4. Các Giải Pháp Đã Loại Bỏ

### Giải pháp B: Stream-only, không dùng Cubit
- `ErrorEventService` (stream + dedup/throttle built-in) → `ErrorListener` StatefulWidget (listen stream trực tiếp)
- **Lý do loại bỏ**:
  - Service phình to (vừa bus, vừa state manager, vừa throttle) → vi phạm Single Responsibility
  - Không hiện trong Bloc DevTools → khó debug cho team 3 người
  - Khó mở rộng thêm error history, retry actions
  - Team đã invested vào Bloc ecosystem, StatefulWidget listener đi ngược convention

## 5. Giải Pháp Được Chọn

### Tổng quan kiến trúc

```
┌─────────────────────────────────────────────────────────────────┐
│                        ERROR BUS FLOW                          │
│                                                                 │
│  ┌──────────────────┐     ┌──────────────────┐                 │
│  │ ErrorInterceptor │     │ Cubit/Repo       │                 │
│  │ (auto-emit       │     │ (opt-in emit)    │                 │
│  │  cross-cutting)  │     │                  │                 │
│  └────────┬─────────┘     └────────┬─────────┘                 │
│           │                        │                            │
│           ▼                        ▼                            │
│  ┌─────────────────────────────────────────────┐               │
│  │         ErrorEventService                    │               │
│  │  (Singleton, StreamController.broadcast)     │               │
│  │  - emit(ErrorEvent)                          │               │
│  │  - Stream<ErrorEvent> errorStream            │               │
│  └──────────────────┬──────────────────────────┘               │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────────────┐               │
│  │         ErrorCubit                           │               │
│  │  (Singleton, listen errorStream)             │               │
│  │  - Dedup by runtimeType + time window        │               │
│  │  - Emit ErrorState (kèm severity)            │               │
│  │  - dismiss() để clear error                  │               │
│  └──────────────────┬──────────────────────────┘               │
│                     │                                           │
│                     ▼                                           │
│  ┌─────────────────────────────────────────────┐               │
│  │   GlobalErrorListener Widget                 │               │
│  │  (BlocListener<ErrorCubit> trong             │               │
│  │   MaterialApp.builder)                       │               │
│  │                                              │               │
│  │  switch (severity):                          │               │
│  │    info/warning → Snackbar                   │               │
│  │    critical     → Dialog                     │               │
│  │    fatal        → Redirect (login/error page)│               │
│  └──────────────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────────┘
```

### Luồng xử lý chi tiết

**Flow 1 — Auto-capture (cross-cutting errors):**
1. API call fail → Dio trigger `ErrorInterceptor.onError()`
2. `ErrorInterceptor` convert DioException → Failure (logic hiện tại giữ nguyên)
3. `ErrorInterceptor` kiểm tra Failure type:
   - `ConnectionFailure` → emit `ErrorEvent(failure, severity: warning)`
   - `AuthFailure` (401/403) → emit `ErrorEvent(failure, severity: fatal)`
   - `ServerFailure` (500/502/503) → emit `ErrorEvent(failure, severity: critical)`
   - Các Failure khác → KHÔNG auto-emit (để cubit/repo tự quyết)
4. `ErrorInterceptor` vẫn reject DioException như bình thường (flow cũ không thay đổi)
5. `ErrorEventService` nhận event → push vào broadcast stream
6. `ErrorCubit` nhận event từ stream → kiểm tra dedup → emit `ErrorState`
7. `GlobalErrorListener` nhận state → show UI tương ứng

**Flow 2 — Opt-in (developer tự emit):**
1. Cubit/Repository gặp lỗi đặc biệt muốn show global
2. Gọi `getIt<ErrorEventService>().emit(ErrorEvent(failure, severity: ...))`
3. Từ bước 5 trở đi giống Flow 1

**Flow 3 — Dedup:**
1. `ErrorCubit` giữ `Map<Type, DateTime>` — key là `failure.runtimeType`, value là timestamp emit gần nhất
2. Khi nhận ErrorEvent mới → check: nếu cùng `runtimeType` và `DateTime.now() - lastEmit < dedupWindow` → bỏ qua
3. `dedupWindow` mặc định 3 giây (configurable qua constructor)

### Định nghĩa các class

**ErrorSeverity** (enum):
```
enum ErrorSeverity { info, warning, critical, fatal }
```
- `info`: Log only, có thể show snackbar nhẹ (ví dụ: cache miss, dùng data cũ)
- `warning`: Snackbar thông thường (ví dụ: mất mạng tạm thời)
- `critical`: Dialog bắt buộc acknowledge (ví dụ: server 500)
- `fatal`: Redirect/force action (ví dụ: session expired → redirect login)

**ErrorEvent** (immutable, Equatable):
```
class ErrorEvent extends Equatable {
  final Failure failure;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final String? source;  // Optional: "ErrorInterceptor", "UserCubit", etc. Hữu ích cho debug/history
}
```

**ErrorState** (sealed class, Equatable):
```
sealed class ErrorState extends Equatable
├── ErrorIdle                          // Không có error (initial + sau dismiss)
└── ErrorReceived(ErrorEvent event)    // Có error mới cần UI xử lý
```

**ErrorEventService** (singleton, `@lazySingleton`):
- `StreamController<ErrorEvent>.broadcast()`
- `void emit(ErrorEvent event)` — push event vào stream
- `Stream<ErrorEvent> get errorStream` — public stream cho ErrorCubit listen
- `void dispose()` — close controller

**ErrorCubit** (singleton, `@lazySingleton`):
- Listen `ErrorEventService.errorStream`
- Giữ `_dedupMap: Map<Type, DateTime>` cho dedup logic
- `dedupWindow: Duration` (default 3 giây)
- `void dismiss()` → emit `ErrorIdle` (UI gọi sau khi show xong)
- `@override close()` → cancel subscription

**GlobalErrorListener** (StatelessWidget):
- Wrap child trong `BlocListener<ErrorCubit, ErrorState>`
- Khi `state is ErrorReceived` → switch severity:
  - `info` / `warning` → `ScaffoldMessenger.showSnackBar()`
  - `critical` → `showDialog()`
  - `fatal` → Tuỳ loại Failure: AuthFailure → redirect login, khác → error page
- Sau khi show → gọi `errorCubit.dismiss()`

### Các Tệp Dự Kiến Thay Đổi / Tạo Mới

#### Lần 1 — Tạo module mới (session này)

| Tệp | Loại | Mô tả |
|-----|------|-------|
| `lib/src/core/error/error_severity.dart` | Tạo mới | Enum `ErrorSeverity` (info, warning, critical, fatal) |
| `lib/src/core/error/error_event.dart` | Tạo mới | Class `ErrorEvent` (Equatable, immutable) — wrap Failure + severity + timestamp + source |
| `lib/src/core/error/error_event_service.dart` | Tạo mới | Singleton stream broadcast bus (`@lazySingleton`) |
| `lib/src/core/error/error_state.dart` | Tạo mới | Sealed class `ErrorState` (ErrorIdle, ErrorReceived) |
| `lib/src/core/error/error_cubit.dart` | Tạo mới | Singleton cubit (`@lazySingleton`), listen stream, dedup/throttle |
| `lib/src/core/error/global_error_listener.dart` | Tạo mới | Widget wrap `BlocListener<ErrorCubit>`, map severity → UI action |
| `lib/src/core/error/error.dart` | Tạo mới | Barrel export file |
| `lib/src/core/network/error_interceptor.dart` | Sửa đổi | Thêm `ErrorEventService` dependency, auto-emit cross-cutting errors |
| `lib/main.dart` | Sửa đổi | Thêm `GlobalErrorListener` vào `MaterialApp.builder` |

#### Lần 2 — Refactor migration (session riêng)

| Tệp | Loại | Mô tả |
|-----|------|-------|
| `lib/src/core/auth/service/auth_event_service.dart` | Xóa | Thay thế bởi ErrorEventService (fatal severity + AuthFailure) |
| `lib/src/core/widgets/network_snackbar_listener.dart` | Xóa | Thay thế bởi GlobalErrorListener (warning severity + ConnectionFailure) |
| `lib/src/core/widgets/session_expired_dialog.dart` | Xóa | Logic chuyển vào GlobalErrorListener |
| `lib/src/features/auth/presentation/bloc/login_cubit.dart` | Sửa đổi | Xóa `_authEventSubscription`, listen ErrorCubit thay vì AuthEventService |
| `lib/src/core/auth/interceptors/token_interceptor.dart` | Sửa đổi | Dùng ErrorEventService thay AuthEventService để notify session expired |
| `lib/src/core/network/error_interceptor.dart` | Sửa đổi | Xóa logic cũ nếu còn duplicate |
| `lib/main.dart` | Sửa đổi | Xóa `NetworkSnackbarListener` wrapper |

### Dependency mới

Không cần thêm package mới. Tất cả đều dùng:
- `flutter_bloc` (đã có)
- `equatable` (đã có)
- `injectable` / `get_it` (đã có)

## 6. Chiến Lược Kiểm Thử

### Unit test
- **ErrorEventService**: emit event → stream nhận đúng event, multiple listeners nhận cùng event, dispose close stream
- **ErrorCubit**:
  - Nhận event → emit `ErrorReceived`
  - Dedup: 2 `ConnectionFailure` trong 3s → chỉ emit 1 lần
  - Dedup: 2 loại Failure khác nhau trong 3s → emit cả 2
  - Dedup: cùng type nhưng sau time window → emit lại
  - `dismiss()` → emit `ErrorIdle`
- **ErrorInterceptor** (updated): DioException → Failure + emit ErrorEvent cho cross-cutting types

### Widget test
- **GlobalErrorListener**:
  - `ErrorReceived(warning)` → verify snackbar hiển thị
  - `ErrorReceived(critical)` → verify dialog hiển thị
  - `ErrorReceived(fatal + AuthFailure)` → verify redirect behavior
  - `ErrorIdle` → không show gì

### Integration test
- Full flow: Mock API fail 500 → ErrorInterceptor emit → ErrorCubit state change → snackbar hiển thị
- Dedup flow: 3 API call fail cùng lúc → chỉ 1 snackbar

## 7. Rủi Ro Còn Lại và Kế Hoạch Giảm Thiểu

| Rủi ro | Mức độ | Giảm thiểu |
|--------|--------|------------|
| **Dual error path Lần 1**: ErrorInterceptor emit lên cả Bus mới VÀ DioException vẫn đi qua flow cũ (AuthEventService, NetworkSnackbarListener) → user thấy error 2 lần | Trung bình | Lần 1: ErrorInterceptor chỉ emit cho các error type mà code cũ KHÔNG handle (ServerFailure 500/503). ConnectionFailure và AuthFailure chờ Lần 2 migrate. Hoặc: thêm flag để disable emit cho types đã có handler cũ |
| **ErrorCubit singleton lifetime**: Nếu dispose sai → memory leak hoặc listen dead stream | Thấp | ErrorCubit là `@lazySingleton`, sống suốt app. Chỉ dispose khi app terminate. Không cần manual dispose |
| **Dedup time window quá ngắn/dài**: 3s có thể miss error khác hoặc vẫn duplicate | Thấp | Configurable qua constructor, dễ tune. Bắt đầu với 3s, điều chỉnh qua real-world testing |
| **Team adoption**: 2 thành viên khác có thể không biết khi nào nên opt-in emit | Thấp | Document convention rõ trong code comments + ADR này. Auto-capture đã cover 90% cross-cutting errors |
| **Race condition**: ErrorEvent emit trước ErrorCubit subscription ready | Thấp | ErrorCubit init trong `configureDependencies()` (trước `runApp`), stream là broadcast nên late listener miss event cũ — nhưng error trước app start không cần show UI |
