import 'package:base_flutter/core/base/constants/app_constants.dart';
import 'package:base_flutter/core/base/storage/secure_storage.dart';
import 'package:encrypt/encrypt.dart';
import 'package:injectable/injectable.dart';
import 'package:pointycastle/asymmetric/api.dart';

abstract class CryptoService {
  Future<String> encrypt(String plainText, {Key? key, IV? iv});
  Future<String> decrypt(String cipherText, {Key? key, IV? iv});
  Future<({String payload, String encryptedKey})> encryptHybrid(
    String plainText, {
    String? publicKey,
  });
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
      final createdAtStr = await _secureStorage.read(
        key: AppConstants.cryptoKeyCreatedAt,
      );
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

    await _secureStorage.write(
      key: AppConstants.cryptoAesKey,
      value: _key!.base64,
    );
    await _secureStorage.write(
      key: AppConstants.cryptoAesIv,
      value: _iv!.base64,
    );
    await _secureStorage.write(
      key: AppConstants.cryptoKeyCreatedAt,
      value: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<String> encrypt(String plainText, {Key? key, IV? iv}) async {
    await _ensureInitialized();
    final effectiveKey = key ?? _key!;
    final effectiveIv = iv ?? _iv!;
    final encrypter = Encrypter(AES(effectiveKey, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: effectiveIv);
    return encrypted.base64;
  }

  @override
  Future<String> decrypt(String cipherText, {Key? key, IV? iv}) async {
    await _ensureInitialized();
    final effectiveKey = key ?? _key!;
    final effectiveIv = iv ?? _iv!;
    final encrypter = Encrypter(AES(effectiveKey, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt64(cipherText, iv: effectiveIv);
    return decrypted;
  }

  @override
  Future<({String payload, String encryptedKey})> encryptHybrid(
    String plainText, {
    String? publicKey,
  }) async {
    // 1. Generate fresh AES Key and IV for this request
    final aesKey = Key.fromSecureRandom(32);
    final aesIv = IV.fromSecureRandom(16);

    // 2. Encrypt body using AES
    final payload = await encrypt(plainText, key: aesKey, iv: aesIv);

    // 3. Encrypt AES Key + IV using Server's RSA Public Key
    final keyPackage = '${aesKey.base64}:${aesIv.base64}';

    final rsaKey = publicKey ?? AppConstants.serverRsaPublicKey;
    final rsaEncrypter = Encrypter(RSA(publicKey: _parsePublicKey(rsaKey)));
    final encryptedKey = rsaEncrypter.encrypt(keyPackage).base64;

    return (payload: payload, encryptedKey: encryptedKey);
  }

  RSAPublicKey _parsePublicKey(String pem) {
    return RSAKeyParser().parse(pem) as RSAPublicKey;
  }
}
