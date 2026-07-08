part of 'quote_cubit.dart'; // Sẽ được import vào file cubit

sealed class QuoteState extends Equatable {
  const QuoteState();
  @override
  List<Object?> get props => [];
}

final class QuoteInitial extends QuoteState {}

final class QuoteLoading extends QuoteState {}

final class QuoteSuccess extends QuoteState {
  final QuoteModel quote;
  final bool isTranslating;
  final String? translatedQuote;
  final Failure? translateFailure;

  const QuoteSuccess(
    this.quote, {
    this.isTranslating = false,
    this.translatedQuote,
    this.translateFailure,
  });

  QuoteSuccess copyWith({
    bool? isTranslating,
    String? translatedQuote,
    Failure? translateFailure,
  }) {
    return QuoteSuccess(
      quote,
      isTranslating: isTranslating ?? this.isTranslating,
      translatedQuote: translatedQuote ?? this.translatedQuote,
      translateFailure: translateFailure,
    );
  }

  @override
  List<Object?> get props => [
    quote,
    isTranslating,
    translatedQuote,
    translateFailure,
  ];
}

/// Trạng thái tải thành công nhưng nội dung quote trống.
final class QuoteEmpty extends QuoteState {}

final class QuoteFailure extends QuoteState {
  final Failure failure;
  const QuoteFailure(this.failure);
  @override
  List<Object> get props => [failure];
}
