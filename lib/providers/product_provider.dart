import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ProductModel> get lowStockProducts =>
      _products.where((product) => product.isLowStock).toList();

  List<ProductModel> get activeProducts =>
      _products.where((product) => product.isActive).toList();

  Future<void> loadProducts(String businessId) async {
    _setLoading(true);
    try {
      _products = await _productService.getProducts(businessId);
      _error = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    _setLoading(true);
    try {
      final createdProduct = await _productService.createProduct(product);
      if (createdProduct != null) {
        _products.insert(0, createdProduct);
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

  Future<bool> updateProduct(ProductModel product) async {
    _setLoading(true);
    try {
      final updatedProduct = await _productService.updateProduct(product);
      if (updatedProduct != null) {
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = updatedProduct;
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

  Future<bool> deleteProduct(String productId) async {
    _setLoading(true);
    try {
      final success = await _productService.deleteProduct(productId);
      if (success) {
        _products.removeWhere((p) => p.id == productId);
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

  Future<bool> updateStock(String productId, int newQuantity) async {
    try {
      final updatedProduct = await _productService.updateStock(
        productId,
        newQuantity,
      );
      if (updatedProduct != null) {
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = updatedProduct;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<ProductModel>> searchProducts(
    String businessId,
    String query,
  ) async {
    try {
      return await _productService.searchProducts(businessId, query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  ProductModel? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  List<ProductModel> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
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
