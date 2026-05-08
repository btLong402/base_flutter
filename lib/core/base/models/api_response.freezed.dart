// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MetaData {

@JsonKey(name: 'currentPage') int? get page; int? get size;@JsonKey(name: 'totalRecords') int? get total; int? get totalPages; String? get sortBy; String? get sortOrder;
/// Create a copy of MetaData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetaDataCopyWith<MetaData> get copyWith => _$MetaDataCopyWithImpl<MetaData>(this as MetaData, _$identity);

  /// Serializes this MetaData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MetaData&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,page,size,total,totalPages,sortBy,sortOrder);

@override
String toString() {
  return 'MetaData(page: $page, size: $size, total: $total, totalPages: $totalPages, sortBy: $sortBy, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $MetaDataCopyWith<$Res>  {
  factory $MetaDataCopyWith(MetaData value, $Res Function(MetaData) _then) = _$MetaDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'currentPage') int? page, int? size,@JsonKey(name: 'totalRecords') int? total, int? totalPages, String? sortBy, String? sortOrder
});




}
/// @nodoc
class _$MetaDataCopyWithImpl<$Res>
    implements $MetaDataCopyWith<$Res> {
  _$MetaDataCopyWithImpl(this._self, this._then);

  final MetaData _self;
  final $Res Function(MetaData) _then;

/// Create a copy of MetaData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? page = freezed,Object? size = freezed,Object? total = freezed,Object? totalPages = freezed,Object? sortBy = freezed,Object? sortOrder = freezed,}) {
  return _then(_self.copyWith(
page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,totalPages: freezed == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int?,sortBy: freezed == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: freezed == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MetaData].
extension MetaDataPatterns on MetaData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MetaData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MetaData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MetaData value)  $default,){
final _that = this;
switch (_that) {
case _MetaData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MetaData value)?  $default,){
final _that = this;
switch (_that) {
case _MetaData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'currentPage')  int? page,  int? size, @JsonKey(name: 'totalRecords')  int? total,  int? totalPages,  String? sortBy,  String? sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MetaData() when $default != null:
return $default(_that.page,_that.size,_that.total,_that.totalPages,_that.sortBy,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'currentPage')  int? page,  int? size, @JsonKey(name: 'totalRecords')  int? total,  int? totalPages,  String? sortBy,  String? sortOrder)  $default,) {final _that = this;
switch (_that) {
case _MetaData():
return $default(_that.page,_that.size,_that.total,_that.totalPages,_that.sortBy,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'currentPage')  int? page,  int? size, @JsonKey(name: 'totalRecords')  int? total,  int? totalPages,  String? sortBy,  String? sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _MetaData() when $default != null:
return $default(_that.page,_that.size,_that.total,_that.totalPages,_that.sortBy,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MetaData implements MetaData {
  const _MetaData({@JsonKey(name: 'currentPage') this.page, this.size, @JsonKey(name: 'totalRecords') this.total, this.totalPages, this.sortBy, this.sortOrder});
  factory _MetaData.fromJson(Map<String, dynamic> json) => _$MetaDataFromJson(json);

@override@JsonKey(name: 'currentPage') final  int? page;
@override final  int? size;
@override@JsonKey(name: 'totalRecords') final  int? total;
@override final  int? totalPages;
@override final  String? sortBy;
@override final  String? sortOrder;

/// Create a copy of MetaData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetaDataCopyWith<_MetaData> get copyWith => __$MetaDataCopyWithImpl<_MetaData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MetaDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MetaData&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,page,size,total,totalPages,sortBy,sortOrder);

@override
String toString() {
  return 'MetaData(page: $page, size: $size, total: $total, totalPages: $totalPages, sortBy: $sortBy, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$MetaDataCopyWith<$Res> implements $MetaDataCopyWith<$Res> {
  factory _$MetaDataCopyWith(_MetaData value, $Res Function(_MetaData) _then) = __$MetaDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'currentPage') int? page, int? size,@JsonKey(name: 'totalRecords') int? total, int? totalPages, String? sortBy, String? sortOrder
});




}
/// @nodoc
class __$MetaDataCopyWithImpl<$Res>
    implements _$MetaDataCopyWith<$Res> {
  __$MetaDataCopyWithImpl(this._self, this._then);

  final _MetaData _self;
  final $Res Function(_MetaData) _then;

/// Create a copy of MetaData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = freezed,Object? size = freezed,Object? total = freezed,Object? totalPages = freezed,Object? sortBy = freezed,Object? sortOrder = freezed,}) {
  return _then(_MetaData(
page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,totalPages: freezed == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int?,sortBy: freezed == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: freezed == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ApiError {

 String? get field; String? get message; String? get code;
/// Create a copy of ApiError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiErrorCopyWith<ApiError> get copyWith => _$ApiErrorCopyWithImpl<ApiError>(this as ApiError, _$identity);

  /// Serializes this ApiError to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiError&&(identical(other.field, field) || other.field == field)&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,field,message,code);

@override
String toString() {
  return 'ApiError(field: $field, message: $message, code: $code)';
}


}

/// @nodoc
abstract mixin class $ApiErrorCopyWith<$Res>  {
  factory $ApiErrorCopyWith(ApiError value, $Res Function(ApiError) _then) = _$ApiErrorCopyWithImpl;
@useResult
$Res call({
 String? field, String? message, String? code
});




}
/// @nodoc
class _$ApiErrorCopyWithImpl<$Res>
    implements $ApiErrorCopyWith<$Res> {
  _$ApiErrorCopyWithImpl(this._self, this._then);

  final ApiError _self;
  final $Res Function(ApiError) _then;

/// Create a copy of ApiError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? field = freezed,Object? message = freezed,Object? code = freezed,}) {
  return _then(_self.copyWith(
field: freezed == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiError].
extension ApiErrorPatterns on ApiError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiError value)  $default,){
final _that = this;
switch (_that) {
case _ApiError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiError value)?  $default,){
final _that = this;
switch (_that) {
case _ApiError() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? field,  String? message,  String? code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiError() when $default != null:
return $default(_that.field,_that.message,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? field,  String? message,  String? code)  $default,) {final _that = this;
switch (_that) {
case _ApiError():
return $default(_that.field,_that.message,_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? field,  String? message,  String? code)?  $default,) {final _that = this;
switch (_that) {
case _ApiError() when $default != null:
return $default(_that.field,_that.message,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiError implements ApiError {
  const _ApiError({this.field, this.message, this.code});
  factory _ApiError.fromJson(Map<String, dynamic> json) => _$ApiErrorFromJson(json);

@override final  String? field;
@override final  String? message;
@override final  String? code;

/// Create a copy of ApiError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiErrorCopyWith<_ApiError> get copyWith => __$ApiErrorCopyWithImpl<_ApiError>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiErrorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiError&&(identical(other.field, field) || other.field == field)&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,field,message,code);

@override
String toString() {
  return 'ApiError(field: $field, message: $message, code: $code)';
}


}

/// @nodoc
abstract mixin class _$ApiErrorCopyWith<$Res> implements $ApiErrorCopyWith<$Res> {
  factory _$ApiErrorCopyWith(_ApiError value, $Res Function(_ApiError) _then) = __$ApiErrorCopyWithImpl;
@override @useResult
$Res call({
 String? field, String? message, String? code
});




}
/// @nodoc
class __$ApiErrorCopyWithImpl<$Res>
    implements _$ApiErrorCopyWith<$Res> {
  __$ApiErrorCopyWithImpl(this._self, this._then);

  final _ApiError _self;
  final $Res Function(_ApiError) _then;

/// Create a copy of ApiError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field = freezed,Object? message = freezed,Object? code = freezed,}) {
  return _then(_ApiError(
field: freezed == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ApiResponse<T> {

 bool? get success; int? get statusCode; String? get message; T? get data;@JsonKey(name: 'pagination', readValue: _readMetaData) MetaData? get meta; Map<String, dynamic>? get summary; List<ApiError>? get errors; String? get timestamp; String? get requestId; bool get fromCache;
/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiResponseCopyWith<T, ApiResponse<T>> get copyWith => _$ApiResponseCopyWithImpl<T, ApiResponse<T>>(this as ApiResponse<T>, _$identity);

  /// Serializes this ApiResponse to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiResponse<T>&&(identical(other.success, success) || other.success == success)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.meta, meta) || other.meta == meta)&&const DeepCollectionEquality().equals(other.summary, summary)&&const DeepCollectionEquality().equals(other.errors, errors)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.fromCache, fromCache) || other.fromCache == fromCache));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,statusCode,message,const DeepCollectionEquality().hash(data),meta,const DeepCollectionEquality().hash(summary),const DeepCollectionEquality().hash(errors),timestamp,requestId,fromCache);

@override
String toString() {
  return 'ApiResponse<$T>(success: $success, statusCode: $statusCode, message: $message, data: $data, meta: $meta, summary: $summary, errors: $errors, timestamp: $timestamp, requestId: $requestId, fromCache: $fromCache)';
}


}

/// @nodoc
abstract mixin class $ApiResponseCopyWith<T,$Res>  {
  factory $ApiResponseCopyWith(ApiResponse<T> value, $Res Function(ApiResponse<T>) _then) = _$ApiResponseCopyWithImpl;
@useResult
$Res call({
 bool? success, int? statusCode, String? message, T? data,@JsonKey(name: 'pagination', readValue: _readMetaData) MetaData? meta, Map<String, dynamic>? summary, List<ApiError>? errors, String? timestamp, String? requestId, bool fromCache
});


$MetaDataCopyWith<$Res>? get meta;

}
/// @nodoc
class _$ApiResponseCopyWithImpl<T,$Res>
    implements $ApiResponseCopyWith<T, $Res> {
  _$ApiResponseCopyWithImpl(this._self, this._then);

  final ApiResponse<T> _self;
  final $Res Function(ApiResponse<T>) _then;

/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = freezed,Object? statusCode = freezed,Object? message = freezed,Object? data = freezed,Object? meta = freezed,Object? summary = freezed,Object? errors = freezed,Object? timestamp = freezed,Object? requestId = freezed,Object? fromCache = null,}) {
  return _then(_self.copyWith(
success: freezed == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool?,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as MetaData?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,errors: freezed == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<ApiError>?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,fromCache: null == fromCache ? _self.fromCache : fromCache // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetaDataCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $MetaDataCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// Adds pattern-matching-related methods to [ApiResponse].
extension ApiResponsePatterns<T> on ApiResponse<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiResponse<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiResponse<T> value)  $default,){
final _that = this;
switch (_that) {
case _ApiResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiResponse<T> value)?  $default,){
final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? success,  int? statusCode,  String? message,  T? data, @JsonKey(name: 'pagination', readValue: _readMetaData)  MetaData? meta,  Map<String, dynamic>? summary,  List<ApiError>? errors,  String? timestamp,  String? requestId,  bool fromCache)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
return $default(_that.success,_that.statusCode,_that.message,_that.data,_that.meta,_that.summary,_that.errors,_that.timestamp,_that.requestId,_that.fromCache);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? success,  int? statusCode,  String? message,  T? data, @JsonKey(name: 'pagination', readValue: _readMetaData)  MetaData? meta,  Map<String, dynamic>? summary,  List<ApiError>? errors,  String? timestamp,  String? requestId,  bool fromCache)  $default,) {final _that = this;
switch (_that) {
case _ApiResponse():
return $default(_that.success,_that.statusCode,_that.message,_that.data,_that.meta,_that.summary,_that.errors,_that.timestamp,_that.requestId,_that.fromCache);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? success,  int? statusCode,  String? message,  T? data, @JsonKey(name: 'pagination', readValue: _readMetaData)  MetaData? meta,  Map<String, dynamic>? summary,  List<ApiError>? errors,  String? timestamp,  String? requestId,  bool fromCache)?  $default,) {final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
return $default(_that.success,_that.statusCode,_that.message,_that.data,_that.meta,_that.summary,_that.errors,_that.timestamp,_that.requestId,_that.fromCache);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _ApiResponse<T> implements ApiResponse<T> {
  const _ApiResponse({this.success, this.statusCode, this.message, this.data, @JsonKey(name: 'pagination', readValue: _readMetaData) this.meta, final  Map<String, dynamic>? summary, final  List<ApiError>? errors, this.timestamp, this.requestId, this.fromCache = false}): _summary = summary,_errors = errors;
  factory _ApiResponse.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$ApiResponseFromJson(json,fromJsonT);

@override final  bool? success;
@override final  int? statusCode;
@override final  String? message;
@override final  T? data;
@override@JsonKey(name: 'pagination', readValue: _readMetaData) final  MetaData? meta;
 final  Map<String, dynamic>? _summary;
@override Map<String, dynamic>? get summary {
  final value = _summary;
  if (value == null) return null;
  if (_summary is EqualUnmodifiableMapView) return _summary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<ApiError>? _errors;
@override List<ApiError>? get errors {
  final value = _errors;
  if (value == null) return null;
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? timestamp;
@override final  String? requestId;
@override@JsonKey() final  bool fromCache;

/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiResponseCopyWith<T, _ApiResponse<T>> get copyWith => __$ApiResponseCopyWithImpl<T, _ApiResponse<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$ApiResponseToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiResponse<T>&&(identical(other.success, success) || other.success == success)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.meta, meta) || other.meta == meta)&&const DeepCollectionEquality().equals(other._summary, _summary)&&const DeepCollectionEquality().equals(other._errors, _errors)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.fromCache, fromCache) || other.fromCache == fromCache));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,statusCode,message,const DeepCollectionEquality().hash(data),meta,const DeepCollectionEquality().hash(_summary),const DeepCollectionEquality().hash(_errors),timestamp,requestId,fromCache);

@override
String toString() {
  return 'ApiResponse<$T>(success: $success, statusCode: $statusCode, message: $message, data: $data, meta: $meta, summary: $summary, errors: $errors, timestamp: $timestamp, requestId: $requestId, fromCache: $fromCache)';
}


}

/// @nodoc
abstract mixin class _$ApiResponseCopyWith<T,$Res> implements $ApiResponseCopyWith<T, $Res> {
  factory _$ApiResponseCopyWith(_ApiResponse<T> value, $Res Function(_ApiResponse<T>) _then) = __$ApiResponseCopyWithImpl;
@override @useResult
$Res call({
 bool? success, int? statusCode, String? message, T? data,@JsonKey(name: 'pagination', readValue: _readMetaData) MetaData? meta, Map<String, dynamic>? summary, List<ApiError>? errors, String? timestamp, String? requestId, bool fromCache
});


@override $MetaDataCopyWith<$Res>? get meta;

}
/// @nodoc
class __$ApiResponseCopyWithImpl<T,$Res>
    implements _$ApiResponseCopyWith<T, $Res> {
  __$ApiResponseCopyWithImpl(this._self, this._then);

  final _ApiResponse<T> _self;
  final $Res Function(_ApiResponse<T>) _then;

/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = freezed,Object? statusCode = freezed,Object? message = freezed,Object? data = freezed,Object? meta = freezed,Object? summary = freezed,Object? errors = freezed,Object? timestamp = freezed,Object? requestId = freezed,Object? fromCache = null,}) {
  return _then(_ApiResponse<T>(
success: freezed == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool?,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as MetaData?,summary: freezed == summary ? _self._summary : summary // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,errors: freezed == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<ApiError>?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,fromCache: null == fromCache ? _self.fromCache : fromCache // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetaDataCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $MetaDataCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}

// dart format on
