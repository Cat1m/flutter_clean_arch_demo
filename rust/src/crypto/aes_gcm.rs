use aes_gcm::aead::{Aead, KeyInit};
use aes_gcm::{Aes256Gcm, Key, Nonce};
use base64::{engine::general_purpose::STANDARD, Engine as _};
use rand::RngCore;

const KEY_LEN: usize = 32;
const NONCE_LEN: usize = 12;

/// Sinh khoá AES-256 ngẫu nhiên, trả về dạng base64 để dễ lưu trữ ở phía Dart.
pub fn generate_key() -> String {
    let mut key_bytes = [0u8; KEY_LEN];
    rand::thread_rng().fill_bytes(&mut key_bytes);
    STANDARD.encode(key_bytes)
}

/// Mã hoá `plaintext` bằng AES-256-GCM. Payload trả về = nonce (12 byte) nối
/// trước ciphertext, sau đó encode base64 để tiện truyền qua FFI dạng String.
pub fn encrypt(key_b64: &str, plaintext: &str) -> Result<String, String> {
    let cipher = build_cipher(key_b64)?;

    let mut nonce_bytes = [0u8; NONCE_LEN];
    rand::thread_rng().fill_bytes(&mut nonce_bytes);
    let nonce = Nonce::from_slice(&nonce_bytes);

    let ciphertext = cipher
        .encrypt(nonce, plaintext.as_bytes())
        .map_err(|e| format!("Mã hoá thất bại: {e}"))?;

    let mut payload = Vec::with_capacity(NONCE_LEN + ciphertext.len());
    payload.extend_from_slice(&nonce_bytes);
    payload.extend_from_slice(&ciphertext);

    Ok(STANDARD.encode(payload))
}

/// Giải mã payload sinh ra bởi [`encrypt`].
pub fn decrypt(key_b64: &str, payload_b64: &str) -> Result<String, String> {
    let cipher = build_cipher(key_b64)?;

    let payload = STANDARD
        .decode(payload_b64)
        .map_err(|e| format!("Payload không đúng định dạng base64: {e}"))?;
    if payload.len() < NONCE_LEN {
        return Err("Payload quá ngắn, thiếu nonce".to_string());
    }
    let (nonce_bytes, ciphertext) = payload.split_at(NONCE_LEN);
    let nonce = Nonce::from_slice(nonce_bytes);

    let plaintext = cipher
        .decrypt(nonce, ciphertext)
        .map_err(|e| format!("Giải mã thất bại: {e}"))?;

    String::from_utf8(plaintext).map_err(|e| format!("Dữ liệu giải mã không phải UTF-8: {e}"))
}

fn build_cipher(key_b64: &str) -> Result<Aes256Gcm, String> {
    let key_bytes = STANDARD
        .decode(key_b64)
        .map_err(|e| format!("Khoá không đúng định dạng base64: {e}"))?;
    if key_bytes.len() != KEY_LEN {
        return Err(format!(
            "Khoá phải dài {KEY_LEN} byte, nhận được {}",
            key_bytes.len()
        ));
    }
    let key = Key::<Aes256Gcm>::from_slice(&key_bytes);
    Ok(Aes256Gcm::new(key))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn encrypt_then_decrypt_returns_original_plaintext() {
        let key = generate_key();
        let plaintext = "hello rust crypto, xin chào 👋";

        let payload = encrypt(&key, plaintext).expect("encrypt should succeed");
        let decrypted = decrypt(&key, &payload).expect("decrypt should succeed");

        assert_eq!(decrypted, plaintext);
    }

    #[test]
    fn same_plaintext_produces_different_payloads_due_to_random_nonce() {
        let key = generate_key();
        let plaintext = "same input";

        let payload_a = encrypt(&key, plaintext).unwrap();
        let payload_b = encrypt(&key, plaintext).unwrap();

        assert_ne!(payload_a, payload_b);
    }

    #[test]
    fn decrypt_with_wrong_key_fails() {
        let key_a = generate_key();
        let key_b = generate_key();
        let payload = encrypt(&key_a, "secret data").unwrap();

        assert!(decrypt(&key_b, &payload).is_err());
    }

    #[test]
    fn generate_key_returns_32_bytes_when_decoded() {
        let key = generate_key();
        let decoded = STANDARD.decode(key).unwrap();
        assert_eq!(decoded.len(), KEY_LEN);
    }
}
