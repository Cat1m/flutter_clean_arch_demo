import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@lazySingleton
class NetworkService {
  final Connectivity _connectivity = Connectivity();

  // 2. Dùng BehaviorSubject
  // Nó là một StreamController "nhớ" giá trị cuối cùng.
  // Chúng ta "gieo" (seed) giá trị ban đầu là 'true' (lạc quan)
  final BehaviorSubject<bool> _networkSubject = BehaviorSubject.seeded(true);

  /// Stream phát ra 'true' (online) hoặc 'false' (offline)
  /// Sẽ ngay lập tức phát ra giá trị cuối cùng cho listener mới.
  Stream<bool> get isOnlineStream => _networkSubject.stream;

  /// Lấy trạng thái đã biết cuối cùng (đồng bộ)
  bool get lastKnownStatus => _networkSubject.value;

  NetworkService() {
    // 3. Di chuyển logic vào constructor
    // Ngay khi service được tạo, nó sẽ:

    // a. Kiểm tra trạng thái thực tế ngay lập tức
    _connectivity.checkConnectivity().then((results) {
      final isOnline = !results.contains(ConnectivityResult.none);
      _networkSubject.add(isOnline); // Cập nhật stream
    });

    // b. Lắng nghe các thay đổi trong tương lai
    _connectivity.onConnectivityChanged.listen((results) {
      final isOnline = !results.contains(ConnectivityResult.none);
      _networkSubject.add(isOnline); // Cập nhật stream
    });
  }

  /// Check trạng thái hiện tại một cách chủ động (bất đồng bộ)
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    final isOnline = !results.contains(ConnectivityResult.none);
    _networkSubject.add(isOnline); // Cập nhật stream với thông tin mới nhất
    return isOnline;
  }

  // Bạn có thể thêm một hàm dispose nếu cần để đóng subject
  // @disposeMethod (nếu dùng injectable-disposable)
  void dispose() {
    _networkSubject.close();
  }
}
