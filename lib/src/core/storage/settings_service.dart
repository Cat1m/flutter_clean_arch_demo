import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SettingKeys {
  static const String rememberMe = 'remember_me';
}

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
}
