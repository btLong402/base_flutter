// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MetaData _$MetaDataFromJson(Map<String, dynamic> json) => _MetaData(
  page: (json['currentPage'] as num?)?.toInt(),
  size: (json['size'] as num?)?.toInt(),
  total: (json['totalRecords'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
  sortBy: json['sortBy'] as String?,
  sortOrder: json['sortOrder'] as String?,
);

Map<String, dynamic> _$MetaDataToJson(_MetaData instance) => <String, dynamic>{
  'currentPage': instance.page,
  'size': instance.size,
  'totalRecords': instance.total,
  'totalPages': instance.totalPages,
  'sortBy': instance.sortBy,
  'sortOrder': instance.sortOrder,
};

_ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => _ApiError(
  field: json['field'] as String?,
  message: json['message'] as String?,
  code: json['code'] as String?,
);

Map<String, dynamic> _$ApiErrorToJson(_ApiError instance) => <String, dynamic>{
  'field': instance.field,
  'message': instance.message,
  'code': instance.code,
};

_ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _ApiResponse<T>(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  meta: _readMetaData(json, 'pagination') == null
      ? null
      : MetaData.fromJson(
          _readMetaData(json, 'pagination') as Map<String, dynamic>,
        ),
  summary: json['summary'] as Map<String, dynamic>?,
  errors: (json['errors'] as List<dynamic>?)
      ?.map((e) => ApiError.fromJson(e as Map<String, dynamic>))
      .toList(),
  timestamp: json['timestamp'] as String?,
  requestId: json['requestId'] as String?,
  fromCache: json['fromCache'] as bool? ?? false,
);

Map<String, dynamic> _$ApiResponseToJson<T>(
  _ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
  'pagination': instance.meta,
  'summary': instance.summary,
  'errors': instance.errors,
  'timestamp': instance.timestamp,
  'requestId': instance.requestId,
  'fromCache': instance.fromCache,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);
