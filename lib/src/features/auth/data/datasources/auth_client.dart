import 'package:dio/dio.dart';
import 'package:reqres_in/src/core/auth/auth_type.dart';
import 'package:retrofit/retrofit.dart';

// Import Model nội bộ của Feature Auth (Đúng nguyên tắc)
import '../../models/auth_models.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String baseUrl}) = _AuthClient;

  // Chỉ chứa API liên quan đến Auth
  @POST('/auth/login')
  @noAuth
  Future<LoginResponse> login(@Body() LoginRequest body);

  @POST('/auth/refresh')
  @noAuth
  Future<RefreshResponse> refresh(@Body() RefreshRequest body);
}
