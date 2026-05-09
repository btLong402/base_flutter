import 'dart:convert';
import 'package:base_flutter/core/base/utils/app_compute.dart';

/// A high-level utility for performing JSON operations in background isolates.
///
/// Use this for large JSON strings or objects that might cause UI jank
/// during encoding or decoding.
abstract class AppJson {
  /// Decodes a JSON string in a background isolate.
  ///
  /// Recommended for JSON strings larger than 50 KB.
  static Future<dynamic> decode(String source, {String? label}) {
    return AppCompute.run(
      jsonDecode,
      source,
      label:
          label ??
          'AppJson.decode (${(source.length / 1024).toStringAsFixed(1)} KB)',
    );
  }

  /// Encodes an object to a JSON string in a background isolate.
  ///
  /// Recommended for large objects or deep trees.
  static Future<String> encode(Object? value, {String? label}) {
    return AppCompute.run(
      jsonEncode,
      value,
      label: label ?? 'AppJson.encode',
    );
  }

  /// Specialized helper to decode a JSON string and map it to a list of models.
  static Future<List<T>> decodeList<T>(
    String source,
    T Function(Map<String, dynamic>) fromJson, {
    String? label,
  }) async {
    final rawList = await decode(source, label: label) as List<dynamic>;
    return rawList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
}
