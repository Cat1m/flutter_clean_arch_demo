# Rust Integration

Module Rust (bridge qua `flutter_rust_bridge`) dùng để demo 3 use-case thực tế của
Rust trong 1 app Flutter: **bảo mật** (mã hoá, derive key) và **hiệu năng**
(benchmark). Đây là project demo/học tập nên phạm vi tích hợp có chủ đích giữ nhỏ,
không cố phủ hết mọi tính năng.

## Cấu trúc thư mục

```
rust/src/
  api/              # Lớp bridge MỎNG expose ra Dart — không chứa logic
    crypto.rs         # generate_key / encrypt / decrypt (AES-256-GCM)
    kdf.rs             # generate_salt / derive_key (Argon2id)
    benchmark.rs        # run_fibonacci_benchmark
    simple.rs            # hàm mẫu (greet) từ khi scaffold, giữ lại làm ví dụ tối giản
  crypto/           # Logic nội bộ, test bằng `cargo test`, KHÔNG bridge trực tiếp
    aes_gcm.rs
    kdf.rs
  benchmark/        # Logic nội bộ cho benchmark
    fibonacci.rs
  lib.rs
  frb_generated.rs  # File tự sinh, KHÔNG sửa tay
```

**Nguyên tắc tách lớp:** `api/*.rs` chỉ gọi xuống module nội bộ tương ứng, không
viết logic trực tiếp ở đó. Lý do: logic nội bộ test được bằng `cargo test` (nhanh,
không cần build FFI/app), còn lớp `api/` chỉ lo việc "hình dạng dữ liệu nào lộ ra
Dart" và có nên chạy sync hay async.

`flutter_rust_bridge.yaml` cấu hình `rust_input: crate::api` — codegen chỉ quét
những gì `pub` và reachable từ `api/mod.rs`, nên module nội bộ (`crypto/`,
`benchmark/`) không bị lộ ra Dart trừ khi cố tình `pub use` lại trong `api/`.

## 3 tính năng demo

### 1. Mã hoá AES-256-GCM cho SecureStorage
`RustCryptoService` (`lib/src/core/crypto/rust_crypto_service.dart`) mã hoá thêm
1 lớp AES-256-GCM (native, Rust) trước khi `SecureStorageService`
(`lib/src/core/storage/secure_storage_service.dart`) ghi token/user data vào
`flutter_secure_storage` — dữ liệu vẫn an toàn ngay cả khi lớp mã hoá của OS
(Keystore/Keychain) bị xâm phạm. Khoá master sinh ngẫu nhiên 1 lần, lưu trong
secure storage.

### 2. Khoá 1 trường dữ liệu bằng PIN + Argon2 (giống app ngân hàng)
`PinLockService` (`lib/src/core/crypto/pin_lock_service.dart`) demo Key
Derivation Function: khoá AES **không** sinh ngẫu nhiên mà **derive trực tiếp từ
PIN 6 số** người dùng nhập, qua Argon2id (chậm có chủ đích, chống brute-force).
Không lưu PIN ở đâu cả — chỉ lưu salt. PIN sai → derive sai khoá → AES-GCM tự
phát hiện qua auth tag, không cần logic so khớp PIN riêng. Áp dụng demo cho
trường "Ví" (`Crypto.wallet`) ở màn hình `/profile`
(`PinLockedWalletTile`).

### 3. Benchmark hiệu năng: Fibonacci đệ quy Dart vs Rust
Trang `/rust-benchmark` (`lib/src/features/benchmark/`) chạy cùng 1 thuật toán
(Fibonacci đệ quy thuần, không nhớ đệm) bằng Dart (trong isolate qua `compute()`)
và Rust, đo thời gian, so sánh trực tiếp trên UI.

## ⚠️ Lưu ý quan trọng: hiệu năng Debug vs Release

**`cargokit`** (công cụ build Rust cho Flutter, ở `rust_builder/`) build Rust
**đúng theo profile của Flutter đang chạy**:

| Lệnh Flutter | Rust build profile | Kết quả benchmark |
|---|---|---|
| `flutter run` (debug) | `cargo build` (debug, KHÔNG tối ưu) | Rust có thể **chậm hơn** Dart |
| `flutter run --release` | `cargo build --release` (tối ưu đầy đủ) | Rust nhanh hơn Dart rõ rệt |

Đây không phải bug — Rust debug build giữ nguyên assertion/debug symbol, không
tối ưu hoá (inlining, vectorization...), nên 1 thuật toán CPU-nặng như Fibonacci
đệ quy có thể chạy chậm hơn cả Dart JIT ở debug mode. **Muốn demo đúng sức mạnh
Rust, luôn build/test ở `--release`.** Trang `/rust-benchmark` tự phát hiện
build mode (`kReleaseMode`) và hiện cảnh báo tương ứng ngay trên UI.

Bài học tương tự cũng áp dụng cho việc **không** đánh dấu `frb(sync)` cho các
hàm Rust chạy lâu (`derive_key`, `run_fibonacci_benchmark`) — nếu để `sync`, hàm
sẽ chặn UI thread của Dart bất kể build mode nào, gây giật frame
(`Choreographer: Skipped N frames!`). Chỉ dùng `frb(sync)` cho hàm nhanh
(AES-GCM encrypt/decrypt, sinh salt/key ngẫu nhiên).

## Thêm hàm Rust mới

1. Viết logic nội bộ trong module tương ứng (hoặc tạo module mới) dưới
   `rust/src/<domain>/`, có unit test (`#[cfg(test)] mod tests`).
2. Viết bridge mỏng trong `rust/src/api/<domain>.rs`, chỉ gọi xuống logic ở bước 1.
   Đánh dấu `#[flutter_rust_bridge::frb(sync)]` CHỈ khi hàm chạy rất nhanh
   (micro giây); bỏ trống nếu có thể chạy lâu (Argon2, benchmark, I/O...).
3. `cargo test` trong `rust/` — xác nhận logic đúng trước khi generate FFI.
4. `flutter_rust_bridge_codegen generate` — sinh code Dart tương ứng dưới
   `lib/src/rust/api/`.
5. Nếu thêm service Dart mới cần DI, đánh dấu `@lazySingleton`/`@injectable`
   rồi chạy `dart run build_runner build --delete-conflicting-outputs`.

## Testing

- `cargo test` (trong `rust/`) — test logic thuần Rust, không cần build FFI/app,
  chạy trong vài giây.
- `integration_test/*.dart` (`crypto_test.dart`, `pin_lock_test.dart`,
  `benchmark_test.dart`) — test qua FFI thật, cần `RustLib.init()` trong
  `setUpAll`. Chạy bằng `flutter test integration_test/<file>.dart -d <device>`
  (không dùng `flutter test integration_test/` gộp hết — dễ gặp lỗi kết nối
  debug khi build lại app liên tục giữa các file).
