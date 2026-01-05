import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// 2. Import Models từ Feature (Chấp nhận Inverse Dependency ở quy mô nhỏ)
import '../../features/auth/models/auth_models.dart';
import '../../features/quote/models/quote_model.dart';
import '../../features/user/models/user_model.dart';
// 1. Import các Config (Auth & Log) từ Core
import 'models/auth_type.dart';
import 'models/log_mode.dart';

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
