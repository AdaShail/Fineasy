import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class TransactionSummaryWidget extends StatelessWidget {
  const TransactionSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final todayIncome = transactionProvider.getTodayIncome();
        final todayExpenses = transactionProvider.getTodayExpenses();
        final monthlyIncome = transactionProvider.getMonthlyIncome();
        final monthlyExpenses = transactionProvider.getMonthlyExpenses();

        final todayNet = todayIncome - todayExpenses;
        final monthlyNet = monthlyIncome - monthlyExpenses;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                  Colors.white,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Financial Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),

                  // Today's Summary
                  _buildPeriodSummary(
                    'Today',
                    todayNet,
                    todayIncome,
                    todayExpenses,
                  ),

                  const SizedBox(height: 16),

                  // Monthly Summary
                  _buildPeriodSummary(
                    'This Month',
                    monthlyNet,
                    monthlyIncome,
                    monthlyExpenses,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodSummary(
    String period,
    double net,
    double income,
    double expenses,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${AppConstants.defaultCurrency}${_formatAmount(net.abs())}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: net >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                net >= 0 ? Icons.trending_up : Icons.trending_down,
                color: net >= 0 ? Colors.green : Colors.red,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetric('Income', income, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetric('Expenses', expenses, Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          '${AppConstants.defaultCurrency}${_formatAmount(amount)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}
