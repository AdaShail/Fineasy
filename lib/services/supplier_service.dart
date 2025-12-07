import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supplier_model.dart';

class SupplierService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<SupplierModel>> getSuppliers(String businessId) async {
    try {
      final response = await _supabase
          .from('suppliers')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return response
          .map<SupplierModel>((json) => SupplierModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get suppliers: ${e.toString()}');
    }
  }

  Future<SupplierModel?> createSupplier(SupplierModel supplier) async {
    try {
      final response =
          await _supabase
              .from('suppliers')
              .insert(
                supplier.toCreateJson(),
              ) // Use toCreateJson for new records
              .select()
              .single();

      return SupplierModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create supplier: ${e.toString()}');
    }
  }

  Future<SupplierModel?> updateSupplier(SupplierModel supplier) async {
    try {
      final response =
          await _supabase
              .from('suppliers')
              .update(supplier.toJson())
              .eq('id', supplier.id)
              .select()
              .single();

      return SupplierModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update supplier: ${e.toString()}');
    }
  }

  Future<bool> deleteSupplier(String supplierId) async {
    try {
      await _supabase.from('suppliers').delete().eq('id', supplierId);

      return true;
    } catch (e) {
      throw Exception('Failed to delete supplier: ${e.toString()}');
    }
  }

  Future<SupplierModel?> getSupplierById(String supplierId) async {
    try {
      final response =
          await _supabase
              .from('suppliers')
              .select()
              .eq('id', supplierId)
              .single();

      return SupplierModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get supplier: ${e.toString()}');
    }
  }

  Future<List<SupplierModel>> searchSuppliers(
    String businessId,
    String query,
  ) async {
    try {
      final response = await _supabase
          .from('suppliers')
          .select()
          .eq('business_id', businessId)
          .or('name.ilike.%$query%,phone.ilike.%$query%,email.ilike.%$query%')
          .order('created_at', ascending: false);

      return response
          .map<SupplierModel>((json) => SupplierModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search suppliers: ${e.toString()}');
    }
  }
}
