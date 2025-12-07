import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';

class PendingActionsCard extends StatelessWidget {
  const PendingActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final pendingInvoices = _getPendingInvoicesCount();
        final pendingPayments = _getPendingPaymentsCount();
        final fraudAlerts = _getFraudAlertsCount();

        final totalPending = pendingInvoices + pendingPayments + fraudAlerts;

        if (totalPending == 0) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'All caught up!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No pending actions at the moment',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.pending_actions, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Pending Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalPending',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (pendingInvoices > 0)
                  _buildPendingItem(
                    context,
                    icon: Icons.receipt_long,
                    title: '$pendingInvoices Invoices due',
                    subtitle: 'Overdue invoices need attention',
                    color: Colors.red,
                    onTap: () => Navigator.pushNamed(context, '/invoices'),
                  ),

                if (pendingPayments > 0)
                  _buildPendingItem(
                    context,
                    icon: Icons.payment,
                    title: '$pendingPayments Payments pending',
                    subtitle: 'Outstanding payments to process',
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, '/payments'),
                  ),

                if (fraudAlerts > 0)
                  _buildPendingItem(
                    context,
                    icon: Icons.security,
                    title:
                        '$fraudAlerts Fraud alert${fraudAlerts > 1 ? 's' : ''}',
                    subtitle: 'Suspicious activities detected',
                    color: Colors.red,
                    onTap: () => Navigator.pushNamed(context, '/fraud-alerts'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  int _getPendingInvoicesCount() {
    // TODO: Implement actual pending invoices logic
    return 3; // Mock data
  }

  int _getPendingPaymentsCount() {
    // TODO: Implement actual pending payments logic
    return 2; // Mock data
  }

  int _getFraudAlertsCount() {
    // TODO: Implement actual fraud alerts logic
    return 1; // Mock data
  }
}
