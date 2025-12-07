import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<TransactionModel>> getTransactions(String businessId) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return response
          .map<TransactionModel>((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions: ${e.toString()}');
    }
  }

  Future<TransactionModel?> createTransaction(
    TransactionModel transaction,
  ) async {
    try {
      final response =
          await _supabase
              .from('transactions')
              .insert(
                transaction.toCreateJson(),
              ) // Use toCreateJson for new transactions
              .select()
              .single();

      return TransactionModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create transaction: ${e.toString()}');
    }
  }

  Future<TransactionModel?> updateTransaction(
    TransactionModel transaction,
  ) async {
    try {
      final response =
          await _supabase
              .from('transactions')
              .update(transaction.toJson())
              .eq('id', transaction.id)
              .select()
              .single();

      return TransactionModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update transaction: ${e.toString()}');
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    try {
      await _supabase.from('transactions').delete().eq('id', transactionId);

      return true;
    } catch (e) {
      throw Exception('Failed to delete transaction: ${e.toString()}');
    }
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
    String businessId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('business_id', businessId)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date', ascending: false);

      return response
          .map<TransactionModel>((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to get transactions by date range: ${e.toString()}',
      );
    }
  }

  Future<List<TransactionModel>> getCustomerTransactions(
    String customerId,
  ) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return response
          .map<TransactionModel>((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get customer transactions: ${e.toString()}');
    }
  }

  Future<List<TransactionModel>> getSupplierTransactions(
    String supplierId,
  ) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('supplier_id', supplierId)
          .order('created_at', ascending: false);

      return response
          .map<TransactionModel>((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get supplier transactions: ${e.toString()}');
    }
  }
}
