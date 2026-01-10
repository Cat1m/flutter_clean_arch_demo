import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:reqres_in/src/core/pdf/pdf_core_export.dart';

class CvTemplate {
  static Future<Uint8List> generate({
    required PdfConfigModel config,
    required String fullName,
    required String githubUrl,
    pw.MemoryImage? avatarImage,
  }) async {
    return PdfGeneratorHelper.buildDocumentBytes(
      config: config,

      // HEADER (Lặp lại ở mỗi trang - trừ trang 1)
      header: (context) {
        if (context.pageNumber == 1) return pw.SizedBox();
        return pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Text(
            'CV: $fullName - Trang ${context.pageNumber}',
            style: PdfTextStyles.bodySmall.copyWith(color: PdfColors.grey500),
          ),
        );
      },

      // FOOTER (Số trang)
      footer: (context) => pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(top: 10),
        child: pw.Text(
          'Trang ${context.pageNumber} / ${context.pagesCount}',
          style: PdfTextStyles.bodySmall,
        ),
      ),

      content: [
        // --- TRANG 1: THÔNG TIN CƠ BẢN ---

        // 1. Header Profile
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  fullName.toUpperCase(),
                  style: PdfTextStyles.h1.copyWith(color: PdfColors.blue900),
                ),
                pw.SizedBox(height: 5),
                PdfComponents.buildLink(
                  text: 'Github: $githubUrl',
                  url: githubUrl,
                ),
              ],
            ),
            pw.Column(
              children: [
                // 👉 Dùng component ẢNH (Có fallback)
                pw.Container(
                  width: 80,
                  height: 80,
                  decoration: const pw.BoxDecoration(shape: pw.BoxShape.circle),
                  child: pw.ClipOval(
                    // Logic: Có ảnh -> vẽ ảnh. Không có ảnh -> vẽ Placeholder
                    child: avatarImage != null
                        ? pw.Image(avatarImage, fit: pw.BoxFit.cover)
                        : PdfComponents.buildAvatarPlaceholder(
                            isError: true,
                          ), // true nếu muốn hiện dấu than đỏ
                  ),
                ),

                pw.SizedBox(height: 10),

                // 👉 Dùng component QR CODE (Generate từ link Github)
                PdfComponents.buildQRCode(data: githubUrl, size: 60),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 20),
        PdfComponents.divider(),

        // 2. Thông tin liên hệ
        pw.Text('THÔNG TIN LIÊN HỆ', style: PdfTextStyles.h3),
        pw.SizedBox(height: 10),
        PdfComponents.buildInfoRow('Email', 'developer@flutter.com'),
        PdfComponents.buildInfoRow('Điện thoại', '0909 123 456'),
        PdfComponents.buildInfoRow('LinkedIN', 'linkedin.com/in/flutter-dev'),
        PdfComponents.buildInfoRow('Github', 'github.com/flutter-dev'),

        pw.SizedBox(height: 20),

        // 3. Giới thiệu bản thân (Text dài để test wrap)
        pw.Text('GIỚI THIỆU', style: PdfTextStyles.h3),
        pw.SizedBox(height: 5),
        pw.Paragraph(
          text:
              'Tôi là một lập trình viên Flutter đam mê Clean Architecture. ' *
              10, // Lặp lại text để dài ra
          style: PdfTextStyles.body,
        ),

        pw.SizedBox(height: 20),

        // --- PHẦN NÀY SẼ LÀM TRÀN TRANG ---
        pw.Text('KINH NGHIỆM LÀM VIỆC (Chi tiết)', style: PdfTextStyles.h3),
        pw.SizedBox(height: 10),

        // Bảng dữ liệu tự động ngắt trang (Table split)
        PdfComponents.buildTable(
          headers: ['Năm', 'Công ty', 'Dự án', 'Chi tiết công việc'],
          columnWidths: [2, 3, 4, 6],
          data: [
            // Dữ liệu thật
            [
              '2024 - Nay',
              'Tech Corp',
              'Super App',
              'Xây dựng core module, tích hợp CI/CD.',
            ],
            [
              '2023 - 2024',
              'Soft Solution',
              'E-Commerce',
              'Tối ưu hiệu năng, giảm size app 30%.',
            ],

            // 🔥 DATA GIẢ LẬP (Gen 20 dòng để chắc chắn qua trang 2)
            ...List.generate(20, (index) {
              return [
                '20${10 + index}',
                'Công ty Demo ${index + 1}',
                'Dự án Test ${index + 1}',
                'Đây là dòng mô tả công việc rất dài để kiểm tra tính năng xuống dòng tự động trong ô của bảng (Cell wrap) và tính năng tự động ngắt trang của thư viện PDF.',
              ];
            }),
          ],
        ),

        // --- NGẮT TRANG THỦ CÔNG ---
        // Ví dụ: Bạn muốn phần "Dự án cá nhân" luôn bắt đầu ở trang mới cho đẹp
        pw.NewPage(),

        pw.Text('DỰ ÁN CÁ NHÂN (Bắt đầu trang mới)', style: PdfTextStyles.h1),
        pw.SizedBox(height: 10),
        pw.Text(
          'Dưới đây là danh sách các dự án Open Source:',
          style: PdfTextStyles.bodyItalic,
        ),
        pw.SizedBox(height: 20),

        // Grid view giả (dùng Wrap)
        pw.Wrap(
          spacing: 20,
          runSpacing: 20,
          children: List.generate(6, (index) => _buildProjectCard(index)),
        ),
      ],
    );
  }

  // Helper tạo Card dự án
  static pw.Widget _buildProjectCard(int index) {
    return pw.Container(
      width: 150,
      height: 100,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Project #$index', style: PdfTextStyles.bodyBold),
          pw.SizedBox(height: 5),
          pw.Text(
            'Mô tả ngắn gọn về dự án này...',
            style: PdfTextStyles.bodySmall,
          ),
          pw.Spacer(),
          pw.Text(
            'Dart • Flutter',
            style: PdfTextStyles.bodySmall.copyWith(color: PdfColors.blue),
          ),
        ],
      ),
    );
  }
}
