import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pdf/pdf.dart';

part 'pdf_config_model.freezed.dart';
part 'pdf_config_model.g.dart';

// Dùng Freezed để tạo model cấu hình immutable
@freezed
abstract class PdfConfigModel with _$PdfConfigModel {
  const factory PdfConfigModel({
    // Khổ giấy mặc định là A4
    @Default(PdfPageFormat.a4)
    // ignore: invalid_annotation_target
    @JsonKey(
      includeFromJson: false,
      includeToJson: false,
    ) // PdfPageFormat không serialize trực tiếp được
    PdfPageFormat pageFormat,

    // Lề trang (cm), mặc định 2.0cm
    @Default(2.0 * PdfPageFormat.cm) double margin,

    // Hướng giấy: true = Portrait, false = Landscape
    @Default(true) bool isPortrait,
  }) = _PdfConfigModel;

  factory PdfConfigModel.fromJson(Map<String, dynamic> json) =>
      _$PdfConfigModelFromJson(json);
}
