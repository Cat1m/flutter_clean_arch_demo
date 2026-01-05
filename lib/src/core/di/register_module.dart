import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/auth/interceptors/auth_interceptor.dart';
import 'package:reqres_in/src/core/auth/interceptors/token_interceptor.dart';
import 'package:reqres_in/src/core/env/env.dart';
import 'package:reqres_in/src/core/network/api_service.dart';
import 'package:reqres_in/src/core/network/dio_client.dart';
import 'package:reqres_in/src/core/network/logger_interceptor.dart';
import 'package:reqres_in/src/features/auth/data/datasources/auth_client.dart';
import 'package:reqres_in/src/features/user/data/datasources/user_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class RegisterModule {
  // ---------------------------------------------------------------------------
  // 1. THIRD PARTY (Thư viện ngoài)
  // ---------------------------------------------------------------------------

  @preResolve
  @lazySingleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  // ---------------------------------------------------------------------------
  // 2. NETWORK WIRING (Lắp ráp mạng)
  // ---------------------------------------------------------------------------

  // a. Tạo DioClient: Bơm các Interceptor từ core/auth vào đây
  @lazySingleton
  DioClient dioClient(
    AuthInterceptor authInterceptor,
    TokenInterceptor tokenInterceptor,
    LoggerInterceptor loggerInterceptor,
  ) {
    return DioClient(
      baseUrl: Env.baseUrl, // Lấy từ biến môi trường
      interceptors: [authInterceptor, tokenInterceptor, loggerInterceptor],
    );
  }

  // b. Cung cấp Dio instance từ DioClient
  @lazySingleton
  Dio dio(DioClient client) => client.dio;

  // c. Cung cấp ApiService (Retrofit)
  @lazySingleton
  ApiService apiService(Dio dio) => ApiService(dio);

  @lazySingleton
  AuthClient authClient(Dio dio) => AuthClient(dio);

  @lazySingleton
  UserClient userClient(Dio dio) => UserClient(dio);

  // ---------------------------------------------------------------------------
  // ⚠️ LƯU Ý QUAN TRỌNG:
  // Đã XÓA 'storageService' và 'settingsService' ở đây.
  // Vì anh đã gắn @lazySingleton trực tiếp lên 2 class đó rồi.
  // Injectable sẽ tự tìm thấy chúng. Đừng đăng ký 2 lần!
  // ---------------------------------------------------------------------------
}
