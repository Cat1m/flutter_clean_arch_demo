// lib/core/ai/firebase_ai_translation_service.dart

import 'package:dartz/dartz.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reqres_in/src/core/ai/translation_prompt.dart';
import 'package:reqres_in/src/core/ai/translation_service.dart';
import 'package:reqres_in/src/core/network/failures.dart';

/// Bản đang thực sự chạy trong app: dịch qua Firebase AI Logic — không lộ
/// API key phía client, Firebase quản lý xác thực/quota ở backend.
@LazySingleton(as: TranslationService)
class FirebaseAiTranslationService implements TranslationService {
  late final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3.5-flash',
  );

  @override
  Future<Either<Failure, String>> translate({
    required String text,
    String targetLanguage = 'Tiếng Việt',
  }) async {
    final prompt = buildTranslatePrompt(text, targetLanguage);

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final translated = response.text?.trim();
      if (translated == null || translated.isEmpty) {
        return const Left(UnknownFailure('Firebase AI trả về nội dung rỗng'));
      }
      return Right(translated);
    } on QuotaExceeded catch (e) {
      return Left(ServerFailure('Hết hạn mức Gemini: ${e.message}'));
    } on ServiceApiNotEnabled catch (e) {
      return Left(ServerFailure('Firebase AI Logic chưa được bật: ${e.message}'));
    } on FirebaseAIException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e, st) {
      debugPrint('[FirebaseAiTranslationService] LỖI THẬT: $e\n$st');
      return Left(ConnectionFailure('Không thể kết nối Firebase AI: $e'));
    }
  }
}
