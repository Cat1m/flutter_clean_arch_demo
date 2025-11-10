import 'package:dartz/dartz.dart';
import 'package:reqres_in/src/core/network/failures.dart';
import 'package:reqres_in/src/features/quote/models/quote_model.dart';

abstract class QuoteRepository {
  Future<Either<Failure, QuoteModel>> getRandomQuote();
}
