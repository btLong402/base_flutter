import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// A secure storage wrapper that provides unified logging and error handling.
///
/// This class wraps [FlutterSecureStorage] to ensure that all sensitive data
/// operations are properly logged and exceptions are handled gracefully.
@lazySingleton
class SecureStorage {
  /// Creates a new [SecureStorage] instance.
  SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  /// Writes a [value] to secure storage with the given [key].
  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } on Object catch (e, s) {
      developer.log(
        'Failed to write to secure storage: $key',
        name: 'core.storage.secure',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  /// Reads a value from secure storage with the given [key].
  ///
  /// Returns null if the key does not exist.
  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } on Object catch (e, s) {
      developer.log(
        'Failed to read from secure storage: $key',
        name: 'core.storage.secure',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  /// Deletes a value from secure storage with the given [key].
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } on Object catch (e, s) {
      developer.log(
        'Failed to delete from secure storage: $key',
        name: 'core.storage.secure',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  /// Deletes all values from secure storage.
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } on Object catch (e, s) {
      developer.log(
        'Failed to clear secure storage',
        name: 'core.storage.secure',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  /// Checks if secure storage contains the given [key].
  Future<bool> containsKey({required String key}) async {
    try {
      return await _storage.containsKey(key: key);
    } on Object catch (e, s) {
      developer.log(
        'Failed to check key existence in secure storage: $key',
        name: 'core.storage.secure',
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }
}
