import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/ai/translation_service.dart';
import 'package:reqres_in/src/core/network/failures.dart';
import 'package:reqres_in/src/features/quote/models/quote_model.dart';
import 'package:reqres_in/src/features/quote/repositories/quote_repository.dart';

part 'quote_state.dart';

@injectable // tương đương với factory
class QuoteCubit extends Cubit<QuoteState> {
  final QuoteRepository _quoteRepository;
  final TranslationService _translationService;

  QuoteCubit(this._quoteRepository, this._translationService)
    : super(QuoteInitial());

  Future<void> fetchRandomQuote() async {
    emit(QuoteLoading());

    final result = await _quoteRepository.getRandomQuote();

    result.fold(
      (failure) => emit(QuoteFailure(failure)),
      (quote) =>
          emit(quote.quote.trim().isEmpty ? QuoteEmpty() : QuoteSuccess(quote)),
    );
  }

  /// Dịch quote hiện tại sang tiếng Việt bằng Gemini AI.
  Future<void> translateQuote() async {
    final current = state;
    if (current is! QuoteSuccess) return;

    emit(current.copyWith(isTranslating: true, translateFailure: null));

    final result = await _translationService.translate(text: current.quote.quote);

    // Nếu trong lúc dịch, user đã fetch quote khác thì bỏ qua kết quả cũ.
    final latest = state;
    if (latest is! QuoteSuccess || latest.quote != current.quote) return;

    result.fold(
      (failure) => emit(
        latest.copyWith(isTranslating: false, translateFailure: failure),
      ),
      (translated) => emit(
        latest.copyWith(isTranslating: false, translatedQuote: translated),
      ),
    );
  }
}
