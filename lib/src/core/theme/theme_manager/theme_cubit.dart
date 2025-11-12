import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/storage/settings_service.dart';

/// Quản lý trạng thái ThemeMode (Light, Dark, System)
/// và đồng bộ với SharedPreferences.
@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  final SettingsService _settingsService;

  /// Khởi tạo Cubit
  /// Nó sẽ tự động tải ThemeMode đã lưu từ SettingsService
  /// ngay khi được tạo.
  ThemeCubit(this._settingsService) : super(_settingsService.loadThemeMode());

  /// Cập nhật theme mode và lưu vào storage
  Future<void> setThemeMode(ThemeMode mode) async {
    // Không emit state nếu không có gì thay đổi
    if (mode == state) return;

    // 1. Lưu vào storage (bất đồng bộ)
    await _settingsService.saveThemeMode(mode);

    // 2. Emit state mới cho UI cập nhật
    emit(mode);
  }
}
