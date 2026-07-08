import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reqres_in/src/core/ui/theme/app_theme.dart';
import 'package:reqres_in/src/features/auth/models/auth_models.dart';
import 'package:reqres_in/src/features/home/presentation/pages/home_view.dart';
import 'package:reqres_in/src/features/quote/cubit/quote_cubit.dart';
import 'package:reqres_in/src/features/quote/repositories/quote_repository.dart';

class MockQuoteRepository extends Mock implements QuoteRepository {}

void main() {
  const userData = LoginResponse(
    id: 1,
    username: 'emilys',
    email: 'emily@x.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    gender: 'female',
    image: 'https://x/img.png',
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
  );

  testWidgets(
    'hiển thị đúng tên/username của userData và nhúng RandomQuoteWidget',
    (tester) async {
      final quoteCubit = QuoteCubit(MockQuoteRepository());
      addTearDown(quoteCubit.close);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: BlocProvider<QuoteCubit>.value(
            value: quoteCubit,
            child: const HomeView(userData: userData),
          ),
        ),
      );

      expect(find.text('Chào mừng trở lại'), findsOneWidget);
      expect(find.text('Emily Johnson'), findsOneWidget);
    },
  );
}
