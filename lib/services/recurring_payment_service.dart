import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/recurring_payment_model.dart';
import '../models/invoice_model.dart';
import 'invoice_service.dart';

/// Service for managing recurring payments
class RecurringPaymentService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const Uuid _uuid = Uuid();

  // ============ CRUD OPERATIONS ============

  /// Create a new recurring payment
  static Future<RecurringPaymentModel?> createRecurringPayment(
    RecurringPaymentModel recurringPayment,
  ) async {
    try {
      // Validate customer_id to prevent UUID error
      if (recurringPayment.customerId.trim().isEmpty) {
        throw Exception('Customer ID is required and cannot be empty');
      }

      final data = recurringPayment.toCreateJson();
      
      // Ensure customer_id is not empty string
      if (data['customer_id'] == null || (data['customer_id'] as String).trim().isEmpty) {
        throw Exception('Customer ID cannot be empty');
      }
      
      // Don't add user_id - table doesn't have this column
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();
      data['occurrences_generated'] = 0;
      data['status'] = RecurringPaymentStatus.active.name;

      final response =
          await _supabase
              .from('recurring_payments')
              .insert(data)
              .select()
              .single();

      return RecurringPaymentModel.fromJson(response);
    } catch (e) {
      print('Error creating recurring payment: $e');
      rethrow; // Rethrow to show actual error to user
    }
  }

  /// Get recurring payment by ID
  static Future<RecurringPaymentModel?> getRecurringPaymentById(
    String id,
  ) async {
    try {
      final response =
          await _supabase
              .from('recurring_payments')
              .select()
              .eq('id', id)
              .single();

      return RecurringPaymentModel.fromJson(response);
    } catch (e) {
      print('Error fetching recurring payment: $e');
      return null;
    }
  }

  /// Get all recurring payments for a business
  static Future<List<RecurringPaymentModel>> getRecurringPayments({
    required String businessId,
    String? customerId,
    RecurringPaymentStatus? status,
  }) async {
    try {
      var query = _supabase
          .from('recurring_payments')
          .select()
          .eq('business_id', businessId);

      if (customerId != null) {
        query = query.eq('customer_id', customerId);
      }

      if (status != null) {
        query = query.eq('status', status.name);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => RecurringPaymentModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching recurring payments: $e');
      return [];
    }
  }

  /// Update recurring payment
  static Future<RecurringPaymentModel?> updateRecurringPayment(
    RecurringPaymentModel recurringPayment,
  ) async {
    try {
      final data = recurringPayment.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('recurring_payments')
          .update(data)
          .eq('id', recurringPayment.id);

      return await getRecurringPaymentById(recurringPayment.id);
    } catch (e) {
      print('Error updating recurring payment: $e');
      return null;
    }
  }

  /// Delete recurring payment
  static Future<bool> deleteRecurringPayment(String id) async {
    try {
      await _supabase.from('recurring_payments').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting recurring payment: $e');
      return false;
    }
  }

  /// Pause recurring payment
  static Future<bool> pauseRecurringPayment(String id) async {
    try {
      await _supabase
          .from('recurring_payments')
          .update({
            'status': RecurringPaymentStatus.paused.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
      return true;
    } catch (e) {
      print('Error pausing recurring payment: $e');
      return false;
    }
  }

  /// Resume recurring payment
  static Future<bool> resumeRecurringPayment(String id) async {
    try {
      await _supabase
          .from('recurring_payments')
          .update({
            'status': RecurringPaymentStatus.active.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
      return true;
    } catch (e) {
      print('Error resuming recurring payment: $e');
      return false;
    }
  }

  /// Cancel recurring payment
  static Future<bool> cancelRecurringPayment(String id) async {
    try {
      await _supabase
          .from('recurring_payments')
          .update({
            'status': RecurringPaymentStatus.cancelled.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
      return true;
    } catch (e) {
      print('Error cancelling recurring payment: $e');
      return false;
    }
  }

  // ============ OCCURRENCE GENERATION ============

  /// Process all active recurring payments and generate occurrences
  static Future<int> processRecurringPayments({
    required String businessId,
  }) async {
    try {
      // Get all active recurring payments
      final recurringPayments = await getRecurringPayments(
        businessId: businessId,
        status: RecurringPaymentStatus.active,
      );

      int generatedCount = 0;

      for (final recurring in recurringPayments) {
        if (recurring.shouldGenerateNext()) {
          final success = await generateOccurrence(recurring);
          if (success) {
            generatedCount++;
          }
        }
      }

      return generatedCount;
    } catch (e) {
      print('Error processing recurring payments: $e');
      return 0;
    }
  }

  /// Generate next occurrence for a recurring payment
  static Future<bool> generateOccurrence(
    RecurringPaymentModel recurringPayment,
  ) async {
    try {
      final now = DateTime.now();

      // Calculate due date
      final dueDate =
          recurringPayment.lastGeneratedDate != null
              ? recurringPayment.calculateNextOccurrenceDate(
                recurringPayment.lastGeneratedDate!,
              )
              : recurringPayment.startDate;

      // Create occurrence record
      final occurrence = RecurringPaymentOccurrence(
        id: _uuid.v4(),
        recurringPaymentId: recurringPayment.id,
        businessId: recurringPayment.businessId,
        customerId: recurringPayment.customerId,
        supplierId: recurringPayment.supplierId,
        amount: recurringPayment.amount,
        dueDate: dueDate,
        generatedAt: now,
        invoiceGenerated: false,
        reminderSent: false,
        paid: false,
        createdAt: now,
        updatedAt: now,
      );

      // Insert occurrence
      await _supabase
          .from('recurring_payment_occurrences')
          .insert(occurrence.toJson());

      // Generate invoice if configured
      String? invoiceId;
      String? transactionId;

      if (recurringPayment.autoGenerateInvoice) {
        final invoice = await _generateInvoiceForOccurrence(
          recurringPayment,
          occurrence,
        );

        if (invoice != null) {
          invoiceId = invoice.id;
          transactionId = invoice.transactionId;

          // Update occurrence with invoice ID
          await _supabase
              .from('recurring_payment_occurrences')
              .update({
                'invoice_id': invoiceId,
                'transaction_id': transactionId,
                'invoice_generated': true,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', occurrence.id);
        }
      }

      // Update recurring payment
      await _supabase
          .from('recurring_payments')
          .update({
            'last_generated_date': dueDate.toIso8601String(),
            'occurrences_generated': recurringPayment.occurrencesGenerated + 1,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', recurringPayment.id);

      // Check if recurring payment should be marked as completed
      final maxOcc = recurringPayment.maxOccurrences;
      if (maxOcc != null &&
          recurringPayment.occurrencesGenerated + 1 >= maxOcc) {
        await _supabase
            .from('recurring_payments')
            .update({
              'status': RecurringPaymentStatus.completed.name,
              'updated_at': now.toIso8601String(),
            })
            .eq('id', recurringPayment.id);
      }

      return true;
    } catch (e) {
      print('Error generating occurrence: $e');
      return false;
    }
  }

  /// Generate invoice for an occurrence
  static Future<InvoiceModel?> _generateInvoiceForOccurrence(
    RecurringPaymentModel recurringPayment,
    RecurringPaymentOccurrence occurrence,
  ) async {
    try {
      // Generate invoice number
      final invoiceNumber = await InvoiceService.generateInvoiceNumber(
        recurringPayment.businessId,
      );

      // Create invoice
      final invoice = InvoiceModel(
        id: _uuid.v4(),
        businessId: recurringPayment.businessId,
        customerId: recurringPayment.customerId,
        supplierId: recurringPayment.supplierId,
        invoiceNumber: invoiceNumber,
        invoiceType:
            recurringPayment.supplierId == null
                ? InvoiceType.customer
                : InvoiceType.supplier,
        invoiceDate: occurrence.generatedAt,
        dueDate: occurrence.dueDate,
        status: InvoiceStatus.sent,
        subtotal: recurringPayment.amount,
        totalAmount: recurringPayment.amount,
        paidAmount: 0.0,
        taxAmount: 0.0,
        discountAmount: 0.0,
        notes:
            'Recurring: ${recurringPayment.description}\n${recurringPayment.notes ?? ''}',
        items: [
          InvoiceItemModel(
            id: _uuid.v4(),
            invoiceId: '',
            name: recurringPayment.description,
            description:
                'Recurring payment - ${recurringPayment.frequencyDescription}',
            quantity: 1,
            unitPrice: recurringPayment.amount,
            totalAmount: recurringPayment.amount,
            taxRate: 0.0,
            discountRate: 0.0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await InvoiceService.createInvoice(invoice);
    } catch (e) {
      print('Error generating invoice for occurrence: $e');
      return null;
    }
  }

  // ============ OCCURRENCE MANAGEMENT ============

  /// Get occurrences for a recurring payment
  static Future<List<RecurringPaymentOccurrence>> getOccurrences({
    required String recurringPaymentId,
  }) async {
    try {
      final response = await _supabase
          .from('recurring_payment_occurrences')
          .select()
          .eq('recurring_payment_id', recurringPaymentId)
          .order('due_date', ascending: false);

      return (response as List)
          .map((json) => RecurringPaymentOccurrence.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching occurrences: $e');
      return [];
    }
  }

  /// Get all occurrences for a business
  static Future<List<RecurringPaymentOccurrence>> getBusinessOccurrences({
    required String businessId,
    bool? paid,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _supabase
          .from('recurring_payment_occurrences')
          .select()
          .eq('business_id', businessId);

      if (paid != null) {
        query = query.eq('paid', paid);
      }

      if (fromDate != null) {
        query = query.gte('due_date', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('due_date', toDate.toIso8601String());
      }

      final response = await query.order('due_date', ascending: false);

      return (response as List)
          .map((json) => RecurringPaymentOccurrence.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching business occurrences: $e');
      return [];
    }
  }

  /// Mark occurrence as paid
  static Future<bool> markOccurrencePaid(String occurrenceId) async {
    try {
      await _supabase
          .from('recurring_payment_occurrences')
          .update({
            'paid': true,
            'paid_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', occurrenceId);
      return true;
    } catch (e) {
      print('Error marking occurrence as paid: $e');
      return false;
    }
  }

  // ============ STATISTICS ============

  /// Get recurring payment statistics
  static Future<Map<String, dynamic>> getRecurringPaymentStats({
    required String businessId,
  }) async {
    try {
      final recurringPayments = await getRecurringPayments(
        businessId: businessId,
      );

      final activeCount =
          recurringPayments
              .where((r) => r.status == RecurringPaymentStatus.active)
              .length;

      final totalMonthlyRevenue = recurringPayments
          .where((r) => r.status == RecurringPaymentStatus.active)
          .where((r) => r.frequency == RecurringFrequency.monthly)
          .fold<double>(0.0, (sum, r) => sum + r.amount);

      final occurrences = await getBusinessOccurrences(
        businessId: businessId,
        paid: false,
      );

      final upcomingAmount = occurrences.fold<double>(
        0.0,
        (sum, o) => sum + o.amount,
      );

      return {
        'active_count': activeCount,
        'total_monthly_revenue': totalMonthlyRevenue,
        'upcoming_amount': upcomingAmount,
        'upcoming_count': occurrences.length,
      };
    } catch (e) {
      print('Error fetching recurring payment stats: $e');
      return {};
    }
  }
}
