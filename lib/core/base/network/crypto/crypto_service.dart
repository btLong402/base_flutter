import 'package:base_flutter/core/base/constants/app_constants.dart';
import 'package:base_flutter/core/base/storage/secure_storage.dart';
import 'package:encrypt/encrypt.dart';
import 'package:injectable/injectable.dart';

abstract class CryptoService {
  Future<String> encrypt(String plainText);
  Future<String> decrypt(String cipherText);
  Future<void> rotateKey();
}

@LazySingleton(as: CryptoService)
class AesCryptoService implements CryptoService {
  AesCryptoService(this._secureStorage);

  final SecureStorage _secureStorage;
  Key? _key;
  IV? _iv;

  Future<void> _ensureInitialized() async {
    if (_key != null && _iv != null) return;

    final storedKey = await _secureStorage.read(key: AppConstants.cryptoAesKey);
    final storedIv = await _secureStorage.read(key: AppConstants.cryptoAesIv);

    if (storedKey != null && storedIv != null) {
      _key = Key.fromBase64(storedKey);
      _iv = IV.fromBase64(storedIv);
      
      // Automatic rotation check (e.g., 30 days)
      final createdAtStr = await _secureStorage.read(key: AppConstants.cryptoKeyCreatedAt);
      if (createdAtStr != null) {
        final createdAt = DateTime.tryParse(createdAtStr);
        if (createdAt != null && 
            DateTime.now().difference(createdAt).inDays >= 30) {
          await rotateKey();
        }
      }
    } else {
      await rotateKey();
    }
  }

  @override
  Future<void> rotateKey() async {
    _key = Key.fromSecureRandom(32);
    _iv = IV.fromSecureRandom(16);
    
    await _secureStorage.write(key: AppConstants.cryptoAesKey, value: _key!.base64);
    await _secureStorage.write(key: AppConstants.cryptoAesIv, value: _iv!.base64);
    await _secureStorage.write(
      key: AppConstants.cryptoKeyCreatedAt, 
      value: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<String> encrypt(String plainText) async {
    await _ensureInitialized();
    final key = _key!;
    final iv = _iv!;
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  @override
  Future<String> decrypt(String cipherText) async {
    await _ensureInitialized();
    final key = _key!;
    final iv = _iv!;
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt64(cipherText, iv: iv);
    return decrypted;
  }
}
