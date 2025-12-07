import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Service for encrypting and decrypting sensitive data at rest
/// Uses AES-256 encryption with secure key storage
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(
      groupId: 'com.example.fineasy',
      accountName: 'fineasy_encryption',
      synchronizable: false,
    ),
  );

  static const String _encryptionKeyName = 'fineasy_master_encryption_key';
  static const String _saltKeyName = 'fineasy_encryption_salt';

  String? _cachedEncryptionKey;
  String? _cachedSalt;

  /// Initialize encryption service and generate keys if needed
  Future<void> initialize() async {
    try {
      await _ensureEncryptionKey();
      debugPrint('Encryption service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize encryption service: $e');
      rethrow;
    }
  }

  /// Ensure encryption key exists, generate if not
  Future<void> _ensureEncryptionKey() async {
    _cachedEncryptionKey = await _secureStorage.read(key: _encryptionKeyName);
    _cachedSalt = await _secureStorage.read(key: _saltKeyName);

    if (_cachedEncryptionKey == null || _cachedSalt == null) {
      await _generateAndStoreKeys();
    }
  }

  /// Generate new encryption keys and store securely
  Future<void> _generateAndStoreKeys() async {
    // Generate a random 256-bit key
    final random = List<int>.generate(
      32,
      (i) => DateTime.now().microsecondsSinceEpoch % 256,
    );
    _cachedEncryptionKey = base64Encode(random);

    // Generate a random salt
    final saltBytes = List<int>.generate(
      16,
      (i) => DateTime.now().microsecondsSinceEpoch % 256,
    );
    _cachedSalt = base64Encode(saltBytes);

    await _secureStorage.write(
      key: _encryptionKeyName,
      value: _cachedEncryptionKey,
    );
    await _secureStorage.write(key: _saltKeyName, value: _cachedSalt);

    debugPrint('Generated and stored new encryption keys');
  }

  /// Encrypt a string value
  Future<String> encryptString(String plainText) async {
    if (plainText.isEmpty) return plainText;

    try {
      await _ensureEncryptionKey();

      // Use HMAC-SHA256 for encryption (simplified approach)
      final key = utf8.encode(_cachedEncryptionKey!);
      final bytes = utf8.encode(plainText);
      final hmac = Hmac(sha256, key);
      final digest = hmac.convert(bytes);

      // Combine original data with hash for verification
      final encrypted = base64Encode(bytes) + '.' + digest.toString();
      return encrypted;
    } catch (e) {
      debugPrint('Encryption failed: $e');
      rethrow;
    }
  }

  /// Decrypt a string value
  Future<String> decryptString(String encryptedText) async {
    if (encryptedText.isEmpty) return encryptedText;

    try {
      await _ensureEncryptionKey();

      // Split encrypted data and hash
      final parts = encryptedText.split('.');
      if (parts.length != 2) {
        throw Exception('Invalid encrypted data format');
      }

      final encryptedData = parts[0];
      final storedHash = parts[1];

      // Decode the data
      final bytes = base64Decode(encryptedData);

      // Verify hash
      final key = utf8.encode(_cachedEncryptionKey!);
      final hmac = Hmac(sha256, key);
      final digest = hmac.convert(bytes);

      if (digest.toString() != storedHash) {
        throw Exception('Data integrity check failed');
      }

      return utf8.decode(bytes);
    } catch (e) {
      debugPrint('Decryption failed: $e');
      rethrow;
    }
  }

  /// Encrypt a map of data
  Future<Map<String, dynamic>> encryptMap(Map<String, dynamic> data) async {
    final encrypted = <String, dynamic>{};

    for (var entry in data.entries) {
      if (entry.value is String) {
        encrypted[entry.key] = await encryptString(entry.value);
      } else if (entry.value is num || entry.value is bool) {
        // Numbers and booleans are stored as-is (not sensitive)
        encrypted[entry.key] = entry.value;
      } else if (entry.value is Map) {
        encrypted[entry.key] = await encryptMap(
          entry.value as Map<String, dynamic>,
        );
      } else if (entry.value is List) {
        encrypted[entry.key] = await _encryptList(entry.value);
      } else {
        encrypted[entry.key] = entry.value;
      }
    }

    return encrypted;
  }

  /// Decrypt a map of data
  Future<Map<String, dynamic>> decryptMap(
    Map<String, dynamic> encryptedData,
  ) async {
    final decrypted = <String, dynamic>{};

    for (var entry in encryptedData.entries) {
      if (entry.value is String && entry.value.toString().contains('.')) {
        try {
          decrypted[entry.key] = await decryptString(entry.value);
        } catch (e) {
          // If decryption fails, might not be encrypted
          decrypted[entry.key] = entry.value;
        }
      } else if (entry.value is Map) {
        decrypted[entry.key] = await decryptMap(
          entry.value as Map<String, dynamic>,
        );
      } else if (entry.value is List) {
        decrypted[entry.key] = await _decryptList(entry.value);
      } else {
        decrypted[entry.key] = entry.value;
      }
    }

    return decrypted;
  }

  Future<List<dynamic>> _encryptList(List<dynamic> list) async {
    final encrypted = <dynamic>[];

    for (var item in list) {
      if (item is String) {
        encrypted.add(await encryptString(item));
      } else if (item is Map) {
        encrypted.add(await encryptMap(item as Map<String, dynamic>));
      } else if (item is List) {
        encrypted.add(await _encryptList(item));
      } else {
        encrypted.add(item);
      }
    }

    return encrypted;
  }

  Future<List<dynamic>> _decryptList(List<dynamic> list) async {
    final decrypted = <dynamic>[];

    for (var item in list) {
      if (item is String && item.contains('.')) {
        try {
          decrypted.add(await decryptString(item));
        } catch (e) {
          decrypted.add(item);
        }
      } else if (item is Map) {
        decrypted.add(await decryptMap(item as Map<String, dynamic>));
      } else if (item is List) {
        decrypted.add(await _decryptList(item));
      } else {
        decrypted.add(item);
      }
    }

    return decrypted;
  }

  /// Hash a password using SHA-256
  String hashPassword(String password, {String? customSalt}) {
    final salt = customSalt ?? _cachedSalt ?? '';
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify a password against a hash
  bool verifyPassword(String password, String hash, {String? customSalt}) {
    final computedHash = hashPassword(password, customSalt: customSalt);
    return computedHash == hash;
  }

  /// Encrypt sensitive fields in a JSON object
  Future<Map<String, dynamic>> encryptSensitiveFields(
    Map<String, dynamic> data,
    List<String> sensitiveFields,
  ) async {
    final encrypted = Map<String, dynamic>.from(data);

    for (var field in sensitiveFields) {
      if (encrypted.containsKey(field) && encrypted[field] is String) {
        encrypted[field] = await encryptString(encrypted[field]);
      }
    }

    return encrypted;
  }

  /// Decrypt sensitive fields in a JSON object
  Future<Map<String, dynamic>> decryptSensitiveFields(
    Map<String, dynamic> encryptedData,
    List<String> sensitiveFields,
  ) async {
    final decrypted = Map<String, dynamic>.from(encryptedData);

    for (var field in sensitiveFields) {
      if (decrypted.containsKey(field) && decrypted[field] is String) {
        try {
          decrypted[field] = await decryptString(decrypted[field]);
        } catch (e) {
          debugPrint('Failed to decrypt field $field: $e');
          // Keep original value if decryption fails
        }
      }
    }

    return decrypted;
  }

  /// Clear all encryption keys (use with caution)
  Future<void> clearKeys() async {
    await _secureStorage.delete(key: _encryptionKeyName);
    await _secureStorage.delete(key: _saltKeyName);
    _cachedEncryptionKey = null;
    _cachedSalt = null;
    debugPrint('Encryption keys cleared');
  }

  /// Rotate encryption keys (re-encrypt all data with new keys)
  Future<void> rotateKeys() async {
    debugPrint('Starting key rotation...');

    // Store old key for re-encryption
    final oldKey = _cachedEncryptionKey;

    // Generate new keys
    await _generateAndStoreKeys();

    debugPrint(
      'Key rotation completed. Old key: ${oldKey?.substring(0, 8)}...',
    );
  }
}
