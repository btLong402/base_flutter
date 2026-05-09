import 'dart:async';
import 'dart:isolate';

import 'package:base_flutter/core/base/utils/logger.dart';

/// A callback function used for background computations.
///
/// [T] is the type of the input message.
/// [R] is the type of the result.
typedef ComputeCallback<T, R> = FutureOr<R> Function(T message);

/// A professional-grade utility for offloading heavy computations to background isolates.
///
/// This utility uses [Isolate.run] for efficient data transfer and provides built-in
/// monitoring, logging, and timeout support.
///
/// ### Important Constraints:
/// - **Sendable Objects:** Only "sendable" objects can be passed to or returned from isolates.
///   This includes primitive types (null, num, bool, double, String), [SendPort], [Capability],
///   and [List]/[Map] containing only sendable objects.
/// - **No UI Objects:** Do NOT pass `BuildContext`, `Widget`, `Controller`, or `Socket` objects.
/// - **Closures:** Closures must be static or top-level functions.
abstract class AppCompute {
  /// Runs a heavy computation in a background isolate.
  ///
  /// [callback] must be a static or top-level function.
  /// [message] is the data to be processed.
  /// [label] is an optional identifier for logging and performance tracking.
  /// [timeout] defines the maximum wait time for the caller. Note that the isolate
  /// might continue running in the background even after a timeout.
  /// [logResult] if true, will log the result of the computation (use with caution for large data).
  ///
  /// Example:
  /// ```dart
  /// final result = await AppCompute.run(
  ///   (data) => data.sort(),
  ///   largeList,
  ///   label: 'Sorting large list',
  ///   timeout: Duration(seconds: 5),
  /// );
  /// ```
  static Future<R> run<T, R>(
    ComputeCallback<T, R> callback,
    T message, {
    String? label,
    Duration? timeout,
    bool logResult = false,
  }) async {
    final effectiveLabel = label ?? 'Task';
    final stopwatch = Stopwatch()..start();

    AppLogger.i('[Compute] Start: $effectiveLabel');

    try {
      var computation = Isolate.run(() => callback(message));

      if (timeout != null) {
        computation = computation.timeout(timeout);
      }

      final result = await computation;
      stopwatch.stop();

      AppLogger.i(
        '[Compute] Done: $effectiveLabel in ${stopwatch.elapsedMilliseconds}ms'
        '${logResult ? ' | Result: $result' : ''}',
      );

      return result;
    } on TimeoutException catch (e, stackTrace) {
      stopwatch.stop();
      AppLogger.e(
        '[Compute] Timeout: $effectiveLabel after ${stopwatch.elapsedMilliseconds}ms',
        e,
        stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      stopwatch.stop();
      AppLogger.e(
        '[Compute] Failure: $effectiveLabel after ${stopwatch.elapsedMilliseconds}ms',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Specialized helper for mapping a large list of objects in the background.
  ///
  /// [items] is the raw list (usually from JSON).
  /// [mapper] is the function that converts each item (e.g., Model.fromJson).
  static Future<List<R>> mapList<T, R>(
    List<T> items,
    R Function(T) mapper, {
    String? label,
  }) {
    return run(
      (list) => list.map(mapper).toList(),
      items,
      label: label ?? 'Map List<$R>',
    );
  }
}
