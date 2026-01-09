import 'package:flutter/material.dart';
import 'package:reqres_in/src/core/ui/ui.dart';
import 'package:reqres_in/src/features/pdf_test/presentation/pages/pdf_preview_page.dart'; // Import trang preview
import 'package:reqres_in/src/features/pdf_test/presentation/templates/cv_template.dart';

class PdfTestPage extends StatelessWidget {
  const PdfTestPage({super.key});

  void _openPdfPreview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewPage(
          fileName: 'CV_NguyenVanA',
          // Truyền hàm generate vào (Callback)
          builder: (config) => CvTemplate.generate(
            config: config,
            fullName: 'Nguyễn Văn A',
            position: 'Senior Flutter Developer',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo CV mẫu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            Text('Demo tính năng xuất PDF', style: context.text.h2),
            const SizedBox(height: 10),
            Text(
              'Xem trước, In và Chia sẻ trực tiếp',
              style: context.text.caption.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            ElevatedButton.icon(
              // Gọi hàm mở Preview
              onPressed: () => _openPdfPreview(context),
              icon: const Icon(Icons.visibility), // Icon con mắt (View)
              label: const Text('Xem trước & Chia sẻ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
