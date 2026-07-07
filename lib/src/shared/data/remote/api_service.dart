import 'package:dio/dio.dart';
// 1. Import các Config (Auth & Log) từ Core
import 'package:reqres_in/src/core/auth/auth_type.dart';
// 2. Import Models từ Feature (Chấp nhận Inverse Dependency ở quy mô nhỏ)
import 'package:reqres_in/src/features/auth/models/auth_models.dart';
import 'package:reqres_in/src/features/quote/models/quote_model.dart';
import 'package:reqres_in/src/features/user/models/user_model.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio) = _ApiService;

  // ---------------------------------------------------------------------------
  // region Authentication
  // ---------------------------------------------------------------------------

  @POST('/auth/login')
  @noAuth
  Future<LoginResponse> login(@Body() LoginRequest body);

  @POST('/auth/refresh')
  @noAuth
  Future<RefreshResponse> refresh(@Body() RefreshRequest body);

  // endregion

  // ---------------------------------------------------------------------------
  // region User
  // ---------------------------------------------------------------------------

  @GET('/auth/me')
  @userToken
  Future<User> getMe();

  // endregion

  // ---------------------------------------------------------------------------
  // region Quotes
  // ---------------------------------------------------------------------------

  @GET('/quotes/random')
  @noAuth
  // Không gắn tag Log -> Mặc định là Basic (do LoggerInterceptor config)
  Future<QuoteModel> getRandomQuote();
  // endregion
}
