// lib/src/core/network/base_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'cache_store.dart';
import 'failures.dart';

/// Mixin cung cấp các method helper cho repository layer.
///
/// Loại bỏ boilerplate try/catch và cung cấp 3 cache strategy:
/// - [apiFirstWithCacheFallback]: Gọi API trước, dùng cache khi mất mạng
/// - [cacheFirstWithTtl]: Dùng cache nếu còn hạn, skip API
/// - [staleWhileRevalidate]: Trả cache ngay, cập nhật API ngầm
///
/// Sử dụng:
/// ```dart
/// class UserRepositoryImpl with BaseRepository implements UserRepository {
///   Future<Either<Failure, User>> getMe() =>
///       safeApiCall(() => _apiService.getMe());
/// }
/// ```
mixin BaseRepository {
  // ---------------------------------------------------------------------------
  // Không cache
  // ---------------------------------------------------------------------------

  /// Wrap một API call, tự động map DioException → [Failure].
  ///
  /// ErrorInterceptor đã convert DioException.error thành Failure,
  /// method này chỉ cần extract và wrap vào Either.
  Future<Either<Failure, T>> safeApiCall<T>(
    Future<T> Function() apiCall,
  ) async {
    try {
      final data = await apiCall();
      return Right(data);
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  /// Giống [safeApiCall] nhưng transform data trước khi trả về.
  ///
  /// Hữu ích khi cần convert DTO → Domain Entity:
  /// ```dart
  /// safeApiCallWithMapping(
  ///   () => _api.getUser(),
  ///   (dto) => dto.toEntity(),
  /// );
  /// ```
  Future<Either<Failure, R>> safeApiCallWithMapping<T, R>(
    Future<T> Function() apiCall,
    R Function(T data) mapper,
  ) async {
    try {
      final data = await apiCall();
      return Right(mapper(data));
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  // ---------------------------------------------------------------------------
  // Strategy 1: API-first + Cache fallback
  // ---------------------------------------------------------------------------

  /// Gọi API trước. Nếu mất mạng ([ConnectionFailure]), fallback sang cache.
  ///
  /// Flow:
  /// 1. Gọi API → thành công → lưu cache + trả data
  /// 2. API fail + là ConnectionFailure → đọc cache → có → trả cache cũ
  /// 3. Không phải ConnectionFailure hoặc cache miss → trả Failure gốc
  ///
  /// Phù hợp: list sản phẩm, lịch sử đơn hàng — cần data mới nhất,
  /// nhưng offline vẫn hiển thị được data cũ.
  Future<Either<Failure, T>> apiFirstWithCacheFallback<T>({
    required Future<T> Function() apiCall,
    required CacheStore cacheStore,
    required String cacheKey,
    required String Function(T data) toJson,
    required T Function(String json) fromJson,
    Duration ttl = const Duration(minutes: 30),
  }) async {
    final apiResult = await safeApiCall(apiCall);

    // Thành công: lưu cache và trả data
    if (apiResult.isRight()) {
      final data = (apiResult as Right<Failure, T>).value;
      await _saveToCache(cacheStore, cacheKey, toJson(data), ttl);
      return apiResult;
    }

    // Chỉ fallback cache khi mất mạng
    final failure = (apiResult as Left<Failure, T>).value;
    if (failure is! ConnectionFailure) return apiResult;

    // Thử đọc cache
    final cached = await _readFromCache(cacheStore, cacheKey, fromJson);
    return cached ?? apiResult;
  }

  // ---------------------------------------------------------------------------
  // Strategy 2: Cache-first + TTL
  // ---------------------------------------------------------------------------

  /// Đọc cache trước. Nếu cache còn hạn, trả ngay mà không gọi API.
  ///
  /// Flow:
  /// 1. Cache tồn tại + chưa hết hạn → trả cache (skip API hoàn toàn)
  /// 2. Cache hết hạn hoặc không có → gọi API → lưu cache + trả data
  /// 3. API fail + có cache cũ (dù hết hạn) → trả cache cũ làm fallback
  /// 4. API fail + không có cache → trả Failure
  ///
  /// Phù hợp: user profile, app config, danh mục tĩnh — data ít thay đổi,
  /// giảm đáng kể số lượng API call.
  Future<Either<Failure, T>> cacheFirstWithTtl<T>({
    required Future<T> Function() apiCall,
    required CacheStore cacheStore,
    required String cacheKey,
    required String Function(T data) toJson,
    required T Function(String json) fromJson,
    Duration ttl = const Duration(minutes: 10),
  }) async {
    // Đọc cache
    final cached = await cacheStore.get(cacheKey);

    // Cache còn hạn → trả ngay
    if (cached != null && !cached.isExpired) {
      final data = _tryParse(cached.data, fromJson);
      if (data != null) return Right(data);
      // Parse fail → cache corrupted, fall through gọi API
    }

    // Gọi API
    final apiResult = await safeApiCall(apiCall);

    // API thành công → lưu cache
    if (apiResult.isRight()) {
      final data = (apiResult as Right<Failure, T>).value;
      await _saveToCache(cacheStore, cacheKey, toJson(data), ttl);
      return apiResult;
    }

    // API fail → thử trả cache cũ (dù hết hạn) làm fallback
    if (cached != null) {
      final staleData = _tryParse(cached.data, fromJson);
      if (staleData != null) return Right(staleData);
    }

    return apiResult;
  }

  // ---------------------------------------------------------------------------
  // Strategy 3: Stale-while-revalidate
  // ---------------------------------------------------------------------------

  /// Trả cache ngay lập tức, đồng thời gọi API ngầm để cập nhật.
  ///
  /// Flow:
  /// 1. Có cache → trả cache ngay (user thấy data tức thì, không loading)
  ///    → gọi API ngầm → thành công → update cache + gọi [onRevalidated]
  /// 2. Không có cache → gọi API đồng bộ (flow bình thường)
  ///
  /// [onRevalidated] callback để Cubit emit state mới khi có data fresh:
  /// ```dart
  /// staleWhileRevalidate(
  ///   apiCall: () => _api.getMe(),
  ///   onRevalidated: (user) => emit(UserLoaded(user)),
  ///   ...
  /// );
  /// ```
  ///
  /// Phù hợp: feed, dashboard — user không bao giờ thấy loading spinner
  /// khi quay lại màn hình.
  Future<Either<Failure, T>> staleWhileRevalidate<T>({
    required Future<T> Function() apiCall,
    required CacheStore cacheStore,
    required String cacheKey,
    required String Function(T data) toJson,
    required T Function(String json) fromJson,
    Duration ttl = const Duration(minutes: 30),
    void Function(T freshData)? onRevalidated,
  }) async {
    // Đọc cache
    final cached = await cacheStore.get(cacheKey);

    if (cached != null) {
      final cachedData = _tryParse(cached.data, fromJson);

      if (cachedData != null) {
        // Trả cache ngay, revalidate ngầm (fire-and-forget)
        unawaited(_revalidateInBackground(
          apiCall: apiCall,
          cacheStore: cacheStore,
          cacheKey: cacheKey,
          toJson: toJson,
          ttl: ttl,
          onRevalidated: onRevalidated,
        ));
        return Right(cachedData);
      }
    }

    // Không có cache → gọi API đồng bộ
    final apiResult = await safeApiCall(apiCall);

    if (apiResult.isRight()) {
      final data = (apiResult as Right<Failure, T>).value;
      await _saveToCache(cacheStore, cacheKey, toJson(data), ttl);
    }

    return apiResult;
  }

  // ---------------------------------------------------------------------------
  // Cache control
  // ---------------------------------------------------------------------------

  /// Xóa cache cho một key cụ thể.
  /// Gọi sau khi update data để đảm bảo lần đọc tiếp theo lấy data mới.
  Future<void> invalidateCache(CacheStore cacheStore, String key) =>
      cacheStore.remove(key);

  /// Xóa toàn bộ cache. Thường dùng khi logout.
  Future<void> invalidateAll(CacheStore cacheStore) => cacheStore.clear();

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Extract Failure từ DioException.
  /// ErrorInterceptor đã set e.error = Failure, chỉ cần cast.
  Failure _mapDioException(DioException e) {
    if (e.error is Failure) return e.error as Failure;
    return ServerFailure(e.message ?? 'Server error');
  }

  /// Lưu data vào cache store
  Future<void> _saveToCache(
    CacheStore store,
    String key,
    String jsonData,
    Duration ttl,
  ) =>
      store.put(
        key,
        CacheEntry(data: jsonData, cachedAt: DateTime.now(), ttl: ttl),
      );

  /// Đọc và parse cache, trả Either hoặc null nếu không có/corrupted
  Future<Either<Failure, T>?> _readFromCache<T>(
    CacheStore store,
    String key,
    T Function(String json) fromJson,
  ) async {
    final cached = await store.get(key);
    if (cached == null) return null;
    final data = _tryParse(cached.data, fromJson);
    if (data == null) return null;
    return Right(data);
  }

  /// Parse JSON an toàn, trả null nếu lỗi
  T? _tryParse<T>(String json, T Function(String json) fromJson) {
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Gọi API ngầm để cập nhật cache. Lỗi bị swallow vì caller đã có data cũ.
  Future<void> _revalidateInBackground<T>({
    required Future<T> Function() apiCall,
    required CacheStore cacheStore,
    required String cacheKey,
    required String Function(T data) toJson,
    required Duration ttl,
    void Function(T freshData)? onRevalidated,
  }) async {
    try {
      final data = await apiCall();
      await _saveToCache(cacheStore, cacheKey, toJson(data), ttl);
      onRevalidated?.call(data);
    } catch (_) {
      // Silently fail — caller đã có stale data
    }
  }
}
