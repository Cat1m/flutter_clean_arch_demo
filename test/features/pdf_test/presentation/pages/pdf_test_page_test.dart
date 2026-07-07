import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reqres_in/src/features/pdf_test/presentation/pages/pdf_test_page.dart';

void main() {
  testWidgets(
    'hiển thị đúng UI ban đầu: tiêu đề, mô tả, nút bấm, chưa loading',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PdfTestPage()));

      expect(find.text('Tạo CV mẫu'), findsOneWidget);
      expect(find.text('Demo tính năng xuất PDF'), findsOneWidget);
      expect(find.text('Xem giao diện đẹp'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );
}
