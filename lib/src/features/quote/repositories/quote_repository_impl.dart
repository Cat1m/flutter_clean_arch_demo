import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/network/network.dart';
import 'package:reqres_in/src/features/quote/models/quote_model.dart';
import 'package:reqres_in/src/features/quote/repositories/quote_repository.dart';
import 'package:reqres_in/src/shared/data/remote/api_service.dart';

@LazySingleton(as: QuoteRepository)
class QuoteRepositoryImpl with BaseRepository implements QuoteRepository {
  final ApiService _apiService;

  QuoteRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, QuoteModel>> getRandomQuote() =>
      safeApiCall(() => _apiService.getRandomQuote());
}
