import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/invoice_model.dart';
import '../services/transaction_service.dart';
import '../services/invoice_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  double _balance = 0.0;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _balance;

  Future<void> loadTransactions(String businessId) async {
    _setLoading(true);
    try {
      _transactions = await _transactionService.getTransactions(businessId);
      _calculateTotals();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<bool> addTransaction(TransactionModel transaction) async {
    _setLoading(true);
    try {
      final createdTransaction = await _transactionService.createTransaction(
        transaction,
      );
      if (createdTransaction != null) {
        _transactions.insert(0, createdTransaction);
        _calculateTotals();
        _error = null; // Clear any previous errors
        _setLoading(false);
        notifyListeners(); // Ensure UI updates immediately
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

  Future<bool> updateTransaction(TransactionModel transaction) async {
    _setLoading(true);
    try {
      final updatedTransaction = await _transactionService.updateTransaction(
        transaction,
      );
      if (updatedTransaction != null) {
        final index = _transactions.indexWhere((t) => t.id == transaction.id);
        if (index != -1) {
          _transactions[index] = updatedTransaction;
          _calculateTotals();
        }
        _error = null; // Clear any previous errors
        _setLoading(false);
        notifyListeners(); // Ensure UI updates immediately
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

  Future<bool> deleteTransaction(String transactionId) async {
    _setLoading(true);
    try {
      final success = await _transactionService.deleteTransaction(
        transactionId,
      );
      if (success) {
        _transactions.removeWhere((t) => t.id == transactionId);
        _calculateTotals();
        _error = null; // Clear any previous errors
        _setLoading(false);
        notifyListeners(); // Ensure UI updates immediately
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

  void _calculateTotals() {
    _totalIncome = _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    _totalExpense = _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    _balance = _totalIncome - _totalExpense;

    // Notify listeners after calculating totals
    notifyListeners();
  }

  List<TransactionModel> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _transactions
        .where(
          (t) =>
              t.date.isAfter(start.subtract(const Duration(days: 1))) &&
              t.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  List<TransactionModel> getTodayTransactions() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _transactions
        .where((t) => t.date.isAfter(startOfDay) && t.date.isBefore(endOfDay))
        .toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh transactions from server
  Future<void> refreshTransactions(String businessId) async {
    try {
      _transactions = await _transactionService.getTransactions(businessId);
      _calculateTotals();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  /// Get today's transactions with real-time filtering
  List<TransactionModel> getTodayTransactionsRealTime() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _transactions
        .where(
          (t) =>
              t.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(endOfDay),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by newest first
  }

  /// Get transactions count for today
  int getTodayTransactionCount() {
    return getTodayTransactionsRealTime().length;
  }

  /// Get today's income
  double getTodayIncome() {
    return getTodayTransactionsRealTime()
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get today's expenses
  double getTodayExpenses() {
    return getTodayTransactionsRealTime()
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get this month's transactions
  List<TransactionModel> getMonthlyTransactions() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    return _transactions
        .where(
          (t) =>
              t.date.isAfter(
                startOfMonth.subtract(const Duration(seconds: 1)),
              ) &&
              t.date.isBefore(endOfMonth),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get monthly income
  double getMonthlyIncome() {
    return getMonthlyTransactions()
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get monthly expenses
  double getMonthlyExpenses() {
    return getMonthlyTransactions()
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // ============ NEW INVOICE INTEGRATION METHODS ============

  /// Create transaction with automatic invoice creation for income with customer
  /// Requirements: 1.1, 8.1
  Future<bool> createTransactionWithInvoice(
    TransactionModel transaction,
  ) async {
    _setLoading(true);
    try {
      // Create transaction first
      final createdTransaction = await _transactionService.createTransaction(
        transaction,
      );

      if (createdTransaction == null) {
        _setLoading(false);
        return false;
      }

      // Add to local list
      _transactions.insert(0, createdTransaction);
      _calculateTotals();

      // If income transaction with customer, create invoice automatically
      // Auto-generate invoice for income transactions with customers
      // Only if invoice doesn't already exist
      if (createdTransaction.type == TransactionType.income &&
          createdTransaction.customerId != null &&
          createdTransaction.invoiceId == null) {
        try {
          final invoice = await InvoiceService.createInvoiceFromTransaction(
            createdTransaction,
          );

          if (invoice != null) {
            // Update transaction with invoice_id
            final updatedTransaction = createdTransaction.copyWith(
              invoiceId: invoice.id,
            );

            // Update in local list
            final index = _transactions.indexWhere(
              (t) => t.id == createdTransaction.id,
            );
            if (index != -1) {
              _transactions[index] = updatedTransaction;
            }
          }
        } catch (invoiceError) {
          // Log error but don't fail transaction creation
        }
      }

      _error = null;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Sync transaction when invoice status changes
  /// Requirements: 8.1
  Future<void> onInvoiceStatusChange({
    required String transactionId,
    required InvoiceStatus newStatus,
  }) async {
    try {
      // Find transaction in local list
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index == -1) return;

      final transaction = _transactions[index];

      // Update transaction status based on invoice status
      TransactionStatus? newTransactionStatus;
      if (newStatus == InvoiceStatus.paid) {
        newTransactionStatus = TransactionStatus.completed;
      } else if (newStatus == InvoiceStatus.cancelled) {
        newTransactionStatus = TransactionStatus.cancelled;
      }

      if (newTransactionStatus != null &&
          transaction.status != newTransactionStatus) {
        // Update transaction in database
        final updatedTransaction = transaction.copyWith(
          status: newTransactionStatus,
        );

        final result = await _transactionService.updateTransaction(
          updatedTransaction,
        );

        if (result != null) {
          _transactions[index] = result;
          _calculateTotals();
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Get transaction by invoice ID
  TransactionModel? getTransactionByInvoiceId(String invoiceId) {
    try {
      return _transactions.firstWhere((t) => t.invoiceId == invoiceId);
    } catch (e) {
      return null;
    }
  }
}
