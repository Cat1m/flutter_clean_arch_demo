use argon2::Argon2;
use base64::{engine::general_purpose::STANDARD, Engine as _};
use rand::RngCore;

const SALT_LEN: usize = 16;
const KEY_LEN: usize = 32;

/// Sinh salt ngẫu nhiên dùng cho Argon2, trả về dạng base64 để dễ lưu trữ.
pub fn generate_salt() -> String {
    let mut salt_bytes = [0u8; SALT_LEN];
    rand::thread_rng().fill_bytes(&mut salt_bytes);
    STANDARD.encode(salt_bytes)
}

/// Derive khoá AES-256 (base64) từ PIN + salt bằng Argon2id.
/// Cùng `pin`/`salt` luôn cho ra cùng khoá; đổi 1 trong 2 sẽ ra khoá khác.
pub fn derive_key(pin: &str, salt_b64: &str) -> Result<String, String> {
    let salt_bytes = STANDARD
        .decode(salt_b64)
        .map_err(|e| format!("Salt không đúng định dạng base64: {e}"))?;

    let mut key_bytes = [0u8; KEY_LEN];
    Argon2::default()
        .hash_password_into(pin.as_bytes(), &salt_bytes, &mut key_bytes)
        .map_err(|e| format!("Derive khoá từ PIN thất bại: {e}"))?;

    Ok(STANDARD.encode(key_bytes))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn same_pin_and_salt_produce_same_key() {
        let salt = generate_salt();

        let key_a = derive_key("123456", &salt).unwrap();
        let key_b = derive_key("123456", &salt).unwrap();

        assert_eq!(key_a, key_b);
    }

    #[test]
    fn different_pin_produces_different_key() {
        let salt = generate_salt();

        let key_a = derive_key("123456", &salt).unwrap();
        let key_b = derive_key("654321", &salt).unwrap();

        assert_ne!(key_a, key_b);
    }

    #[test]
    fn different_salt_produces_different_key() {
        let key_a = derive_key("123456", &generate_salt()).unwrap();
        let key_b = derive_key("123456", &generate_salt()).unwrap();

        assert_ne!(key_a, key_b);
    }

    #[test]
    fn generate_salt_returns_16_bytes_when_decoded() {
        let salt = generate_salt();
        let decoded = STANDARD.decode(salt).unwrap();
        assert_eq!(decoded.len(), SALT_LEN);
    }

    #[test]
    fn derived_key_is_32_bytes_when_decoded() {
        let key = derive_key("123456", &generate_salt()).unwrap();
        let decoded = STANDARD.decode(key).unwrap();
        assert_eq!(decoded.len(), KEY_LEN);
    }
}
