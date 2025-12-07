import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice_model.dart';
import '../models/transaction_model.dart';
import '../models/payment_model.dart';
import 'invoice_service.dart';

/// Service for ensuring data consistency across invoices, transactions, payments, and customers
/// This service acts as the central coordinator for all accounting-related data synchronization
class AccountingSyncService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sync all related entities when invoice status changes
  /// This ensures transaction status and customer balance are updated when invoice is paid
  Future<void> syncInvoiceStatusChange({
    required InvoiceModel invoice,
    required InvoiceStatus oldStatus,
    required InvoiceStatus newStatus,
  }) async {
    try {
      // Start a transaction for atomic updates
      await _supabase.rpc('begin_transaction');

      try {
        // Update linked transaction status if invoice is fully paid
        if (newStatus == InvoiceStatus.paid && invoice.transactionId != null) {
          await _updateTransactionStatus(
            transactionId: invoice.transactionId!,
            status: 'completed',
          );
        }

        // Recalculate customer balance if customer is linked
        if (invoice.customerId != null) {
          await recalculateCustomerBalance(invoice.customerId!);
        }

        // Create audit trail entry
        await _createAuditEntry(
          businessId: invoice.businessId,
          entityType: 'invoice',
          entityId: invoice.id,
          action: 'status_change',
          metadata: {
            'old_status': oldStatus.name,
            'new_status': newStatus.name,
            'invoice_number': invoice.invoiceNumber,
            'total_amount': invoice.totalAmount,
            'paid_amount': invoice.paidAmount,
          },
        );

        // Commit transaction
        await _supabase.rpc('commit_transaction');

        // Notify providers (this will be handled by the calling code through state management)
      } catch (e) {
        // Rollback on error
        await _supabase.rpc('rollback_transaction');
        rethrow;
      }
    } catch (e) {
      throw Exception('Failed to sync invoice status change: ${e.toString()}');
    }
  }

  /// Sync when payment is recorded
  /// Updates invoice, transaction, customer balance, and creates audit trail
  Future<void> syncPaymentRecorded({
    required PaymentModel payment,
    required InvoiceModel invoice,
  }) async {
    try {
      // Start a transaction for atomic updates
      await _supabase.rpc('begin_transaction');

      try {
        // Update invoice paid_amount and status
        final newPaidAmount = invoice.paidAmount + payment.amount;
        final newStatus = _determineInvoiceStatus(
          totalAmount: invoice.totalAmount,
          paidAmount: newPaidAmount,
          dueDate:
              invoice.dueDate ?? DateTime.now().add(const Duration(days: 30)),
        );

        await _supabase
            .from('invoices')
            .update({
              'paid_amount': newPaidAmount,
              'status': newStatus.name,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', invoice.id);

        // Update transaction status if fully paid
        if (newStatus == InvoiceStatus.paid && invoice.transactionId != null) {
          await _updateTransactionStatus(
            transactionId: invoice.transactionId!,
            status: 'completed',
          );
        }

        // Update customer balance
        if (invoice.customerId != null) {
          await recalculateCustomerBalance(invoice.customerId!);
        }

        // Create audit trail entry
        await _createAuditEntry(
          businessId: invoice.businessId,
          entityType: 'payment',
          entityId: payment.id,
          action: 'payment_recorded',
          metadata: {
            'invoice_id': invoice.id,
            'invoice_number': invoice.invoiceNumber,
            'payment_amount': payment.amount,
            'payment_mode': payment.paymentMode.name,
            'new_paid_amount': newPaidAmount,
            'new_status': newStatus.name,
            'customer_id': invoice.customerId,
          },
        );

        // Commit transaction
        await _supabase.rpc('commit_transaction');
      } catch (e) {
        // Rollback on error
        await _supabase.rpc('rollback_transaction');
        rethrow;
      }
    } catch (e) {
      throw Exception('Failed to sync payment recorded: ${e.toString()}');
    }
  }

  /// Sync when transaction is created
  /// Creates linked invoice if transaction has customer and links them bidirectionally
  Future<InvoiceModel?> syncTransactionCreated({
    required TransactionModel transaction,
  }) async {
    try {
      // Only create invoice for income transactions with customers
      if (transaction.type != TransactionType.income ||
          transaction.customerId == null) {
        return null;
      }

      // Start a transaction for atomic updates
      await _supabase.rpc('begin_transaction');

      try {
        // Generate invoice number
        final invoiceNumber = await InvoiceService.generateInvoiceNumber(
          transaction.businessId,
        );

        // Create invoice from transaction
        final now = DateTime.now();
        final invoice = InvoiceModel(
          id: '', // Will be generated by database
          businessId: transaction.businessId,
          customerId: transaction.customerId,
          invoiceNumber: invoiceNumber,
          invoiceType: InvoiceType.customer,
          invoiceDate: transaction.date,
          dueDate: transaction.date.add(const Duration(days: 30)),
          status: InvoiceStatus.sent,
          subtotal: transaction.amount,
          taxAmount: 0,
          totalAmount: transaction.amount,
          paidAmount: 0,
          notes: transaction.description,
          transactionId: transaction.id,
          items: [
            InvoiceItemModel(
              id: '',
              invoiceId: '', // Will be set after invoice creation
              name: transaction.description,
              description: transaction.description,
              quantity: 1,
              unitPrice: transaction.amount,
              taxRate: 0,
              totalAmount: transaction.amount,
              createdAt: now,
              updatedAt: now,
            ),
          ],
          createdAt: now,
          updatedAt: now,
        );

        // Create invoice
        final createdInvoice = await InvoiceService.createInvoice(invoice);
        if (createdInvoice == null) {
          throw Exception('Failed to create invoice');
        }

        // Link transaction to invoice
        await _supabase
            .from('transactions')
            .update({
              'invoice_id': createdInvoice.id,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', transaction.id);

        // Update customer receivables
        if (transaction.customerId != null) {
          await recalculateCustomerBalance(transaction.customerId!);
        }

        // Create audit trail entry
        await _createAuditEntry(
          businessId: transaction.businessId,
          entityType: 'transaction',
          entityId: transaction.id,
          action: 'invoice_created',
          metadata: {
            'transaction_id': transaction.id,
            'invoice_id': createdInvoice.id,
            'invoice_number': invoiceNumber,
            'amount': transaction.amount,
            'customer_id': transaction.customerId,
          },
        );

        // Commit transaction
        await _supabase.rpc('commit_transaction');

        return createdInvoice;
      } catch (e) {
        // Rollback on error
        await _supabase.rpc('rollback_transaction');
        rethrow;
      }
    } catch (e) {
      throw Exception('Failed to sync transaction created: ${e.toString()}');
    }
  }

  /// Recalculate customer balance based on ALL financial activities
  /// This ensures the customer balance field is always accurate
  /// 
  /// Balance calculation includes:
  /// - All unpaid and partially paid invoices
  /// - Direct income transactions without invoices
  /// - Payments received (reduces balance)
  /// - Credits issued (reduces balance)
  Future<void> recalculateCustomerBalance(String customerId) async {
    try {
      double outstandingBalance = 0;

      // 1. Sum outstanding amounts from invoices
      final invoicesResponse = await _supabase
          .from('invoices')
          .select('total_amount, paid_amount, status')
          .eq('customer_id', customerId)
          .inFilter('status', [
            InvoiceStatus.sent.name,
            InvoiceStatus.partiallyPaid.name,
            InvoiceStatus.overdue.name,
          ]);

      for (final invoice in invoicesResponse as List) {
        final totalAmount = (invoice['total_amount'] as num?)?.toDouble() ?? 0;
        final paidAmount = (invoice['paid_amount'] as num?)?.toDouble() ?? 0;
        outstandingBalance += (totalAmount - paidAmount);
      }

      // 2. Add income transactions without invoices (pending receivables)
      final transactionsResponse = await _supabase
          .from('transactions')
          .select('amount, type, status')
          .eq('customer_id', customerId)
          .isFilter('invoice_id', null) // No invoice linked
          .inFilter('type', ['income', 'sale', 'payment_in'])
          .neq('status', 'completed'); // Not yet received

      for (final transaction in transactionsResponse as List) {
        final amount = (transaction['amount'] as num?)?.toDouble() ?? 0;
        outstandingBalance += amount;
      }

      // 3. Subtract direct payments received (not linked to invoices)
      final paymentsResponse = await _supabase
          .from('payments')
          .select('amount, status')
          .eq('customer_id', customerId)
          .isFilter('invoice_id', null) // Direct payments
          .eq('status', PaymentStatus.completed.name);

      for (final payment in paymentsResponse as List) {
        final amount = (payment['amount'] as num?)?.toDouble() ?? 0;
        outstandingBalance -= amount;
      }

      // 4. Handle credits/refunds (reduce balance)
      final creditsResponse = await _supabase
          .from('transactions')
          .select('amount')
          .eq('customer_id', customerId)
          .inFilter('type', ['refund', 'credit'])
          .eq('status', 'completed');

      for (final credit in creditsResponse as List) {
        final amount = (credit['amount'] as num?)?.toDouble() ?? 0;
        outstandingBalance -= amount;
      }

      // Ensure balance is not negative (customer doesn't owe negative amount)
      outstandingBalance = outstandingBalance.clamp(0.0, double.infinity);

      // Update customer balance field atomically
      await _supabase
          .from('customers')
          .update({
            'balance': outstandingBalance,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', customerId);

      // Log balance calculation for debugging
      print('Customer $customerId balance recalculated: ₹$outstandingBalance');
    } catch (e) {
      throw Exception(
        'Failed to recalculate customer balance: ${e.toString()}',
      );
    }
  }

  // ============ PRIVATE HELPER METHODS ============

  /// Update transaction status
  Future<void> _updateTransactionStatus({
    required String transactionId,
    required String status,
  }) async {
    await _supabase
        .from('transactions')
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', transactionId);
  }

  /// Determine invoice status based on payment amount and due date
  InvoiceStatus _determineInvoiceStatus({
    required double totalAmount,
    required double paidAmount,
    required DateTime dueDate,
  }) {
    if (paidAmount >= totalAmount) {
      return InvoiceStatus.paid;
    } else if (paidAmount > 0) {
      return InvoiceStatus.partiallyPaid;
    } else if (dueDate.isBefore(DateTime.now())) {
      return InvoiceStatus.overdue;
    } else {
      return InvoiceStatus.sent;
    }
  }

  /// Create audit trail entry for accounting operations
  Future<void> _createAuditEntry({
    required String businessId,
    required String entityType,
    required String entityId,
    required String action,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      await _supabase.from('audit_logs').insert({
        'business_id': businessId,
        'entity_type': entityType,
        'entity_id': entityId,
        'action': action,
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Log error but don't fail the operation
      print('Warning: Failed to create audit entry: $e');
    }
  }
}
