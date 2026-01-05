enum EnvMode {
  /// Môi trường thật (Lấy từ .env)
  prod,

  /// Môi trường Dev Server (Test online)
  dev,

  /// Chạy Localhost trên máy tính (Android Emulator: 10.0.2.2)
  localAndroid,

  /// Chạy Localhost trên máy tính (iOS Simulator: localhost)
  localIos,

  /// Chạy qua Ngrok (Public URL tạm thời)
  ngrok,
}
