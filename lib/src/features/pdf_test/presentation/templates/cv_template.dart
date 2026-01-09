import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:reqres_in/src/core/pdf/pdf_core_export.dart';

// Đây là template cụ thể cho tính năng CV
class CvTemplate {
  // Hàm này khớp với signature của builder trong IPdfService
  static Future<Uint8List> generate({
    required PdfConfigModel config,
    required String fullName,
    required String position,
  }) async {
    // Gọi Helper từ Core để đảm bảo Font và cấu hình chuẩn
    return PdfGeneratorHelper.buildDocumentBytes(
      config: config,
      header: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(bottom: 10),
        child: pw.Text(
          'CV được tạo bởi Flutter App',
          style: PdfTextStyles.bodySmall,
        ),
      ),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(top: 10),
        child: pw.Text(
          'Trang ${context.pageNumber}/${context.pagesCount}',
          style: PdfTextStyles.bodySmall,
        ),
      ),
      content: [
        // 1. Header CV (Tên & Vị trí)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  fullName.toUpperCase(),
                  style: PdfTextStyles.h1.copyWith(color: PdfColors.blue800),
                ),
                pw.Text(
                  position,
                  style: PdfTextStyles.h2.copyWith(color: PdfColors.grey700),
                ),
              ],
            ),
            // Placeholder cho Avatar
            pw.Container(
              height: 60,
              width: 60,
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
                shape: pw.BoxShape.circle,
              ),
              child: pw.Center(child: pw.Text('IMG')),
            ),
          ],
        ),

        pw.SizedBox(height: 20),
        PdfComponents.divider(),

        // 2. Thông tin cá nhân
        pw.Text('THÔNG TIN LIÊN HỆ', style: PdfTextStyles.h3),
        pw.SizedBox(height: 10),
        PdfComponents.buildInfoRow('Email', 'developer@flutter.com'),
        PdfComponents.buildInfoRow('Điện thoại', '0909 123 456'),
        PdfComponents.buildInfoRow('Địa chỉ', 'Tây Ninh, Việt Nam'),

        pw.SizedBox(height: 20),

        // 3. Kinh nghiệm làm việc (Dùng Table từ Core)
        pw.Text('KINH NGHIỆM LÀM VIỆC', style: PdfTextStyles.h3),
        pw.SizedBox(height: 10),
        PdfComponents.buildTable(
          headers: ['Thời gian', 'Công ty', 'Vị trí', 'Mô tả'],
          columnWidths: [2, 3, 3, 4], // Tỷ lệ cột
          data: [
            [
              '2024 - Nay',
              'Tech Corp',
              'Senior Flutter Dev',
              'Xây dựng core modules, tối ưu hiệu năng app.',
            ],
            [
              '2022 - 2024',
              'Soft Solution',
              'Mobile Dev',
              'Phát triển ứng dụng e-commerce, tích hợp thanh toán.',
            ],
            [
              '2020 - 2022',
              'Freelancer',
              'Fullstack',
              'Làm các dự án nhỏ với Nodejs và Flutter.',
            ],
            // Thêm dữ liệu giả để test multipage
            ...List.generate(
              5,
              (i) => ['201$i', 'Company $i', 'Staff', 'Làm việc chăm chỉ...'],
            ),
          ],
        ),

        pw.SizedBox(height: 20),

        // 4. Kỹ năng
        pw.Text('KỸ NĂNG', style: PdfTextStyles.h3),
        pw.Wrap(
          spacing: 10,
          children: [
            _buildSkillBadge('Flutter'),
            _buildSkillBadge('Dart'),
            _buildSkillBadge('Clean Architecture'),
            _buildSkillBadge('BLoC'),
            _buildSkillBadge('Firebase'),
          ],
        ),
      ],
    );
  }

  // Widget nhỏ private dùng nội bộ trong template này
  static pw.Widget _buildSkillBadge(String skill) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 5),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(skill, style: PdfTextStyles.body),
    );
  }
}
