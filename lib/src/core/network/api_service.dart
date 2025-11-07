import 'package:dio/dio.dart';
import 'package:reqres_in/src/core/network/auth_type.dart';
import 'package:retrofit/retrofit.dart';
// Import Models từ các features cần thiết (hoặc để models chung ở core nếu muốn)
import '../../features/auth/data/models/auth_models.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio) = _ApiService;

  // --- Auth Endpoints ---
  @apiKey
  @POST('/login')
  Future<LoginResponse> login(@Body() LoginRequest body);

  // @POST('/register')
  // Future<RegisterResponse> register(@Body() RegisterRequest body);

  // --- User Endpoints ---
  // @GET('/users/{id}')
  // Future<UserResponse> getUser(@Path('id') int id);
}
