import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ExpenseModel>> getExpenses(String businessId) async {
    try {
      final response = await _supabase
          .from('expenses')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return response
          .map<ExpenseModel>((json) => ExpenseModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses: ${e.toString()}');
    }
  }

  Future<ExpenseModel?> createExpense(ExpenseModel expense) async {
    try {
      final response =
          await _supabase
              .from('expenses')
              .insert(expense.toCreateJson())
              .select()
              .single();

      return ExpenseModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create expense: ${e.toString()}');
    }
  }

  Future<ExpenseModel?> updateExpense(ExpenseModel expense) async {
    try {
      final response =
          await _supabase
              .from('expenses')
              .update(expense.toJson())
              .eq('id', expense.id)
              .select()
              .single();

      return ExpenseModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update expense: ${e.toString()}');
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    try {
      await _supabase.from('expenses').delete().eq('id', expenseId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete expense: ${e.toString()}');
    }
  }

  Future<List<ExpenseModel>> getExpensesByCategory(
    String businessId,
    String category,
  ) async {
    try {
      final response = await _supabase
          .from('expenses')
          .select()
          .eq('business_id', businessId)
          .eq('category', category)
          .order('created_at', ascending: false);

      return response
          .map<ExpenseModel>((json) => ExpenseModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses by category: ${e.toString()}');
    }
  }

  Future<List<ExpenseModel>> getExpensesByDateRange(
    String businessId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase
          .from('expenses')
          .select()
          .eq('business_id', businessId)
          .gte('expense_date', startDate.toIso8601String().split('T')[0])
          .lte('expense_date', endDate.toIso8601String().split('T')[0])
          .order('expense_date', ascending: false);

      return response
          .map<ExpenseModel>((json) => ExpenseModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses by date range: ${e.toString()}');
    }
  }

  Future<double> getTotalExpensesByCategory(
    String businessId,
    String category,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase
          .from('expenses')
          .select('amount')
          .eq('business_id', businessId)
          .eq('category', category)
          .gte('expense_date', startDate.toIso8601String().split('T')[0])
          .lte('expense_date', endDate.toIso8601String().split('T')[0]);

      double total = 0.0;
      for (final expense in response) {
        total += (expense['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      throw Exception('Failed to get total expenses: ${e.toString()}');
    }
  }
}
