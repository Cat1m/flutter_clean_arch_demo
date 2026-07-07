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

/// Trạng thái tải thành công nhưng nội dung quote trống.
final class QuoteEmpty extends QuoteState {}

final class QuoteFailure extends QuoteState {
  final Failure failure;
  const QuoteFailure(this.failure);
  @override
  List<Object> get props => [failure];
}
