import 'package:flutter/material.dart';
import '../models/recurring_payment_model.dart';
import '../services/recurring_payment_service.dart';

/// Provider for managing recurring payment state
class RecurringPaymentProvider extends ChangeNotifier {
  List<RecurringPaymentModel> _recurringPayments = [];
  List<RecurringPaymentOccurrence> _occurrences = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<RecurringPaymentModel> get recurringPayments => _recurringPayments;
  List<RecurringPaymentOccurrence> get occurrences => _occurrences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get active recurring payments
  List<RecurringPaymentModel> get activeRecurringPayments {
    return _recurringPayments
        .where((r) => r.status == RecurringPaymentStatus.active)
        .toList();
  }

  /// Get paused recurring payments
  List<RecurringPaymentModel> get pausedRecurringPayments {
    return _recurringPayments
        .where((r) => r.status == RecurringPaymentStatus.paused)
        .toList();
  }

  /// Get unpaid occurrences
  List<RecurringPaymentOccurrence> get unpaidOccurrences {
    return _occurrences.where((o) => !o.paid).toList();
  }

  /// Load recurring payments for a business
  Future<void> loadRecurringPayments({
    required String businessId,
    String? customerId,
    RecurringPaymentStatus? status,
  }) async {
    _setLoading(true);
    try {
      _recurringPayments = await RecurringPaymentService.getRecurringPayments(
        businessId: businessId,
        customerId: customerId,
        status: status,
      );
      _error = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  /// Load occurrences for a business
  Future<void> loadOccurrences({
    required String businessId,
    bool? paid,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      _occurrences = await RecurringPaymentService.getBusinessOccurrences(
        businessId: businessId,
        paid: paid,
        fromDate: fromDate,
        toDate: toDate,
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Create a new recurring payment
  Future<RecurringPaymentModel?> createRecurringPayment(
    RecurringPaymentModel recurringPayment,
  ) async {
    _setLoading(true);
    try {
      final created = await RecurringPaymentService.createRecurringPayment(
        recurringPayment,
      );

      if (created != null) {
        _recurringPayments.insert(0, created);
        _error = null;
      }

      _setLoading(false);
      return created;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  /// Update a recurring payment
  Future<RecurringPaymentModel?> updateRecurringPayment(
    RecurringPaymentModel recurringPayment,
  ) async {
    _setLoading(true);
    try {
      final updated = await RecurringPaymentService.updateRecurringPayment(
        recurringPayment,
      );

      if (updated != null) {
        final index = _recurringPayments.indexWhere((r) => r.id == updated.id);
        if (index != -1) {
          _recurringPayments[index] = updated;
        }
        _error = null;
      }

      _setLoading(false);
      return updated;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  /// Delete a recurring payment
  Future<bool> deleteRecurringPayment(String id) async {
    _setLoading(true);
    try {
      final success = await RecurringPaymentService.deleteRecurringPayment(id);

      if (success) {
        _recurringPayments.removeWhere((r) => r.id == id);
        _error = null;
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Pause a recurring payment
  Future<bool> pauseRecurringPayment(String id) async {
    try {
      final success = await RecurringPaymentService.pauseRecurringPayment(id);

      if (success) {
        final index = _recurringPayments.indexWhere((r) => r.id == id);
        if (index != -1) {
          _recurringPayments[index] = _recurringPayments[index].copyWith(
            status: RecurringPaymentStatus.paused,
          );
        }
        _error = null;
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Resume a recurring payment
  Future<bool> resumeRecurringPayment(String id) async {
    try {
      final success = await RecurringPaymentService.resumeRecurringPayment(id);

      if (success) {
        final index = _recurringPayments.indexWhere((r) => r.id == id);
        if (index != -1) {
          _recurringPayments[index] = _recurringPayments[index].copyWith(
            status: RecurringPaymentStatus.active,
          );
        }
        _error = null;
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cancel a recurring payment
  Future<bool> cancelRecurringPayment(String id) async {
    try {
      final success = await RecurringPaymentService.cancelRecurringPayment(id);

      if (success) {
        final index = _recurringPayments.indexWhere((r) => r.id == id);
        if (index != -1) {
          _recurringPayments[index] = _recurringPayments[index].copyWith(
            status: RecurringPaymentStatus.cancelled,
          );
        }
        _error = null;
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Process all recurring payments (generate occurrences)
  Future<int> processRecurringPayments(String businessId) async {
    try {
      final count = await RecurringPaymentService.processRecurringPayments(
        businessId: businessId,
      );

      // Reload data after processing
      await loadRecurringPayments(businessId: businessId);
      await loadOccurrences(businessId: businessId);

      return count;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0;
    }
  }

  /// Get occurrences for a specific recurring payment
  Future<List<RecurringPaymentOccurrence>> getOccurrencesForRecurring(
    String recurringPaymentId,
  ) async {
    try {
      return await RecurringPaymentService.getOccurrences(
        recurringPaymentId: recurringPaymentId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Mark occurrence as paid
  Future<bool> markOccurrencePaid(String occurrenceId) async {
    try {
      final success = await RecurringPaymentService.markOccurrencePaid(
        occurrenceId,
      );

      if (success) {
        final index = _occurrences.indexWhere((o) => o.id == occurrenceId);
        if (index != -1) {
          _occurrences[index] = _occurrences[index].copyWith(
            paid: true,
            paidAt: DateTime.now(),
          );
        }
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStats(String businessId) async {
    try {
      return await RecurringPaymentService.getRecurringPaymentStats(
        businessId: businessId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }

  // ============ PRIVATE HELPER METHODS ============

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh(String businessId) async {
    await loadRecurringPayments(businessId: businessId);
    await loadOccurrences(businessId: businessId);
  }
}
