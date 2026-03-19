import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reqres_in/src/core/error/error_event.dart';
import 'package:reqres_in/src/core/error/error_event_service.dart';
import 'package:reqres_in/src/core/error/error_severity.dart';
import 'package:reqres_in/src/core/network/failures.dart';

void main() {
  late ErrorEventService service;

  setUp(() {
    service = ErrorEventService();
  });

  tearDown(() {
    service.dispose();
  });

  ErrorEvent createEvent({
    Failure failure = const ServerFailure('Test', statusCode: 500),
    ErrorSeverity severity = ErrorSeverity.critical,
  }) {
    return ErrorEvent(failure: failure, severity: severity);
  }

  group('ErrorEventService', () {
    test('emit event → stream nhận đúng event', () async {
      final event = createEvent();

      // Set up expectation trước, emit sau — expectLater không block
      final future = expectLater(service.errorStream, emits(event));
      service.emit(event);
      await future;
    });

    test('multiple listeners nhận cùng event (broadcast)', () async {
      final event = createEvent();
      final completer1 = Completer<ErrorEvent>();
      final completer2 = Completer<ErrorEvent>();

      service.errorStream.listen(completer1.complete);
      service.errorStream.listen(completer2.complete);

      service.emit(event);

      final result1 = await completer1.future;
      final result2 = await completer2.future;

      expect(result1, equals(event));
      expect(result2, equals(event));
    });

    test('emit nhiều events → stream nhận đúng thứ tự', () async {
      final event1 = createEvent(
        failure: const ServerFailure('Error 1', statusCode: 500),
      );
      final event2 = createEvent(
        failure: const ConnectionFailure('No Internet'),
        severity: ErrorSeverity.warning,
      );

      final future = expectLater(
        service.errorStream,
        emitsInOrder([event1, event2]),
      );
      service.emit(event1);
      service.emit(event2);
      await future;
    });

    test('dispose → stream đóng, emit không crash', () async {
      final future = expectLater(service.errorStream, emitsDone);
      service.dispose();
      await future;

      // Emit sau dispose không throw
      service.emit(createEvent());
    });
  });
}
