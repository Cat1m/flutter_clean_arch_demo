import 'package:dio/dio.dart';
import 'package:reqres_in/src/core/auth/auth_type.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/user_model.dart';

part 'user_client.g.dart';

@RestApi()
abstract class UserClient {
  factory UserClient(Dio dio, {String baseUrl}) = _UserClient;

  // Chỉ chứa API liên quan đến User
  @GET('/auth/me')
  @userToken
  Future<User> getMe();
}
