import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reqres_in/src/core/network/failures.dart';
import 'package:reqres_in/src/features/quote/cubit/quote_cubit.dart';
import 'package:reqres_in/src/features/quote/models/quote_model.dart';
import 'package:reqres_in/src/features/quote/repositories/quote_repository.dart';

class MockQuoteRepository extends Mock implements QuoteRepository {}

void main() {
  late MockQuoteRepository repository;

  const quote = QuoteModel(
    id: 1,
    quote: 'Stay hungry, stay foolish.',
    author: 'Steve Jobs',
  );

  setUp(() {
    repository = MockQuoteRepository();
  });

  group('QuoteCubit', () {
    blocTest<QuoteCubit, QuoteState>(
      'fetch thành công, có nội dung → QuoteLoading rồi QuoteSuccess',
      build: () {
        when(() => repository.getRandomQuote()).thenAnswer(
          (_) async => const Right(quote),
        );
        return QuoteCubit(repository);
      },
      act: (cubit) => cubit.fetchRandomQuote(),
      expect: () => [isA<QuoteLoading>(), const QuoteSuccess(quote)],
    );

    blocTest<QuoteCubit, QuoteState>(
      'fetch thành công nhưng nội dung quote trống → QuoteEmpty',
      build: () {
        when(() => repository.getRandomQuote()).thenAnswer(
          (_) async =>
              const Right(QuoteModel(id: 2, quote: '   ', author: 'Nobody')),
        );
        return QuoteCubit(repository);
      },
      act: (cubit) => cubit.fetchRandomQuote(),
      expect: () => [isA<QuoteLoading>(), isA<QuoteEmpty>()],
    );

    blocTest<QuoteCubit, QuoteState>(
      'fetch thất bại → QuoteLoading rồi QuoteFailure chứa đúng Failure gốc',
      build: () {
        when(() => repository.getRandomQuote()).thenAnswer(
          (_) async => const Left(ConnectionFailure.noInternet),
        );
        return QuoteCubit(repository);
      },
      act: (cubit) => cubit.fetchRandomQuote(),
      expect: () => [
        isA<QuoteLoading>(),
        isA<QuoteFailure>().having(
          (s) => s.failure,
          'failure',
          isA<ConnectionFailure>(),
        ),
      ],
    );
  });
}
