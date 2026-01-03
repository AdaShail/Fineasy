import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/business_model.dart';
import '../models/transaction_model.dart';
import '../models/customer_model.dart';
import '../models/supplier_model.dart';
import '../models/invoice_model.dart';
import '../utils/constants.dart';

class PdfService {
  static Future<Uint8List> generateTransactionReport({
    required BusinessModel business,
    required List<TransactionModel> transactions,
    required DateTime startDate,
    required DateTime endDate,
    String? title,
  }) async {
    final pdf = pw.Document();

    // Calculate totals
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final netAmount = totalIncome - totalExpense;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header:
            (context) => _buildHeader(business, title ?? 'Transaction Report'),
        footer: (context) => _buildFooter(context),
        build:
            (context) => [
              // Report Period
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Report Period: ${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Summary Section
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildSummaryCard(
                      'Total Income',
                      totalIncome,
                      PdfColors.green,
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: _buildSummaryCard(
                      'Total Expense',
                      totalExpense,
                      PdfColors.red,
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: _buildSummaryCard(
                      'Net Amount',
                      netAmount,
                      netAmount >= 0 ? PdfColors.green : PdfColors.red,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // Transactions Table
              pw.Text(
                'Transaction Details',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              if (transactions.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Center(
                    child: pw.Text(
                      'No transactions found for the selected period',
                    ),
                  ),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.5),
                    4: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        _buildTableCell('Date', isHeader: true),
                        _buildTableCell('Description', isHeader: true),
                        _buildTableCell('Type', isHeader: true),
                        _buildTableCell('Payment Mode', isHeader: true),
                        _buildTableCell('Amount', isHeader: true),
                      ],
                    ),
                    // Data rows
                    ...transactions.map(
                      (transaction) => pw.TableRow(
                        children: [
                          _buildTableCell(
                            DateFormat('dd/MM/yyyy').format(transaction.date),
                          ),
                          _buildTableCell(transaction.description),
                          _buildTableCell(
                            transaction.type == TransactionType.income
                                ? 'Income'
                                : 'Expense',
                          ),
                          _buildTableCell(
                            transaction.paymentMode
                                .toString()
                                .split('.')
                                .last
                                .toUpperCase(),
                          ),
                          _buildTableCell(
                            '${transaction.type == TransactionType.income ? '+' : '-'}${business.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateCustomerReport({
    required BusinessModel business,
    required List<CustomerModel> customers,
    String? title,
  }) async {
    final pdf = pw.Document();

    final totalReceivables = customers.fold(0.0, (sum, c) => sum + c.balance);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(business, title ?? 'Customer Report'),
        footer: (context) => _buildFooter(context),
        build:
            (context) => [
              // Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Total Customers: ${customers.length}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Total Receivables: ${business.currencySymbol}${totalReceivables.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.Text(
                      'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Customers Table
              if (customers.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Center(child: pw.Text('No customers found')),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        _buildTableCell('Customer Name', isHeader: true),
                        _buildTableCell('Phone', isHeader: true),
                        _buildTableCell('Balance', isHeader: true),
                        _buildTableCell('Last Transaction', isHeader: true),
                      ],
                    ),
                    // Data rows
                    ...customers.map(
                      (customer) => pw.TableRow(
                        children: [
                          _buildTableCell(customer.name),
                          _buildTableCell(customer.phone ?? '-'),
                          _buildTableCell(
                            '${business.currencySymbol}${customer.balance.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                          ),
                          _buildTableCell(
                            customer.lastTransactionDate != null
                                ? DateFormat(
                                  'dd/MM/yyyy',
                                ).format(customer.lastTransactionDate!)
                                : '-',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateSupplierReport({
    required BusinessModel business,
    required List<SupplierModel> suppliers,
    String? title,
  }) async {
    final pdf = pw.Document();

    final totalPayables = suppliers.fold(0.0, (sum, s) => sum + s.balance);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(business, title ?? 'Supplier Report'),
        footer: (context) => _buildFooter(context),
        build:
            (context) => [
              // Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Total Suppliers: ${suppliers.length}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Total Payables: ${business.currencySymbol}${totalPayables.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.Text(
                      'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Suppliers Table
              if (suppliers.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Center(child: pw.Text('No suppliers found')),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        _buildTableCell('Supplier Name', isHeader: true),
                        _buildTableCell('Phone', isHeader: true),
                        _buildTableCell('Balance', isHeader: true),
                        _buildTableCell('Last Transaction', isHeader: true),
                      ],
                    ),
                    // Data rows
                    ...suppliers.map(
                      (supplier) => pw.TableRow(
                        children: [
                          _buildTableCell(supplier.name),
                          _buildTableCell(supplier.phone ?? '-'),
                          _buildTableCell(
                            '${business.currencySymbol}${supplier.balance.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                          ),
                          _buildTableCell(
                            supplier.lastTransactionDate != null
                                ? DateFormat(
                                  'dd/MM/yyyy',
                                ).format(supplier.lastTransactionDate!)
                                : '-',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
      ),
    );

    return pdf.save();
  }

  // ============================================================================
  // INVOICE PDF GENERATION METHODS
  // ============================================================================

  /// Generate a professional invoice PDF with all details
  /// Requirements: 3.1, 3.2
  static Future<Uint8List> generateInvoicePdf({
    required InvoiceModel invoice,
    required BusinessModel business,
    CustomerModel? customer,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build:
              (context) => [
                // Business Header
                _buildInvoiceHeader(business),
                pw.SizedBox(height: 30),

                // Invoice Title and Number
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          invoice.invoiceNumber,
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildInfoRow(
                          'Invoice Date:',
                          DateFormat('dd/MM/yyyy').format(invoice.invoiceDate),
                        ),
                        if (invoice.dueDate != null)
                          _buildInfoRow(
                            'Due Date:',
                            DateFormat('dd/MM/yyyy').format(invoice.dueDate!),
                          ),
                        _buildInfoRow(
                          'Status:',
                          _getStatusText(invoice.status),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 30),

                // Customer Information Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Bill To:',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        customer?.name ?? 'Customer',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (customer?.phone != null) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Phone: ${customer!.phone}',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                      if (customer?.email != null) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Email: ${customer!.email}',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                      if (customer?.address != null) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          customer!.address!,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                      if (customer?.gstNumber != null) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'GST: ${customer!.gstNumber}',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // Invoice Items Table
                pw.Text(
                  'Items',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),

                _buildInvoiceItemsTable(invoice, business),

                pw.SizedBox(height: 20),

                // Totals Section
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left side - Notes
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (invoice.notes != null &&
                              invoice.notes!.isNotEmpty) ...[
                            pw.Text(
                              'Notes:',
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              invoice.notes!,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    // Right side - Totals
                    pw.Expanded(
                      flex: 2,
                      child: _buildTotalsSection(invoice, business),
                    ),
                  ],
                ),

                pw.SizedBox(height: 30),

                // Payment Terms and Conditions
                if (invoice.termsConditions != null &&
                    invoice.termsConditions!.isNotEmpty) ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Terms & Conditions:',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          invoice.termsConditions!,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ],

                pw.SizedBox(height: 20),

                // Footer
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'Thank you for your business!',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    'Generated by Fineasy on ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ],
        ),
      );

      return await pdf.save();
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Generate invoice PDF with UPI payment QR code
  /// Requirements: 3.2
  static Future<Uint8List> generateInvoiceWithPaymentQR({
    required InvoiceModel invoice,
    required BusinessModel business,
    CustomerModel? customer,
    String? upiId,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build:
              (context) => [
                // Business Header
                _buildInvoiceHeader(business),
                pw.SizedBox(height: 30),

                // Invoice Title and Number
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          invoice.invoiceNumber,
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildInfoRow(
                          'Invoice Date:',
                          DateFormat('dd/MM/yyyy').format(invoice.invoiceDate),
                        ),
                        if (invoice.dueDate != null)
                          _buildInfoRow(
                            'Due Date:',
                            DateFormat('dd/MM/yyyy').format(invoice.dueDate!),
                          ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 30),

                // Customer Information
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Bill To:',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        customer?.name ?? 'Customer',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (customer?.phone != null) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Phone: ${customer!.phone}',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // Invoice Items Table
                _buildInvoiceItemsTable(invoice, business),

                pw.SizedBox(height: 20),

                // Totals and QR Code Section
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left side - Payment QR Code
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(16),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.blue300,
                            width: 2,
                          ),
                          borderRadius: pw.BorderRadius.circular(8),
                          color: PdfColors.blue50,
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'Scan to Pay',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue800,
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            // Placeholder for QR code
                            // Note: Actual QR code generation requires qr_flutter package
                            pw.Container(
                              width: 120,
                              height: 120,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.grey400),
                                color: PdfColors.white,
                              ),
                              child: pw.Center(
                                child: pw.Text(
                                  'QR Code\nPlaceholder',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey600,
                                  ),
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            if (upiId != null)
                              pw.Text(
                                'UPI ID: $upiId',
                                style: const pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Amount: ${business.currencySymbol}${invoice.outstandingAmount.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    // Right side - Totals
                    pw.Expanded(
                      flex: 2,
                      child: _buildTotalsSection(invoice, business),
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Payment Instructions
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber50,
                    border: pw.Border.all(color: PdfColors.amber300),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Payment Instructions:',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '• Scan the QR code with any UPI app (Google Pay, PhonePe, Paytm, etc.)',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        '• Verify the amount and merchant details',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        '• Complete the payment',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        '• Share payment confirmation with us',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Terms and Conditions
                if (invoice.termsConditions != null &&
                    invoice.termsConditions!.isNotEmpty) ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Terms & Conditions:',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          invoice.termsConditions!,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ],

                pw.SizedBox(height: 20),

                // Footer
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'Thank you for your business!',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
              ],
        ),
      );

      return await pdf.save();
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Save invoice PDF to Android-specific directory
  /// Requirements: 3.3, 3.4
  static Future<File> saveInvoicePdfAndroid(
    Uint8List pdfData,
    String invoiceNumber,
  ) async {
    try {
      // Get app-specific directory (doesn't require storage permissions)
      final directory = await getApplicationDocumentsDirectory();

      // Create invoices subdirectory if it doesn't exist
      final invoicesDir = Directory('${directory.path}/invoices');
      if (!await invoicesDir.exists()) {
        await invoicesDir.create(recursive: true);
      }

      // Create file with sanitized invoice number
      final sanitizedNumber = invoiceNumber.replaceAll(RegExp(r'[^\w\-]'), '_');
      final fileName =
          'invoice_${sanitizedNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${invoicesDir.path}/$fileName');

      // Write PDF data
      await file.writeAsBytes(pdfData);

      return file;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Share invoice PDF using Android share intent
  /// Requirements: 3.5
  static Future<void> shareInvoicePdfAndroid(
    File pdfFile,
    String invoiceNumber,
  ) async {
    try {
      // Use share_plus package for cross-platform sharing
      final result = await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject: 'Invoice $invoiceNumber',
        text: 'Please find attached invoice $invoiceNumber',
      );

      if (result.status == ShareResultStatus.success) {
      } else if (result.status == ShareResultStatus.dismissed) {
      } else {
      }
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  // ============================================================================
  // ERROR HANDLING AND RETRY MECHANISM
  // ============================================================================

  /// Generate invoice PDF with comprehensive error handling and retry
  /// Requirements: 3.3
  static Future<PdfGenerationResult> generateInvoicePdfWithErrorHandling({
    required InvoiceModel invoice,
    required BusinessModel business,
    CustomerModel? customer,
    bool includeQR = false,
    String? upiId,
    int maxRetries = 2,
  }) async {
    int attempt = 0;
    Object? lastError;
    String? errorDetails;

    while (attempt < maxRetries) {
      attempt++;

      try {
        // Generate PDF based on type
        final Uint8List pdfData;
        if (includeQR) {
          pdfData = await generateInvoiceWithPaymentQR(
            invoice: invoice,
            business: business,
            customer: customer,
            upiId: upiId,
          );
        } else {
          pdfData = await generateInvoicePdf(
            invoice: invoice,
            business: business,
            customer: customer,
          );
        }


        return PdfGenerationResult(
          success: true,
          pdfData: pdfData,
          message: 'Invoice PDF generated successfully',
        );
      } on OutOfMemoryError catch (e, stackTrace) {
        lastError = e;
        errorDetails = 'Out of memory while generating PDF';

        // Don't retry on memory errors
        break;
      } on FileSystemException catch (e, stackTrace) {
        lastError = e;
        errorDetails = 'File system error: ${e.message}';

        // Wait before retry
        if (attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      } catch (e, stackTrace) {
        lastError = e;
        errorDetails = 'Unexpected error: ${e.toString()}';

        // Wait before retry
        if (attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
    }

    // All retries failed
    final errorMessage = _getUserFriendlyErrorMessage(lastError, errorDetails);

    return PdfGenerationResult(
      success: false,
      message: errorMessage,
      errorDetails: errorDetails,
      error: lastError,
    );
  }

  /// Save and share invoice PDF with error handling
  /// Requirements: 3.3, 3.4, 3.5
  static Future<PdfShareResult> saveAndShareInvoicePdf({
    required InvoiceModel invoice,
    required BusinessModel business,
    CustomerModel? customer,
    bool includeQR = false,
    String? upiId,
  }) async {
    try {
      // Generate PDF with error handling
      final generationResult = await generateInvoicePdfWithErrorHandling(
        invoice: invoice,
        business: business,
        customer: customer,
        includeQR: includeQR,
        upiId: upiId,
      );

      if (!generationResult.success || generationResult.pdfData == null) {
        return PdfShareResult(
          success: false,
          message: generationResult.message,
          errorDetails: generationResult.errorDetails,
        );
      }

      // Save PDF
      File? savedFile;
      try {
        savedFile = await saveInvoicePdfAndroid(
          generationResult.pdfData!,
          invoice.invoiceNumber,
        );
      } catch (e, stackTrace) {
        return PdfShareResult(
          success: false,
          message: 'Failed to save PDF file',
          errorDetails: 'Error: ${e.toString()}',
        );
      }

      // Share PDF
      try {
        await shareInvoicePdfAndroid(savedFile, invoice.invoiceNumber);

        return PdfShareResult(
          success: true,
          message: 'Invoice PDF shared successfully',
          filePath: savedFile.path,
        );
      } catch (e, stackTrace) {

        // PDF is saved even if sharing failed
        return PdfShareResult(
          success: true,
          message:
              'PDF saved but sharing failed. File saved at: ${savedFile.path}',
          filePath: savedFile.path,
          errorDetails: 'Share error: ${e.toString()}',
        );
      }
    } catch (e, stackTrace) {

      return PdfShareResult(
        success: false,
        message: 'An unexpected error occurred',
        errorDetails: e.toString(),
      );
    }
  }

  /// Get user-friendly error message based on exception type
  static String _getUserFriendlyErrorMessage(Object? error, String? details) {
    if (error == null) {
      return 'Failed to generate PDF. Please try again.';
    }

    if (error is OutOfMemoryError) {
      return 'Not enough memory to generate PDF. Please close some apps and try again.';
    }

    if (error is FileSystemException) {
      return 'Unable to save PDF file. Please check storage permissions and available space.';
    }

    if (details != null && details.contains('permission')) {
      return 'Storage permission required. Please grant permission in app settings.';
    }

    if (details != null && details.contains('space')) {
      return 'Not enough storage space. Please free up some space and try again.';
    }

    return 'Failed to generate PDF. Please try again or contact support if the issue persists.';
  }

  // ============================================================================
  // INVOICE PDF HELPER METHODS
  // ============================================================================

  static pw.Widget _buildInvoiceHeader(BusinessModel business) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue800, width: 3),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                business.name,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 4),
              if (business.address != null)
                pw.Text(
                  business.address!,
                  style: const pw.TextStyle(fontSize: 11),
                ),
              if (business.city != null && business.state != null)
                pw.Text(
                  '${business.city}, ${business.state} - ${business.pincode ?? ''}',
                  style: const pw.TextStyle(fontSize: 11),
                ),
              if (business.gstNumber != null)
                pw.Text(
                  'GST: ${business.gstNumber}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(width: 8),
          pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceItemsTable(
    InvoiceModel invoice,
    BusinessModel business,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue800),
          children: [
            _buildInvoiceTableCell('Item', isHeader: true, isWhite: true),
            _buildInvoiceTableCell('Qty', isHeader: true, isWhite: true),
            _buildInvoiceTableCell('Unit Price', isHeader: true, isWhite: true),
            _buildInvoiceTableCell('Tax %', isHeader: true, isWhite: true),
            _buildInvoiceTableCell(
              'Amount',
              isHeader: true,
              isWhite: true,
              textAlign: pw.TextAlign.right,
            ),
          ],
        ),
        // Items
        ...invoice.items.map(
          (item) => pw.TableRow(
            children: [
              _buildInvoiceTableCell(
                item.description != null && item.description!.isNotEmpty
                    ? '${item.name}\n${item.description}'
                    : item.name,
              ),
              _buildInvoiceTableCell(
                item.quantity.toStringAsFixed(2),
                textAlign: pw.TextAlign.center,
              ),
              _buildInvoiceTableCell(
                '${business.currencySymbol}${item.unitPrice.toStringAsFixed(2)}',
                textAlign: pw.TextAlign.right,
              ),
              _buildInvoiceTableCell(
                '${item.taxRate.toStringAsFixed(1)}%',
                textAlign: pw.TextAlign.center,
              ),
              _buildInvoiceTableCell(
                '${business.currencySymbol}${item.totalAmount.toStringAsFixed(2)}',
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceTableCell(
    String text, {
    bool isHeader = false,
    bool isWhite = false,
    pw.TextAlign textAlign = pw.TextAlign.left,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isWhite ? PdfColors.white : PdfColors.black,
        ),
        textAlign: textAlign,
      ),
    );
  }

  static pw.Widget _buildTotalsSection(
    InvoiceModel invoice,
    BusinessModel business,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          _buildTotalRow(
            'Subtotal:',
            '${business.currencySymbol}${invoice.subtotal.toStringAsFixed(2)}',
          ),
          if (invoice.discountAmount > 0) ...[
            pw.SizedBox(height: 8),
            _buildTotalRow(
              'Discount:',
              '-${business.currencySymbol}${invoice.discountAmount.toStringAsFixed(2)}',
              color: PdfColors.red,
            ),
          ],
          if (invoice.taxAmount > 0) ...[
            pw.SizedBox(height: 8),
            _buildTotalRow(
              'Tax:',
              '${business.currencySymbol}${invoice.taxAmount.toStringAsFixed(2)}',
            ),
          ],
          pw.SizedBox(height: 12),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 8),
          _buildTotalRow(
            'Total:',
            '${business.currencySymbol}${invoice.totalAmount.toStringAsFixed(2)}',
            isBold: true,
            fontSize: 14,
          ),
          if (invoice.paidAmount > 0) ...[
            pw.SizedBox(height: 8),
            _buildTotalRow(
              'Paid:',
              '-${business.currencySymbol}${invoice.paidAmount.toStringAsFixed(2)}',
              color: PdfColors.green,
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 8),
            _buildTotalRow(
              'Balance Due:',
              '${business.currencySymbol}${invoice.outstandingAmount.toStringAsFixed(2)}',
              isBold: true,
              fontSize: 14,
              color: PdfColors.red700,
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 11,
    PdfColor? color,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  static String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  // ============================================================================
  // EXISTING REPORT GENERATION METHODS
  // ============================================================================

  static pw.Widget _buildHeader(BusinessModel business, String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                business.name,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (business.address != null)
                pw.Text(
                  business.address!,
                  style: const pw.TextStyle(fontSize: 12),
                ),
              if (business.gstNumber != null)
                pw.Text(
                  'GST: ${business.gstNumber}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Fineasy Business Management',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by Fineasy',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryCard(
    String title,
    double amount,
    PdfColor color,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${AppConstants.defaultCurrency}${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign textAlign = pw.TextAlign.left,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: textAlign,
      ),
    );
  }

  static Future<void> printPdf(Uint8List pdfData, String fileName) async {
    // Save PDF and open with system default app for printing
    final file = await savePdf(pdfData, fileName);
    final uri = Uri.file(file.path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static Future<File> savePdf(Uint8List pdfData, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfData);
    return file;
  }

  static Future<void> sharePdf(Uint8List pdfData, String fileName) async {
    try {
      // Save PDF first
      final file = await savePdf(pdfData, fileName);

      // For Android, use share_plus package or file provider
      // For now, just open the file location
      final uri = Uri.file(file.path);

      // Try to launch with mode that works on Android
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: just save the file
        throw Exception('PDF saved to: ${file.path}');
      }
    } catch (e) {
      // If sharing fails, at least the file is saved
      rethrow;
    }
  }
}

// ============================================================================
// RESULT CLASSES FOR ERROR HANDLING
// ============================================================================

/// Result class for PDF generation operations
class PdfGenerationResult {
  final bool success;
  final Uint8List? pdfData;
  final String message;
  final String? errorDetails;
  final Object? error;

  PdfGenerationResult({
    required this.success,
    this.pdfData,
    required this.message,
    this.errorDetails,
    this.error,
  });
}

/// Result class for PDF save and share operations
class PdfShareResult {
  final bool success;
  final String message;
  final String? filePath;
  final String? errorDetails;

  PdfShareResult({
    required this.success,
    required this.message,
    this.filePath,
    this.errorDetails,
  });
}
