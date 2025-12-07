import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import '../models/payment_model.dart';
import '../models/transaction_model.dart';
import '../services/invoice_service.dart';
import '../services/payment_service.dart';

class InvoiceProvider extends ChangeNotifier {
  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;
  String? _error;
  final Map<String, List<PaymentModel>> _paymentHistoryCache = {};

  List<InvoiceModel> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<InvoiceModel> get draftInvoices =>
      _invoices
          .where((invoice) => invoice.status == InvoiceStatus.draft)
          .toList();

  List<InvoiceModel> get sentInvoices =>
      _invoices
          .where((invoice) => invoice.status == InvoiceStatus.sent)
          .toList();

  List<InvoiceModel> get paidInvoices =>
      _invoices
          .where((invoice) => invoice.status == InvoiceStatus.paid)
          .toList();

  List<InvoiceModel> get overdueInvoices =>
      _invoices.where((invoice) => invoice.isOverdue).toList();

  List<InvoiceModel> get partiallyPaidInvoices =>
      _invoices
          .where((invoice) => invoice.status == InvoiceStatus.partiallyPaid)
          .toList();

  // Unpaid and partially paid invoices (for receivables calculation)
  List<InvoiceModel> get unpaidAndPartiallyPaidInvoices =>
      _invoices
          .where(
            (invoice) =>
                (invoice.status == InvoiceStatus.sent ||
                    invoice.status == InvoiceStatus.partiallyPaid ||
                    invoice.status == InvoiceStatus.overdue) &&
                invoice.status != InvoiceStatus.cancelled,
          )
          .toList();

  double get totalOutstanding =>
      _invoices.fold(0.0, (sum, invoice) => sum + invoice.outstandingAmount);

  double get totalPaid =>
      _invoices.fold(0.0, (sum, invoice) => sum + invoice.paidAmount);

  // Total amount from PAID invoices only (for dashboard income calculation)
  // Excludes draft and cancelled invoices
  double get totalPaidInvoiceAmount => _invoices
      .where(
        (invoice) =>
            invoice.status == InvoiceStatus.paid &&
            invoice.status != InvoiceStatus.draft &&
            invoice.status != InvoiceStatus.cancelled,
      )
      .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);

  // Revenue calculation: only paid invoices, excluding draft and cancelled
  double get totalRevenue => totalPaidInvoiceAmount;

  // Receivables calculation: only unpaid and partially_paid invoices, excluding cancelled
  double get totalReceivables => unpaidAndPartiallyPaidInvoices.fold(
    0.0,
    (sum, invoice) => sum + invoice.outstandingAmount,
  );

  Future<void> loadInvoices(String businessId) async {
    _setLoading(true);
    try {
      _invoices = await InvoiceService.getInvoices(businessId: businessId);
      _error = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // Refresh invoices without showing loading state (for real-time updates)
  Future<void> refreshInvoices(String businessId) async {
    try {
      _invoices = await InvoiceService.getInvoices(businessId: businessId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addInvoice(InvoiceModel invoice) async {
    _setLoading(true);
    try {
      //InvoiceService.generateInvoiceNumber(businessId)
      final createdInvoice = await InvoiceService.createInvoice(invoice);
      if (createdInvoice != null) {
        _invoices.insert(0, createdInvoice);
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

  Future<bool> updateInvoice(InvoiceModel invoice) async {
    _setLoading(true);
    try {
      final updatedInvoice = await InvoiceService.updateInvoice(invoice);
      if (updatedInvoice != null) {
        final index = _invoices.indexWhere((i) => i.id == invoice.id);
        if (index != -1) {
          _invoices[index] = updatedInvoice;
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

  Future<bool> deleteInvoice(String invoiceId) async {
    _setLoading(true);
    try {
      final success = await InvoiceService.deleteInvoice(invoiceId);
      if (success) {
        _invoices.removeWhere((i) => i.id == invoiceId);
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

  Future<String> generateInvoiceNumber(String businessId) async {
    try {
      return await InvoiceService.generateInvoiceNumber(businessId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 'INV-001';
    }
  }

  Future<List<InvoiceModel>> getCustomerInvoices(String customerId) async {
    try {
      return await InvoiceService.getInvoices(businessId: customerId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  InvoiceModel? getInvoiceById(String invoiceId) {
    try {
      return _invoices.firstWhere((invoice) => invoice.id == invoiceId);
    } catch (e) {
      return null;
    }
  }

  List<InvoiceModel> getInvoicesByStatus(InvoiceStatus status) {
    return _invoices.where((invoice) => invoice.status == status).toList();
  }

  List<InvoiceModel> getInvoicesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _invoices
        .where(
          (invoice) =>
              invoice.invoiceDate.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              invoice.invoiceDate.isBefore(
                endDate.add(const Duration(days: 1)),
              ),
        )
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

  // ============ NEW PAYMENT FLOW METHODS ============

  /// Load invoice with payment history
  /// Requirements: 6.3, 6.4
  Future<InvoiceModel?> loadInvoiceWithPayments(String invoiceId) async {
    try {
      final invoice = getInvoiceById(invoiceId);
      if (invoice == null) {
        _error = 'Invoice not found';
        notifyListeners();
        return null;
      }

      // Load payment history for this invoice
      final payments = await PaymentService.getInvoicePayments(invoiceId);
      _paymentHistoryCache[invoiceId] = payments;

      notifyListeners();
      return invoice;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Get cached payment history for an invoice
  List<PaymentModel> getInvoicePayments(String invoiceId) {
    return _paymentHistoryCache[invoiceId] ?? [];
  }

  /// Record payment against an invoice
  /// Requirements: 6.1, 6.3
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

      if (result.success && result.updatedInvoice != null) {
        // Update invoice in local list
        final index = _invoices.indexWhere((i) => i.id == invoiceId);
        if (index != -1) {
          _invoices[index] = result.updatedInvoice!;
        }

        // Update payment history cache
        if (result.payment != null) {
          final currentPayments = _paymentHistoryCache[invoiceId] ?? [];
          _paymentHistoryCache[invoiceId] = [
            result.payment!,
            ...currentPayments,
          ];
        }

        _error = null;
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

  /// Listen to payment updates and refresh invoice
  /// This method should be called when external payment updates occur
  /// Requirements: 6.4
  Future<void> onPaymentUpdate(String invoiceId) async {
    try {
      // Reload invoice from server to get latest status
      final invoiceResponse = await InvoiceService.getInvoiceById(invoiceId);
      if (invoiceResponse != null) {
        final index = _invoices.indexWhere((i) => i.id == invoiceId);
        if (index != -1) {
          _invoices[index] = invoiceResponse;
        }

        // Reload payment history
        final payments = await PaymentService.getInvoicePayments(invoiceId);
        _paymentHistoryCache[invoiceId] = payments;

        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clear payment history cache for an invoice
  void clearPaymentCache(String invoiceId) {
    _paymentHistoryCache.remove(invoiceId);
    notifyListeners();
  }

  /// Clear all payment history cache
  void clearAllPaymentCache() {
    _paymentHistoryCache.clear();
    notifyListeners();
  }
}
