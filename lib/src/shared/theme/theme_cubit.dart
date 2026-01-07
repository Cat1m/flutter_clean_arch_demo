import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Key để lưu vào SharedPreferences
const String _kThemeKey = 'app_theme_mode';

@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;

  /// Khởi tạo Cubit, inject SharedPreferences và tự động load theme đã lưu
  ThemeCubit(this._prefs) : super(ThemeMode.system) {
    _loadSavedTheme();
  }

  /// Load theme từ Local Storage. Nếu chưa có thì mặc định là System.
  void _loadSavedTheme() {
    final savedThemeIndex = _prefs.getInt(_kThemeKey);
    if (savedThemeIndex != null) {
      // Convert int (index) -> Enum
      // 0: system, 1: light, 2: dark
      emit(ThemeMode.values[savedThemeIndex]);
    }
  }

  /// Thay đổi Theme và lưu lại vào Local Storage
  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    // Lưu index của enum vào storage (0, 1, hoặc 2)
    await _prefs.setInt(_kThemeKey, mode.index);
  }

  /// Helper để toggle nhanh giữa Light/Dark (bỏ qua System)
  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setTheme(ThemeMode.light);
    } else {
      setTheme(ThemeMode.dark);
    }
  }
}
