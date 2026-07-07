// lib/core/network/file_upload_service.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;

// 1. Đảm bảo import đúng Env và DioClient của bạn
import 'package:reqres_in/src/core/env/env.dart';
import 'package:reqres_in/src/core/logging/app_logger.dart';

@lazySingleton // Đăng ký với GetIt/Injectable
class FileUploadService {
  final Dio _dio;

  FileUploadService(this._dio);

  // --- Các hằng số cho server file ---
  static final String _fileServerBaseUrl = Env.fileServer;

  // ⭐️ SỬA ĐỔI: Tạo URL tuyệt đối ngay tại đây
  static final String _uploadUrl = '$_fileServerBaseUrl/UploadChunk';
  static final String _completeUrl = '$_fileServerBaseUrl/CompleteUpload';

  static const int _chunkSize = 1 * 1024 * 1024; // 1MB

  /// Tải file lên server theo từng chunk (phần nhỏ)
  /// Trả về URL tuyệt đối của file sau khi tải lên thành công, hoặc null nếu thất bại.
  Future<String?> uploadImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        throw Exception('File không tồn tại tại đường dẫn: $imagePath');
      }

      final fileSize = file.lengthSync();
      final totalChunks = (fileSize / _chunkSize).ceil();
      final fileName = path.basename(imagePath);

      // --- 1. Vòng lặp tải lên từng chunk ---
      for (var i = 0; i < totalChunks; i++) {
        final start = i * _chunkSize;
        final end = ((i + 1) * _chunkSize > fileSize)
            ? fileSize
            : ((i + 1) * _chunkSize);
        final chunkStream = file.openRead(start, end);
        final chunkSize = end - start;

        AppLogger.debug(
          'Uploading chunk ${i + 1}/$totalChunks: size=$chunkSize',
          tag: 'FileUploadService',
        );

        // Tạo FormData cho chunk
        final formData = FormData.fromMap({
          'chunk': MultipartFile.fromStream(
            () => chunkStream,
            chunkSize,
            filename: fileName,
          ),
          'fileName': fileName,
          'chunkNumber': (i + 1).toString(),
          'totalChunks': totalChunks.toString(),
        });

        // ⭐️ SỬA ĐỔI: Dùng URL tuyệt đối, xóa `options`
        final response = await _dio.post(
          _uploadUrl, // Dùng URL tuyệt đối
          data: formData,
          onSendProgress: (sent, total) {
            AppLogger.debug(
              'Chunk ${i + 1} progress: ${(sent / total * 100).toStringAsFixed(0)}%',
              tag: 'FileUploadService',
            );
          },
        );

        if (response.statusCode != 200) {
          throw Exception('Upload chunk thất bại: HTTP ${response.statusCode}');
        }
      }

      // --- 2. Gọi API hoàn tất upload ---
      AppLogger.debug(
        'All chunks uploaded. Completing upload...',
        tag: 'FileUploadService',
      );

      final completeFormData = FormData.fromMap({
        'fileName': fileName,
        'totalChunks': totalChunks.toString(),
      });

      // ⭐️ SỬA ĐỔI: Dùng URL tuyệt đối, xóa `options`
      final completeResponse = await _dio.post(
        _completeUrl, // Dùng URL tuyệt đối
        data: completeFormData,
      );

      if (completeResponse.statusCode != 200) {
        throw Exception(
          'Hoàn tất upload thất bại: HTTP ${completeResponse.statusCode}',
        );
      }

      // Dio tự động decode JSON
      final completeJson = completeResponse.data as Map<String, dynamic>;

      // Giả sử Server trả { filename: "/uploads/xxx.jpg" }
      final relativePath = (completeJson['filename'] ?? '').toString();
      if (relativePath.isEmpty) {
        throw Exception('Server không trả về filename sau khi hoàn tất.');
      }

      // Trả về URL tuyệt đối: https://fileserver.com/uploads/xxx.jpg
      return '$_fileServerBaseUrl$relativePath';
    } catch (e) {
      // Bắt lỗi (ErrorInterceptor của bạn cũng sẽ chạy và log)
      if (e is DioException) {
        // e.error chứa Failure nếu ErrorInterceptor bắt được
        AppLogger.error(
          'Dio Upload error: ${e.error ?? e.message}',
          tag: 'FileUploadService',
          error: e,
        );
      } else {
        AppLogger.error(
          'Generic Upload error: $e',
          tag: 'FileUploadService',
          error: e,
        );
      }
      return null; // Trả về null nếu có lỗi
    }
  }
}
