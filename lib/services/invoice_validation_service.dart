import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice_model.dart';
import '../models/transaction_model.dart';

/// Service for validating invoice operations and preventing data inconsistencies
class InvoiceValidationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Check if transaction already has an invoice
  /// Returns existing invoice if found, null otherwise
  static Future<InvoiceModel?> getExistingInvoiceForTransaction(
    String transactionId,
  ) async {
    try {
      final response = await _supabase
          .from('invoices')
          .select()
          .eq('transaction_id', transactionId)
          .maybeSingle();

      if (response == null) return null;

      return InvoiceModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Validate if invoice can be created for transaction
  /// Returns validation result with error message if invalid
  static Future<InvoiceValidationResult> validateInvoiceCreation({
    required TransactionModel transaction,
  }) async {
    // Check if transaction already has invoice
    if (transaction.invoiceId != null && transaction.invoiceId!.isNotEmpty) {
      return InvoiceValidationResult(
        isValid: false,
        errorMessage: 'Transaction already has an invoice',
        existingInvoiceId: transaction.invoiceId,
      );
    }

    // Check database for existing invoice
    final existingInvoice = await getExistingInvoiceForTransaction(
      transaction.id,
    );

    if (existingInvoice != null) {
      return InvoiceValidationResult(
        isValid: false,
        errorMessage: 'Invoice already exists for this transaction',
        existingInvoiceId: existingInvoice.id,
      );
    }

    // Validate transaction has customer or supplier
    if (transaction.customerId == null && transaction.supplierId == null) {
      return InvoiceValidationResult(
        isValid: false,
        errorMessage: 'Transaction must have a customer or supplier',
      );
    }

    // Validate transaction amount
    if (transaction.amount <= 0) {
      return InvoiceValidationResult(
        isValid: false,
        errorMessage: 'Transaction amount must be greater than zero',
      );
    }

    return InvoiceValidationResult(isValid: true);
  }

  /// Check if multiple invoices exist for same transaction (data integrity check)
  static Future<List<InvoiceModel>> findDuplicateInvoices(
    String transactionId,
  ) async {
    try {
      final response = await _supabase
          .from('invoices')
          .select()
          .eq('transaction_id', transactionId);

      return (response as List)
          .map((json) => InvoiceModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Clean up duplicate invoices (keep the first one, delete others)
  static Future<CleanupResult> cleanupDuplicateInvoices(
    String transactionId,
  ) async {
    try {
      final duplicates = await findDuplicateInvoices(transactionId);

      if (duplicates.length <= 1) {
        return CleanupResult(
          success: true,
          message: 'No duplicates found',
          deletedCount: 0,
        );
      }

      // Keep the first invoice (oldest), delete others
      final toKeep = duplicates.first;
      final toDelete = duplicates.skip(1).toList();

      int deletedCount = 0;
      for (final invoice in toDelete) {
        try {
          await _supabase.from('invoices').delete().eq('id', invoice.id);
          deletedCount++;
        } catch (e) {
          // Continue deleting others even if one fails
        }
      }

      return CleanupResult(
        success: true,
        message: 'Kept invoice ${toKeep.invoiceNumber}, deleted $deletedCount duplicates',
        deletedCount: deletedCount,
        keptInvoiceId: toKeep.id,
      );
    } catch (e) {
      return CleanupResult(
        success: false,
        message: 'Error cleaning up duplicates: $e',
        deletedCount: 0,
      );
    }
  }

  /// Scan all transactions and find those with multiple invoices
  static Future<List<String>> scanForDuplicateInvoices(
    String businessId,
  ) async {
    try {
      // Get all invoices with transaction IDs
      final response = await _supabase
          .from('invoices')
          .select('transaction_id')
          .eq('business_id', businessId)
          .not('transaction_id', 'is', null);

      final transactionIds = (response as List)
          .map((row) => row['transaction_id'] as String)
          .toList();

      // Find duplicates
      final Map<String, int> counts = {};
      for (final id in transactionIds) {
        counts[id] = (counts[id] ?? 0) + 1;
      }

      // Return transaction IDs with multiple invoices
      return counts.entries
          .where((entry) => entry.value > 1)
          .map((entry) => entry.key)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Validate invoice amount matches transaction amount
  static bool validateInvoiceTransactionAmountMatch({
    required InvoiceModel invoice,
    required TransactionModel transaction,
    double tolerance = 0.01, // Allow small rounding differences
  }) {
    final difference = (invoice.totalAmount - transaction.amount).abs();
    return difference <= tolerance;
  }

  /// Get invoice creation recommendations
  static Future<InvoiceCreationRecommendation> getInvoiceCreationRecommendation({
    required TransactionModel transaction,
  }) async {
    final validation = await validateInvoiceCreation(transaction: transaction);

    if (!validation.isValid) {
      return InvoiceCreationRecommendation(
        shouldCreate: false,
        reason: validation.errorMessage,
        existingInvoiceId: validation.existingInvoiceId,
      );
    }

    // Check if transaction type is suitable for invoice
    final suitableTypes = [
      TransactionType.income,
      TransactionType.sale,
      TransactionType.expense,
      TransactionType.purchase,
    ];

    if (!suitableTypes.contains(transaction.type)) {
      return InvoiceCreationRecommendation(
        shouldCreate: false,
        reason: 'Transaction type ${transaction.type.name} is not suitable for invoice creation',
      );
    }

    return InvoiceCreationRecommendation(
      shouldCreate: true,
      reason: 'Transaction is valid for invoice creation',
    );
  }
}

/// Result of invoice validation
class InvoiceValidationResult {
  final bool isValid;
  final String errorMessage;
  final String? existingInvoiceId;

  InvoiceValidationResult({
    required this.isValid,
    this.errorMessage = '',
    this.existingInvoiceId,
  });
}

/// Result of duplicate cleanup operation
class CleanupResult {
  final bool success;
  final String message;
  final int deletedCount;
  final String? keptInvoiceId;

  CleanupResult({
    required this.success,
    required this.message,
    required this.deletedCount,
    this.keptInvoiceId,
  });
}

/// Recommendation for invoice creation
class InvoiceCreationRecommendation {
  final bool shouldCreate;
  final String reason;
  final String? existingInvoiceId;

  InvoiceCreationRecommendation({
    required this.shouldCreate,
    required this.reason,
    this.existingInvoiceId,
  });
}
