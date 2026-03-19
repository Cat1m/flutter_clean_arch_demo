import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/auth/interceptors/auth_interceptor.dart';
import 'package:reqres_in/src/core/auth/interceptors/token_interceptor.dart';
import 'package:reqres_in/src/core/env/env_config.dart';
import 'package:reqres_in/src/core/error/error_event_service.dart';
import 'package:reqres_in/src/core/network/dio_client.dart';
import 'package:reqres_in/src/core/network/logger_interceptor.dart';
import 'package:reqres_in/src/core/network/network_service.dart';
import 'package:reqres_in/src/core/pdf/infrastructure/pdf_font_helper.dart';
import 'package:reqres_in/src/shared/data/remote/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

//! nhớ chạy lại: dart run build_runner build --delete-conflicting-outputs
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

  @lazySingleton
  DioClient dioClient(
    AuthInterceptor authInterceptor,
    TokenInterceptor tokenInterceptor,
    NetworkService networkService,
    ErrorEventService errorEventService,
  ) {
    // 1. Lấy URL từ Config
    final String baseUrl = EnvConfig.baseUrl;

    // 2. Log cảnh báo nếu đang Dev (Để tránh build nhầm bản Prod mà trỏ server Dev)
    if (kDebugMode) {
      log('⚠️------------------------------------------------⚠️');
      log('🚀 APP RUNNING IN MODE: ${EnvConfig.mode.name.toUpperCase()}');
      log('🔗 BASE URL: $baseUrl');
      log('⚠️------------------------------------------------⚠️');
    }

    // 3. Inject vào Client (Client giờ không cần lo logic này nữa)
    return DioClient(
      baseUrl: baseUrl,
      interceptors: [authInterceptor, tokenInterceptor],
      networkService: networkService,
      errorEventService: errorEventService,
      logger: kDebugMode ? LoggerInterceptor.development() : null,
    );
  }

  // b. Cung cấp Dio instance từ DioClient
  @lazySingleton
  Dio dio(DioClient client) => client.dio;

  @lazySingleton
  ApiService apiService(Dio dio) => ApiService(dio);

  // --------------------------------------------------------
  // PDF MODULE
  // --------------------------------------------------------
  @singleton
  PdfFontHelper get pdfFontHelper => PdfFontHelper.instance;
}
