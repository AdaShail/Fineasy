import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ProductModel>> getProducts(String businessId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return response
          .map<ProductModel>((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products: ${e.toString()}');
    }
  }

  Future<ProductModel?> createProduct(ProductModel product) async {
    try {
      final response =
          await _supabase
              .from('products')
              .insert(product.toCreateJson())
              .select()
              .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create product: ${e.toString()}');
    }
  }

  Future<ProductModel?> updateProduct(ProductModel product) async {
    try {
      final response =
          await _supabase
              .from('products')
              .update(product.toJson())
              .eq('id', product.id)
              .select()
              .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _supabase.from('products').delete().eq('id', productId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      final response =
          await _supabase
              .from('products')
              .select()
              .eq('id', productId)
              .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get product: ${e.toString()}');
    }
  }

  Future<List<ProductModel>> searchProducts(
    String businessId,
    String query,
  ) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('business_id', businessId)
          .or('name.ilike.%$query%,sku.ilike.%$query%,category.ilike.%$query%')
          .order('created_at', ascending: false);

      return response
          .map<ProductModel>((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: ${e.toString()}');
    }
  }

  Future<List<ProductModel>> getLowStockProducts(String businessId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('business_id', businessId)
          .filter('stock_quantity', 'lte', 'min_stock_level')
          .eq('is_active', true)
          .order('stock_quantity', ascending: true);

      return response
          .map<ProductModel>((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get low stock products: ${e.toString()}');
    }
  }

  Future<ProductModel?> updateStock(String productId, int newQuantity) async {
    try {
      final response =
          await _supabase
              .from('products')
              .update({
                'stock_quantity': newQuantity,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', productId)
              .select()
              .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update stock: ${e.toString()}');
    }
  }
}
