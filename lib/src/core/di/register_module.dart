// core/di/register_module.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/storage/secure_storage_service.dart';

import '../network/api_service.dart';
import '../network/dio_client.dart';

@module
abstract class RegisterModule {
  // Bảo Injectable: "Khi ai đó cần Dio, hãy gọi hàm này"
  @lazySingleton
  Dio get dio => DioClient().dio;

  // "Khi ai đó cần ApiService, hãy gọi hàm này (và nhớ đưa Dio cho tôi)"
  @lazySingleton
  ApiService getApiService(Dio dio) => ApiService(dio);

  // "Khi ai đó cần SecureStorageService, hãy tạo 1 instance"
  @lazySingleton
  SecureStorageService get storageService => SecureStorageService();
}
