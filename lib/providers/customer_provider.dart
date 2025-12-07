import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../models/invoice_model.dart';
import '../models/payment_model.dart';
import '../services/customer_service.dart';
import '../services/accounting_sync_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService _customerService = CustomerService();
  final AccountingSyncService _syncService = AccountingSyncService();

  List<CustomerModel> _customers = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CustomerModel> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCustomers(String businessId) async {
    _setLoading(true);
    try {
      _customers = await _customerService.getCustomers(businessId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<bool> addCustomer(CustomerModel customer) async {
    _setLoading(true);
    try {
      final createdCustomer = await _customerService.createCustomer(customer);
      if (createdCustomer != null) {
        _customers.insert(0, createdCustomer);
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

  Future<bool> updateCustomer(CustomerModel customer) async {
    _setLoading(true);
    try {
      final updatedCustomer = await _customerService.updateCustomer(customer);
      if (updatedCustomer != null) {
        final index = _customers.indexWhere((c) => c.id == customer.id);
        if (index != -1) {
          _customers[index] = updatedCustomer;
        }
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

  Future<bool> deleteCustomer(String customerId) async {
    _setLoading(true);
    try {
      final success = await _customerService.deleteCustomer(customerId);
      if (success) {
        _customers.removeWhere((c) => c.id == customerId);
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

  CustomerModel? getCustomerById(String customerId) {
    try {
      return _customers.firstWhere((c) => c.id == customerId);
    } catch (e) {
      return null;
    }
  }

  List<CustomerModel> searchCustomers(String query) {
    if (query.isEmpty) return _customers;

    return _customers
        .where(
          (customer) =>
              customer.name.toLowerCase().contains(query.toLowerCase()) ||
              (customer.phone?.contains(query) ?? false) ||
              (customer.email?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .toList();
  }

  double get totalReceivables {
    return _customers.fold(0.0, (sum, customer) => sum + customer.balance);
  }

  double getTotalReceivables() {
    return totalReceivables;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ============ NEW PAYMENT AND INVOICE SYNC METHODS ============

  /// Recalculate customer balance when payment is recorded
  /// Requirements: 4.2, 8.2
  Future<void> onPaymentRecorded({
    required String customerId,
    required PaymentModel payment,
  }) async {
    try {
      // Recalculate balance using sync service
      await _syncService.recalculateCustomerBalance(customerId);

      // Reload customer to get updated balance
      final updatedCustomer = await _customerService.getCustomerById(
        customerId,
      );
      if (updatedCustomer != null) {
        final index = _customers.indexWhere((c) => c.id == customerId);
        if (index != -1) {
          _customers[index] = updatedCustomer;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Update customer balance when invoice status changes
  /// Requirements: 4.2, 8.2
  Future<void> onInvoiceStatusChange({
    required String customerId,
    required InvoiceStatus oldStatus,
    required InvoiceStatus newStatus,
  }) async {
    try {
      // Recalculate balance using sync service
      await _syncService.recalculateCustomerBalance(customerId);

      // Reload customer to get updated balance
      final updatedCustomer = await _customerService.getCustomerById(
        customerId,
      );
      if (updatedCustomer != null) {
        final index = _customers.indexWhere((c) => c.id == customerId);
        if (index != -1) {
          _customers[index] = updatedCustomer;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Manually trigger balance recalculation for a customer
  /// Requirements: 4.2
  Future<void> recalculateBalance(String customerId) async {
    try {
      await _syncService.recalculateCustomerBalance(customerId);

      // Reload customer to get updated balance
      final updatedCustomer = await _customerService.getCustomerById(
        customerId,
      );
      if (updatedCustomer != null) {
        final index = _customers.indexWhere((c) => c.id == customerId);
        if (index != -1) {
          _customers[index] = updatedCustomer;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Refresh customer list and recalculate all balances
  /// Requirements: 8.2
  Future<void> refreshCustomersWithBalances(String businessId) async {
    _setLoading(true);
    try {
      // Reload all customers
      _customers = await _customerService.getCustomers(businessId);

      // Recalculate balances for all customers
      for (final customer in _customers) {
        try {
          await _syncService.recalculateCustomerBalance(customer.id);
        } catch (e) {
          // Log error but continue with other customers
          print(
            'Warning: Failed to recalculate balance for customer ${customer.id}: $e',
          );
        }
      }

      // Reload customers again to get updated balances
      _customers = await _customerService.getCustomers(businessId);

      _error = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  /// Get customers with outstanding balances
  List<CustomerModel> get customersWithBalance {
    return _customers.where((c) => c.balance > 0).toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));
  }

  /// Get total outstanding from all customers
  double get totalOutstanding {
    return _customers.fold(0.0, (sum, c) => sum + c.balance);
  }
}
