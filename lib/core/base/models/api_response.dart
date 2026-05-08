import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

/// Meta info cho phân trang / thống kê
@freezed
abstract class MetaData with _$MetaData {
  const factory MetaData({
    @JsonKey(name: 'currentPage') int? page,
    int? size,
    @JsonKey(name: 'totalRecords') int? total,
    int? totalPages,
    String? sortBy,
    String? sortOrder,
  }) = _MetaData;

  factory MetaData.fromJson(Map<String, dynamic> json) =>
      _$MetaDataFromJson(json);
}

/// Mô tả lỗi chi tiết (nếu có)
@freezed
abstract class ApiError with _$ApiError {
  const factory ApiError({String? field, String? message, String? code}) =
      _ApiError;

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);
}

/// Response tổng quát cho mọi API
@Freezed(genericArgumentFactories: true)
abstract class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    bool? success,
    int? statusCode,
    String? message,
    T? data,
    @JsonKey(name: 'pagination', readValue: _readMetaData) MetaData? meta,
    Map<String, dynamic>? summary,
    List<ApiError>? errors,
    String? timestamp,
    String? requestId,
    @Default(false) bool fromCache,
  }) = _ApiResponse<T>;

  /// Generic JSON factory: cần truyền hàm parse cho `T`
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);
}

Object? _readMetaData(Map<dynamic, dynamic> json, String key) {
  return json['meta'] ?? json['pagination'];
}
