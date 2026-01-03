import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'encryption_service.dart';

/// Service for storing encrypted data locally using SharedPreferences
/// All data is encrypted before storage and decrypted on retrieval
class EncryptedStorageService {
  static final EncryptedStorageService _instance =
      EncryptedStorageService._internal();
  factory EncryptedStorageService() => _instance;
  EncryptedStorageService._internal();

  final _encryptionService = EncryptionService();
  SharedPreferences? _prefs;

  /// Initialize the storage service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _encryptionService.initialize();
  }

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Store an encrypted string value
  Future<bool> setString(String key, String value) async {
    try {
      final encrypted = await _encryptionService.encryptString(value);
      final prefs = await _preferences;
      return await prefs.setString(key, encrypted);
    } catch (e) {
      return false;
    }
  }

  /// Retrieve and decrypt a string value
  Future<String?> getString(String key) async {
    try {
      final prefs = await _preferences;
      final encrypted = prefs.getString(key);
      if (encrypted == null) return null;

      return await _encryptionService.decryptString(encrypted);
    } catch (e) {
      return null;
    }
  }

  /// Store an encrypted JSON object
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final encrypted = await _encryptionService.encryptMap(value);
      final jsonString = jsonEncode(encrypted);
      final prefs = await _preferences;
      return await prefs.setString(key, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Retrieve and decrypt a JSON object
  Future<Map<String, dynamic>?> getJson(String key) async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(key);
      if (jsonString == null) return null;

      final encrypted = jsonDecode(jsonString) as Map<String, dynamic>;
      return await _encryptionService.decryptMap(encrypted);
    } catch (e) {
      return null;
    }
  }

  /// Store an encrypted list
  Future<bool> setList(String key, List<String> values) async {
    try {
      final encrypted = <String>[];
      for (var value in values) {
        encrypted.add(await _encryptionService.encryptString(value));
      }
      final prefs = await _preferences;
      return await prefs.setStringList(key, encrypted);
    } catch (e) {
      return false;
    }
  }

  /// Retrieve and decrypt a list
  Future<List<String>?> getList(String key) async {
    try {
      final prefs = await _preferences;
      final encrypted = prefs.getStringList(key);
      if (encrypted == null) return null;

      final decrypted = <String>[];
      for (var value in encrypted) {
        decrypted.add(await _encryptionService.decryptString(value));
      }
      return decrypted;
    } catch (e) {
      return null;
    }
  }

  /// Store an integer (not encrypted, as it's not sensitive)
  Future<bool> setInt(String key, int value) async {
    final prefs = await _preferences;
    return await prefs.setInt(key, value);
  }

  /// Retrieve an integer
  Future<int?> getInt(String key) async {
    final prefs = await _preferences;
    return prefs.getInt(key);
  }

  /// Store a double (not encrypted, as it's not sensitive)
  Future<bool> setDouble(String key, double value) async {
    final prefs = await _preferences;
    return await prefs.setDouble(key, value);
  }

  /// Retrieve a double
  Future<double?> getDouble(String key) async {
    final prefs = await _preferences;
    return prefs.getDouble(key);
  }

  /// Store a boolean (not encrypted, as it's not sensitive)
  Future<bool> setBool(String key, bool value) async {
    final prefs = await _preferences;
    return await prefs.setBool(key, value);
  }

  /// Retrieve a boolean
  Future<bool?> getBool(String key) async {
    final prefs = await _preferences;
    return prefs.getBool(key);
  }

  /// Remove a key
  Future<bool> remove(String key) async {
    final prefs = await _preferences;
    return await prefs.remove(key);
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    final prefs = await _preferences;
    return prefs.containsKey(key);
  }

  /// Clear all stored data
  Future<bool> clear() async {
    final prefs = await _preferences;
    return await prefs.clear();
  }

  /// Get all keys
  Future<Set<String>> getKeys() async {
    final prefs = await _preferences;
    return prefs.getKeys();
  }
}
