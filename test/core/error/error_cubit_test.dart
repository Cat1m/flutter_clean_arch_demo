import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reqres_in/src/core/error/error_cubit.dart';
import 'package:reqres_in/src/core/error/error_event.dart';
import 'package:reqres_in/src/core/error/error_event_service.dart';
import 'package:reqres_in/src/core/error/error_severity.dart';
import 'package:reqres_in/src/core/error/error_state.dart';
import 'package:reqres_in/src/core/network/failures.dart';

void main() {
  late ErrorEventService eventService;

  setUp(() {
    eventService = ErrorEventService();
  });

  tearDown(() {
    eventService.dispose();
  });

  ErrorEvent createEvent({
    Failure failure = const ServerFailure('Test', statusCode: 500),
    ErrorSeverity severity = ErrorSeverity.critical,
    String? source,
  }) {
    return ErrorEvent(
      failure: failure,
      severity: severity,
      source: source,
    );
  }

  group('ErrorCubit', () {
    blocTest<ErrorCubit, ErrorState>(
      'initial state là ErrorIdle',
      build: () => ErrorCubit(eventService),
      verify: (cubit) => expect(cubit.state, const ErrorIdle()),
    );

    blocTest<ErrorCubit, ErrorState>(
      'nhận event → emit ErrorReceived',
      build: () => ErrorCubit(eventService),
      act: (cubit) {
        eventService.emit(createEvent());
      },
      expect: () => [isA<ErrorReceived>()],
    );

    blocTest<ErrorCubit, ErrorState>(
      'dismiss() → emit ErrorIdle',
      build: () => ErrorCubit(eventService),
      act: (cubit) async {
        eventService.emit(createEvent());
        // Đợi stream event được xử lý trước khi dismiss
        await Future<void>.delayed(Duration.zero);
        cubit.dismiss();
      },
      expect: () => [isA<ErrorReceived>(), const ErrorIdle()],
    );

    blocTest<ErrorCubit, ErrorState>(
      'dedup: 2 cùng failure type trong 3s → chỉ emit 1 lần',
      build: () => ErrorCubit.withConfig(
        eventService,
        dedupWindow: const Duration(seconds: 3),
      ),
      act: (cubit) {
        // Cả 2 đều là ServerFailure
        eventService.emit(createEvent(
          failure: const ServerFailure('Error 1', statusCode: 500),
        ));
        eventService.emit(createEvent(
          failure: const ServerFailure('Error 2', statusCode: 503),
        ));
      },
      expect: () => [isA<ErrorReceived>()],
      // Chỉ 1 ErrorReceived, cái thứ 2 bị dedup
    );

    blocTest<ErrorCubit, ErrorState>(
      'dedup: 2 failure type KHÁC nhau trong 3s → emit cả 2',
      build: () => ErrorCubit.withConfig(
        eventService,
        dedupWindow: const Duration(seconds: 3),
      ),
      act: (cubit) {
        eventService.emit(createEvent(
          failure: const ServerFailure('Server Error', statusCode: 500),
        ));
        eventService.emit(createEvent(
          failure: const ConnectionFailure('No Internet'),
          severity: ErrorSeverity.warning,
        ));
      },
      expect: () => [isA<ErrorReceived>(), isA<ErrorReceived>()],
    );

    blocTest<ErrorCubit, ErrorState>(
      'dedup: cùng type nhưng sau time window → emit lại',
      build: () => ErrorCubit.withConfig(
        eventService,
        // Window cực ngắn để test
        dedupWindow: Duration.zero,
      ),
      act: (cubit) async {
        eventService.emit(createEvent(
          failure: const ServerFailure('Error 1', statusCode: 500),
        ));
        // Đợi 1ms để vượt qua dedupWindow = 0
        await Future<void>.delayed(const Duration(milliseconds: 1));
        eventService.emit(createEvent(
          failure: const ServerFailure('Error 2', statusCode: 500),
        ));
      },
      expect: () => [isA<ErrorReceived>(), isA<ErrorReceived>()],
    );

    blocTest<ErrorCubit, ErrorState>(
      'ErrorReceived chứa đúng event data',
      build: () => ErrorCubit(eventService),
      act: (cubit) {
        eventService.emit(createEvent(
          failure: const AuthFailure('Session expired', statusCode: 401),
          severity: ErrorSeverity.fatal,
          source: 'TokenInterceptor',
        ));
      },
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<ErrorReceived>());
        final received = state as ErrorReceived;
        expect(received.event.failure, isA<AuthFailure>());
        expect(received.event.severity, ErrorSeverity.fatal);
        expect(received.event.source, 'TokenInterceptor');
      },
    );
  });
}
