import 'package:flutter/material.dart';
import '../models/business_model.dart';
import '../services/business_service.dart';

class BusinessProvider extends ChangeNotifier {
  final BusinessService _businessService = BusinessService();

  BusinessModel? _business;
  bool _isLoading = false;
  String? _error;

  // Getters
  BusinessModel? get business => _business;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBusiness(String userId) async {
    _setLoading(true);
    try {
      _business = await _businessService.getBusinessByUserId(userId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<bool> hasBusiness(String userId) async {
    try {
      final business = await _businessService.getBusinessByUserId(userId);
      return business != null;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> createBusiness(BusinessModel business) async {
    _setLoading(true);
    try {
      final createdBusiness = await _businessService.createBusiness(business);
      if (createdBusiness != null) {
        _business = createdBusiness;
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

  Future<bool> updateBusiness(BusinessModel business) async {
    _setLoading(true);
    try {
      final updatedBusiness = await _businessService.updateBusiness(business);
      if (updatedBusiness != null) {
        _business = updatedBusiness;
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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearBusiness() {
    _business = null;
    _error = null;
    notifyListeners();
  }
}
