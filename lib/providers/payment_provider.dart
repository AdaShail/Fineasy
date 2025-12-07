import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../models/invoice_model.dart';
import '../models/transaction_model.dart';
import '../services/payment_service.dart';

/// Provider for managing payment state and operations
/// Requirements: 6.1, 6.2
class PaymentProvider extends ChangeNotifier {
  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load payments for a business
  Future<void> loadPayments({
    required String businessId,
    String? customerId,
    String? supplierId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    _setLoading(true);
    try {
      _payments = await PaymentService.getBusinessPayments(
        businessId: businessId,
        customerId: customerId,
        supplierId: supplierId,
        fromDate: fromDate,
        toDate: toDate,
      );
      _error = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  /// Record payment against a single invoice
  /// Requirements: 6.1
  Future<PaymentResult> recordPayment({
    required String invoiceId,
    required double amount,
    required PaymentMode paymentMode,
    String? reference,
    String? notes,
    DateTime? paymentDate,
  }) async {
    _setLoading(true);
    try {
      final result = await PaymentService.recordPayment(
        invoiceId: invoiceId,
        amount: amount,
        paymentMode: paymentMode,
        reference: reference,
        notes: notes,
        paymentDate: paymentDate,
      );

      if (result.success && result.payment != null) {
        // Add payment to local list
        _payments.insert(0, result.payment!);
        _error = null;

        // Notify related providers about payment
        _notifyPaymentRecorded(result.payment!, result.updatedInvoice);
      } else {
        _error = result.message;
      }

      _setLoading(false);
      return result;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return PaymentResult.failure(message: e.toString());
    }
  }

  /// Record distributed payment across multiple invoices
  /// Requirements: 6.2
  Future<PaymentResult> recordDistributedPayment({
    required List<InvoicePaymentAllocation> allocations,
    required PaymentMode paymentMode,
    String? reference,
    String? notes,
    DateTime? paymentDate,
  }) async {
    _setLoading(true);
    try {
      final result = await PaymentService.recordDistributedPayment(
        allocations: allocations,
        paymentMode: paymentMode,
        reference: reference,
        notes: notes,
        paymentDate: paymentDate,
      );

      if (result.success) {
        // Reload payments to get all new payment records
        // Note: We need businessId to reload, so caller should call loadPayments after
        _error = null;

        // Notify related providers about distributed payment
        _notifyDistributedPaymentRecorded(allocations);
      } else {
        _error = result.message;
      }

      _setLoading(false);
      return result;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return PaymentResult.failure(message: e.toString());
    }
  }

  /// Reverse a payment
  /// Requirements: 6.5
  Future<PaymentResult> reversePayment(String paymentId) async {
    _setLoading(true);
    try {
      final result = await PaymentService.reversePayment(paymentId);

      if (result.success) {
        // Update payment status in local list
        final index = _payments.indexWhere((p) => p.id == paymentId);
        if (index != -1) {
          _payments[index] = _payments[index].copyWith(
            status: PaymentStatus.cancelled,
          );
        }

        _error = null;

        // Notify related providers about reversal
        if (result.updatedInvoice != null) {
          _notifyPaymentReversed(paymentId, result.updatedInvoice!);
        }
      } else {
        _error = result.message;
      }

      _setLoading(false);
      return result;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return PaymentResult.failure(message: e.toString());
    }
  }

  /// Get payment history for a specific invoice
  Future<List<PaymentModel>> getInvoicePayments(String invoiceId) async {
    try {
      return await PaymentService.getInvoicePayments(invoiceId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Get payment statistics
  Future<Map<String, dynamic>> getPaymentStats({
    required String businessId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      return await PaymentService.getPaymentStats(
        businessId: businessId,
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }

  /// Get payments by customer
  List<PaymentModel> getPaymentsByCustomer(String customerId) {
    return _payments.where((p) => p.customerId == customerId).toList();
  }

  /// Get payments by supplier
  List<PaymentModel> getPaymentsBySupplier(String supplierId) {
    return _payments.where((p) => p.supplierId == supplierId).toList();
  }

  /// Get total payments amount
  double get totalPaymentsAmount {
    return _payments
        .where((p) => p.status == PaymentStatus.completed)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Get total payments (alias for totalPaymentsAmount)
  double get totalPayments => totalPaymentsAmount;

  /// Get total pending payments amount
  double get totalPendingPayments {
    return _payments
        .where((p) => p.status == PaymentStatus.pending)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Get payments by date range
  List<PaymentModel> getPaymentsByDateRange(DateTime start, DateTime end) {
    return _payments
        .where(
          (p) =>
              p.paymentDate.isAfter(start.subtract(const Duration(days: 1))) &&
              p.paymentDate.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  /// Add a new payment (for compatibility with old screens)
  Future<bool> addPayment(PaymentModel payment) async {
    try {
      // This is a simplified version - in reality, should use recordPayment
      _payments.insert(0, payment);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update an existing payment (for compatibility with old screens)
  Future<bool> updatePayment(PaymentModel payment) async {
    try {
      final index = _payments.indexWhere((p) => p.id == payment.id);
      if (index != -1) {
        _payments[index] = payment;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a payment
  Future<bool> deletePayment(String paymentId) async {
    try {
      final success = await PaymentService.deletePayment(paymentId);
      if (success) {
        _payments.removeWhere((p) => p.id == paymentId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
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

  /// Notify related providers when payment is recorded
  /// This is a placeholder - actual implementation should use provider communication
  void _notifyPaymentRecorded(PaymentModel payment, InvoiceModel? invoice) {
    // In a real implementation, this would notify:
    // - InvoiceProvider to update invoice status
    // - CustomerProvider to update customer balance
    // - TransactionProvider if transaction is linked

    // For now, just notify listeners
    notifyListeners();
  }

  /// Notify related providers when distributed payment is recorded
  void _notifyDistributedPaymentRecorded(
    List<InvoicePaymentAllocation> allocations,
  ) {
    // In a real implementation, this would notify:
    // - InvoiceProvider to update multiple invoice statuses
    // - CustomerProvider to update customer balances

    // For now, just notify listeners
    notifyListeners();
  }

  /// Notify related providers when payment is reversed
  void _notifyPaymentReversed(String paymentId, InvoiceModel invoice) {
    // In a real implementation, this would notify:
    // - InvoiceProvider to update invoice status
    // - CustomerProvider to update customer balance

    // For now, just notify listeners
    notifyListeners();
  }

  /// Refresh payments from server
  Future<void> refreshPayments(String businessId) async {
    try {
      _payments = await PaymentService.getBusinessPayments(
        businessId: businessId,
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
