// lib/src/core/navigation/navigation_service.dart
import 'package:flutter/material.dart';

/// Một GlobalKey cho Navigator.
/// Giúp chúng ta truy cập Navigator.context từ bất kỳ đâu trong app
/// mà không cần truyền BuildContext.
///
/// Dùng để hiển thị dialog/snackbar toàn cục từ Cubit/Service.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
