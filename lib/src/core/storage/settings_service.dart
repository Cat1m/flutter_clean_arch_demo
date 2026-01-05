// Import thêm 'package:flutter/material.dart' để dùng ThemeMode
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SettingKeys {
  static const String rememberMe = 'remember_me';
  // Thêm key mới
  static const String themeMode = 'theme_mode';
}

@lazySingleton
class SettingsService {
  final SharedPreferences _prefs;

  // Constructor này sẽ được getIt gọi
  SettingsService(this._prefs);

  // --- Remember Me ---
  Future<void> saveRememberMe(bool value) async {
    await _prefs.setBool(_SettingKeys.rememberMe, value);
  }

  // Mặc định là false nếu chưa từng lưu
  bool getRememberMe() {
    return _prefs.getBool(_SettingKeys.rememberMe) ?? false;
  }

  // --- Theme Mode (Thêm mới) ---

  /// Lưu ThemeMode (light, dark, system)
  Future<void> saveThemeMode(ThemeMode mode) async {
    // Lưu dưới dạng String (ví dụ: "dark")
    await _prefs.setString(_SettingKeys.themeMode, mode.name);
  }

  /// Tải ThemeMode đã lưu.
  /// Mặc định là ThemeMode.system nếu chưa từng lưu.
  ThemeMode loadThemeMode() {
    final themeName = _prefs.getString(_SettingKeys.themeMode);
    if (themeName == null) {
      return ThemeMode.system; // Mặc định là system
    }

    // Chuyển đổi String (vd: "dark") về lại enum (ThemeMode.dark)
    try {
      return ThemeMode.values.firstWhere((e) => e.name == themeName);
    } catch (e) {
      // Bắt lỗi nếu tên đã lưu không hợp lệ
      return ThemeMode.system;
    }
  }
}
