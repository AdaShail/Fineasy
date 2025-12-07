import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();

  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalExpenses =>
      _expenses.fold(0.0, (sum, expense) => sum + expense.amount);

  List<ExpenseModel> get recurringExpenses =>
      _expenses.where((expense) => expense.isRecurring).toList();

  Future<void> loadExpenses(String businessId) async {
    _setLoading(true);
    try {
      _expenses = await _expenseService.getExpenses(businessId);
      _error = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<bool> addExpense(ExpenseModel expense) async {
    _setLoading(true);
    try {
      final createdExpense = await _expenseService.createExpense(expense);
      if (createdExpense != null) {
        _expenses.insert(0, createdExpense);
        _error = null;
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateExpense(ExpenseModel expense) async {
    _setLoading(true);
    try {
      final updatedExpense = await _expenseService.updateExpense(expense);
      if (updatedExpense != null) {
        final index = _expenses.indexWhere((e) => e.id == expense.id);
        if (index != -1) {
          _expenses[index] = updatedExpense;
        }
        _error = null;
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    _setLoading(true);
    try {
      final success = await _expenseService.deleteExpense(expenseId);
      if (success) {
        _expenses.removeWhere((e) => e.id == expenseId);
        _error = null;
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<List<ExpenseModel>> fetchExpensesByCategory(
    String businessId,
    String category,
  ) async {
    try {
      return await _expenseService.getExpensesByCategory(businessId, category);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<ExpenseModel>> getExpensesByDateRange(
    String businessId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _expenseService.getExpensesByDateRange(
        businessId,
        startDate,
        endDate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<double> getTotalExpensesByCategory(
    String businessId,
    String category,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _expenseService.getTotalExpensesByCategory(
        businessId,
        category,
        startDate,
        endDate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0.0;
    }
  }

  ExpenseModel? getExpenseById(String expenseId) {
    try {
      return _expenses.firstWhere((expense) => expense.id == expenseId);
    } catch (e) {
      return null;
    }
  }

  List<ExpenseModel> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  Map<String, double> getExpensesByCategories() {
    final Map<String, double> categoryTotals = {};

    for (final expense in _expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }

    return categoryTotals;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
