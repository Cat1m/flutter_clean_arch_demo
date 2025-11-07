import 'package:dartz/dartz.dart';
import 'package:reqres_in/src/core/network/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> login(String email, String password);
}
