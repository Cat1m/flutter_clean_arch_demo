import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reqres_in/src/core/error/error_event.dart';
import 'package:reqres_in/src/core/error/error_event_service.dart';
import 'package:reqres_in/src/core/error/error_severity.dart';
import 'package:reqres_in/src/core/network/error_interceptor.dart';
import 'package:reqres_in/src/core/network/failures.dart';

void main() {
  late ErrorEventService errorEventService;
  late ErrorInterceptor interceptor;

  setUp(() {
    errorEventService = ErrorEventService();
    interceptor = ErrorInterceptor(errorEventService: errorEventService);
  });

  tearDown(() {
    errorEventService.dispose();
  });

  RequestOptions options() => RequestOptions(path: '/test');

  group('ErrorInterceptor auto-emit', () {
    test('ServerFailure 500 → emit critical lên Error Bus', () async {
      final completer = Completer<ErrorEvent>();
      errorEventService.errorStream.listen(completer.complete);

      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: options(),
        response: Response(
          requestOptions: options(),
          statusCode: 500,
          data: <String, dynamic>{'message': 'Internal Server Error'},
        ),
        type: DioExceptionType.badResponse,
      );

      interceptor.onError(err, handler);

      final event = await completer.future.timeout(const Duration(seconds: 1));

      expect(event.failure, isA<ServerFailure>());
      expect(event.severity, ErrorSeverity.critical);
      expect(event.source, 'ErrorInterceptor');
    });

    test('ServerFailure 503 → emit critical lên Error Bus', () async {
      final completer = Completer<ErrorEvent>();
      errorEventService.errorStream.listen(completer.complete);

      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: options(),
        response: Response(
          requestOptions: options(),
          statusCode: 503,
          data: <String, dynamic>{'message': 'Service Unavailable'},
        ),
        type: DioExceptionType.badResponse,
      );

      interceptor.onError(err, handler);

      final event = await completer.future.timeout(const Duration(seconds: 1));

      expect(event.failure, isA<ServerFailure>());
      expect((event.failure as ServerFailure).statusCode, 503);
      expect(event.severity, ErrorSeverity.critical);
    });

    test('ServerFailure 400 → KHÔNG emit (business error)', () async {
      ErrorEvent? captured;
      errorEventService.errorStream.listen((e) => captured = e);

      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: options(),
        response: Response(
          requestOptions: options(),
          statusCode: 400,
          data: <String, dynamic>{'message': 'Bad Request'},
        ),
        type: DioExceptionType.badResponse,
      );

      interceptor.onError(err, handler);

      // Đợi 1 event loop để đảm bảo stream đã xử lý
      await Future<void>.delayed(Duration.zero);

      expect(captured, isNull);
    });

    test('AuthFailure 401 → KHÔNG emit (chờ Lần 2 migrate)', () async {
      ErrorEvent? captured;
      errorEventService.errorStream.listen((e) => captured = e);

      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: options(),
        response: Response(requestOptions: options(), statusCode: 401),
        type: DioExceptionType.badResponse,
      );

      interceptor.onError(err, handler);
      await Future<void>.delayed(Duration.zero);

      expect(captured, isNull);
    });

    test('ConnectionFailure → KHÔNG emit (chờ Lần 2 migrate)', () async {
      ErrorEvent? captured;
      errorEventService.errorStream.listen((e) => captured = e);

      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: options(),
        type: DioExceptionType.connectionTimeout,
      );

      interceptor.onError(err, handler);
      await Future<void>.delayed(Duration.zero);

      expect(captured, isNull);
    });

    test('onError vẫn reject DioException như bình thường', () {
      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: options(),
        response: Response(
          requestOptions: options(),
          statusCode: 500,
          data: <String, dynamic>{'message': 'Server Error'},
        ),
        type: DioExceptionType.badResponse,
      );

      interceptor.onError(err, handler);

      // Verify handler.reject was called
      expect(handler.rejected, isTrue);
      expect(handler.rejectedError?.error, isA<ServerFailure>());
    });

    test('không có ErrorEventService → không crash', () {
      final interceptorNoService = ErrorInterceptor();
      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: options(),
        response: Response(
          requestOptions: options(),
          statusCode: 500,
          data: <String, dynamic>{'message': 'Server Error'},
        ),
        type: DioExceptionType.badResponse,
      );

      // Không throw
      interceptorNoService.onError(err, handler);
      expect(handler.rejected, isTrue);
    });
  });
}

/// Minimal mock cho ErrorInterceptorHandler.
class _MockErrorHandler extends ErrorInterceptorHandler {
  bool rejected = false;
  DioException? rejectedError;

  @override
  void reject(DioException error) {
    rejected = true;
    rejectedError = error;
  }
}
