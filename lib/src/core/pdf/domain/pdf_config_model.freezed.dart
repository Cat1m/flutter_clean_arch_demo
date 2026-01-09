// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pdf_config_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PdfConfigModel {

// Khổ giấy mặc định là A4
@JsonKey(includeFromJson: false, includeToJson: false) PdfPageFormat get pageFormat;// Lề trang (cm), mặc định 2.0cm
 double get margin;// Hướng giấy: true = Portrait, false = Landscape
 bool get isPortrait;
/// Create a copy of PdfConfigModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PdfConfigModelCopyWith<PdfConfigModel> get copyWith => _$PdfConfigModelCopyWithImpl<PdfConfigModel>(this as PdfConfigModel, _$identity);

  /// Serializes this PdfConfigModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PdfConfigModel&&(identical(other.pageFormat, pageFormat) || other.pageFormat == pageFormat)&&(identical(other.margin, margin) || other.margin == margin)&&(identical(other.isPortrait, isPortrait) || other.isPortrait == isPortrait));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pageFormat,margin,isPortrait);

@override
String toString() {
  return 'PdfConfigModel(pageFormat: $pageFormat, margin: $margin, isPortrait: $isPortrait)';
}


}

/// @nodoc
abstract mixin class $PdfConfigModelCopyWith<$Res>  {
  factory $PdfConfigModelCopyWith(PdfConfigModel value, $Res Function(PdfConfigModel) _then) = _$PdfConfigModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) PdfPageFormat pageFormat, double margin, bool isPortrait
});




}
/// @nodoc
class _$PdfConfigModelCopyWithImpl<$Res>
    implements $PdfConfigModelCopyWith<$Res> {
  _$PdfConfigModelCopyWithImpl(this._self, this._then);

  final PdfConfigModel _self;
  final $Res Function(PdfConfigModel) _then;

/// Create a copy of PdfConfigModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pageFormat = null,Object? margin = null,Object? isPortrait = null,}) {
  return _then(_self.copyWith(
pageFormat: null == pageFormat ? _self.pageFormat : pageFormat // ignore: cast_nullable_to_non_nullable
as PdfPageFormat,margin: null == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as double,isPortrait: null == isPortrait ? _self.isPortrait : isPortrait // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PdfConfigModel].
extension PdfConfigModelPatterns on PdfConfigModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PdfConfigModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PdfConfigModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PdfConfigModel value)  $default,){
final _that = this;
switch (_that) {
case _PdfConfigModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PdfConfigModel value)?  $default,){
final _that = this;
switch (_that) {
case _PdfConfigModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  PdfPageFormat pageFormat,  double margin,  bool isPortrait)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PdfConfigModel() when $default != null:
return $default(_that.pageFormat,_that.margin,_that.isPortrait);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeFromJson: false, includeToJson: false)  PdfPageFormat pageFormat,  double margin,  bool isPortrait)  $default,) {final _that = this;
switch (_that) {
case _PdfConfigModel():
return $default(_that.pageFormat,_that.margin,_that.isPortrait);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeFromJson: false, includeToJson: false)  PdfPageFormat pageFormat,  double margin,  bool isPortrait)?  $default,) {final _that = this;
switch (_that) {
case _PdfConfigModel() when $default != null:
return $default(_that.pageFormat,_that.margin,_that.isPortrait);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PdfConfigModel implements PdfConfigModel {
  const _PdfConfigModel({@JsonKey(includeFromJson: false, includeToJson: false) this.pageFormat = PdfPageFormat.a4, this.margin = 2.0 * PdfPageFormat.cm, this.isPortrait = true});
  factory _PdfConfigModel.fromJson(Map<String, dynamic> json) => _$PdfConfigModelFromJson(json);

// Khổ giấy mặc định là A4
@override@JsonKey(includeFromJson: false, includeToJson: false) final  PdfPageFormat pageFormat;
// Lề trang (cm), mặc định 2.0cm
@override@JsonKey() final  double margin;
// Hướng giấy: true = Portrait, false = Landscape
@override@JsonKey() final  bool isPortrait;

/// Create a copy of PdfConfigModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PdfConfigModelCopyWith<_PdfConfigModel> get copyWith => __$PdfConfigModelCopyWithImpl<_PdfConfigModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PdfConfigModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PdfConfigModel&&(identical(other.pageFormat, pageFormat) || other.pageFormat == pageFormat)&&(identical(other.margin, margin) || other.margin == margin)&&(identical(other.isPortrait, isPortrait) || other.isPortrait == isPortrait));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pageFormat,margin,isPortrait);

@override
String toString() {
  return 'PdfConfigModel(pageFormat: $pageFormat, margin: $margin, isPortrait: $isPortrait)';
}


}

/// @nodoc
abstract mixin class _$PdfConfigModelCopyWith<$Res> implements $PdfConfigModelCopyWith<$Res> {
  factory _$PdfConfigModelCopyWith(_PdfConfigModel value, $Res Function(_PdfConfigModel) _then) = __$PdfConfigModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeFromJson: false, includeToJson: false) PdfPageFormat pageFormat, double margin, bool isPortrait
});




}
/// @nodoc
class __$PdfConfigModelCopyWithImpl<$Res>
    implements _$PdfConfigModelCopyWith<$Res> {
  __$PdfConfigModelCopyWithImpl(this._self, this._then);

  final _PdfConfigModel _self;
  final $Res Function(_PdfConfigModel) _then;

/// Create a copy of PdfConfigModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pageFormat = null,Object? margin = null,Object? isPortrait = null,}) {
  return _then(_PdfConfigModel(
pageFormat: null == pageFormat ? _self.pageFormat : pageFormat // ignore: cast_nullable_to_non_nullable
as PdfPageFormat,margin: null == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as double,isPortrait: null == isPortrait ? _self.isPortrait : isPortrait // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
