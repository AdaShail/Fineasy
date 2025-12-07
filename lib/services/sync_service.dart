import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../utils/constants.dart';
import '../models/transaction_model.dart';
import '../models/customer_model.dart';
import '../models/supplier_model.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  late SharedPreferences _prefs;

  static Future<void> initialize() async {
    final instance = SyncService();
    instance._prefs = await SharedPreferences.getInstance();
  }

  // Get pending sync items count
  Future<int> getPendingSyncItemsCount() async {
    final transactions = await _getOfflineTransactions();
    final customers = await _getOfflineCustomers();
    final suppliers = await _getOfflineSuppliers();

    return transactions.length + customers.length + suppliers.length;
  }

  // Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final timestamp = _prefs.getInt('last_sync_time');
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  // Set last sync time
  Future<void> _setLastSyncTime() async {
    await _prefs.setInt(
      'last_sync_time',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Sync all data
  Future<void> syncAllData() async {
    await Future.wait([syncTransactions(), syncCustomers(), syncSuppliers()]);
    await _setLastSyncTime();
  }

  // Sync transactions
  Future<void> syncTransactions() async {
    final offlineTransactions = await _getOfflineTransactions();

    for (final transactionData in offlineTransactions) {
      try {
        final transaction = TransactionModel.fromJson(transactionData);

        if (transactionData['action'] == 'create') {
          await _supabase.from('transactions').insert(transaction.toJson());
        } else if (transactionData['action'] == 'update') {
          await _supabase
              .from('transactions')
              .update(transaction.toJson())
              .eq('id', transaction.id);
        } else if (transactionData['action'] == 'delete') {
          await _supabase
              .from('transactions')
              .delete()
              .eq('id', transaction.id);
        }

        // Remove from offline queue
        await _removeFromOfflineTransactions(transaction.id);
      } catch (e) {
        // Log error but continue with other transactions
        debugPrint('Failed to sync transaction: $e');
      }
    }
  }

  // Sync customers
  Future<void> syncCustomers() async {
    final offlineCustomers = await _getOfflineCustomers();

    for (final customerData in offlineCustomers) {
      try {
        final customer = CustomerModel.fromJson(customerData);

        if (customerData['action'] == 'create') {
          await _supabase.from('customers').insert(customer.toJson());
        } else if (customerData['action'] == 'update') {
          await _supabase
              .from('customers')
              .update(customer.toJson())
              .eq('id', customer.id);
        } else if (customerData['action'] == 'delete') {
          await _supabase.from('customers').delete().eq('id', customer.id);
        }

        // Remove from offline queue
        await _removeFromOfflineCustomers(customer.id);
      } catch (e) {
        debugPrint('Failed to sync customer: $e');
      }
    }
  }

  // Sync suppliers
  Future<void> syncSuppliers() async {
    final offlineSuppliers = await _getOfflineSuppliers();

    for (final supplierData in offlineSuppliers) {
      try {
        final supplier = SupplierModel.fromJson(supplierData);

        if (supplierData['action'] == 'create') {
          await _supabase.from('suppliers').insert(supplier.toJson());
        } else if (supplierData['action'] == 'update') {
          await _supabase
              .from('suppliers')
              .update(supplier.toJson())
              .eq('id', supplier.id);
        } else if (supplierData['action'] == 'delete') {
          await _supabase.from('suppliers').delete().eq('id', supplier.id);
        }

        // Remove from offline queue
        await _removeFromOfflineSuppliers(supplier.id);
      } catch (e) {
        debugPrint('Failed to sync supplier: $e');
      }
    }
  }

  // Add transaction to offline queue
  Future<void> addTransactionToOfflineQueue(
    TransactionModel transaction,
    String action,
  ) async {
    final offlineTransactions = await _getOfflineTransactions();
    final transactionData = transaction.toJson();
    transactionData['action'] = action;
    transactionData['queued_at'] = DateTime.now().toIso8601String();

    offlineTransactions.add(transactionData);
    await _saveOfflineTransactions(offlineTransactions);
  }

  // Add customer to offline queue
  Future<void> addCustomerToOfflineQueue(
    CustomerModel customer,
    String action,
  ) async {
    final offlineCustomers = await _getOfflineCustomers();
    final customerData = customer.toJson();
    customerData['action'] = action;
    customerData['queued_at'] = DateTime.now().toIso8601String();

    offlineCustomers.add(customerData);
    await _saveOfflineCustomers(offlineCustomers);
  }

  // Add supplier to offline queue
  Future<void> addSupplierToOfflineQueue(
    SupplierModel supplier,
    String action,
  ) async {
    final offlineSuppliers = await _getOfflineSuppliers();
    final supplierData = supplier.toJson();
    supplierData['action'] = action;
    supplierData['queued_at'] = DateTime.now().toIso8601String();

    offlineSuppliers.add(supplierData);
    await _saveOfflineSuppliers(offlineSuppliers);
  }

  // Get offline transactions
  Future<List<Map<String, dynamic>>> _getOfflineTransactions() async {
    final data = _prefs.getString(AppConstants.offlineTransactionsKey);
    if (data == null) return [];

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.cast<Map<String, dynamic>>();
  }

  // Save offline transactions
  Future<void> _saveOfflineTransactions(
    List<Map<String, dynamic>> transactions,
  ) async {
    await _prefs.setString(
      AppConstants.offlineTransactionsKey,
      jsonEncode(transactions),
    );
  }

  // Remove transaction from offline queue
  Future<void> _removeFromOfflineTransactions(String transactionId) async {
    final offlineTransactions = await _getOfflineTransactions();
    offlineTransactions.removeWhere((t) => t['id'] == transactionId);
    await _saveOfflineTransactions(offlineTransactions);
  }

  // Get offline customers
  Future<List<Map<String, dynamic>>> _getOfflineCustomers() async {
    final data = _prefs.getString(AppConstants.offlineCustomersKey);
    if (data == null) return [];

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.cast<Map<String, dynamic>>();
  }

  // Save offline customers
  Future<void> _saveOfflineCustomers(
    List<Map<String, dynamic>> customers,
  ) async {
    await _prefs.setString(
      AppConstants.offlineCustomersKey,
      jsonEncode(customers),
    );
  }

  // Remove customer from offline queue
  Future<void> _removeFromOfflineCustomers(String customerId) async {
    final offlineCustomers = await _getOfflineCustomers();
    offlineCustomers.removeWhere((c) => c['id'] == customerId);
    await _saveOfflineCustomers(offlineCustomers);
  }

  // Get offline suppliers
  Future<List<Map<String, dynamic>>> _getOfflineSuppliers() async {
    final data = _prefs.getString(AppConstants.offlineSuppliersKey);
    if (data == null) return [];

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.cast<Map<String, dynamic>>();
  }

  // Save offline suppliers
  Future<void> _saveOfflineSuppliers(
    List<Map<String, dynamic>> suppliers,
  ) async {
    await _prefs.setString(
      AppConstants.offlineSuppliersKey,
      jsonEncode(suppliers),
    );
  }

  // Remove supplier from offline queue
  Future<void> _removeFromOfflineSuppliers(String supplierId) async {
    final offlineSuppliers = await _getOfflineSuppliers();
    offlineSuppliers.removeWhere((s) => s['id'] == supplierId);
    await _saveOfflineSuppliers(offlineSuppliers);
  }

  // Clear all offline data
  Future<void> clearAllOfflineData() async {
    await Future.wait([
      _prefs.remove(AppConstants.offlineTransactionsKey),
      _prefs.remove(AppConstants.offlineCustomersKey),
      _prefs.remove(AppConstants.offlineSuppliersKey),
    ]);
  }
}
