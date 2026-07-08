use crate::crypto::aes_gcm;

/// Sinh khoá AES-256 ngẫu nhiên (base64), dùng để lưu ở SecureStorage phía Dart.
#[flutter_rust_bridge::frb(sync)]
pub fn generate_key() -> String {
    aes_gcm::generate_key()
}

/// Mã hoá `plaintext` bằng AES-256-GCM với khoá `key_b64` (base64).
#[flutter_rust_bridge::frb(sync)]
pub fn encrypt(key_b64: String, plaintext: String) -> Result<String, String> {
    aes_gcm::encrypt(&key_b64, &plaintext)
}

/// Giải mã payload sinh ra bởi [`encrypt`].
#[flutter_rust_bridge::frb(sync)]
pub fn decrypt(key_b64: String, payload_b64: String) -> Result<String, String> {
    aes_gcm::decrypt(&key_b64, &payload_b64)
}
