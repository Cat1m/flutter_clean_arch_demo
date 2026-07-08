import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqres_in/src/core/ui/ui.dart';
import 'package:reqres_in/src/features/quote/cubit/quote_cubit.dart';

class RandomQuoteWidget extends StatelessWidget {
  const RandomQuoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Widget này sẽ lắng nghe QuoteCubit (được cung cấp ở HomePage)
    return BlocBuilder<QuoteCubit, QuoteState>(
      builder: (context, state) {
        return switch (state) {
          // 1. Đang tải
          QuoteLoading() => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimens.s16),
              child: CircularProgressIndicator(),
            ),
          ),

          // 2. Tải thành công
          QuoteSuccess() => _QuoteCard(state: state),

          // 3. Bị lỗi
          QuoteFailure(failure: final failure) => AppErrorView(
            failure: failure,
            onRetry: () =>
                unawaited(context.read<QuoteCubit>().fetchRandomQuote()),
          ),

          // 4. Tải thành công nhưng nội dung trống
          QuoteEmpty() => const AppEmptyView(
            message: 'Không có quote nào để hiển thị',
          ),

          // 5. Trạng thái ban đầu (hoặc không hiển thị gì)
          QuoteInitial() => const SizedBox.shrink(),
        };
      },
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final QuoteSuccess state;

  const _QuoteCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.s16),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.s16),
        child: Column(
          children: [
            Text(
              '"${state.quote.quote}"',
              textAlign: TextAlign.center,
              style: context.text.body1.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: AppDimens.s12),
            Text(
              '— ${state.quote.author}',
              style: context.text.body2.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: AppDimens.s16),
            _buildTranslateSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslateSection(BuildContext context) {
    if (state.translatedQuote != null) {
      return Column(
        children: [
          const Divider(),
          const SizedBox(height: AppDimens.s8),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: AppDimens.s8,
            children: [AppBadge(label: 'Gemini AI')],
          ),
          const SizedBox(height: AppDimens.s8),
          Text(
            state.translatedQuote!,
            textAlign: TextAlign.center,
            style: context.text.body2.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      );
    }

    if (state.translateFailure != null) {
      return AppErrorView(
        failure: state.translateFailure!,
        onRetry: () =>
            unawaited(context.read<QuoteCubit>().translateQuote()),
      );
    }

    return AppButton(
      text: 'Dịch sang Tiếng Việt',
      icon: Icons.translate,
      isExpanded: false,
      isLoading: state.isTranslating,
      onPressed: () => unawaited(context.read<QuoteCubit>().translateQuote()),
    );
  }
}
