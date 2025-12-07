import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessContextService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current business context
  Future<Map<String, dynamic>> getCurrentContext(String businessId) async {
    return await getBusinessContext(businessId);
  }

  // Get business context for analysis
  Future<Map<String, dynamic>> getBusinessContext(String businessId) async {
    try {
      final response =
          await _supabase
              .from('businesses')
              .select('*')
              .eq('id', businessId)
              .single();

      return response;
    } catch (e) {
      return {};
    }
  }

  // Get business metrics
  Future<Map<String, dynamic>> getBusinessMetrics(String businessId) async {
    try {
      // Get transactions summary
      final transactions = await _supabase
          .from('transactions')
          .select('amount, type, created_at')
          .eq('business_id', businessId)
          .gte(
            'created_at',
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          );

      double totalIncome = 0;
      double totalExpense = 0;

      for (var transaction in transactions) {
        if (transaction['type'] == 'income') {
          totalIncome += (transaction['amount'] as num).toDouble();
        } else {
          totalExpense += (transaction['amount'] as num).toDouble();
        }
      }

      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'netProfit': totalIncome - totalExpense,
        'transactionCount': transactions.length,
      };
    } catch (e) {
      return {
        'totalIncome': 0.0,
        'totalExpense': 0.0,
        'netProfit': 0.0,
        'transactionCount': 0,
      };
    }
  }

  // Get industry benchmarks
  Future<Map<String, dynamic>> getIndustryBenchmarks(String industry) async {
    // Return default benchmarks
    return {
      'averageRevenue': 100000.0,
      'averageExpense': 70000.0,
      'averageProfit': 30000.0,
      'industry': industry,
    };
  }

  // Get business trends
  Future<List<Map<String, dynamic>>> getBusinessTrends(
    String businessId, {
    int days = 30,
  }) async {
    try {
      final transactions = await _supabase
          .from('transactions')
          .select('amount, type, created_at')
          .eq('business_id', businessId)
          .gte(
            'created_at',
            DateTime.now().subtract(Duration(days: days)).toIso8601String(),
          )
          .order('created_at');

      return List<Map<String, dynamic>>.from(transactions);
    } catch (e) {
      return [];
    }
  }
}
