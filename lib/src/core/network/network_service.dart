// lib/src/core/network/network_service.dart

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

/// Service theo dõi trạng thái kết nối mạng.
///
/// Phối hợp 2 nguồn tín hiệu:
/// - **connectivity_plus**: phát hiện mất kết nối transport (tắt WiFi/Mobile)
///   → phản hồi tức thì, nhưng không biết internet thực sự hoạt động hay không.
/// - **Dio request thực tế**: khi request fail ([reportConnectionFailure]) hoặc
///   thành công ([reportConnectionSuccess]) → xác nhận chính xác 100%.
///
/// ```
/// connectivity_plus  ──► None → offline ngay
///                    ──► WiFi/Mobile → "có thể online" (chưa chắc)
/// Dio ErrorInterceptor ──► ConnectionFailure → offline (chính xác)
/// Dio onResponse       ──► OK → online (chính xác)
/// ```
@lazySingleton
class NetworkService {
  final Connectivity _connectivity = Connectivity();

  /// BehaviorSubject "nhớ" giá trị cuối cùng.
  /// Seed = true (lạc quan: giả sử online cho đến khi biết ngược lại).
  final BehaviorSubject<bool> _networkSubject = BehaviorSubject.seeded(true);

  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  /// Stream phát ra `true` (online) hoặc `false` (offline).
  /// [distinct] lọc duplicate → listener chỉ nhận khi trạng thái thay đổi.
  /// BehaviorSubject phát giá trị cuối ngay cho listener mới.
  Stream<bool> get isOnlineStream => _networkSubject.stream.distinct();

  /// Trạng thái đã biết cuối cùng (đồng bộ, không tốn async).
  bool get lastKnownStatus => _networkSubject.value;

  NetworkService() {
    // Kiểm tra trạng thái thực tế ngay lập tức
    _connectivity.checkConnectivity().then(_updateFromConnectivity);

    // Lắng nghe các thay đổi transport trong tương lai
    _connectivitySub = _connectivity.onConnectivityChanged.listen(
      _updateFromConnectivity,
    );
  }

  /// Cập nhật từ connectivity_plus event.
  ///
  /// Chỉ tin tưởng khi báo [ConnectivityResult.none] (chắc chắn offline).
  /// Khi báo WiFi/Mobile → set online, nhưng Dio sẽ correct lại nếu
  /// internet thực tế không hoạt động (captive portal, router mất WAN).
  void _updateFromConnectivity(List<ConnectivityResult> results) {
    final isOnline = !results.contains(ConnectivityResult.none);
    _networkSubject.add(isOnline);
  }

  // ---------------------------------------------------------------------------
  // Được gọi bởi ErrorInterceptor / Dio interceptor chain
  // ---------------------------------------------------------------------------

  /// Gọi khi Dio request fail với [ConnectionFailure].
  /// → Đồng bộ trạng thái: chắc chắn offline (internet không hoạt động).
  void reportConnectionFailure() {
    _networkSubject.add(false);
  }

  /// Gọi khi Dio request thành công (onResponse).
  /// → Chắc chắn online. Chỉ emit nếu đang offline để tránh spam.
  void reportConnectionSuccess() {
    if (!_networkSubject.value) {
      _networkSubject.add(true);
    }
  }

  /// Check trạng thái hiện tại một cách chủ động (bất đồng bộ).
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    _updateFromConnectivity(results);
    return _networkSubject.value;
  }

  @disposeMethod
  void dispose() {
    _connectivitySub.cancel();
    _networkSubject.close();
  }
}
