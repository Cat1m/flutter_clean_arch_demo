import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reqres_in/src/core/di/injection.dart';
import 'package:reqres_in/src/core/service/network_service.dart';

/// Một widget "lắng nghe" trạng thái mạng và hiển thị SnackBar
/// một cách tự động từ ScaffoldMessenger gốc.
class NetworkSnackbarListener extends StatefulWidget {
  final Widget child;
  const NetworkSnackbarListener({super.key, required this.child});

  @override
  State<NetworkSnackbarListener> createState() =>
      _NetworkSnackbarListenerState();
}

class _NetworkSnackbarListenerState extends State<NetworkSnackbarListener> {
  late final NetworkService _networkService;
  StreamSubscription? _networkSubscription;
  bool _wasOffline = false; // Theo dõi để hiển thị "online trở lại"

  @override
  void initState() {
    super.initState();
    _networkService = getIt<NetworkService>();

    // Chúng ta cần `context` có ScaffoldMessenger,
    // nên chúng ta đợi frame đầu tiên được build xong.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Khởi tạo giá trị ban đầu
        _wasOffline = !_networkService.lastKnownStatus;
        _listenToNetworkChanges();
      }
    });
  }

  void _listenToNetworkChanges() {
    _networkSubscription = _networkService.isOnlineStream.listen((isOnline) {
      if (!mounted) return;

      // ⭐️⭐️⭐️ FIX QUAN TRỌNG ⭐️⭐️⭐️
      // 1. Luôn HỦY snackbar hiện tại (bất kể là cái nào)
      // `hideCurrentSnackBar` an toàn hơn `close()`
      // để tránh race condition
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      // ⭐️⭐️⭐️ HẾT FIX ⭐️⭐️⭐️

      if (!isOnline) {
        // --- XỬ LÝ KHI OFFLINE ---
        _wasOffline = true;

        // 2. Hiển thị snackbar "offline" mới
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Bạn đang offline',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(days: 365), // Hiển thị vĩnh viễn
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),

            action: SnackBarAction(
              label: 'ĐÓNG',
              textColor: Colors.white,
              onPressed: () {
                // ⭐️ Dùng `hide` ở đây
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      } else {
        // --- XỬ LÝ KHI ONLINE ---

        // (Không cần gọi close() hay hide() ở đây nữa
        //  vì chúng ta đã gọi ở trên cùng)

        // Chỉ hiển thị "online trở lại" nếu TRƯỚC ĐÓ đã offline
        if (_wasOffline) {
          _wasOffline = false;
          if (mounted) {
            // 2. Hiển thị snackbar "online" mới
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Đã kết nối trở lại',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: Colors.green.shade700,
                duration: const Duration(seconds: 3), // Hiển thị tạm thời
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    // ⭐️ Đảm bảo snackbar cũng bị đóng khi widget bị hủy
    // Kiểm tra `mounted` trước khi truy cập context
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Widget này chỉ render "con" của nó.
    // Toàn bộ logic là lắng nghe và gọi ScaffoldMessenger.
    return widget.child;
  }
}
