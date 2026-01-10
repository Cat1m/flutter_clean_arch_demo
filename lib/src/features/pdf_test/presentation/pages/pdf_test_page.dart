import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reqres_in/src/core/di/injection.dart';
import 'package:reqres_in/src/core/pdf/pdf_core_export.dart'; // Import Core PDF
import 'package:reqres_in/src/core/ui/ui.dart';
import 'package:reqres_in/src/features/pdf_test/presentation/pages/beautiful_pdf_viewer.dart'; // Import trang View đẹp mới tạo
import 'package:reqres_in/src/features/pdf_test/presentation/templates/cv_template.dart';

// Chuyển sang StatefulWidget để quản lý trạng thái Loading
class PdfTestPage extends StatefulWidget {
  const PdfTestPage({super.key});

  @override
  State<PdfTestPage> createState() => _PdfTestPageState();
}

class _PdfTestPageState extends State<PdfTestPage> {
  bool _isLoading = false; // Biến để hiện vòng xoay loading

  Future<void> _generateAndOpenBeautifulView(BuildContext context) async {
    setState(() => _isLoading = true);

    // 1. Khởi tạo Service
    final IPdfService pdfService = getIt<IPdfService>();

    final avatar = await PdfImageHelper.loadNetworkImage(
      'https://reqres.in/img/faces/7-image.jpg',
    );

    // 2. Tạo file PDF và lưu xuống bộ nhớ máy
    final result = await pdfService.generatePdf(
      fileName: 'CV_NguyenVanA', // Tên file (Service tự thêm đuôi .pdf)
      config: const PdfConfigModel(isPortrait: true),
      // Gọi Template
      builder: (config) => CvTemplate.generate(
        config: config,
        fullName: 'Nguyễn Văn A',
        githubUrl: 'https://github.com/Cat1m',
        avatarImage: avatar, // Truyền ảnh đã tải vào đây
      ),
    );

    setState(() => _isLoading = false);

    // 3. Kiểm tra kết quả và Điều hướng
    if (!mounted) return;

    switch (result) {
      case PdfSuccess(:final file):
        // ✅ Thành công: Mở trang Beautiful View với file vừa tạo
        unawaited(
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BeautifulPdfViewer(
                pdfFile: file,
                title: 'Xem trước CV (Syncfusion)',
              ),
            ),
          ),
        );
        break;

      case PdfFailure(:final message):
        // ❌ Thất bại: Báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo PDF: $message'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
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
              'Giao diện đẹp (Syncfusion) & Share',
              style: context.text.caption.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Nếu đang tạo file thì hiện loading, ngược lại hiện nút bấm
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: () => _generateAndOpenBeautifulView(context),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Xem giao diện đẹp'),
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
