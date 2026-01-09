// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PdfConfigModel _$PdfConfigModelFromJson(Map<String, dynamic> json) =>
    _PdfConfigModel(
      margin: (json['margin'] as num?)?.toDouble() ?? 2.0 * PdfPageFormat.cm,
      isPortrait: json['isPortrait'] as bool? ?? true,
    );

Map<String, dynamic> _$PdfConfigModelToJson(_PdfConfigModel instance) =>
    <String, dynamic>{
      'margin': instance.margin,
      'isPortrait': instance.isPortrait,
    };
