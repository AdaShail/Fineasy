import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/payment_provider.dart';
import '../../providers/business_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import 'add_edit_payment_screen.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPayments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadPayments() {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business != null) {
      paymentProvider.loadPayments(businessId: businessProvider.business!.id);
    }
  }

  List<PaymentModel> _getFilteredPayments(
    List<PaymentModel> payments,
    PaymentStatus? status,
  ) {
    var filtered = payments;

    // Status filter
    if (status != null) {
      filtered = filtered.where((payment) => payment.status == status).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (payment) =>
                    (payment.reference?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false) ||
                    payment.amount.toString().contains(_searchQuery) ||
                    (payment.notes?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading && paymentProvider.payments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paymentProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading payments',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paymentProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPayments,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search payments...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Summary Cards
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total Payments',
                        amount: paymentProvider.totalPayments,
                        color: AppTheme.primaryColor,
                        icon: Icons.payments,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Pending Payments',
                        amount: paymentProvider.totalPendingPayments,
                        color: AppTheme.warningColor,
                        icon: Icons.pending,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Payment Lists
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPaymentList(
                      _getFilteredPayments(paymentProvider.payments, null),
                    ),
                    _buildPaymentList(
                      _getFilteredPayments(
                        paymentProvider.payments,
                        PaymentStatus.pending,
                      ),
                    ),
                    _buildPaymentList(
                      _getFilteredPayments(
                        paymentProvider.payments,
                        PaymentStatus.completed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPayment,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPaymentList(List<PaymentModel> payments) {
    if (payments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No payments found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Record your first payment to get started',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return PaymentListTile(
          payment: payment,
          onTap: () => _editPayment(payment),
          onDelete: () => _deletePayment(payment),
        );
      },
    );
  }

  void _addPayment() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddEditPaymentScreen()));
  }

  void _editPayment(PaymentModel payment) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditPaymentScreen(payment: payment)),
    );
  }

  void _deletePayment(PaymentModel payment) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Payment'),
            content: Text(
              'Are you sure you want to delete this payment of ${AppConstants.defaultCurrency}${payment.amount.toStringAsFixed(2)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final paymentProvider = Provider.of<PaymentProvider>(
                    context,
                    listen: false,
                  );
                  final success = await paymentProvider.deletePayment(
                    payment.id,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Payment deleted successfully'
                              : 'Failed to delete payment',
                        ),
                        backgroundColor:
                            success
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
              ),
            ],
          ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${AppConstants.defaultCurrency}${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentListTile extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PaymentListTile({
    super.key,
    required this.payment,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(payment.status),
          child: Icon(
            _getPaymentModeIcon(payment.paymentMode),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          payment.customerId != null ? 'From Customer' : 'To Supplier',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mode: ${_getPaymentModeDisplayName(payment.paymentMode)}'),
            Text(
              'Date: ${payment.paymentDate.day}/${payment.paymentDate.month}/${payment.paymentDate.year}',
            ),
            if (payment.reference != null) Text('Ref: ${payment.reference}'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(payment.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusDisplayName(payment.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${AppConstants.defaultCurrency}${payment.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color:
                    payment.customerId != null
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
              ),
            ),
            PopupMenuButton(
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppTheme.errorColor),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppTheme.errorColor),
                          ),
                        ],
                      ),
                    ),
                  ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onTap();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return AppTheme.warningColor;
      case PaymentStatus.completed:
        return AppTheme.successColor;
      case PaymentStatus.failed:
        return AppTheme.errorColor;
      case PaymentStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getPaymentModeIcon(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return Icons.money;
      case PaymentMode.card:
        return Icons.credit_card;
      case PaymentMode.upi:
        return Icons.qr_code;
      case PaymentMode.netBanking:
        return Icons.account_balance;
      case PaymentMode.cheque:
        return Icons.receipt;
      case PaymentMode.bankTransfer:
        return Icons.swap_horiz;
      case PaymentMode.other:
        return Icons.payment;
    }
  }

  String _getPaymentModeDisplayName(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.card:
        return 'Card';
      case PaymentMode.upi:
        return 'UPI';
      case PaymentMode.netBanking:
        return 'Net Banking';
      case PaymentMode.cheque:
        return 'Cheque';
      case PaymentMode.bankTransfer:
        return 'Bank Transfer';
      case PaymentMode.other:
        return 'Other';
    }
  }

  String _getStatusDisplayName(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }
}
