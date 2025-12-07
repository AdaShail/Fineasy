import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'encryption_service.dart';

/// Service for managing encrypted SQLite database
/// Provides encryption for sensitive fields in database tables
class EncryptedDatabaseService {
  static final EncryptedDatabaseService _instance =
      EncryptedDatabaseService._internal();
  factory EncryptedDatabaseService() => _instance;
  EncryptedDatabaseService._internal();

  final _encryptionService = EncryptionService();
  Database? _database;

  /// Initialize the database
  Future<void> initialize() async {
    await _encryptionService.initialize();
    await _getDatabase();
    debugPrint('Encrypted database service initialized');
  }

  Future<Database> _getDatabase() async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'fineasy_encrypted.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create encrypted data table
    await db.execute('''
      CREATE TABLE encrypted_data (
        id TEXT PRIMARY KEY,
        table_name TEXT NOT NULL,
        encrypted_data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create index for faster lookups
    await db.execute('''
      CREATE INDEX idx_encrypted_data_table 
      ON encrypted_data(table_name)
    ''');

    debugPrint('Database tables created');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion');
    // Handle database migrations here
  }

  /// Insert encrypted data
  Future<int> insertEncrypted({
    required String tableName,
    required String id,
    required Map<String, dynamic> data,
    List<String>? sensitiveFields,
  }) async {
    try {
      final db = await _getDatabase();

      // Encrypt sensitive fields if specified
      Map<String, dynamic> dataToStore = data;
      if (sensitiveFields != null && sensitiveFields.isNotEmpty) {
        dataToStore = await _encryptionService.encryptSensitiveFields(
          data,
          sensitiveFields,
        );
      }

      final encryptedJson = jsonEncode(dataToStore);
      final now = DateTime.now().millisecondsSinceEpoch;

      return await db.insert('encrypted_data', {
        'id': id,
        'table_name': tableName,
        'encrypted_data': encryptedJson,
        'created_at': now,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('Failed to insert encrypted data: $e');
      rethrow;
    }
  }

  /// Update encrypted data
  Future<int> updateEncrypted({
    required String tableName,
    required String id,
    required Map<String, dynamic> data,
    List<String>? sensitiveFields,
  }) async {
    try {
      final db = await _getDatabase();

      // Encrypt sensitive fields if specified
      Map<String, dynamic> dataToStore = data;
      if (sensitiveFields != null && sensitiveFields.isNotEmpty) {
        dataToStore = await _encryptionService.encryptSensitiveFields(
          data,
          sensitiveFields,
        );
      }

      final encryptedJson = jsonEncode(dataToStore);
      final now = DateTime.now().millisecondsSinceEpoch;

      return await db.update(
        'encrypted_data',
        {'encrypted_data': encryptedJson, 'updated_at': now},
        where: 'id = ? AND table_name = ?',
        whereArgs: [id, tableName],
      );
    } catch (e) {
      debugPrint('Failed to update encrypted data: $e');
      rethrow;
    }
  }

  /// Query encrypted data by ID
  Future<Map<String, dynamic>?> queryById({
    required String tableName,
    required String id,
    List<String>? sensitiveFields,
  }) async {
    try {
      final db = await _getDatabase();

      final results = await db.query(
        'encrypted_data',
        where: 'id = ? AND table_name = ?',
        whereArgs: [id, tableName],
      );

      if (results.isEmpty) return null;

      final encryptedJson = results.first['encrypted_data'] as String;
      final data = jsonDecode(encryptedJson) as Map<String, dynamic>;

      // Decrypt sensitive fields if specified
      if (sensitiveFields != null && sensitiveFields.isNotEmpty) {
        return await _encryptionService.decryptSensitiveFields(
          data,
          sensitiveFields,
        );
      }

      return data;
    } catch (e) {
      debugPrint('Failed to query encrypted data: $e');
      return null;
    }
  }

  /// Query all encrypted data for a table
  Future<List<Map<String, dynamic>>> queryAll({
    required String tableName,
    List<String>? sensitiveFields,
  }) async {
    try {
      final db = await _getDatabase();

      final results = await db.query(
        'encrypted_data',
        where: 'table_name = ?',
        whereArgs: [tableName],
      );

      final decryptedResults = <Map<String, dynamic>>[];

      for (var result in results) {
        final encryptedJson = result['encrypted_data'] as String;
        final data = jsonDecode(encryptedJson) as Map<String, dynamic>;

        // Decrypt sensitive fields if specified
        if (sensitiveFields != null && sensitiveFields.isNotEmpty) {
          final decrypted = await _encryptionService.decryptSensitiveFields(
            data,
            sensitiveFields,
          );
          decryptedResults.add(decrypted);
        } else {
          decryptedResults.add(data);
        }
      }

      return decryptedResults;
    } catch (e) {
      debugPrint('Failed to query all encrypted data: $e');
      return [];
    }
  }

  /// Delete encrypted data
  Future<int> deleteEncrypted({
    required String tableName,
    required String id,
  }) async {
    try {
      final db = await _getDatabase();

      return await db.delete(
        'encrypted_data',
        where: 'id = ? AND table_name = ?',
        whereArgs: [id, tableName],
      );
    } catch (e) {
      debugPrint('Failed to delete encrypted data: $e');
      rethrow;
    }
  }

  /// Delete all data for a table
  Future<int> deleteAllForTable(String tableName) async {
    try {
      final db = await _getDatabase();

      return await db.delete(
        'encrypted_data',
        where: 'table_name = ?',
        whereArgs: [tableName],
      );
    } catch (e) {
      debugPrint('Failed to delete all data for table: $e');
      rethrow;
    }
  }

  /// Batch insert encrypted data
  Future<void> batchInsertEncrypted({
    required String tableName,
    required List<Map<String, dynamic>> dataList,
    List<String>? sensitiveFields,
  }) async {
    try {
      final db = await _getDatabase();
      final batch = db.batch();
      final now = DateTime.now().millisecondsSinceEpoch;

      for (var data in dataList) {
        // Encrypt sensitive fields if specified
        Map<String, dynamic> dataToStore = data;
        if (sensitiveFields != null && sensitiveFields.isNotEmpty) {
          dataToStore = await _encryptionService.encryptSensitiveFields(
            data,
            sensitiveFields,
          );
        }

        final encryptedJson = jsonEncode(dataToStore);
        final id =
            data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

        batch.insert('encrypted_data', {
          'id': id,
          'table_name': tableName,
          'encrypted_data': encryptedJson,
          'created_at': now,
          'updated_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Failed to batch insert encrypted data: $e');
      rethrow;
    }
  }

  /// Close the database
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
      debugPrint('Database closed');
    }
  }

  /// Clear all encrypted data (use with caution)
  Future<void> clearAll() async {
    try {
      final db = await _getDatabase();
      await db.delete('encrypted_data');
      debugPrint('All encrypted data cleared');
    } catch (e) {
      debugPrint('Failed to clear all data: $e');
      rethrow;
    }
  }
}
