import 'package:flutter/material.dart';
import '../models/cashbook_entry_model.dart';
import '../services/cashbook_service.dart';

class CashbookProvider extends ChangeNotifier {
  final CashbookService _cashbookService = CashbookService();

  List<CashbookEntryModel> _entries = [];
  bool _isLoading = false;
  String? _error;
  double _currentBalance = 0.0;

  List<CashbookEntryModel> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get currentBalance => _currentBalance;

  List<CashbookEntryModel> get cashInEntries =>
      _entries.where((entry) => entry.type == CashbookType.cashIn).toList();

  List<CashbookEntryModel> get cashOutEntries =>
      _entries.where((entry) => entry.type == CashbookType.cashOut).toList();

  double get totalCashIn =>
      cashInEntries.fold(0.0, (sum, entry) => sum + entry.amount);

  double get totalCashOut =>
      cashOutEntries.fold(0.0, (sum, entry) => sum + entry.amount);

  Future<void> loadCashbookEntries(String businessId) async {
    _setLoading(true);
    try {
      _entries = await _cashbookService.getCashbookEntries(businessId);
      _currentBalance = await _cashbookService.getCashBalance(businessId, null);
      _error = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<bool> addCashbookEntry(CashbookEntryModel entry) async {
    _setLoading(true);
    try {
      final createdEntry = await _cashbookService.createCashbookEntry(entry);
      if (createdEntry != null) {
        _entries.insert(0, createdEntry);
        _updateBalance(entry);
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

  Future<bool> updateCashbookEntry(CashbookEntryModel entry) async {
    _setLoading(true);
    try {
      final updatedEntry = await _cashbookService.updateCashbookEntry(entry);
      if (updatedEntry != null) {
        final index = _entries.indexWhere((e) => e.id == entry.id);
        if (index != -1) {
          final oldEntry = _entries[index];
          _entries[index] = updatedEntry;
          _revertBalance(oldEntry);
          _updateBalance(updatedEntry);
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

  Future<bool> deleteCashbookEntry(String entryId) async {
    _setLoading(true);
    try {
      final success = await _cashbookService.deleteCashbookEntry(entryId);
      if (success) {
        final entry = _entries.firstWhere((e) => e.id == entryId);
        _entries.removeWhere((e) => e.id == entryId);
        _revertBalance(entry);
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

  Future<List<CashbookEntryModel>> getEntriesByDate(
    String businessId,
    DateTime date,
  ) async {
    try {
      return await _cashbookService.getCashbookEntriesByDate(businessId, date);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<Map<String, double>> getDailySummary(
    String businessId,
    DateTime date,
  ) async {
    try {
      return await _cashbookService.getDailySummary(businessId, date);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'cashIn': 0.0, 'cashOut': 0.0, 'netCash': 0.0};
    }
  }

  Future<double> getCashBalance(String businessId, DateTime? upToDate) async {
    try {
      return await _cashbookService.getCashBalance(businessId, upToDate);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0.0;
    }
  }

  CashbookEntryModel? getEntryById(String entryId) {
    try {
      return _entries.firstWhere((entry) => entry.id == entryId);
    } catch (e) {
      return null;
    }
  }

  List<CashbookEntryModel> getEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _entries
        .where(
          (entry) =>
              entry.entryDate.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              entry.entryDate.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  List<CashbookEntryModel> getTodayEntries() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _entries
        .where(
          (entry) =>
              entry.entryDate.isAfter(startOfDay) &&
              entry.entryDate.isBefore(endOfDay),
        )
        .toList();
  }

  void _updateBalance(CashbookEntryModel entry) {
    if (entry.type == CashbookType.cashIn) {
      _currentBalance += entry.amount;
    } else {
      _currentBalance -= entry.amount;
    }
  }

  void _revertBalance(CashbookEntryModel entry) {
    if (entry.type == CashbookType.cashIn) {
      _currentBalance -= entry.amount;
    } else {
      _currentBalance += entry.amount;
    }
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
