import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/network/failures.dart';
import 'package:reqres_in/src/features/quote/models/quote_model.dart';
import 'package:reqres_in/src/features/quote/repositories/quote_repository.dart';
import 'package:reqres_in/src/shared/data/remote/api_service.dart';

@LazySingleton(as: QuoteRepository)
class QuoteRepositoryImpl implements QuoteRepository {
  final ApiService _apiService;

  QuoteRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, QuoteModel>> getRandomQuote() async {
    try {
      // 1. Gọi API
      final quote = await _apiService.getRandomQuote();
      // 2. Trả về thành công
      return Right(quote);

      // ✅ BẮT LỖI (giống hệt file auth_repository_impl.dart của bạn)
    } on DioException catch (e) {
      if (e.error is Failure) {
        return Left(e.error as Failure);
      } else {
        return Left(UnknownFailure('Lỗi Dio không xác định: ${e.message}'));
      }
    } catch (e) {
      return Left(UnknownFailure('Lỗi hệ thống: ${e.toString()}'));
    }
  }
}
