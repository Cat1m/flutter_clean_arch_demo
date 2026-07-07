import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reqres_in/src/core/error/error_event.dart';
import 'package:reqres_in/src/core/error/error_event_service.dart';
import 'package:reqres_in/src/core/error/error_severity.dart';
import 'package:reqres_in/src/core/network/failures.dart' as network;
import 'package:reqres_in/src/features/auth/models/auth_models.dart';
import 'package:reqres_in/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:reqres_in/src/features/auth/presentation/bloc/login_cubit.dart';
import 'package:reqres_in/src/features/auth/repository/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late ErrorEventService errorEventService;

  const loginResponse = LoginResponse(
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

  setUp(() {
    repository = MockAuthRepository();
    errorEventService = ErrorEventService();
  });

  tearDown(() {
    errorEventService.dispose();
  });

  group('LoginCubit', () {
    blocTest<LoginCubit, AuthState>(
      'login thành công → AuthLoading rồi AuthSuccess',
      build: () {
        when(
          () => repository.login('emilys', 'emilyspass', false),
        ).thenAnswer((_) async => const Right(loginResponse));
        return LoginCubit(repository, errorEventService);
      },
      act: (cubit) => cubit.login('emilys', 'emilyspass', false),
      expect: () => [isA<AuthLoading>(), const AuthSuccess(loginResponse)],
    );

    blocTest<LoginCubit, AuthState>(
      'login thất bại → AuthLoading rồi AuthFailure chứa đúng Failure gốc',
      build: () {
        when(() => repository.login('emilys', 'wrong', false)).thenAnswer(
          (_) async => const Left(network.AuthFailure.invalidCredentials),
        );
        return LoginCubit(repository, errorEventService);
      },
      act: (cubit) => cubit.login('emilys', 'wrong', false),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
          (s) => s.failure,
          'failure',
          isA<network.AuthFailure>(),
        ),
      ],
    );

    blocTest<LoginCubit, AuthState>(
      'nhận fatal AuthFailure từ Error Bus → AuthSessionExpired',
      build: () => LoginCubit(repository, errorEventService),
      act: (cubit) {
        errorEventService.emit(
          ErrorEvent(
            failure: network.AuthFailure.tokenExpired,
            severity: ErrorSeverity.fatal,
            source: 'TokenInterceptor',
          ),
        );
      },
      expect: () => [const AuthSessionExpired()],
    );
  });
}
