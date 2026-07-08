use crate::benchmark::fibonacci;

/// Kết quả benchmark trả về cho Dart: giá trị fib(n) và thời gian chạy (micro giây).
pub struct FibBenchmarkResult {
    pub result: u64,
    pub elapsed_micros: u64,
}

/// Chạy benchmark Fibonacci đệ quy thuần trong Rust.
/// Cố tình KHÔNG đánh dấu `frb(sync)` — N lớn có thể chạy vài giây, để async
/// giúp flutter_rust_bridge tự chạy trên thread nền, không treo UI thread.
pub fn run_fibonacci_benchmark(n: u32) -> FibBenchmarkResult {
    let (result, elapsed_micros) = fibonacci::run_benchmark(n);
    FibBenchmarkResult {
        result,
        elapsed_micros,
    }
}
