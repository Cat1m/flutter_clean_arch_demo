import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Cần thiết để dùng SchedulerBinding (đợi frame)
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Màn hình xem PDF sử dụng Syncfusion.
/// Đã xử lý lỗi Crash "RenderBox was not laid out" khi Back bằng kỹ thuật "Safe Back".
class BeautifulPdfViewer extends StatefulWidget {
  final File pdfFile;
  final String title;

  const BeautifulPdfViewer({
    super.key,
    required this.pdfFile,
    required this.title,
  });

  @override
  State<BeautifulPdfViewer> createState() => _BeautifulPdfViewerState();
}

class _BeautifulPdfViewerState extends State<BeautifulPdfViewer> {
  final PdfViewerController _pdfViewerController = PdfViewerController();

  // ✅ 1. Cờ kiểm soát hiển thị (Mấu chốt của giải pháp)
  // - true: Đang xem -> Hiển thị SfPdfViewer (Widget Nặng).
  // - false: Đang back -> Hiển thị SizedBox (Widget Nhẹ).
  bool _isShowPdf = true;

  void _shareFile() {
    // ignore: deprecated_member_use
    Share.shareXFiles([
      XFile(widget.pdfFile.path),
    ], text: 'Gửi bạn file CV từ ứng dụng Flutter');
  }

  // ✅ 2. Hàm xử lý Back an toàn (Safe Back Logic)
  // Nguyên lý: "Triệt tiêu" Widget nặng trước khi Animation chuyển trang bắt đầu.
  void _onSafeBack() {
    // Bước 1: Ra lệnh ẩn PDF đi ngay lập tức.
    // Lúc này UI sẽ vẽ lại thành SizedBox rỗng.
    setState(() {
      _isShowPdf = false;
    });

    // Bước 2: Đợi đúng 1 Frame (khoảng 16ms) để đảm bảo UI đã cập nhật xong (SfPdfViewer đã bị hủy).
    // Nếu không đợi, Navigator.pop sẽ chạy song song với việc hủy Widget -> Vẫn Crash.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Bước 3: Bây giờ mới thực sự Back.
        // Lúc này Navigator sẽ thực hiện Animation trượt một cái "Hộp rỗng" (SizedBox).
        // Vì hộp rỗng rất nhẹ và không tính toán Layout -> Animation mượt, không Crash.
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 3. Chặn nút Back vật lý (trên Android)
    // Phải chặn hành động back mặc định để ép nó chạy qua hàm _onSafeBack của mình.
    return PopScope(
      canPop: false, // false = Chặn không cho pop tự động
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (didPop) return;
        _onSafeBack(); // Gọi hàm xử lý thủ công
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          // ✅ 4. Ghi đè nút Back trên AppBar (Góc trái trên cùng)
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onSafeBack, // Bấm nút này cũng phải gọi Safe Back
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Chia sẻ',
              onPressed: _shareFile,
            ),
          ],
        ),
        // ✅ 5. Logic hiển thị (Tráo hàng)
        // Nếu cờ đang bật -> Hiện PDF.
        // Nếu cờ tắt (đang back) -> Hiện hộp rỗng để Animation trượt cho nhẹ.
        body: _isShowPdf
            ? SfPdfViewer.file(
                widget.pdfFile,
                controller: _pdfViewerController,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                pageLayoutMode: PdfPageLayoutMode.continuous,
                enableDoubleTapZooming: true,
              )
            : const SizedBox(), // Placeholder nhẹ tưng, không tốn tài nguyên render
      ),
    );
  }
}
