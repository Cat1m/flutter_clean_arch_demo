import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/features/quote/models/quote_model.dart';
import 'package:reqres_in/src/features/quote/repositories/quote_repository.dart';

part 'quote_state.dart';

@injectable // tương đương với factory
class QuoteCubit extends Cubit<QuoteState> {
  final QuoteRepository _quoteRepository;

  QuoteCubit(this._quoteRepository) : super(QuoteInitial());

  Future<void> fetchRandomQuote() async {
    emit(QuoteLoading());

    final result = await _quoteRepository.getRandomQuote();

    result.fold(
      (failure) => emit(QuoteError(failure.message)),
      (quote) => emit(QuoteSuccess(quote)),
    );
  }
}
