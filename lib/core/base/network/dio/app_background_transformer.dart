import 'dart:convert';

import 'package:base_flutter/core/base/utils/app_compute.dart';
import 'package:dio/dio.dart';

/// A Dio [Transformer] that offloads heavy JSON decoding to a background isolate
/// using [AppCompute] for better UI responsiveness and performance monitoring.
class AppBackgroundTransformer extends BackgroundTransformer {
  AppBackgroundTransformer({
    this.jsonThresholdBytes = 50 * 1024,
    this.isEnabled = true,
  });

  /// The threshold in bytes above which JSON decoding will be offloaded to an isolate.
  /// Default is 50 KB.
  final int jsonThresholdBytes;

  /// Whether the background parsing is enabled.
  final bool isEnabled;

  @override
  Future<dynamic> transformResponse(
    RequestOptions options,
    ResponseBody responseBody,
  ) async {
    // 1. Read the response body using BackgroundTransformer's logic
    final dynamic transformed =
        await super.transformResponse(options, responseBody);

    // 2. If it's a JSON response and a String, check if we should decode in background
    if (isEnabled &&
        transformed is String &&
        options.responseType == ResponseType.json) {
      final bytes = transformed.length;

      if (bytes >= jsonThresholdBytes) {
        // Offload to background isolate with performance metrics
        return AppCompute.run(
          _jsonDecodeTask,
          transformed,
          label: 'Dio JSON Decode (${(bytes / 1024).toStringAsFixed(1)} KB)',
        );
      } else {
        // Small payload: decode on main thread to avoid isolate overhead
        return jsonDecode(transformed);
      }
    }

    return transformed;
  }
}

/// Top-level function for Isolate compatibility
dynamic _jsonDecodeTask(String source) => jsonDecode(source);
