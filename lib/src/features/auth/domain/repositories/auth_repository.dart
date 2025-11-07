import 'package:dartz/dartz.dart';
import 'package:reqres_in/src/core/network/failures.dart';
import 'package:reqres_in/src/features/auth/data/models/auth_models.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponse>> login(String email, String password);
}
