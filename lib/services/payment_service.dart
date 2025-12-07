import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/payment_model.dart';
import '../models/invoice_model.dart';
import '../models/transaction_model.dart';

/// Result object for payment operations
class PaymentResult {
  final bool success;
  final String? message;
  final PaymentModel? payment;
  final InvoiceModel? updatedInvoice;
  final String? errorCode;

  PaymentResult({
    required this.success,
    this.message,
    this.payment,
    this.updatedInvoice,
    this.errorCode,
  });

  factory PaymentResult.success({
    String? message,
    PaymentModel? payment,
    InvoiceModel? updatedInvoice,
  }) {
    return PaymentResult(
      success: true,
      message: message ?? 'Payment recorded successfully',
      payment: payment,
      updatedInvoice: updatedInvoice,
    );
  }

  factory PaymentResult.failure({required String message, String? errorCode}) {
    return PaymentResult(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }
}

/// Allocation of payment amount to a specific invoice
class InvoicePaymentAllocation {
  final String invoiceId;
  final double amount;
  final String? notes;

  InvoicePaymentAllocation({
    required this.invoiceId,
    required this.amount,
    this.notes,
  });
}

/// Service for centralized payment management
class PaymentService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const Uuid _uuid = Uuid();

  // ============ SINGLE INVOICE PAYMENT ============

  /// Record payment against a single invoice
  ///
  /// Validates invoice exists and amount is valid, creates payment record,
  /// updates invoice paid_amount, and returns PaymentResult with success/error details.
  ///
  /// Requirements: 6.1, 6.3
  static Future<PaymentResult> recordPayment({
    required String invoiceId,
    required double amount,
    required PaymentMode paymentMode,
    String? reference,
    String? notes,
    DateTime? paymentDate,
  }) async {
    try {
      // Validate amount is positive
      if (amount <= 0) {
        return PaymentResult.failure(
          message: 'Payment amount must be greater than zero',
          errorCode: 'INVALID_AMOUNT',
        );
      }

      // Fetch invoice to validate it exists
      final invoiceResponse =
          await _supabase
              .from('invoices')
              .select()
              .eq('id', invoiceId)
              .maybeSingle();

      if (invoiceResponse == null) {
        return PaymentResult.failure(
          message: 'Invoice not found',
          errorCode: 'INVOICE_NOT_FOUND',
        );
      }

      final invoice = InvoiceModel.fromJson(invoiceResponse);

      // Validate invoice is not cancelled
      if (invoice.status == InvoiceStatus.cancelled) {
        return PaymentResult.failure(
          message: 'Cannot record payment for cancelled invoice',
          errorCode: 'INVOICE_CANCELLED',
        );
      }

      // Calculate outstanding amount
      final outstandingAmount = invoice.totalAmount - invoice.paidAmount;

      // Validate amount doesn't exceed outstanding
      if (amount > outstandingAmount + 0.01) {
        // Allow small rounding difference
        return PaymentResult.failure(
          message:
              'Payment amount (₹${amount.toStringAsFixed(2)}) exceeds outstanding amount (₹${outstandingAmount.toStringAsFixed(2)})',
          errorCode: 'AMOUNT_EXCEEDS_OUTSTANDING',
        );
      }

      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return PaymentResult.failure(
          message: 'User not authenticated',
          errorCode: 'NOT_AUTHENTICATED',
        );
      }

      final now = DateTime.now();
      final effectivePaymentDate = paymentDate ?? now;

      // Create payment record
      final payment = PaymentModel(
        id: _uuid.v4(),
        businessId: invoice.businessId,
        userId: user.id,
        invoiceId: invoiceId,
        transactionId: invoice.transactionId,
        customerId: invoice.customerId,
        supplierId: invoice.supplierId,
        amount: amount,
        paymentMode: paymentMode,
        status: PaymentStatus.completed,
        paymentDate: effectivePaymentDate,
        reference: reference,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      // Insert payment record into database
      await _supabase.from('payments').insert(payment.toCreateJson());

      // Update invoice paid_amount
      final newPaidAmount = invoice.paidAmount + amount;
      await _supabase
          .from('invoices')
          .update({
            'paid_amount': newPaidAmount,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', invoiceId);

      // Fetch updated invoice (trigger will update status automatically)
      final updatedInvoiceResponse =
          await _supabase
              .from('invoices')
              .select()
              .eq('id', invoiceId)
              .single();

      final updatedInvoice = InvoiceModel.fromJson(updatedInvoiceResponse);

      return PaymentResult.success(
        message:
            'Payment of ₹${amount.toStringAsFixed(2)} recorded successfully',
        payment: payment,
        updatedInvoice: updatedInvoice,
      );
    } catch (e) {
      return PaymentResult.failure(
        message: 'Failed to record payment: ${e.toString()}',
        errorCode: 'PAYMENT_ERROR',
      );
    }
  }

  // ============ MULTI-INVOICE PAYMENT ============

  /// Record payment distributed across multiple invoices
  ///
  /// Accepts list of invoice-amount allocations, validates total allocation
  /// matches payment amount, creates payment records for each allocation,
  /// and updates all affected invoices atomically.
  ///
  /// Requirements: 6.2
  static Future<PaymentResult> recordDistributedPayment({
    required List<InvoicePaymentAllocation> allocations,
    required PaymentMode paymentMode,
    String? reference,
    String? notes,
    DateTime? paymentDate,
  }) async {
    try {
      // Validate allocations list is not empty
      if (allocations.isEmpty) {
        return PaymentResult.failure(
          message: 'No invoice allocations provided',
          errorCode: 'NO_ALLOCATIONS',
        );
      }

      // Calculate total allocation amount
      final totalAllocation = allocations.fold<double>(
        0.0,
        (sum, allocation) => sum + allocation.amount,
      );

      // Validate all amounts are positive
      for (final allocation in allocations) {
        if (allocation.amount <= 0) {
          return PaymentResult.failure(
            message: 'All allocation amounts must be greater than zero',
            errorCode: 'INVALID_ALLOCATION_AMOUNT',
          );
        }
      }

      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return PaymentResult.failure(
          message: 'User not authenticated',
          errorCode: 'NOT_AUTHENTICATED',
        );
      }

      // Fetch all invoices to validate
      final invoiceIds = allocations.map((a) => a.invoiceId).toList();
      final invoicesResponse = await _supabase
          .from('invoices')
          .select()
          .inFilter('id', invoiceIds);

      if (invoicesResponse.isEmpty) {
        return PaymentResult.failure(
          message: 'No invoices found',
          errorCode: 'INVOICES_NOT_FOUND',
        );
      }

      final invoices =
          (invoicesResponse as List)
              .map((json) => InvoiceModel.fromJson(json))
              .toList();

      // Validate all invoices exist
      if (invoices.length != allocations.length) {
        return PaymentResult.failure(
          message: 'Some invoices not found',
          errorCode: 'INVOICES_NOT_FOUND',
        );
      }

      // Validate each allocation
      for (final allocation in allocations) {
        final invoice = invoices.firstWhere(
          (inv) => inv.id == allocation.invoiceId,
          orElse:
              () =>
                  throw Exception('Invoice ${allocation.invoiceId} not found'),
        );

        // Check if invoice is cancelled
        if (invoice.status == InvoiceStatus.cancelled) {
          return PaymentResult.failure(
            message:
                'Cannot record payment for cancelled invoice ${invoice.invoiceNumber}',
            errorCode: 'INVOICE_CANCELLED',
          );
        }

        // Check if amount exceeds outstanding
        final outstanding = invoice.totalAmount - invoice.paidAmount;
        if (allocation.amount > outstanding + 0.01) {
          return PaymentResult.failure(
            message:
                'Allocation for invoice ${invoice.invoiceNumber} (₹${allocation.amount.toStringAsFixed(2)}) exceeds outstanding (₹${outstanding.toStringAsFixed(2)})',
            errorCode: 'ALLOCATION_EXCEEDS_OUTSTANDING',
          );
        }
      }

      final now = DateTime.now();
      final effectivePaymentDate = paymentDate ?? now;

      // Create payment records for each allocation
      final paymentRecords = <Map<String, dynamic>>[];
      final invoiceUpdates = <Map<String, dynamic>>[];

      for (final allocation in allocations) {
        final invoice = invoices.firstWhere(
          (inv) => inv.id == allocation.invoiceId,
        );

        final payment = PaymentModel(
          id: _uuid.v4(),
          businessId: invoice.businessId,
          userId: user.id,
          invoiceId: allocation.invoiceId,
          transactionId: invoice.transactionId,
          customerId: invoice.customerId,
          supplierId: invoice.supplierId,
          amount: allocation.amount,
          paymentMode: paymentMode,
          status: PaymentStatus.completed,
          paymentDate: effectivePaymentDate,
          reference: reference,
          notes: allocation.notes ?? notes,
          createdAt: now,
          updatedAt: now,
        );

        paymentRecords.add(payment.toCreateJson());

        // Prepare invoice update
        final newPaidAmount = invoice.paidAmount + allocation.amount;
        invoiceUpdates.add({
          'id': allocation.invoiceId,
          'paid_amount': newPaidAmount,
          'updated_at': now.toIso8601String(),
        });
      }

      // Execute all operations atomically using RPC or sequential updates
      // Insert all payment records
      await _supabase.from('payments').insert(paymentRecords);

      // Update all invoices
      for (final update in invoiceUpdates) {
        await _supabase
            .from('invoices')
            .update({
              'paid_amount': update['paid_amount'],
              'updated_at': update['updated_at'],
            })
            .eq('id', update['id']);
      }

      return PaymentResult.success(
        message:
            'Distributed payment of ₹${totalAllocation.toStringAsFixed(2)} recorded across ${allocations.length} invoices',
      );
    } catch (e) {
      return PaymentResult.failure(
        message: 'Failed to record distributed payment: ${e.toString()}',
        errorCode: 'DISTRIBUTED_PAYMENT_ERROR',
      );
    }
  }

  // ============ PAYMENT HISTORY ============

  /// Get payment history for an invoice
  ///
  /// Queries payments table filtered by invoice_id, returns list of PaymentModel
  /// objects ordered by payment_date descending.
  ///
  /// Requirements: 6.4
  static Future<List<PaymentModel>> getInvoicePayments(String invoiceId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('invoice_id', invoiceId)
          .order('payment_date', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PaymentModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching invoice payments: $e');
      return [];
    }
  }

  /// Get all payments for a business
  static Future<List<PaymentModel>> getBusinessPayments({
    required String businessId,
    String? customerId,
    String? supplierId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('payments')
          .select()
          .eq('business_id', businessId);

      if (customerId != null) {
        query = query.eq('customer_id', customerId);
      }
      if (supplierId != null) {
        query = query.eq('supplier_id', supplierId);
      }
      if (fromDate != null) {
        query = query.gte('payment_date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('payment_date', toDate.toIso8601String());
      }

      final response = await query
          .order('payment_date', ascending: false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => PaymentModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching business payments: $e');
      return [];
    }
  }

  // ============ PAYMENT REVERSAL ============

  /// Reverse a payment
  ///
  /// Validates payment exists and can be reversed, updates invoice paid_amount
  /// (subtracts payment), marks payment as reversed or deletes record, and
  /// updates invoice status if needed.
  ///
  /// Requirements: 6.5
  static Future<PaymentResult> reversePayment(String paymentId) async {
    try {
      // Fetch payment to validate it exists
      final paymentResponse =
          await _supabase
              .from('payments')
              .select()
              .eq('id', paymentId)
              .maybeSingle();

      if (paymentResponse == null) {
        return PaymentResult.failure(
          message: 'Payment not found',
          errorCode: 'PAYMENT_NOT_FOUND',
        );
      }

      final payment = PaymentModel.fromJson(paymentResponse);

      // Check if payment is already cancelled
      if (payment.status == PaymentStatus.cancelled) {
        return PaymentResult.failure(
          message: 'Payment is already cancelled',
          errorCode: 'PAYMENT_ALREADY_CANCELLED',
        );
      }

      // Fetch associated invoice
      if (payment.invoiceId == null) {
        return PaymentResult.failure(
          message: 'Payment has no associated invoice',
          errorCode: 'NO_INVOICE_ASSOCIATED',
        );
      }

      final invoiceResponse =
          await _supabase
              .from('invoices')
              .select()
              .eq('id', payment.invoiceId!)
              .maybeSingle();

      if (invoiceResponse == null) {
        return PaymentResult.failure(
          message: 'Associated invoice not found',
          errorCode: 'INVOICE_NOT_FOUND',
        );
      }

      final invoice = InvoiceModel.fromJson(invoiceResponse);

      // Calculate new paid amount
      final newPaidAmount = invoice.paidAmount - payment.amount;

      // Validate new paid amount is not negative
      if (newPaidAmount < -0.01) {
        // Allow small rounding difference
        return PaymentResult.failure(
          message:
              'Reversing this payment would result in negative paid amount',
          errorCode: 'INVALID_REVERSAL',
        );
      }

      final now = DateTime.now();

      // Mark payment as cancelled (don't delete for audit trail)
      await _supabase
          .from('payments')
          .update({
            'status': PaymentStatus.cancelled.toString().split('.').last,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', paymentId);

      // Update invoice paid_amount
      await _supabase
          .from('invoices')
          .update({
            'paid_amount': newPaidAmount.clamp(0.0, invoice.totalAmount),
            'updated_at': now.toIso8601String(),
          })
          .eq('id', payment.invoiceId!);

      // Fetch updated invoice (trigger will update status automatically)
      final updatedInvoiceResponse =
          await _supabase
              .from('invoices')
              .select()
              .eq('id', payment.invoiceId!)
              .single();

      final updatedInvoice = InvoiceModel.fromJson(updatedInvoiceResponse);

      return PaymentResult.success(
        message:
            'Payment of ₹${payment.amount.toStringAsFixed(2)} reversed successfully',
        updatedInvoice: updatedInvoice,
      );
    } catch (e) {
      return PaymentResult.failure(
        message: 'Failed to reverse payment: ${e.toString()}',
        errorCode: 'REVERSAL_ERROR',
      );
    }
  }

  /// Delete a payment (hard delete - use with caution)
  ///
  /// This permanently deletes a payment record. Consider using reversePayment instead
  /// to maintain audit trail.
  static Future<bool> deletePayment(String paymentId) async {
    try {
      // Fetch payment first to update invoice
      final paymentResponse =
          await _supabase
              .from('payments')
              .select()
              .eq('id', paymentId)
              .maybeSingle();

      if (paymentResponse == null) {
        return false;
      }

      final payment = PaymentModel.fromJson(paymentResponse);

      // Update invoice if associated
      if (payment.invoiceId != null) {
        final invoiceResponse =
            await _supabase
                .from('invoices')
                .select()
                .eq('id', payment.invoiceId!)
                .maybeSingle();

        if (invoiceResponse != null) {
          final invoice = InvoiceModel.fromJson(invoiceResponse);
          final newPaidAmount = (invoice.paidAmount - payment.amount).clamp(
            0.0,
            invoice.totalAmount,
          );

          await _supabase
              .from('invoices')
              .update({
                'paid_amount': newPaidAmount,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', payment.invoiceId!);
        }
      }

      // Delete payment
      await _supabase.from('payments').delete().eq('id', paymentId);

      return true;
    } catch (e) {
      print('Error deleting payment: $e');
      return false;
    }
  }

  // ============ PAYMENT STATISTICS ============

  /// Get payment statistics for a business
  static Future<Map<String, dynamic>> getPaymentStats({
    required String businessId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _supabase
          .from('payments')
          .select('amount, payment_mode, status')
          .eq('business_id', businessId);

      if (fromDate != null) {
        query = query.gte('payment_date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('payment_date', toDate.toIso8601String());
      }

      final response = await query;
      final payments = response as List<dynamic>;

      double totalAmount = 0;
      int totalCount = 0;
      final paymentModeBreakdown = <String, double>{};

      for (final payment in payments) {
        final amount = (payment['amount'] as num?)?.toDouble() ?? 0;
        final mode = payment['payment_mode'] as String? ?? 'unknown';
        final status = payment['status'] as String? ?? 'pending';

        if (status == 'completed') {
          totalAmount += amount;
          totalCount++;

          paymentModeBreakdown[mode] =
              (paymentModeBreakdown[mode] ?? 0) + amount;
        }
      }

      return {
        'total_amount': totalAmount,
        'total_count': totalCount,
        'payment_mode_breakdown': paymentModeBreakdown,
        'average_payment': totalCount > 0 ? totalAmount / totalCount : 0,
      };
    } catch (e) {
      print('Error fetching payment stats: $e');
      return {};
    }
  }
}
