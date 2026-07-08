use crate::crypto::kdf;

/// Sinh salt ngẫu nhiên (base64) dùng cho việc derive khoá từ PIN.
#[flutter_rust_bridge::frb(sync)]
pub fn generate_salt() -> String {
    kdf::generate_salt()
}

/// Derive khoá AES-256 (base64) từ PIN + salt bằng Argon2id.
/// Cố tình KHÔNG đánh dấu `frb(sync)` — Argon2 chậm có chủ đích (chống
/// brute-force), nếu chạy sync sẽ chặn UI thread. Để async, flutter_rust_bridge
/// tự chạy hàm này trên 1 thread nền, Dart nhận về Future thay vì bị block.
pub fn derive_key(pin: String, salt_b64: String) -> Result<String, String> {
    kdf::derive_key(&pin, &salt_b64)
}
