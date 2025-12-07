import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cashbook_entry_model.dart';

class CashbookService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CashbookEntryModel>> getCashbookEntries(String businessId) async {
    try {
      final response = await _supabase
          .from('cashbook_entries')
          .select()
          .eq('business_id', businessId)
          .order('entry_date', ascending: false);

      return response
          .map<CashbookEntryModel>((json) => CashbookEntryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get cashbook entries: ${e.toString()}');
    }
  }

  Future<CashbookEntryModel?> createCashbookEntry(
    CashbookEntryModel entry,
  ) async {
    try {
      final response =
          await _supabase
              .from('cashbook_entries')
              .insert(entry.toCreateJson())
              .select()
              .single();

      return CashbookEntryModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create cashbook entry: ${e.toString()}');
    }
  }

  Future<CashbookEntryModel?> updateCashbookEntry(
    CashbookEntryModel entry,
  ) async {
    try {
      final response =
          await _supabase
              .from('cashbook_entries')
              .update(entry.toJson())
              .eq('id', entry.id)
              .select()
              .single();

      return CashbookEntryModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update cashbook entry: ${e.toString()}');
    }
  }

  Future<bool> deleteCashbookEntry(String entryId) async {
    try {
      await _supabase.from('cashbook_entries').delete().eq('id', entryId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete cashbook entry: ${e.toString()}');
    }
  }

  Future<List<CashbookEntryModel>> getCashbookEntriesByDate(
    String businessId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _supabase
          .from('cashbook_entries')
          .select()
          .eq('business_id', businessId)
          .eq('entry_date', dateStr)
          .order('created_at', ascending: false);

      return response
          .map<CashbookEntryModel>((json) => CashbookEntryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to get cashbook entries by date: ${e.toString()}',
      );
    }
  }

  Future<double> getCashBalance(String businessId, DateTime? upToDate) async {
    try {
      var query = _supabase
          .from('cashbook_entries')
          .select('type, amount')
          .eq('business_id', businessId);

      if (upToDate != null) {
        query = query.lte(
          'entry_date',
          upToDate.toIso8601String().split('T')[0],
        );
      }

      final response = await query;

      double balance = 0.0;
      for (final entry in response) {
        final amount = (entry['amount'] as num).toDouble();
        if (entry['type'] == 'IN') {
          balance += amount;
        } else {
          balance -= amount;
        }
      }
      return balance;
    } catch (e) {
      throw Exception('Failed to get cash balance: ${e.toString()}');
    }
  }

  Future<Map<String, double>> getDailySummary(
    String businessId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _supabase
          .from('cashbook_entries')
          .select('type, amount')
          .eq('business_id', businessId)
          .eq('entry_date', dateStr);

      double cashIn = 0.0;
      double cashOut = 0.0;

      for (final entry in response) {
        final amount = (entry['amount'] as num).toDouble();
        if (entry['type'] == 'IN') {
          cashIn += amount;
        } else {
          cashOut += amount;
        }
      }

      return {
        'cashIn': cashIn,
        'cashOut': cashOut,
        'netCash': cashIn - cashOut,
      };
    } catch (e) {
      throw Exception('Failed to get daily summary: ${e.toString()}');
    }
  }
}
