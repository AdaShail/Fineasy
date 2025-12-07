import 'package:flutter/material.dart';
import '../../models/invoice_model.dart';
import '../../services/payment_service.dart';
import '../../services/invoice_service.dart';
import 'payment_recording_dialog.dart';

/// A reusable button widget for recording payments
///
/// This widget can be used anywhere in the app to quickly
/// open the payment recording dialog for an invoice.
///
/// Example usage:
/// ```dart
/// PaymentRecordingButton(
///   invoice: invoice,
///   onPaymentRecorded: (result) {
///     // Handle payment recorded
///     print('Payment recorded: ${result.message}');
///   },
/// )
/// ```
class PaymentRecordingButton extends StatelessWidget {
  final InvoiceModel invoice;
  final Function(PaymentResult)? onPaymentRecorded;
  final bool isIconButton;
  final String? label;

  const PaymentRecordingButton({
    Key? key,
    required this.invoice,
    this.onPaymentRecorded,
    this.isIconButton = false,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Don't show button for paid or cancelled invoices
    if (invoice.status == InvoiceStatus.paid ||
        invoice.status == InvoiceStatus.cancelled) {
      return const SizedBox.shrink();
    }

    if (isIconButton) {
      return IconButton(
        icon: const Icon(Icons.payment),
        tooltip: 'Record Payment',
        onPressed: () => _showPaymentDialog(context),
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _showPaymentDialog(context),
      icon: const Icon(Icons.payment),
      label: Text(label ?? 'Record Payment'),
    );
  }

  Future<void> _showPaymentDialog(BuildContext context) async {
    // Get customer invoices for multi-invoice payment option
    List<InvoiceModel>? customerInvoices;
    if (invoice.customerId != null) {
      try {
        customerInvoices = await InvoiceService.getInvoices(
          businessId: invoice.businessId,
          customerId: invoice.customerId,
        );
        // Filter to only unpaid and partially paid invoices
        customerInvoices =
            customerInvoices
                .where(
                  (inv) =>
                      inv.outstandingAmount > 0 &&
                      inv.status != InvoiceStatus.cancelled,
                )
                .toList();
      } catch (e) {
        // If we can't load customer invoices, just proceed with single invoice
        customerInvoices = null;
      }
    }

    // Show payment recording dialog
    final result = await showDialog<PaymentResult>(
      context: context,
      builder:
          (context) => PaymentRecordingDialog(
            invoice: invoice,
            customerInvoices: customerInvoices,
            onPaymentRecorded: onPaymentRecorded,
          ),
    );

    // Callback with result if provided
    if (result != null && result.success && onPaymentRecorded != null) {
      onPaymentRecorded!(result);
    }
  }
}

/// A floating action button variant for payment recording
class PaymentRecordingFAB extends StatelessWidget {
  final InvoiceModel invoice;
  final Function(PaymentResult)? onPaymentRecorded;

  const PaymentRecordingFAB({
    Key? key,
    required this.invoice,
    this.onPaymentRecorded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Don't show FAB for paid or cancelled invoices
    if (invoice.status == InvoiceStatus.paid ||
        invoice.status == InvoiceStatus.cancelled) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: () => _showPaymentDialog(context),
      icon: const Icon(Icons.payment),
      label: const Text('Record Payment'),
    );
  }

  Future<void> _showPaymentDialog(BuildContext context) async {
    // Get customer invoices for multi-invoice payment option
    List<InvoiceModel>? customerInvoices;
    if (invoice.customerId != null) {
      try {
        customerInvoices = await InvoiceService.getInvoices(
          businessId: invoice.businessId,
          customerId: invoice.customerId,
        );
        // Filter to only unpaid and partially paid invoices
        customerInvoices =
            customerInvoices
                .where(
                  (inv) =>
                      inv.outstandingAmount > 0 &&
                      inv.status != InvoiceStatus.cancelled,
                )
                .toList();
      } catch (e) {
        // If we can't load customer invoices, just proceed with single invoice
        customerInvoices = null;
      }
    }

    // Show payment recording dialog
    final result = await showDialog<PaymentResult>(
      context: context,
      builder:
          (context) => PaymentRecordingDialog(
            invoice: invoice,
            customerInvoices: customerInvoices,
            onPaymentRecorded: onPaymentRecorded,
          ),
    );

    // Callback with result if provided
    if (result != null && result.success && onPaymentRecorded != null) {
      onPaymentRecorded!(result);
    }
  }
}
