# 🏗️ Flutter Pre-Build Checklist

> **Cách dùng:** Chạy qua Tier 0 → 1 → 2 trước/trong khi bắt đầu mỗi project.
> **Tier 3 KHÔNG tick sẵn** — chỉ thêm khi bạn thật sự cảm thấy đau mà không có nó.
> Nguyên tắc: `Strongly recommend` làm ngay, `Conditional` để dành.
>
> **Chú thích nguồn:** 📘 = từ doc chính chủ Flutter · ⭐ = bổ sung ngoài doc (cross-cutting, app thật cần)

---

## 🔴 TIER 0 — Quyết TRƯỚC dòng code đầu tiên
*Sai ở đây = refactor toàn bộ project. Dừng lại và quyết cho xong.*

- [ ] ⭐ **Folder structure**: chọn **feature-first** (`features/auth/`, `features/cart/`…) hay **layer-first** (`ui/`, `data/` toàn app)? → App vừa/lớn hoặc nhiều người: **feature-first**.
- [ ] 📘 **State management**: chọn **DUY NHẤT 1** và đào sâu (Riverpod / Bloc / ChangeNotifier). Đừng trộn.
- [ ] ⭐ **Flavors / environments**: dev / staging / prod — entry point riêng + `--dart-define`.
- [ ] ⭐ **Secrets & API keys**: cơ chế nạp key (env/dart-define). **KHÔNG hardcode, KHÔNG commit key.**
- [ ] ⭐ **Error handling strategy**: dùng `Result`/`Either` hay `throw`? Lỗi được "dịch" ở layer nào (network → domain → message hiển thị)?
- [ ] 📘 **Unidirectional data flow**: chốt luật — data chỉ chảy từ data layer → UI; sự kiện UI đi ngược về data layer.

---

## 🟠 TIER 1 — Dựng khung tuần đầu (scaffolding)
*Cắm vào từ đầu dễ hơn nhồi vào sau 6 tháng.*

- [ ] 📘 **Repository pattern**: tạo **abstract repository classes** (đổi impl cho dev/staging/prod).
- [ ] 📘 **Dependency injection**: setup DI (`provider` theo doc, hoặc `get_it` + `injectable`). Tránh global object.
- [ ] 📘 **Navigation**: `go_router` (deep link + auth redirect).
- [ ] ⭐ **Design system / theming**: theme tập trung + design tokens **trước khi** style rải khắp widget.
- [ ] ⭐ **Logging & observability**: crash reporting (Sentry/Crashlytics) + analytics + structured logging.
- [ ] 📘 **Testing setup**: cấu hình test + `flutter_lints`. Chuẩn bị `mocktail`/fakes.
- [ ] 📘 **Naming conventions**: `HomeViewModel`, `HomeScreen`, `UserRepository`… Shared widgets để trong `ui/core/`, **không** đặt tên trùng SDK.
- [ ] ⭐ **i18n & a11y** *(nếu có khả năng cần)*: setup localization + semantics từ đầu — retrofit rất khổ.

---

## 🟡 TIER 2 — Thói quen khi build TỪNG feature
*Không phải làm 1 lần — là cách bạn code mỗi ngày.*

- [ ] 📘 **Tách UI layer / data layer** rõ ràng; trong mỗi layer tách class theo trách nhiệm.
- [ ] 📘 **MVVM**: mỗi màn hình có ViewModel + View. Widget "dumb".
- [ ] 📘 **Không để logic trong widget** (chỉ cho phép: if ẩn/hiện đơn giản, animation, layout theo screen size, routing đơn giản).
- [ ] 📘 **Immutable data models** — dùng `freezed`/`built_value` (JSON ser/des, deep equality, copyWith).
- [ ] 📘 **Commands** để chuẩn hóa event từ UI → data layer, tránh render error.
- [ ] ⭐ **Handle đủ trạng thái**: loading / error / empty / retry — **không chỉ happy path**.
- [ ] 📘 **Test ngay khi build feature**: ≥1 test/feature. Unit cho service/repo/ViewModel; widget test cho view (test cả routing + DI). Viết code để tận dụng fakes.

---

## 🟢 TIER 3 — Chỉ thêm KHI thấy đau (đừng làm sẵn)
*Đây là các mục `Conditional`. Thêm vội = over-engineering.*

- [ ] 📘 **Domain layer / use-cases** — chỉ khi logic phình to làm ViewModel quá tải, hoặc lặp logic nhiều nơi.
- [ ] 📘 **Tách API model vs domain model** — chỉ ở app lớn (thêm verbosity, đổi lại giảm phức tạp ViewModel).
- [ ] ⭐ **Offline / caching / sync strategy** — chỉ khi app cần chạy offline (cache-first vs network-first).

### 🚀 Trước khi release lên store (cửa riêng, đừng quên)
- [ ] ⭐ **Secure storage** cho token/nhạy cảm (không dùng SharedPreferences thường).
- [ ] ⭐ **Code obfuscation** (`--obfuscate --split-debug-info`).
- [ ] ⭐ **Certificate pinning** *(nếu app xử lý dữ liệu nhạy cảm)*.
- [ ] ⭐ **CI/CD**: build + test tự động (Codemagic / GitHub Actions), signing/provisioning.

---

## 📚 Tài nguyên tham khảo (từ doc chính chủ)
- **Compass app** — source code app mẫu áp dụng các recommendation này.
- **very_good_cli** — template scaffold theo cấu trúc chuẩn (Very Good Ventures).
- **Very Good Engineering** — docs architecture, demo, project mã nguồn mở.
- **Flutter DevTools** — bộ công cụ performance & debug.
- **flutter_lints** — lint chuẩn của team Flutter.

---
> 💡 **Nhắc cuối:** Architecture tốt *mọc lên từ nhu cầu thật*, không phải copy trọn checklist.
> Nếu Tier 3 vẫn trống sau vài project nhỏ — đó là dấu hiệu tốt, không phải thiếu sót.