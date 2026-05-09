import 'package:base_flutter/core/base/constants/app_constants.dart';
import 'package:base_flutter/core/base/network/crypto/crypto_service.dart';
import 'package:base_flutter/core/base/storage/secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  late AesCryptoService cryptoService;
  late MockSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockSecureStorage();
    cryptoService = AesCryptoService(mockSecureStorage);
  });

  group('AesCryptoService', () {
    test('should encrypt and decrypt correctly', () async {
      // Arrange
      const plainText = 'Hello World';
      when(
        () => mockSecureStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);
      when(
        () => mockSecureStorage.read(key: AppConstants.cryptoKeyCreatedAt),
      ).thenAnswer((_) async => null);
      when(
        () => mockSecureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      // Act
      final encrypted = await cryptoService.encrypt(plainText);
      final decrypted = await cryptoService.decrypt(encrypted);

      // Assert
      expect(decrypted, equals(plainText));
      expect(encrypted, isNot(equals(plainText)));
    });

    test('should reuse existing keys from storage', () async {
      // Arrange
      const plainText = 'Hello World';
      const fakeKey =
          'MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI='; // 32 bytes base64
      const fakeIv = 'MTIzNDU2Nzg5MDEyMzQ1Ng=='; // 16 bytes base64

      when(
        () => mockSecureStorage.read(key: 'crypto_aes_key'),
      ).thenAnswer((_) async => fakeKey);
      when(
        () => mockSecureStorage.read(key: 'crypto_aes_iv'),
      ).thenAnswer((_) async => fakeIv);
      when(
        () => mockSecureStorage.read(key: AppConstants.cryptoKeyCreatedAt),
      ).thenAnswer((_) async => DateTime.now().toIso8601String());

      // Act
      final encrypted = await cryptoService.encrypt(plainText);
      final decrypted = await cryptoService.decrypt(encrypted);

      // Assert
      expect(decrypted, equals(plainText));
      verify(() => mockSecureStorage.read(key: 'crypto_aes_key')).called(1);
    });

    test('should rotate key and update timestamp', () async {
      // Arrange
      when(
        () => mockSecureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await cryptoService.rotateKey();

      // Assert
      verify(
        () => mockSecureStorage.write(
          key: AppConstants.cryptoAesKey,
          value: any(named: 'value'),
        ),
      ).called(1);
      verify(
        () => mockSecureStorage.write(
          key: AppConstants.cryptoAesIv,
          value: any(named: 'value'),
        ),
      ).called(1);
      verify(
        () => mockSecureStorage.write(
          key: AppConstants.cryptoKeyCreatedAt,
          value: any(named: 'value'),
        ),
      ).called(1);
    });
  });
}
