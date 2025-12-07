import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business_model.dart';

class BusinessService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<BusinessModel?> getBusinessByUserId(String userId) async {
    try {
      debugPrint('Looking for business with user_id: $userId');

      final response =
          await _supabase
              .from('businesses')
              .select()
              .eq('user_id', userId)
              .single();

      debugPrint('Found business: ${response['id']} for user: $userId');
      return BusinessModel.fromJson(response);
    } catch (e) {
      debugPrint('Business lookup failed for user $userId: $e');

      if (e.toString().contains('No rows found')) {
        return null;
      }
      throw Exception('Failed to get business: ${e.toString()}');
    }
  }

  Future<BusinessModel?> createBusiness(BusinessModel business) async {
    try {
      final response =
          await _supabase
              .from('businesses')
              .insert(business.toCreateJson())
              .select()
              .single();

      return BusinessModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create business: ${e.toString()}');
    }
  }

  Future<BusinessModel?> updateBusiness(BusinessModel business) async {
    try {
      final response =
          await _supabase
              .from('businesses')
              .update(business.toJson())
              .eq('id', business.id)
              .select()
              .single();

      return BusinessModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update business: ${e.toString()}');
    }
  }

  Future<bool> deleteBusiness(String businessId) async {
    try {
      await _supabase.from('businesses').delete().eq('id', businessId);

      return true;
    } catch (e) {
      throw Exception('Failed to delete business: ${e.toString()}');
    }
  }
}
