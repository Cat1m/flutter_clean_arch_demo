// test/core/network/certificate_test.dart
//
// Test certificate handling:
// 1. Unit test: ErrorInterceptor map badCertificate → CertificateFailure
// 2. Integration test: DioClient + badssl.com endpoints

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reqres_in/src/core/error/error_event.dart';
import 'package:reqres_in/src/core/error/error_event_service.dart';
import 'package:reqres_in/src/core/error/error_severity.dart';
import 'package:reqres_in/src/core/network/dio_client.dart';
import 'package:reqres_in/src/core/network/error_interceptor.dart';
import 'package:reqres_in/src/core/network/failures.dart';

void main() {
  // ---------------------------------------------------------------------------
  // 1. Unit Test: ErrorInterceptor mapping
  // ---------------------------------------------------------------------------
  group('ErrorInterceptor — CertificateFailure', () {
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

    test('badCertificate → CertificateFailure (không phải UnknownFailure)', () {
      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: options(),
        type: DioExceptionType.badCertificate,
      );

      interceptor.onError(err, handler);

      expect(handler.rejected, isTrue);
      expect(handler.rejectedError?.error, isA<CertificateFailure>());
      expect(
        (handler.rejectedError?.error as CertificateFailure).message,
        'Bad Certificate',
      );
    });

    test('badCertificate → emit critical lên Error Bus', () async {
      final completer = Completer<ErrorEvent>();
      errorEventService.errorStream.listen(completer.complete);

      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: options(),
        type: DioExceptionType.badCertificate,
      );

      interceptor.onError(err, handler);

      final event = await completer.future.timeout(const Duration(seconds: 1));

      expect(event.failure, isA<CertificateFailure>());
      expect(event.severity, ErrorSeverity.critical);
      expect(event.source, 'ErrorInterceptor');
    });
  });

  // ---------------------------------------------------------------------------
  // 2. Unit Test: CertificateFailure properties
  // ---------------------------------------------------------------------------
  group('CertificateFailure', () {
    test('predefined constants', () {
      expect(CertificateFailure.badCertificate.message, 'Bad Certificate');
      expect(CertificateFailure.untrusted.message, 'Untrusted Certificate');
    });

    test('helper isCertificateError works', () {
      const Failure failure = CertificateFailure('test');
      expect(failure.isCertificateError, isTrue);
      expect(failure.isServerError, isFalse);
      expect(failure.isNetworkError, isFalse);
    });

    test('copyWith preserves/overrides message', () {
      const original = CertificateFailure('original');
      final copied = original.copyWith(message: 'changed');
      expect(copied.message, 'changed');

      final unchanged = original.copyWith();
      expect(unchanged.message, 'original');
    });

    test('Equatable works', () {
      const a = CertificateFailure('Bad Certificate');
      const b = CertificateFailure('Bad Certificate');
      const c = CertificateFailure('Different');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  // ---------------------------------------------------------------------------
  // 3. Integration Test: DioClient + badssl.com (cần internet)
  // ---------------------------------------------------------------------------
  group(
    'DioClient — Certificate Integration (badssl.com)',
    () {
      test(
        'allowBadCertificate = false → self-signed cert bị reject',
        () async {
          final client = DioClient(
            baseUrl: 'https://self-signed.badssl.com',
            allowBadCertificate: false, // Mặc định, reject cert lỗi
          );

          try {
            await client.dio.get<dynamic>('/');
            fail('Phải throw DioException với badCertificate');
          } on DioException catch (e) {
            // Dio reject cert → badCertificate
            // ErrorInterceptor map → CertificateFailure
            expect(e.error, isA<CertificateFailure>());
          }
        },
      );

      test(
        'allowBadCertificate = true → self-signed cert được chấp nhận',
        () async {
          final client = DioClient(
            baseUrl: 'https://self-signed.badssl.com',
            allowBadCertificate: true, // Cho phép cert lỗi (dev mode)
          );

          // Không throw, request thành công (dù cert self-signed)
          final response = await client.dio.get<dynamic>('/');
          expect(response.statusCode, 200);
        },
      );

      test('allowBadCertificate = false → expired cert bị reject', () async {
        final client = DioClient(
          baseUrl: 'https://expired.badssl.com',
          allowBadCertificate: false,
        );

        try {
          await client.dio.get<dynamic>('/');
          fail('Phải throw DioException với badCertificate');
        } on DioException catch (e) {
          expect(e.error, isA<CertificateFailure>());
        }
      });

      test(
        'allowBadCertificate = true → expired cert được chấp nhận',
        () async {
          final client = DioClient(
            baseUrl: 'https://expired.badssl.com',
            allowBadCertificate: true,
          );

          final response = await client.dio.get<dynamic>('/');
          expect(response.statusCode, 200);
        },
      );

      test('allowBadCertificate = false → wrong host cert bị reject', () async {
        final client = DioClient(
          baseUrl: 'https://wrong.host.badssl.com',
          allowBadCertificate: false,
        );

        try {
          await client.dio.get<dynamic>('/');
          fail('Phải throw DioException với badCertificate');
        } on DioException catch (e) {
          expect(e.error, isA<CertificateFailure>());
        }
      });

      test(
        'cert hợp lệ (badssl.com chính) → luôn thành công dù allowBadCertificate = false',
        () async {
          final client = DioClient(
            baseUrl: 'https://badssl.com',
            allowBadCertificate: false,
          );

          final response = await client.dio.get<dynamic>('/');
          expect(response.statusCode, 200);
        },
      );
    },
    // Cần internet để chạy. Skip bằng:
    // flutter test --dart-define=SKIP_INTEGRATION=true
    skip: const bool.fromEnvironment('SKIP_INTEGRATION')
        ? 'Bỏ qua integration test (không có internet)'
        : null,
  );
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
