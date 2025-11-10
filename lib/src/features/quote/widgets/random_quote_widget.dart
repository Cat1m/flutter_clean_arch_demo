import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqres_in/src/features/quote/cubit/quote_cubit.dart';

class RandomQuoteWidget extends StatelessWidget {
  const RandomQuoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Widget này sẽ lắng nghe QuoteCubit (được cung cấp ở HomePage)
    return BlocBuilder<QuoteCubit, QuoteState>(
      builder: (context, state) {
        return switch (state) {
          // 1. Đang tải
          QuoteLoading() => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),

          // 2. Tải thành công
          QuoteSuccess() => Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '"${state.quote.quote}"',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '— ${state.quote.author}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bị lỗi
          QuoteError() => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tải quote thất bại: ${state.message}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),

          // 4. Trạng thái ban đầu (hoặc không hiển thị gì)
          QuoteInitial() => const SizedBox.shrink(),
        };
      },
    );
  }
}
