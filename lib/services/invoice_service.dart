import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice_model.dart';
import '../models/transaction_model.dart';
import '../models/payment_model.dart';
import 'accounting_sync_service.dart';
import 'payment_service.dart';

class InvoiceService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const Uuid _uuid = Uuid();

  // ============ INVOICE CRUD OPERATIONS ============

  /// Create a new invoice with optional transaction linking
  ///
  /// If transactionId is provided, creates bidirectional link between invoice and transaction.
  /// Updates transaction record with invoice_id after invoice creation.
  ///
  /// Requirements: 1.1, 1.5
  static Future<InvoiceModel?> createInvoice(
    InvoiceModel invoice, {
    String? transactionId,
  }) async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('Error: User not authenticated');
        return null;
      }

      final invoiceData = invoice.toJson();
      invoiceData.remove('id'); // Let database generate ID
      invoiceData['user_id'] = user.id; // Add user_id
      invoiceData['created_at'] = DateTime.now().toIso8601String();
      invoiceData['updated_at'] = DateTime.now().toIso8601String();

      // Add transaction link if provided
      if (transactionId != null) {
        invoiceData['transaction_id'] = transactionId;
      }

      final response =
          await _supabase
              .from('invoices')
              .insert(invoiceData)
              .select()
              .single();

      final createdInvoice = InvoiceModel.fromJson(response);

      // Create invoice items if any
      if (invoice.items.isNotEmpty) {
        await _createInvoiceItems(createdInvoice.id, invoice.items);
      }

      // Create bidirectional link: update transaction with invoice_id
      if (transactionId != null) {
        await _supabase
            .from('transactions')
            .update({
              'invoice_id': createdInvoice.id,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', transactionId);
      }

      return await getInvoiceById(createdInvoice.id);
    } catch (e) {
      print('Error creating invoice: $e');
      return null;
    }
  }

  /// Create invoice from an existing transaction
  ///
  /// Accepts TransactionModel as input, generates invoice with transaction details,
  /// links invoice to transaction, and returns created InvoiceModel.
  ///
  /// Requirements: 1.1, 1.4
  static Future<InvoiceModel?> createInvoiceFromTransaction(
    TransactionModel transaction,
  ) async {
    try {
      // Validate transaction has required fields
      if (transaction.customerId == null && transaction.supplierId == null) {
        print('Error: Transaction must have either customerId or supplierId');
        return null;
      }

      // CRITICAL: Prevent multiple invoices for same transaction
      if (transaction.invoiceId != null && transaction.invoiceId!.isNotEmpty) {
        print('Error: Transaction already has an invoice (${transaction.invoiceId})');
        return null;
      }

      // Check if an invoice already exists for this transaction
      final existingInvoices = await _supabase
          .from('invoices')
          .select('id')
          .eq('transaction_id', transaction.id)
          .limit(1);

      if (existingInvoices.isNotEmpty) {
        print('Error: Invoice already exists for transaction ${transaction.id}');
        return null;
      }

      // Generate invoice number
      final invoiceNumber = await generateInvoiceNumber(
        transaction.businessId,
        prefix: 'INV',
      );

      // Determine invoice type based on transaction type
      final invoiceType = _determineInvoiceType(transaction.type);

      // Create invoice from transaction details
      final invoice = InvoiceModel(
        id: _uuid.v4(),
        businessId: transaction.businessId,
        customerId: transaction.customerId,
        supplierId: transaction.supplierId,
        invoiceNumber: invoiceNumber,
        invoiceType: invoiceType,
        invoiceDate: transaction.date,
        dueDate:
            transaction.dueDate ??
            transaction.date.add(const Duration(days: 30)),
        status: InvoiceStatus.sent,
        subtotal: transaction.amount,
        totalAmount: transaction.amount,
        paidAmount: 0.0,
        taxAmount: 0.0,
        discountAmount: 0.0,
        notes: transaction.notes,
        transactionId: transaction.id,
        items: [
          // Create a single line item from transaction
          InvoiceItemModel(
            id: _uuid.v4(),
            invoiceId: '', // Will be set after invoice creation
            name: transaction.description,
            description: transaction.notes,
            quantity: 1,
            unitPrice: transaction.amount,
            totalAmount: transaction.amount,
            taxRate: 0.0,
            discountRate: 0.0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create invoice with transaction linking
      return await createInvoice(invoice, transactionId: transaction.id);
    } catch (e) {
      print('Error creating invoice from transaction: $e');
      return null;
    }
  }

  /// Helper method to determine invoice type from transaction type
  static InvoiceType _determineInvoiceType(TransactionType transactionType) {
    switch (transactionType) {
      case TransactionType.income:
      case TransactionType.sale:
      case TransactionType.paymentIn:
        return InvoiceType.customer;
      case TransactionType.expense:
      case TransactionType.purchase:
      case TransactionType.paymentOut:
        return InvoiceType.supplier;
      default:
        return InvoiceType.customer;
    }
  }

  /// Update an existing invoice with related entity synchronization
  ///
  /// Calls AccountingSyncService when status changes to maintain data consistency.
  /// Updates linked transaction if needed.
  ///
  /// Requirements: 4.2
  static Future<InvoiceModel?> updateInvoice(
    InvoiceModel invoice, {
    InvoiceStatus? oldStatus,
  }) async {
    try {
      // Fetch current invoice to detect status changes
      final currentInvoice =
          oldStatus == null ? await getInvoiceById(invoice.id) : null;
      final effectiveOldStatus = oldStatus ?? currentInvoice?.status;

      final invoiceData = invoice.toJson();
      invoiceData.remove('created_at');
      invoiceData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('invoices').update(invoiceData).eq('id', invoice.id);

      // Update invoice items
      await _updateInvoiceItems(invoice.id, invoice.items);

      final updatedInvoice = await getInvoiceById(invoice.id);
      if (updatedInvoice == null) return null;

      // Sync related entities if status changed
      if (effectiveOldStatus != null && effectiveOldStatus != invoice.status) {
        try {
          // Import AccountingSyncService dynamically to avoid circular dependency
          final accountingSyncService = AccountingSyncService();
          await accountingSyncService.syncInvoiceStatusChange(
            invoice: updatedInvoice,
            oldStatus: effectiveOldStatus,
            newStatus: invoice.status,
          );
        } catch (syncError) {
          print('Warning: Failed to sync related entities: $syncError');
          // Continue even if sync fails - invoice is already updated
        }
      }

      return updatedInvoice;
    } catch (e) {
      print('Error updating invoice: $e');
      return null;
    }
  }

  /// Get invoice by ID with items
  static Future<InvoiceModel?> getInvoiceById(String invoiceId) async {
    try {
      final response =
          await _supabase
              .from('invoices')
              .select()
              .eq('id', invoiceId)
              .single();

      final invoice = InvoiceModel.fromJson(response);

      // Get invoice items
      final itemsResponse = await _supabase
          .from('invoice_items')
          .select()
          .eq('invoice_id', invoiceId)
          .order('created_at');

      final items =
          (itemsResponse as List)
              .map((json) => InvoiceItemModel.fromJson(json))
              .toList();

      return invoice.copyWith(items: items);
    } catch (e) {
      print('Error fetching invoice: $e');
      return null;
    }
  }

  /// Get invoice with complete payment history and statistics
  ///
  /// Fetches invoice by ID, includes all payment records, and calculates
  /// payment statistics such as total paid, outstanding amount, and payment count.
  ///
  /// Requirements: 6.4
  static Future<InvoiceWithPaymentHistory?> getInvoiceWithPaymentHistory(
    String invoiceId,
  ) async {
    try {
      // Fetch invoice with items
      final invoice = await getInvoiceById(invoiceId);
      if (invoice == null) return null;

      // Fetch payment history
      final payments = await PaymentService.getInvoicePayments(invoiceId);

      // Calculate payment statistics
      final totalPaid = payments
          .where((p) => p.status == PaymentStatus.completed)
          .fold<double>(0.0, (sum, payment) => sum + payment.amount);

      final outstandingAmount = (invoice.totalAmount - totalPaid).clamp(
        0.0,
        invoice.totalAmount,
      );

      final paymentCount =
          payments.where((p) => p.status == PaymentStatus.completed).length;

      final lastPaymentDate =
          payments.isNotEmpty ? payments.first.paymentDate : null;

      return InvoiceWithPaymentHistory(
        invoice: invoice,
        payments: payments,
        totalPaid: totalPaid,
        outstandingAmount: outstandingAmount,
        paymentCount: paymentCount,
        lastPaymentDate: lastPaymentDate,
      );
    } catch (e) {
      print('Error fetching invoice with payment history: $e');
      return null;
    }
  }

  /// Get invoices for a business
  static Future<List<InvoiceModel>> getInvoices({
    required String businessId,
    InvoiceStatus? status,
    InvoiceType? type,
    String? customerId,
    String? supplierId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('invoices')
          .select()
          .eq('business_id', businessId);

      if (status != null) {
        query = query.eq('status', status.name);
      }
      if (type != null) {
        query = query.eq('invoice_type', type.name);
      }
      if (customerId != null) {
        query = query.eq('customer_id', customerId);
      }
      if (supplierId != null) {
        query = query.eq('supplier_id', supplierId);
      }
      if (fromDate != null) {
        query = query.gte(
          'invoice_date',
          fromDate.toIso8601String().split('T')[0],
        );
      }
      if (toDate != null) {
        query = query.lte(
          'invoice_date',
          toDate.toIso8601String().split('T')[0],
        );
      }

      final response = await query
          .order('invoice_date', ascending: false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => InvoiceModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching invoices: $e');
      return [];
    }
  }

  /// Delete an invoice
  static Future<bool> deleteInvoice(String invoiceId) async {
    try {
      // Delete invoice items first (cascade should handle this, but being explicit)
      await _supabase
          .from('invoice_items')
          .delete()
          .eq('invoice_id', invoiceId);

      // Delete invoice
      await _supabase.from('invoices').delete().eq('id', invoiceId);

      return true;
    } catch (e) {
      print('Error deleting invoice: $e');
      return false;
    }
  }

  // ============ INVOICE ITEMS MANAGEMENT ============

  /// Create invoice items
  static Future<void> _createInvoiceItems(
    String invoiceId,
    List<InvoiceItemModel> items,
  ) async {
    try {
      final itemsData =
          items.map((item) {
            final data = item.toJson();
            data.remove('id'); // Let database generate ID
            data['invoice_id'] = invoiceId;
            data['created_at'] = DateTime.now().toIso8601String();
            data['updated_at'] = DateTime.now().toIso8601String();
            return data;
          }).toList();

      if (itemsData.isNotEmpty) {
        await _supabase.from('invoice_items').insert(itemsData);
      }
    } catch (e) {
      print('Error creating invoice items: $e');
    }
  }

  /// Update invoice items
  static Future<void> _updateInvoiceItems(
    String invoiceId,
    List<InvoiceItemModel> items,
  ) async {
    try {
      // Delete existing items
      await _supabase
          .from('invoice_items')
          .delete()
          .eq('invoice_id', invoiceId);

      // Create new items
      await _createInvoiceItems(invoiceId, items);
    } catch (e) {
      print('Error updating invoice items: $e');
    }
  }

  // ============ INVOICE NUMBER GENERATION ============

  /// Generate next invoice number for a business
  static Future<String> generateInvoiceNumber(
    String businessId, {
    String prefix = 'INV',
  }) async {
    try {
      // Try database function first
      final response = await _supabase.rpc(
        'generate_invoice_number',
        params: {'business_uuid': businessId, 'invoice_prefix': prefix},
      );

      return response as String;
    } catch (e) {
      print('Error generating invoice number via RPC: $e');
      print('Falling back to client-side generation...');

      // Fallback to client-side generation
      try {
        // Get all invoices for this business
        final invoices = await getInvoices(businessId: businessId);

        if (invoices.isEmpty) {
          return '$prefix-0001';
        }

        // Extract numbers and find max
        int maxNum = 0;
        final regex = RegExp(r'$prefix-(\d+)');

        for (var invoice in invoices) {
          final match = regex.firstMatch(invoice.invoiceNumber);
          if (match != null) {
            final num = int.tryParse(match.group(1) ?? '0') ?? 0;
            if (num > maxNum) maxNum = num;
          }
        }

        // Generate next number
        final nextNum = maxNum + 1;
        return '$prefix-${nextNum.toString().padLeft(4, '0')}';
      } catch (fallbackError) {
        print('Error in fallback generation: $fallbackError');
        // Last resort: timestamp-based
        final now = DateTime.now();
        final year = now.year.toString().substring(2);
        final month = now.month.toString().padLeft(2, '0');
        final day = now.day.toString().padLeft(2, '0');
        final timestamp = now.millisecondsSinceEpoch.toString().substring(8);
        return '$prefix-$year$month$day$timestamp';
      }
    }
  }

  // ============ INVOICE ANALYTICS ============

  /// Get invoice statistics for a business
  static Future<Map<String, dynamic>> getInvoiceStats(
    String businessId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _supabase
          .from('invoices')
          .select('status, total_amount, paid_amount, invoice_type')
          .eq('business_id', businessId);

      if (fromDate != null) {
        query = query.gte(
          'invoice_date',
          fromDate.toIso8601String().split('T')[0],
        );
      }
      if (toDate != null) {
        query = query.lte(
          'invoice_date',
          toDate.toIso8601String().split('T')[0],
        );
      }

      final response = await query;
      final invoices = response as List<dynamic>;

      double totalAmount = 0;
      double paidAmount = 0;
      double outstandingAmount = 0;
      int totalCount = 0;
      int paidCount = 0;
      int overdueCount = 0;
      int draftCount = 0;

      for (final invoice in invoices) {
        final total = (invoice['total_amount'] as num?)?.toDouble() ?? 0;
        final paid = (invoice['paid_amount'] as num?)?.toDouble() ?? 0;
        final status = invoice['status'] as String?;

        totalAmount += total;
        paidAmount += paid;
        outstandingAmount += (total - paid);
        totalCount++;

        switch (status) {
          case 'paid':
            paidCount++;
            break;
          case 'overdue':
            overdueCount++;
            break;
          case 'draft':
            draftCount++;
            break;
        }
      }

      return {
        'total_amount': totalAmount,
        'paid_amount': paidAmount,
        'outstanding_amount': outstandingAmount,
        'total_count': totalCount,
        'paid_count': paidCount,
        'overdue_count': overdueCount,
        'draft_count': draftCount,
        'collection_rate':
            totalAmount > 0 ? (paidAmount / totalAmount) * 100 : 0,
      };
    } catch (e) {
      print('Error fetching invoice stats: $e');
      return {};
    }
  }

  /// Get overdue invoices
  static Future<List<InvoiceModel>> getOverdueInvoices(
    String businessId,
  ) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _supabase
          .from('invoices')
          .select()
          .eq('business_id', businessId)
          .lt('due_date', today)
          .neq('status', 'paid')
          .neq('status', 'cancelled')
          .order('due_date');

      return (response as List)
          .map((json) => InvoiceModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching overdue invoices: $e');
      return [];
    }
  }

  /// Get upcoming due invoices (due in next 7 days)
  static Future<List<InvoiceModel>> getUpcomingDueInvoices(
    String businessId,
  ) async {
    try {
      final today = DateTime.now();
      final nextWeek = today.add(const Duration(days: 7));

      final response = await _supabase
          .from('invoices')
          .select()
          .eq('business_id', businessId)
          .gte('due_date', today.toIso8601String().split('T')[0])
          .lte('due_date', nextWeek.toIso8601String().split('T')[0])
          .neq('status', 'paid')
          .neq('status', 'cancelled')
          .order('due_date');

      return (response as List)
          .map((json) => InvoiceModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching upcoming due invoices: $e');
      return [];
    }
  }

  // ============ PAYMENT MANAGEMENT ============

  /// Record payment for an invoice
  static Future<bool> recordPayment({
    required String invoiceId,
    required double amount,
    required String paymentMethod,
    String? notes,
    DateTime? paymentDate,
  }) async {
    try {
      final invoice = await getInvoiceById(invoiceId);
      if (invoice == null) return false;

      final newPaidAmount = invoice.paidAmount + amount;
      final newStatus =
          newPaidAmount >= invoice.totalAmount
              ? InvoiceStatus.paid
              : invoice.status;

      await _supabase
          .from('invoices')
          .update({
            'paid_amount': newPaidAmount,
            'status': newStatus.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', invoiceId);

      // Create transaction record
      await _supabase.from('transactions').insert({
        'business_id': invoice.businessId,
        'customer_id': invoice.customerId,
        'supplier_id': invoice.supplierId,
        'type':
            invoice.invoiceType == InvoiceType.customer ? 'income' : 'expense',
        'amount': amount,
        'description': 'Payment for Invoice #${invoice.invoiceNumber}',
        'payment_mode': paymentMethod.toLowerCase(),
        'date': (paymentDate ?? DateTime.now()).toIso8601String(),
        'reference': invoice.invoiceNumber,
        'notes': notes,
      });

      return true;
    } catch (e) {
      print('Error recording payment: $e');
      return false;
    }
  }

  // ============ INVOICE TEMPLATES ============

  /// Get invoice templates for a business
  static Future<List<Map<String, dynamic>>> getInvoiceTemplates(
    String businessId,
  ) async {
    try {
      final response = await _supabase
          .from('invoice_templates')
          .select()
          .eq('business_id', businessId)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching invoice templates: $e');
      return [];
    }
  }

  /// Create invoice from template
  static Future<InvoiceModel?> createInvoiceFromTemplate({
    required String businessId,
    required String templateId,
    String? customerId,
    String? supplierId,
    InvoiceType type = InvoiceType.customer,
  }) async {
    try {
      final invoiceNumber = await generateInvoiceNumber(businessId);

      final invoice = InvoiceModel(
        id: _uuid.v4(),
        businessId: businessId,
        customerId: customerId,
        supplierId: supplierId,
        invoiceNumber: invoiceNumber,
        invoiceType: type,
        invoiceDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        templateId: templateId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await createInvoice(invoice);
    } catch (e) {
      print('Error creating invoice from template: $e');
      return null;
    }
  }
}

/// Data class containing invoice with complete payment history and statistics
class InvoiceWithPaymentHistory {
  final InvoiceModel invoice;
  final List<PaymentModel> payments;
  final double totalPaid;
  final double outstandingAmount;
  final int paymentCount;
  final DateTime? lastPaymentDate;

  InvoiceWithPaymentHistory({
    required this.invoice,
    required this.payments,
    required this.totalPaid,
    required this.outstandingAmount,
    required this.paymentCount,
    this.lastPaymentDate,
  });

  /// Check if invoice is fully paid
  bool get isFullyPaid =>
      outstandingAmount <= 0.01; // Allow small rounding difference

  /// Check if invoice has any payments
  bool get hasPayments => payments.isNotEmpty;

  /// Get payment completion percentage
  double get paymentPercentage {
    if (invoice.totalAmount <= 0) return 0.0;
    return (totalPaid / invoice.totalAmount * 100).clamp(0.0, 100.0);
  }
}
