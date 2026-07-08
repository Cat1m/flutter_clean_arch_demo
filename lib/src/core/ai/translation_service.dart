// lib/core/ai/translation_service.dart

import 'package:dartz/dartz.dart';
import 'package:reqres_in/src/core/network/failures.dart';

/// Interface cho dịch vụ dịch văn bản bằng AI.
///
/// Hiện thực đang chạy trong app: `FirebaseAiTranslationService` — gọi qua
/// Firebase AI Logic, không lộ API key phía client (Firebase quản lý xác
/// thực/quota ở backend). Xem `core/ai/README.md` để biết chi tiết.
abstract class TranslationService {
  Future<Either<Failure, String>> translate({
    required String text,
    String targetLanguage = 'Tiếng Việt',
  });
}
