import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer_model.dart';

class CustomerService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CustomerModel>> getCustomers(String businessId) async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return response
          .map<CustomerModel>((json) => CustomerModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get customers: ${e.toString()}');
    }
  }

  Future<CustomerModel?> createCustomer(CustomerModel customer) async {
    try {
      final response =
          await _supabase
              .from('customers')
              .insert(
                customer.toCreateJson(),
              ) // Use toCreateJson for new records
              .select()
              .single();

      return CustomerModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create customer: ${e.toString()}');
    }
  }

  Future<CustomerModel?> updateCustomer(CustomerModel customer) async {
    try {
      final response =
          await _supabase
              .from('customers')
              .update(customer.toJson())
              .eq('id', customer.id)
              .select()
              .single();

      return CustomerModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update customer: ${e.toString()}');
    }
  }

  Future<bool> deleteCustomer(String customerId) async {
    try {
      await _supabase.from('customers').delete().eq('id', customerId);

      return true;
    } catch (e) {
      throw Exception('Failed to delete customer: ${e.toString()}');
    }
  }

  Future<CustomerModel?> getCustomerById(String customerId) async {
    try {
      final response =
          await _supabase
              .from('customers')
              .select()
              .eq('id', customerId)
              .single();

      return CustomerModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get customer: ${e.toString()}');
    }
  }

  Future<List<CustomerModel>> searchCustomers(
    String businessId,
    String query,
  ) async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .eq('business_id', businessId)
          .or('name.ilike.%$query%,phone.ilike.%$query%,email.ilike.%$query%')
          .order('created_at', ascending: false);

      return response
          .map<CustomerModel>((json) => CustomerModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search customers: ${e.toString()}');
    }
  }
}
