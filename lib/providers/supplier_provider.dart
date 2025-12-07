import 'package:flutter/material.dart';
import '../models/supplier_model.dart';
import '../services/supplier_service.dart';

class SupplierProvider extends ChangeNotifier {
  final SupplierService _supplierService = SupplierService();

  List<SupplierModel> _suppliers = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SupplierModel> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSuppliers(String businessId) async {
    _setLoading(true);
    try {
      _suppliers = await _supplierService.getSuppliers(businessId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<bool> addSupplier(SupplierModel supplier) async {
    _setLoading(true);
    try {
      final createdSupplier = await _supplierService.createSupplier(supplier);
      if (createdSupplier != null) {
        _suppliers.insert(0, createdSupplier);
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

  Future<bool> updateSupplier(SupplierModel supplier) async {
    _setLoading(true);
    try {
      final updatedSupplier = await _supplierService.updateSupplier(supplier);
      if (updatedSupplier != null) {
        final index = _suppliers.indexWhere((s) => s.id == supplier.id);
        if (index != -1) {
          _suppliers[index] = updatedSupplier;
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

  Future<bool> deleteSupplier(String supplierId) async {
    _setLoading(true);
    try {
      final success = await _supplierService.deleteSupplier(supplierId);
      if (success) {
        _suppliers.removeWhere((s) => s.id == supplierId);
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

  SupplierModel? getSupplierById(String supplierId) {
    try {
      return _suppliers.firstWhere((s) => s.id == supplierId);
    } catch (e) {
      return null;
    }
  }

  List<SupplierModel> searchSuppliers(String query) {
    if (query.isEmpty) return _suppliers;

    return _suppliers
        .where(
          (supplier) =>
              supplier.name.toLowerCase().contains(query.toLowerCase()) ||
              (supplier.phone?.contains(query) ?? false) ||
              (supplier.email?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .toList();
  }

  double get totalPayables {
    return _suppliers.fold(0.0, (sum, supplier) => sum + supplier.balance);
  }

  double getTotalPayables() {
    return totalPayables;
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
