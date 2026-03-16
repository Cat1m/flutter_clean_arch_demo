// lib/src/core/network/cache_store.dart

import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Đại diện một entry trong cache, bao gồm data, thời điểm lưu và TTL.
class CacheEntry {
  final String data; // JSON-encoded string
  final DateTime cachedAt;
  final Duration ttl;

  const CacheEntry({
    required this.data,
    required this.cachedAt,
    required this.ttl,
  });

  /// Kiểm tra cache đã hết hạn chưa
  bool get isExpired => DateTime.now().isAfter(cachedAt.add(ttl));

  Map<String, dynamic> toJson() => {
    'data': data,
    'cachedAt': cachedAt.toIso8601String(),
    'ttlMs': ttl.inMilliseconds,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
    data: json['data'] as String,
    cachedAt: DateTime.parse(json['cachedAt'] as String),
    ttl: Duration(milliseconds: json['ttlMs'] as int),
  );
}

/// Interface trừu tượng cho cache storage.
/// Cho phép swap giữa in-memory, SharedPreferences, Hive, SQLite...
abstract class CacheStore {
  Future<CacheEntry?> get(String key);
  Future<void> put(String key, CacheEntry entry);
  Future<void> remove(String key);
  Future<void> clear();
}

/// Cache trong bộ nhớ, mất khi kill app.
/// Phù hợp cho data session-scoped (profile, config tạm thời).
@LazySingleton(as: CacheStore)
class InMemoryCacheStore implements CacheStore {
  final Map<String, CacheEntry> _store = {};

  @override
  Future<CacheEntry?> get(String key) async => _store[key];

  @override
  Future<void> put(String key, CacheEntry entry) async => _store[key] = entry;

  @override
  Future<void> remove(String key) async => _store.remove(key);

  @override
  Future<void> clear() async => _store.clear();
}

/// Cache persistent qua SharedPreferences, giữ được khi restart app.
/// Phù hợp cho data ít thay đổi (app config, danh mục tỉnh/thành...).
@Named('persistent')
@LazySingleton(as: CacheStore)
class SharedPrefsCacheStore implements CacheStore {
  final SharedPreferences _prefs;
  static const _prefix = 'cache_';

  SharedPrefsCacheStore(this._prefs);

  @override
  Future<CacheEntry?> get(String key) async {
    final raw = _prefs.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return CacheEntry.fromJson(json);
    } catch (_) {
      // Cache bị corrupted → xóa luôn
      await remove(key);
      return null;
    }
  }

  @override
  Future<void> put(String key, CacheEntry entry) async {
    await _prefs.setString('$_prefix$key', jsonEncode(entry.toJson()));
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove('$_prefix$key');
  }

  @override
  Future<void> clear() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
