import 'dart:async';

import 'package:base_flutter/core/base/utils/app_compute.dart';
import 'package:flutter_test/flutter_test.dart';

// Top-level functions for Isolate compatibility
int _simpleTask(int value) => value * 2;

int _heavyTask(int count) {
  var result = 0;
  for (var i = 0; i < count; i++) {
    result += i;
  }
  return result;
}

Future<int> _errorTask(String _) async {
  throw Exception('Test calculation error');
}

List<int> _sortTask(List<int> list) {
  final copy = List<int>.from(list)..sort();
  return copy;
}

void main() {
  group('AppCompute Tests', () {
    test('should execute simple task correctly', () async {
      final result = await AppCompute.run(
        _simpleTask,
        21,
        label: 'Simple Double',
      );
      expect(result, equals(42));
    });

    test('should execute heavy task correctly', () async {
      final result = await AppCompute.run(
        _heavyTask,
        1000000,
        label: 'Sum to 1M',
      );
      expect(result, isPositive);
    });

    test('should handle and rethrow errors', () async {
      expect(
        () => AppCompute.run(_errorTask, 'test', label: 'Error Task'),
        throwsException,
      );
    });

    test('should handle timeout', () async {
      expect(
        () => AppCompute.run(
          (_) async => Future<void>.delayed(const Duration(seconds: 2)),
          null,
          label: 'Hanging Task',
          timeout: const Duration(milliseconds: 100),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('should handle large data transfer and sorting', () async {
      final largeList = List.generate(10000, (index) => 10000 - index);
      final result = await AppCompute.run(
        _sortTask,
        largeList,
        label: 'Sort 10k items',
      );

      expect(result.length, equals(10000));
      expect(result.first, equals(1));
      expect(result.last, equals(10000));
    });

    test('should support concurrent executions', () async {
      final futures = List.generate(
        5,
        (i) => AppCompute.run(_simpleTask, i, label: 'Concurrent Task $i'),
      );

      final results = await Future.wait(futures);
      expect(results, equals([0, 2, 4, 6, 8]));
    });
  });
}
