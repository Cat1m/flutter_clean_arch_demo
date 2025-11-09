// lib/src/core/navigation/stream_listenable.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Chuyển đổi một [Stream] thành một [Listenable].
/// [GoRouter] sẽ dùng class này để lắng nghe [Cubit.stream].
class StreamListenable extends ChangeNotifier {
  late final StreamSubscription _subscription;

  StreamListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
