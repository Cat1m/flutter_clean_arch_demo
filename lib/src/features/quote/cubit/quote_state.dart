part of 'quote_cubit.dart'; // Sẽ được import vào file cubit

sealed class QuoteState extends Equatable {
  const QuoteState();
  @override
  List<Object> get props => [];
}

final class QuoteInitial extends QuoteState {}

final class QuoteLoading extends QuoteState {}

final class QuoteSuccess extends QuoteState {
  final QuoteModel quote;
  const QuoteSuccess(this.quote);
  @override
  List<Object> get props => [quote];
}

final class QuoteError extends QuoteState {
  final String message;
  const QuoteError(this.message);
  @override
  List<Object> get props => [message];
}
