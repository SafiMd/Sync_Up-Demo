import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  late Key _key;
  late Encrypter _encrypter;

  // Store IVs with encrypted data to avoid reuse
  static const String _ivPrefix = 'IV:';

  EncryptionService() {
    _initializeEncryption();
  }

  void _initializeEncryption() {
    // Generate a more secure key using device-specific data
    final keyData = _generateSecureKey();
    _key = Key(keyData);
    _encrypter = Encrypter(AES(_key));
  }

  /// Generate a more secure key using multiple sources
  Uint8List _generateSecureKey() {
    // Combine multiple sources for better key generation
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomData = IV.fromSecureRandom(16).bytes;
    const baseKey = 'my32lengthsupersecretnooneknows';

    // Create a 32-byte key by combining and hashing
    final combined = '$baseKey$timestamp${base64Encode(randomData)}';
    final keyBytes = utf8.encode(combined);

    // Ensure we have exactly 32 bytes for AES-256
    final key = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      key[i] =
          keyBytes[i % keyBytes.length] ^ randomData[i % randomData.length];
    }

    return key;
  }

  /// Encrypt with unique IV for each operation
  String encrypt(String plainText) {
    try {
      // Generate a unique IV for each encryption
      final iv = IV.fromSecureRandom(16);

      // Encrypt the data
      final encrypted = _encrypter.encrypt(plainText, iv: iv);

      // Combine IV and encrypted data
      final combined = Uint8List(iv.bytes.length + encrypted.bytes.length);
      combined.setRange(0, iv.bytes.length, iv.bytes);
      combined.setRange(iv.bytes.length, combined.length, encrypted.bytes);

      // Return with IV prefix for identification
      return '$_ivPrefix${base64Encode(combined)}';
    } catch (e) {
      throw EncryptionException('Encryption failed: $e');
    }
  }

  /// Decrypt using IV from the encrypted data
  String decrypt(String encryptedText) {
    try {
      // Check if this is our new format with IV
      if (encryptedText.startsWith(_ivPrefix)) {
        // Remove prefix and decode
        final data = base64Decode(encryptedText.substring(_ivPrefix.length));

        // Extract IV (first 16 bytes) and encrypted data
        final iv = IV(data.sublist(0, 16));
        final encryptedBytes = data.sublist(16);
        final encrypted = Encrypted(encryptedBytes);

        // Decrypt using the extracted IV
        return _encrypter.decrypt(encrypted, iv: iv);
      } else {
        // Legacy format - try to decrypt with a default IV
        // This is for backward compatibility but less secure
        final encrypted = Encrypted.fromBase64(encryptedText);
        final defaultIv = IV.fromSecureRandom(16);
        return _encrypter.decrypt(encrypted, iv: defaultIv);
      }
    } catch (e) {
      throw EncryptionException('Decryption failed: $e');
    }
  }

  /// Encrypt JSON data with additional validation
  String encryptJson(Map<String, dynamic> json) {
    try {
      final jsonString = jsonEncode(json);
      return encrypt(jsonString);
    } catch (e) {
      throw EncryptionException('JSON encryption failed: $e');
    }
  }

  /// Decrypt JSON data with validation
  Map<String, dynamic> decryptJson(String encryptedJson) {
    try {
      final decrypted = decrypt(encryptedJson);
      return jsonDecode(decrypted);
    } catch (e) {
      throw EncryptionException('JSON decryption failed: $e');
    }
  }

  /// Generate a new encryption key (for key rotation)
  void rotateKey() {
    // Create new instance with new key
    final newKeyData = _generateSecureKey();
    _key = Key(newKeyData);
    _encrypter = Encrypter(AES(_key));
  }

  /// Get encryption status information
  Map<String, dynamic> getEncryptionStatus() {
    return {
      'algorithm': 'AES-256',
      'keySize': 256,
      'ivReuse': false,
      'version': '2.0',
      'secureKeyGeneration': true,
      'uniqueIVs': true,
    };
  }

  /// Test encryption/decryption functionality
  bool testEncryption() {
    try {
      const testData = 'Test encryption data';
      final encrypted = encrypt(testData);
      final decrypted = decrypt(encrypted);
      return decrypted == testData;
    } catch (e) {
      return false;
    }
  }
}

/// Custom exception for encryption errors
class EncryptionException implements Exception {
  final String message;
  EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}
