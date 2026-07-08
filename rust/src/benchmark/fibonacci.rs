use std::time::Instant;

/// Fibonacci đệ quy thuần, KHÔNG memoization — cố ý để tốn CPU thật,
/// dùng làm bài benchmark so sánh tốc độ Dart vs Rust.
fn fib(n: u32) -> u64 {
    if n < 2 {
        n as u64
    } else {
        fib(n - 1) + fib(n - 2)
    }
}

/// Chạy `fib(n)` và đo thời gian thực thi. Trả về `(kết quả, micro giây)`.
pub fn run_benchmark(n: u32) -> (u64, u64) {
    let start = Instant::now();
    let result = fib(n);
    let elapsed_micros = start.elapsed().as_micros() as u64;
    (result, elapsed_micros)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn fib_base_cases() {
        assert_eq!(fib(0), 0);
        assert_eq!(fib(1), 1);
    }

    #[test]
    fn fib_10_is_55() {
        assert_eq!(fib(10), 55);
    }

    #[test]
    fn run_benchmark_returns_correct_result() {
        let (result, _elapsed_micros) = run_benchmark(10);
        assert_eq!(result, 55);
    }
}
