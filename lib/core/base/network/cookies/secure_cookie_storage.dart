import 'package:base_flutter/core/base/storage/secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart';

/// A [Storage] implementation for [PersistCookieJar] that uses [SecureStorage]
/// to encrypt cookies on the device.
class SecureCookieStorage implements Storage {
  SecureCookieStorage(this._secureStorage);

  final SecureStorage _secureStorage;

  @override
  Future<void> init(bool persist, bool ignoreCase) async {
    // No initialization needed for SecureStorage wrapper
  }

  @override
  Future<String?> read(String key) async {
    return _secureStorage.read(key: 'cookie_$key');
  }

  @override
  Future<void> write(String key, String value) async {
    await _secureStorage.write(key: 'cookie_$key', value: value);
  }

  @override
  Future<void> delete(String key) async {
    await _secureStorage.delete(key: 'cookie_$key');
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }
}
