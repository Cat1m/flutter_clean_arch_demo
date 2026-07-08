// lib/core/ai/translation_prompt.dart

/// Prompt dùng chung cho mọi cách gọi AI dịch văn bản (REST thô lẫn Firebase
/// AI Logic), để đảm bảo cả 2 luôn hỏi model theo đúng 1 kiểu.
String buildTranslatePrompt(String text, String targetLanguage) {
  return 'Dịch câu sau sang $targetLanguage, chỉ trả lời đúng bản dịch, '
      'không thêm giải thích hay dấu ngoặc kép: "$text"';
}
