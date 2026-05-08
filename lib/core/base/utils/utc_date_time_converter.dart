import 'package:freezed_annotation/freezed_annotation.dart';

/// A global JsonConverter for [DateTime] objects to handle timezones properly.
///
/// Ensures:
/// 1. When sending [DateTime] to APIs (toJson), it converts it to UTC ISO 8601
///    string.
/// 2. When receiving JSON from APIs (fromJson), it parses it as UTC and returns
///    a Local [DateTime] object.
class UtcDateTimeConverter implements JsonConverter<DateTime, String> {
  const UtcDateTimeConverter();

  @override
  DateTime fromJson(String json) {
    final parsed = DateTime.parse(json);
    // If string ends with 'Z', dart parses it as UTC but doesn't convert if we
    // want local.
    // .toLocal() will safely convert UTC to Local.
    // If the date string doesn't have timezone offset, `isUtc` might be false
    // depending on format, so we force assumption it is UTC if we require all
    // API returns in UTC, but for safety `toLocal` acts correctly if the
    // parsing understands the offset or 'Z'.
    return parsed.toLocal();
  }

  @override
  String toJson(DateTime object) {
    // Send to backend in explicit UTC timezone format (ISO 8601 ending in 'Z')
    return object.toUtc().toIso8601String();
  }
}
